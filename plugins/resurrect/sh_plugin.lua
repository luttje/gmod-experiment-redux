local PLUGIN = PLUGIN

PLUGIN.name = "Resurrection"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Lets players resurrect other players."

ix.lang.AddTable("english", {
	resurrect = "Resurrect",
	resurrecting = "Resurrecting...",
	beingResurrected = "You are being resurrected...",
})

ix.config.Add("resurrectTimeInSeconds", 5, "The time in seconds that it takes to resurrect a player.", nil, {
	data = {min = 0, max = 60, decimals = 0},
})

if (CLIENT) then
	function PLUGIN:AdjustPlayerRagdollEntityMenu(options, target, corpse)
		local client = LocalPlayer()

		if (target:Alive()) then
			return
		end

		if (not Schema.perk.GetOwned("phoenix_tamer")) then
			return
		end

		if (not IsValid(target) or target:Alive()) then
			return
		end

		local canResurrect = hook.Run("CanPlayerResurrectTarget", client, target, corpse) ~= false

		if (not canResurrect) then
			return
		end

		options[L("resurrect")] = true
	end
end

if (not SERVER) then
    return
end

function PLUGIN:ShouldShowSpawnSelection(client)
	if (client.expIsResurrecting) then
		return false
	end
end

function PLUGIN:ResurrectPlayer(client, target, corpse, newHealth)
	if (corpse.expIsResurrecting) then
		return
	end

	-- Prevent double resurrection, which might lead to inventory duplication
    corpse.expIsResurrecting = true

	-- Make sure that whoever is inspecting the corpse inventory has their storage menu closed
	-- Furthermore return all remaining items and money to the resurrected player
    if (corpse.ixInventory) then
        ix.storage.Close(corpse.ixInventory)
        -- TODO: Shouldn't this happen automatically? Helix bug?
        corpse.ixInventory.receivers = {}

        local items = corpse.ixInventory:GetItems()
        local money = corpse:GetMoney()

        local character = target:GetCharacter()
        local targetInventory = character:GetInventory()
        character:GiveMoney(money)

        for _, item in ipairs(items) do
            item:Transfer(targetInventory:GetID(), item.gridX, item.gridY, nil, false, true)
        end

        corpse.ixInventory = nil
    end

	-- Prevent showing the spawn selection menu
	target.expIsResurrecting = true

	corpse:RemoveWithEffect()
	target:SetNetVar("deathTime", nil)
	target:Spawn()
	target:SetPos(corpse:GetPos())
    target:SetHealth(newHealth or target:GetMaxHealth())

	target.expIsResurrecting = false

	if (target:IsStuck()) then
		corpse:DropToFloor()
		target:SetPos(corpse:GetPos() + Vector(0, 0, 16))

		local positions = ix.util.FindEmptySpace(target, { corpse, target })

		for _, v in ipairs(positions) do
			target:SetPos(v)

			if (not target:IsStuck()) then
				return
			end
		end
	end

	Schema.achievement.Progress("paramedic", client)

	local alliance = client:GetAlliance()

	if (alliance ~= nil and alliance == target:GetAlliance()) then
		Schema.achievement.Progress("guardian_of_the_fallen", client)
	end

	hook.Run("PlayerResurrectedTarget", client, target)
end

function PLUGIN:CanPlayerSearchCorpse(client, corpse)
	if (Schema.perk.GetOwned("phoenix_tamer", client)) then
		-- Disable searching through USE, since we'll be using the entity menu
		return false
	end
end

function PLUGIN:OnPlayerRagdollOptionSelected(client, ragdollPlayer, ragdoll, option, data)
	if (option ~= L("resurrect", client)) then
		return
	end

	local hasPhoenixTamer, phoenixTamerPerkTable = Schema.perk.GetOwned("phoenix_tamer", client)

	if (not hasPhoenixTamer) then
		return
	end

	local healthPenaltyFactor = phoenixTamerPerkTable.healthPenaltyFactor

	local target = ragdoll:GetNetVar("player")

	if (not IsValid(target) or target:Alive()) then
		client:Notify("This corpse is beyond saving!")
		return
	end

	local canResurrect = hook.Run("CanPlayerResurrectTarget", client, target, ragdoll) ~= false

	if (not canResurrect) then
		client:Notify("This corpse is blocked from being resurrected!")
		return
	end

	local baseTaskTime = ix.config.Get("resurrectTimeInSeconds")
	local resurrectTimeInSeconds = Schema.GetDexterityTime(client, baseTaskTime)

	target:SetAction("@beingResurrected", resurrectTimeInSeconds)
	client:SetAction("@resurrecting", resurrectTimeInSeconds)
	client:DoStaredAction(ragdoll, function()
		if (not IsValid(target) or target:Alive() or not IsValid(client)) then
			return
		end

		local newHealth

		if (healthPenaltyFactor) then
			newHealth = client:Health() * healthPenaltyFactor
			local damageInfo = DamageInfo()
			damageInfo:SetDamage(newHealth)
			damageInfo:SetAttacker(client)
			damageInfo:SetInflictor(client:GetActiveWeapon())
			damageInfo:SetDamageType(DMG_BURN)
			client:TakeDamageInfo(damageInfo)
		end

		self:ResurrectPlayer(client, target, ragdoll, newHealth)
	end, resurrectTimeInSeconds, function()
		if (IsValid(client)) then
			client:SetAction()
		end

		if (IsValid(target)) then
			target:SetAction()
		end
	end)
end
