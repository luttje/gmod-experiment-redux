local BUFF = BUFF

BUFF.name = "Blood Bond"
BUFF.foregroundImage = {
	spritesheet = "experiment-redux/flatmsicons32.png",
	x = 5,
	y = 16,
	size = 32,
}
BUFF.durationInSeconds = 30 * 60
BUFF.description = "You're bonded to '%s', meaning you can't hurt them. %s you're near them their generators output 10%% more."
BUFF.generatorEarningsMultiplier = 1.1
BUFF.nearbyDistance = 512

--- @param client Player
--- @param buff ActiveBuff
--- @return string
function BUFF:GetDescription(client, buff)
    local allyName = "someone"

    if (buff.data.allyName) then
        allyName = buff.data.allyName
    end

    local nearbyText = "If"
	local nearbyDistance = self.nearbyDistance * self.nearbyDistance

	if (IsValid(buff.data.ally) and client:GetPos():DistToSqr(buff.data.ally:GetPos()) <= nearbyDistance) then
		nearbyText = "Because"
	end

    return string.format(self.description, allyName, nearbyText)
end

local function canBloodBond(client, target)
    local existingBloodBond = client:GetNetVar("bloodBondAlly")

    if (IsValid(existingBloodBond)) then
        return false
    end

    existingBloodBond = target:GetNetVar("bloodBondAlly")

    if (IsValid(existingBloodBond)) then
        return false
    end

    return true
end

local function emitBloodBondEffect(client, ally)
	if (not Schema.util.Throttle("BloodBondSound", 0.5, client)) then
		client:EmitSound("plats/elevbell1.wav", 30, math.random(160, 225))
	end
end

function BUFF.hooks:GetPlayerEntityMenu(target, options)
    if (not target:Alive()) then
        return
    end

    local client = LocalPlayer()

    if (not canBloodBond(client, target)) then
        return
    end

    local existingRequest = target:GetNetVar("bloodBondRequest")

    if (IsValid(existingRequest)) then
        if (existingRequest == client) then
            options[L("bloodBondAccept")] = true
        end

        return
    end

    options[L("bloodBondRequest")] = true
end

function BUFF.hooks:CanPlayerMutilate(client, target, ragdoll)
	local targetBloodBondAlly = target:GetNetVar("bloodBondAlly")

	if (IsValid(targetBloodBondAlly) and targetBloodBondAlly == client) then
		client:NotifyLocalized("bloodBondCannotMutilate")
		emitBloodBondEffect(client, target)
		return false
	end
end

if (not SERVER) then
    return
end

function BUFF:OnExpire(client, buff)
    local ally = buff.data.ally

	if (IsValid(ally)) then
        Schema.buff.ExpireAllOfType(ally, self.index)
	end

    client:SetNetVar("bloodBondAlly", nil)
end

function BUFF.hooks:OnPlayerOptionSelected(target, client, option, data)
    if (option == L("bloodBondRequest", client)) then
        if (not canBloodBond(client, target)) then
            return
        end

        client:SetNetVar("bloodBondRequest", target)
        client:NotifyLocalized("bloodBondRequestSent", target:GetName())
        target:NotifyLocalized("bloodBondRequested", client:GetName())

        return
    end

    if (option == L("bloodBondAccept", client)) then
        if (not canBloodBond(client, target)) then
            return
        end

        local existingRequest = target:GetNetVar("bloodBondRequest")

        if (not IsValid(existingRequest) or existingRequest ~= client) then
            return
        end

        local targetAllyData = {
            ally = client,
            allyName = client:GetName(),
        }

        local clientAllyData = {
            ally = target,
            allyName = target:GetName(),
        }

        target:SetNetVar("bloodBondRequest", nil)

        -- Expire all other blood bonds so only one can be active at a time
        Schema.buff.ExpireAllOfType(target, self.index)
        Schema.buff.ExpireAllOfType(client, self.index)

        Schema.buff.SetActive(target, self.index, nil, targetAllyData)
        Schema.buff.SetActive(client, self.index, nil, clientAllyData)

        target:SetNetVar("bloodBondAlly", client)
        client:SetNetVar("bloodBondAlly", target)

        target:NotifyLocalized("bloodBondActivated", client:GetName())
        client:NotifyLocalized("bloodBondActivated", target:GetName())

        return
    end
end

function BUFF.hooks:GeneratorAdjustEarnings(generator, earningsData)
	local client = generator:GetItemOwner()

    if (not IsValid(client)) then
        return
    end

    local ally = client:GetNetVar("bloodBondAlly")
    local nearbyDistance = self.nearbyDistance * self.nearbyDistance

	if (IsValid(ally) and generator:GetPos():DistToSqr(ally:GetPos()) <= nearbyDistance) then
		earningsData.earnings = earningsData.earnings * self.generatorEarningsMultiplier
	end
end

function BUFF.hooks:EntityTakeDamage(entity, damageInfo)
    if (not entity:IsPlayer()) then
        return
    end

	local attacker = damageInfo:GetAttacker()

    if (not IsValid(attacker) or not attacker:IsPlayer()) then
        return
    end

	local attackerBloodBondAlly = attacker:GetNetVar("bloodBondAlly")

    if (IsValid(attackerBloodBondAlly) and attackerBloodBondAlly == entity) then
        damageInfo:ScaleDamage(0)

        emitBloodBondEffect(attacker, entity)

		return true
	end
end

function BUFF.hooks:CanPlayerTie(client, target)
    local targetBloodBondAlly = target:GetNetVar("bloodBondAlly")

    if (IsValid(targetBloodBondAlly) and targetBloodBondAlly == client) then
        client:NotifyLocalized("bloodBondCannotTie")
		emitBloodBondEffect(client, target)
        return false
    end
end

function BUFF.hooks:CanPlayerChloroform(client, target)
	local targetBloodBondAlly = target:GetNetVar("bloodBondAlly")

	if (IsValid(targetBloodBondAlly) and targetBloodBondAlly == client) then
		client:NotifyLocalized("bloodBondCannotChloroform")
		emitBloodBondEffect(client, target)
		return false
	end
end

function BUFF.hooks:CanPlayerUntie(client, target)
	local targetBloodBondAlly = target:GetNetVar("bloodBondAlly")

    if (IsValid(targetBloodBondAlly) and targetBloodBondAlly == client) then
        -- Return nil so we don't block any other plugins from running, but provide a speed factor of 0.5
		-- so allies can untie each other twice as fast
		return nil, 0.5
	end
end
