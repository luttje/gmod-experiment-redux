local PLUGIN = PLUGIN

PLUGIN.name = "Monitors"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Display giant monitor screens in the city."

ix.util.Include("sh_commands.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")

PLUGIN.presets = {
	tv = {
		description = "A medium sized tv monitor",
		spawn = function(client, trace)
			local parent = ents.Create("prop_physics")
			parent:SetModel("models/props_c17/tv_monitor01.mdl")
			parent:SetModelScale(1)
			parent:SetPos(trace.HitPos + Vector(0, 0, 5))
			parent:Spawn()
			local monitor = ents.Create("exp_monitor")
			monitor:SetMonitorWidth(570)
			monitor:SetMonitorHeight(420)
			monitor:SetMonitorScale(0.025)
			monitor:ConfigureParent(parent, Vector(6, -9, 6), Angle(0, 0, 0))
			monitor:Spawn()
			monitor:SetHelper(true)
			monitor:SetPoweredOn(true)

			PLUGIN:RelateMonitorToParent(monitor, parent)
		end
	},

	wall_mounted = {
		description = "A monitor that is mounted on a wall",
		spawn = function(client, trace)
			local parent = ents.Create("prop_physics")
			parent:SetModel("models/props_wasteland/controlroom_monitor001b.mdl")
			parent:SetModelScale(1)
			parent:SetPos(trace.HitPos + Vector(0, 0, 32))
			parent:Spawn()

			local monitor = ents.Create("exp_monitor")
			monitor:SetMonitorWidth(2000)
			monitor:SetMonitorHeight(1550)
			monitor:SetMonitorScale(0.0111)
			monitor:ConfigureParent(parent, Vector(16, -11, 2), Angle(13, 0, -1))
			monitor:Spawn()
			monitor:SetHelper(true)
			monitor:SetPoweredOn(true)

			PLUGIN:RelateMonitorToParent(monitor, parent)
		end
	},

	tiny_monitor = {
		description = "A cute little monitor",
		spawn = function(client, trace)
			local parent = ents.Create("prop_physics")
			parent:SetModel("models/props_lab/monitor01b.mdl")
			parent:SetModelScale(1)
			parent:SetPos(trace.HitPos + Vector(0, 0, 5))
			parent:Spawn()

			local monitor = ents.Create("exp_monitor")
			monitor:SetMonitorWidth(100.61094665527)
			monitor:SetMonitorHeight(100.15102386475)
			monitor:SetMonitorScale(0.094292886555195)
			monitor:ConfigureParent(parent, Vector(6, -6, 5), Angle(0, 0, 0))
			monitor:Spawn()
			monitor:SetHelper(true)
			monitor:SetPoweredOn(true)

			PLUGIN:RelateMonitorToParent(monitor, parent)
		end
	},

	combine_small = {
		description = "A small combine display",
		spawn = function(client, trace)
			local parent = ents.Create("prop_physics")
			parent:SetModel("models/props_combine/combine_smallmonitor001.mdl")
			parent:SetModelScale(1)
			parent:SetPos(trace.HitPos + Vector(0, 0, 5))
			parent:Spawn()

			local monitor = ents.Create("exp_monitor")
			monitor:SetMonitorWidth(330.20141601563)
			monitor:SetMonitorHeight(356.4782409668)
			monitor:SetMonitorScale(0.053095187991858)
			monitor:ConfigureParent(parent, Vector(13, -7, 20), Angle(0, 0, 0))
			monitor:Spawn()
			monitor:SetHelper(true)
			monitor:SetPoweredOn(true)

			PLUGIN:RelateMonitorToParent(monitor, parent)
		end
	},

	combine_multiple = {
		description = "Multiple monitors on a cool wall mount",
		spawn = function(client, trace)
			local parent = ents.Create("prop_physics")
			parent:SetModel("models/combine_room/combine_monitor001temp.mdl")
			parent:SetModelScale(1)
			parent:SetPos(trace.HitPos + Vector(0, 0, 15))
			parent:Spawn()

			local monitor = ents.Create("exp_monitor") -- Left 1
			monitor:SetMonitorWidth(260)
			monitor:SetMonitorHeight(480)
			monitor:SetMonitorScale(0.065)
			monitor:ConfigureParent(parent, Vector(27, -37, 16), Angle(6, 10, 0))
			monitor:Spawn()
			monitor:SetHelper(true)
			monitor:SetPoweredOn(true)
			local monitor1 = ents.Create("exp_monitor") -- Left 2
			monitor1:SetMonitorWidth(240)
			monitor1:SetMonitorHeight(460)
			monitor1:SetMonitorScale(0.07)
			monitor1:ConfigureParent(parent, Vector(26, -20, 16), Angle(5, 14, 0))
			monitor1:Spawn()
			monitor1:SetHelper(true)
			monitor1:SetPoweredOn(true)
			local monitor2 = ents.Create("exp_monitor") -- Tiny top left
			monitor2:SetMonitorWidth(440)
			monitor2:SetMonitorHeight(330)
			monitor2:SetMonitorScale(0.02)
			monitor2:ConfigureParent(parent, Vector(31, -22, 26), Angle(27, 51, 3))
			monitor2:Spawn()
			monitor2:SetHelper(true)
			monitor2:SetPoweredOn(true)
			local monitor3 = ents.Create("exp_monitor") -- Right bottom
			monitor3:SetMonitorWidth(550)
			monitor3:SetMonitorHeight(350)
			monitor3:SetMonitorScale(0.035)
			monitor3:ConfigureParent(parent, Vector(14, -3, 7), Angle(21, -31, -2))
			monitor3:Spawn()
			monitor3:SetHelper(true)
			monitor3:SetPoweredOn(true)
			local monitor4 = ents.Create("exp_monitor") -- Right middle
			monitor4:SetMonitorWidth(500)
			monitor4:SetMonitorHeight(340)
			monitor4:SetMonitorScale(0.034)
			monitor4:ConfigureParent(parent, Vector(10, -3, 23), Angle(2, -20, 2))
			monitor4:Spawn()
			monitor4:SetHelper(true)
			monitor4:SetPoweredOn(true)
			local monitor5 = ents.Create("exp_monitor") -- Right top
			monitor5:SetMonitorWidth(470)
			monitor5:SetMonitorHeight(340)
			monitor5:SetMonitorScale(0.02)
			monitor5:ConfigureParent(parent, Vector(21, -2, 30), Angle(28, -21, 3))
			monitor5:Spawn()
			monitor5:SetHelper(true)
			monitor5:SetPoweredOn(true)

			PLUGIN:RelateMonitorToParent(monitor, parent)
			PLUGIN:RelateMonitorToParent(monitor1, parent)
			PLUGIN:RelateMonitorToParent(monitor2, parent)
			PLUGIN:RelateMonitorToParent(monitor3, parent)
			PLUGIN:RelateMonitorToParent(monitor4, parent)
			PLUGIN:RelateMonitorToParent(monitor5, parent)
		end
	},

	combine_big = {
		description = "Big wall mounted combine monitor",
		spawn = function(client, trace)
			local parent = ents.Create("prop_physics")
			parent:SetModel("models/combine_room/combine_monitor003a.mdl")
			parent:SetModelScale(1)
			parent:SetPos(trace.HitPos + Vector(0, 0, 300))
			parent:Spawn()

			local monitor = ents.Create("exp_monitor")
			monitor:SetMonitorWidth(2000)
			monitor:SetMonitorHeight(3520)
			monitor:SetMonitorScale(0.1)
			monitor:ConfigureParent(parent, Vector(134, -73, 174), Angle(1, 0, -1))
			monitor:Spawn()
			monitor:SetHelper(true)
			monitor:SetPoweredOn(true)

			PLUGIN:RelateMonitorToParent(monitor, parent)
		end
	},
}
