ix.currency.symbol = ""
ix.currency.singular = "bolt"
ix.currency.plural = "bolts"
ix.currency.model = "models/props_lab/exp01a.mdl"

ix.config.SetDefault("intro", false)
ix.config.SetDefault("music", "music/HL2_song23_SuitSong3.mp3")
ix.config.SetDefault("maxAttributes", 100)
ix.config.SetDefault("communityURL", "")

ix.config.Add("allianceCost", 10000, "How much an alliance costs to create.", nil, {
	data = { min = 0, max = 1000000 },
	category = "alliances"
})

ix.config.Add("incomeMultiplier", 1, "The income multiplier for generators and salary", nil, {
	data = { min = 0, max = 100, decimals = 1 },
	category = "income"
})

ix.config.Add("teleportGeneratorEarnings", false,
	"Wether income from generators should be teleported to the player. If not they'll have to get it from the generator manually.",
	nil, {
		category = "income"
	})

ix.config.Add("armorEffectiveness", 0.75,
	"How much damage armor will prevent, for example 0.75 will let a quarter of the damage through.", nil, {
	data = { min = 0, max = 1, decimals = 2 }
})

ix.config.Add("beanbagRagdollDuration", 15, "How long players knocked out by beanbags will be ragdolled for.", nil, {
	data = { min = 0, max = 600 }
})

ix.config.Add("requiredGraceAfterDamage", 60,
	"How long after taking damage a player can disconnect without dropping everything.", nil, {
	data = { min = 0, max = 300 },
	category = "moderation"
})

ix.config.Add("grenadeTrailsEnabled", true, "Whether or not grenades leave a colored trail behind them.", nil, {
	category = "grenades"
})

ix.config.Add("grenadeTrailColor", Color(255, 100, 0), "The color of the grenade trail.", nil, {
	category = "grenades"
})

ix.config.Add("grenadeTrailMaxLifetime", 10,
	"How long the grenade trail lasts for (-1 means for as long as the grenade exists).", nil, {
	data = { min = -1, max = 10, decimals = 0 },
	category = "grenades"
})

ix.config.Add("maxInteractionDistance", 192, "How far away from the player an item/object can be placed.", nil, {
	data = { min = 128, max = math.huge, decimals = 0 },
})

Schema.implantPacData = {
	[1] = {
		["children"] = {
			[1] = {
				["children"] = {
				},
				["self"] = {
					["Skin"] = 0,
					["UniqueID"] = "88e3e8489e963c739a45cb011fc9fa10803471b8d6ad2575fc3cacfef2e390a8",
					["NoLighting"] = false,
					["AimPartName"] = "",
					["IgnoreZ"] = false,
					["AimPartUID"] = "",
					["Materials"] = "",
					["Name"] = "",
					["LevelOfDetail"] = 0,
					["NoTextureFiltering"] = false,
					["PositionOffset"] = Vector(0, 0, 0),
					["IsDisturbing"] = false,
					["EyeAngles"] = false,
					["DrawOrder"] = 0,
					["TargetEntityUID"] = "",
					["Alpha"] = 1,
					["Material"] = "",
					["Invert"] = false,
					["ForceObjUrl"] = false,
					["Bone"] = "eyes",
					["Angles"] = Angle(21.10000038147, 23.200000762939, -4.5999999046326),
					["AngleOffset"] = Angle(0, 0, 0),
					["BoneMerge"] = false,
					["Color"] = Vector(1, 1, 1),
					["Position"] = Vector(-1.82373046875, -0.5068359375, -0.1075439453125),
					["ClassName"] = "model2",
					["Brightness"] = 1,
					["Hide"] = false,
					["NoCulling"] = false,
					["Scale"] = Vector(1.5, 1.2999999523163, 1.2000000476837),
					["LegacyTransform"] = false,
					["EditorExpand"] = false,
					["Size"] = 1,
					["ModelModifiers"] = "",
					["Translucent"] = false,
					["BlendMode"] = "",
					["EyeTargetUID"] = "",
					["Model"] = "models/gibs/shield_scanner_gib1.mdl",
				},
			},
		},
		["self"] = {
			["DrawOrder"] = 0,
			["UniqueID"] = "809ca082ce58a4fd10cd900777123d09ead082b54a7212111d2f2e3de22d154a",
			["Hide"] = false,
			["TargetEntityUID"] = "",
			["EditorExpand"] = true,
			["OwnerName"] = "self",
			["IsDisturbing"] = false,
			["Name"] = "my outfit",
			["Duplicate"] = false,
			["ClassName"] = "group",
		},
	},
}
