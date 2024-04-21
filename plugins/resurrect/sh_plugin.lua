local PLUGIN = PLUGIN

PLUGIN.name = "Resurrection"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Lets players resurrect other players."

ix.lang.AddTable("english", {
	resurrect = "Resurrect",
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

	if (not Schema.perk.GetOwned("phoenix_tamer", client)) then
		return
	end

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

		-- Resurrect the player
		entity:RemoveWithEffect()
		target:SetNetVar("deathTime", nil)
		target:SetPos(entity:GetPos())
		target:Spawn()
		target:SetPos(entity:GetPos())

		Schema.achievement.Progress(client, "paramedic")

		local alliance = client:GetAlliance()

		if (alliance ~= nil and alliance == target:GetAlliance()) then
			Schema.achievement.Progress(client, "guardian_of_the_fallen")
		end

		hook.Run("PlayerResurrectedTarget", client, target)
	end
end
