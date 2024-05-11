local PLUGIN = PLUGIN

PLUGIN.name = "Monitors"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Display giant monitor screens in the city."

ix.util.Include("sh_commands.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")

PLUGIN.presets = {
	combine_big = {
        description = "Big wall mounted combine monitor",
		model = "models/combine_room/combine_monitor003a.mdl",
		spawnOffset = Vector(0, 0, 300),
        monitors = {
            {
                width = 2000,
                height = 3520,
                scale = 0.1,
                offsetPosition = Vector(134, -73, 174),
                offsetAngles = Angle(1, 0, -1),
			},
		},
    },

	combine_small = {
		description = "A small combine display",
		model = "models/props_combine/combine_smallmonitor001.mdl",
		spawnOffset = Vector(0, 0, 5),
		monitors = {
			{
				width = 330.20141601563,
				height = 356.4782409668,
				scale = 0.053095187991858,
				offsetPosition = Vector(13, -7, 20),
				offsetAngles = Angle(0, 0, 0),
			},
		},
    },

	tiny_monitor = {
		description = "A cute little monitor",
		model = "models/props_lab/monitor01b.mdl",
		spawnOffset = Vector(0, 0, 5),
		monitors = {
			{
				width = 100.61094665527,
				height = 100.15102386475,
				scale = 0.094292886555195,
				offsetPosition = Vector(6, -6, 5),
				offsetAngles = Angle(0, 0, 0),
			},
		},
    },

	wall_mounted = {
		description = "A monitor that is mounted on a wall",
		model = "models/props_wasteland/controlroom_monitor001b.mdl",
		spawnOffset = Vector(0, 0, 32),
		monitors = {
			{
				width = 2000,
				height = 1550,
				scale = 0.0111,
				offsetPosition = Vector(16, -11, 2),
				offsetAngles = Angle(13, 0, -1),
			},
		},
    },

	tv = {
		description = "A medium sized tv monitor",
		model = "models/props_c17/tv_monitor01.mdl",
		spawnOffset = Vector(0, 0, 5),
		monitors = {
			{
				width = 570,
				height = 420,
				scale = 0.025,
				offsetPosition = Vector(6, -9, 6),
				offsetAngles = Angle(0, 0, 0),
			},
		},
    },
}
