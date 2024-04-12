local PLUGIN = PLUGIN

do
	local COMMAND = {}

	COMMAND.description =
	"Spawn a monitor screen and configure it's size or spawn a preset (use `/MonitorSpawn help` to print a list of presets in console)."
	COMMAND.arguments = {
		bit.bor(ix.type.string, ix.type.optional),
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, presetKey)
		local presets = PLUGIN.presets
		local trace = client:GetEyeTraceNoCursor()

		if (presetKey and presetKey == "help") then
			net.Start("expMonitorsPrintPresets")
			net.Send(client)

			return
		end

		if (presetKey) then
			local preset = presets[presetKey]

			if (not preset) then
				client:Notify("Invalid preset specified!")
				return
			end

			preset.spawn(client, trace)
			client:Notify("Monitor spawned with preset: " .. presetKey)

			return
		end

		local ent = ents.Create("exp_monitor")
		ent:SetPos(trace.HitPos + trace.HitNormal + Vector(0, 0, 30))
		ent:Spawn()
		ent:Activate()
		ent:SetHelper(true)

		client:Notify("Monitor spawned.")
	end

	ix.command.Add("MonitorSpawn", COMMAND)
end
