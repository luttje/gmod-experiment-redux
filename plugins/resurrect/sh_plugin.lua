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
	function PLUGIN:NetworkEntityCreated(entity)
		local client = LocalPlayer()

		if (entity:GetClass() ~= "prop_ragdoll" or not IsValid(client)) then
			return
		end

		if (not Schema.perk.GetOwned("phoenix_tamer")) then
			return
		end

		entity.GetEntityMenu = function(entity, options)
			local target = entity:GetNetVar("player", NULL)
			local options = {}

			options[L("searchCorpse")] = true

			if (not IsValid(target) or target:Alive()) then
				return options
			end

			local canResurrect = hook.Run("CanPlayerResurrectTarget", client, target, entity) ~= false

			if (not canResurrect) then
				return options
			end

			options[L("resurrect")] = true

			return options
		end
	end
end

if (not SERVER) then
	return
end

function PLUGIN:ResurrectPlayer(client, target, entity, newHealth)
	entity:RemoveWithEffect()
	target:SetNetVar("deathTime", nil)
	target:Spawn()
	target:SetPos(entity:GetPos())
	target:SetHealth(newHealth or target:GetMaxHealth())

	if (target:IsStuck()) then
		entity:DropToFloor()
		target:SetPos(entity:GetPos() + Vector(0, 0, 16))

		local positions = ix.util.FindEmptySpace(target, { entity, target })

		for _, v in ipairs(positions) do
			target:SetPos(v)

			if (not target:IsStuck()) then
				return
			end
		end
	end

	Schema.achievement.Progress(client, "paramedic")

	local alliance = client:GetAlliance()

	if (alliance ~= nil and alliance == target:GetAlliance()) then
		Schema.achievement.Progress(client, "guardian_of_the_fallen")
	end

	hook.Run("PlayerResurrectedTarget", client, target)
end

function PLUGIN:CanPlayerSearchCorpse(client, corpse)
	if (Schema.perk.GetOwned("phoenix_tamer", client)) then
		-- Disable searching through USE, since we'll be using the entity menu
		return false
	end
end

function PLUGIN:PlayerInteractEntity(client, entity, option, data)
	if (entity:GetClass() ~= "prop_ragdoll") then
		return
	end

	local hasPhoenixTamer, phoenixTamerPerkTable = Schema.perk.GetOwned("phoenix_tamer", client)

	if (not hasPhoenixTamer) then
		return
	end

	local healthPenaltyFactor = phoenixTamerPerkTable.healthPenaltyFactor

	entity.OnOptionSelected = function(entity, client, option, data)
		if (option == L("searchCorpse", client) and entity.StartSearchCorpse) then
			entity:StartSearchCorpse(client)
		end

		if (option ~= L("resurrect", client)) then
			return
		end

		local target = entity:GetNetVar("player")

		if (not IsValid(target) or target:Alive()) then
			client:Notify("This corpse is beyond saving!")
			return
		end

		local canResurrect = hook.Run("CanPlayerResurrectTarget", client, target, entity) ~= false

		if (not canResurrect) then
			client:Notify("This corpse is blocked from being resurrected!")
			return
		end

		local resurrectTimeInSeconds = ix.config.Get("resurrectTimeInSeconds")

		target:SetAction("@beingResurrected", resurrectTimeInSeconds)
		client:SetAction("@resurrecting", resurrectTimeInSeconds)
		client:DoStaredAction(entity, function()
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

			self:ResurrectPlayer(client, target, entity, newHealth)
		end, resurrectTimeInSeconds, function()
			if (IsValid(client)) then
				client:SetAction()
			end

			if (IsValid(target)) then
				target:SetAction()
			end
		end)
	end
end
