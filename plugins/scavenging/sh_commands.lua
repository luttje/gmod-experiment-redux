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
		local entity = ents.Create("exp_scavenging_source")
		entity:SetPos(trace.HitPos + trace.HitNormal + Vector(0, 0, 1))
		entity:Spawn()

		if (name) then
			entity:SetSourceName(name)
		end

		entity:MakeInventory()
        entity:Activate()

		client:Notify("Scavenging source spawned.")
	end

	ix.command.Add("ScavengeSpawn", COMMAND)
end
