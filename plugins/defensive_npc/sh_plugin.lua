local PLUGIN = PLUGIN

PLUGIN.name = "Defensive NPC's"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Let super admins spawn defensive NPC's."

ix.util.Include("sv_plugin.lua")

ix.lang.AddTable("english", {
	turretOwnerSelf = "Your Turret",
	turretOwnerName = "%s's Turret",
	turretOwnerTheBusiness = "The Business' Turret",

	turretHealth = "Health: ",
})

do
	local COMMAND = {}

	COMMAND.description = "Spawn a defensive NPC."
	COMMAND.arguments = {
		bit.bor(ix.type.string, ix.type.optional),
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, turretType)
		turretType = turretType or "floor"

		if (not PLUGIN.turretTypes[turretType]) then
			client:Notify("Invalid turret type. Valid types are: " ..
				table.concat(table.GetKeys(PLUGIN.turretTypes), ", "))
			return
		end

		local canSpawn = PLUGIN.turretTypes[turretType]
		local trace = client:GetEyeTraceNoCursor()

		if (not canSpawn(client, trace)) then
			client:Notify("Cannot spawn a " .. turretType .. " defensive NPC here.")
			return
		end

		local facingAwayFromPlayerUpright = Angle(0, client:EyeAngles().y, 0)
		local entity = PLUGIN:SpawnTurret(turretType, trace.HitPos, facingAwayFromPlayerUpright)

		client:Notify("You have spawned a defensive turret (" .. turretType .. ").")
	end

	ix.command.Add("DefensiveNpcSpawn", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Remove a defensive NPC you are looking at."

	COMMAND.description = "Remove a defensive NPC you are looking at or all within a range."
	COMMAND.arguments = {
		bit.bor(ix.type.number, ix.type.optional)
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, range)
		if (range) then
			local removed = 0

			for _, ent in ipairs(ents.FindInSphere(client:GetPos(), range)) do
				if (IsValid(ent) and ent:GetClass() == "exp_turret") then
					ent:Remove()
					removed = removed + 1
				end
			end

			client:Notify("Removed " .. removed .. " turret(s) within range " .. range .. ".")

			return
		end

		local trace = client:GetEyeTraceNoCursor()
		local entity = trace.Entity

		if (not IsValid(entity) or entity:GetClass() ~= "exp_turret") then
			client:Notify("You are not looking at a valid defensive NPC.")
			return
		end

		entity:Remove()
		client:Notify("You have removed a defensive NPC.")
	end

	ix.command.Add("DefensiveNpcRemove", COMMAND)
end
