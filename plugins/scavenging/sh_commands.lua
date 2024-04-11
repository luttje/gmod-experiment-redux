local PLUGIN = PLUGIN

do
	local COMMAND = {}

	COMMAND.description = "Spawn a scavenging source at your target position."
	COMMAND.arguments = {
		bit.bor(ix.type.string, ix.type.optional),
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, name)
		local trace = client:GetEyeTraceNoCursor()
		local ent = ents.Create("exp_scavenging_source")
		ent:SetPos(trace.HitPos + trace.HitNormal + Vector(0, 0, 1))
		ent:Spawn()

		if (name) then
			ent:SetSourceName(name)
		end

		ent:MakeInventory()
		ent:Activate()

		client:Notify("Scavenging source spawned!")
	end

	ix.command.Add("ScavengeSpawn", COMMAND)
end
