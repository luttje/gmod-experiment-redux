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

do
	local COMMAND = {}

	COMMAND.description = "Set the monitor target to the character you specify."
	COMMAND.arguments = {
		ix.type.character,
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target)
		PLUGIN:SetTarget(target:GetPlayer())
		client:Notify("Monitor target set to " .. target:GetName() .. ".")
	end

	ix.command.Add("MonitorSetTarget", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Turn off all (or random) monitors."
	COMMAND.arguments = {
		bit.bor(ix.type.bool, ix.type.optional),
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, random)
		PLUGIN:DramaticDelayEachMonitor(function(monitor)
			if (random and math.random(0, 1) == 1) then
				return
			end

			monitor:SetPoweredOn(false)
		end)

		client:Notify("All monitors turned off.")
	end

	ix.command.Add("MonitorTurnOff", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Enable the specified VGUI screens for all monitors."
	COMMAND.arguments = {
		bit.bor(ix.type.string, ix.type.optional),
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, vguiScreen)
		PLUGIN:DramaticDelayEachMonitor(function(monitor)
			monitor:SetPoweredOn(true)
		end)

		net.Start("expSetMonitorVgui")
		net.WriteString(vguiScreen)
		net.Broadcast()

		client:Notify("All monitors set to VGUI screen: " .. (vguiScreen) .. ".")
	end

	ix.command.Add("MonitorSetVgui", COMMAND)
end
