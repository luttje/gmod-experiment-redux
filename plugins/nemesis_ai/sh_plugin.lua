local PLUGIN = PLUGIN

PLUGIN.name = "Nemesis AI"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "An AI that communicates through giant screens in the city."

ix.util.Include("sh_commands.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")

if (SERVER) then
    resource.AddFile("materials/experiment-redux/locker_rot.png")
    resource.AddFile("materials/experiment-redux/locker_rot_icon.png")
    resource.AddFile("materials/experiment-redux/locker_rot_anti_virus.png")
else
	PLUGIN.lockerRotIcon = ix.util.GetMaterial("experiment-redux/locker_rot_icon.png")
	PLUGIN.lockerRotAntiVirusSymbol = ix.util.GetMaterial("experiment-redux/locker_rot_anti_virus.png")
end

ix.chat.Register("nemesis_ai", {
	CanSay = function(self, speaker, text)
		return not IsValid(speaker)
	end,
    OnChatAdd = function(self, speaker, text)
        local icon = ix.util.GetMaterial("icon16/bullet_blue.png")

		chat.AddText(icon, Color(126, 199, 248), "An artificial voice says \"" .. tostring(text) .. "\"")
	end,
	noSpaceAfter = true
})

ix.chat.Register("nemesis_ai_locker_rot", {
	CanSay = function(self, speaker, text)
		return not IsValid(speaker)
	end,
    OnChatAdd = function(self, speaker, text, anonymous, data)
        local textColor = Color(84, 106, 118) -- alternative: Color(98, 168, 124)
        local highlightColor = Color(126, 224, 129)

        chat.AddText(
			PLUGIN.lockerRotIcon,
			highlightColor,
			"'" .. text .. "'",
			textColor,
            " has a score of ",
            highlightColor,
            data.score,
            textColor,
            " for '",
            highlightColor,
            data.metric,
            textColor,
            "'.\nDue to the ",
            highlightColor,
            "Locker Rot Virus",
            textColor,
            " they are holding their most ",
            highlightColor,
            "valuable items",
            textColor,
            ". They will be running to find the anti-virus, so be on the lookout to ",
            highlightColor,
			"slay them and claim their items for yourself!"
		)
	end,
	noSpaceAfter = true
})

ix.chat.Register("nemesis_ai_locker_rot_hint", {
	CanSay = function(self, speaker, text)
		return not IsValid(speaker)
	end,
    OnChatAdd = function(self, speaker, text, anonymous, data)
        local textColor = Color(84, 106, 118)
        local highlightColor = Color(126, 224, 129)

        chat.AddText(
			PLUGIN.lockerRotIcon,
            highlightColor,
			"Hint: ",
            textColor,
            text
		)
	end,
	noSpaceAfter = true
})

ix.chat.Register("nemesis_ai_locker_rot_warning", {
	CanSay = function(self, speaker, text)
		return not IsValid(speaker)
	end,
	OnChatAdd = function(self, speaker, text, anonymous, data)
		local textColor = Color(162, 62, 72)
		local highlightColor = Color(255, 60, 56)

        chat.AddText(
			PLUGIN.lockerRotIcon,
			highlightColor,
			"Warning: ",
			textColor,
            text
		)
	end,
	noSpaceAfter = true
})

ix.config.Add("nemesisAiEnabled", true, "Whether or not the Nemesis AI is enabled.", nil, {
	category = "nemesis_ai"
})

ix.config.Add("nemesisAiLockerRotIntervalSeconds", 60 * 60, "The interval in seconds that the Nemesis AI will check for bounties.", nil, {
	data = {min = 1, max = 86400},
	category = "nemesis_ai"
})

ix.config.Add("nemesisAiLockerRotTaskSeconds", 60 * 10, "How long a player has to complete the Locker Rot task.", nil, {
	data = {min = 1, max = 86400},
	category = "nemesis_ai"
})

ix.lang.AddTable("english", {
    nemesis_ai = "Nemesis AI",
})

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

	combine_medium = {
        description = "Medium wall mounted combine monitor",
		model = "models/combine_room/combine_monitor002.mdl",
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
