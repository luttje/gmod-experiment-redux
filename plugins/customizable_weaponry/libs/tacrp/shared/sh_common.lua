local PLUGIN                = PLUGIN
PLUGIN.Version              = "19" -- 2024-04-01

PLUGIN.PenTable             = {
	[MAT_ANTLION]     = 0.1,
	[MAT_BLOODYFLESH] = 0.1,
	[MAT_CONCRETE]    = 0.5,
	[MAT_DIRT]        = 0.25,
	[MAT_EGGSHELL]    = 0.25,
	[MAT_FLESH]       = 0.1,
	[MAT_GRATE]       = 0.25,
	[MAT_ALIENFLESH]  = 0.25,
	[MAT_CLIP]        = 1000,
	[MAT_SNOW]        = 0.1,
	[MAT_PLASTIC]     = 0.25,
	[MAT_METAL]       = 1,
	[MAT_SAND]        = 0.5,
	[MAT_FOLIAGE]     = 0.25,
	[MAT_COMPUTER]    = 0.25,
	[MAT_SLOSH]       = 0.25,
	[MAT_TILE]        = 0.5, -- you know, like ceramic armor
	[MAT_GRASS]       = 0.25,
	[MAT_VENT]        = 0.1,
	[MAT_WOOD]        = 0.25,
	[MAT_DEFAULT]     = 0.25,
	[MAT_GLASS]       = 0.1,
	[MAT_WARPSHIELD]  = 1
}

-- Why the fuck is this a thing???
PLUGIN.CancelMultipliers    = {
	[1] = {
		[HITGROUP_HEAD]     = 2,
		[HITGROUP_LEFTARM]  = 0.25,
		[HITGROUP_RIGHTARM] = 0.25,
		[HITGROUP_LEFTLEG]  = 0.25,
		[HITGROUP_RIGHTLEG] = 0.25,
		[HITGROUP_GEAR]     = 0.25,
	},
	["terrortown"] = {
		[HITGROUP_HEAD]     = 1,
		[HITGROUP_LEFTARM]  = 0.55,
		[HITGROUP_RIGHTARM] = 0.55,
		[HITGROUP_LEFTLEG]  = 0.55,
		[HITGROUP_RIGHTLEG] = 0.55,
		[HITGROUP_GEAR]     = 0.55,
	},
}

PLUGIN.PresetPath           = "tacrp_presets/"

PLUGIN.OverDraw             = false

PLUGIN.HUToM                = 0.3048 / 12

PLUGIN.HolsterNetBits       = 3
PLUGIN.HOLSTER_SLOT_BACK    = 1
PLUGIN.HOLSTER_SLOT_BACK2   = 2
PLUGIN.HOLSTER_SLOT_PISTOL  = 3
PLUGIN.HOLSTER_SLOT_GEAR    = 4
PLUGIN.HOLSTER_SLOT_SPECIAL = 5

PLUGIN.IN_MELEE             = IN_WEAPON1

PLUGIN.HolsterBones         = {
	[PLUGIN.HOLSTER_SLOT_BACK] = {
		"ValveBiped.Bip01_Spine2",
		Vector(0, 0, 0),
		{ "models/props_c17/SuitCase_Passenger_Physics.mdl", Vector(6, 4, 8), Angle(0, 0, 0) },
	},
	[PLUGIN.HOLSTER_SLOT_BACK2] = {
		"ValveBiped.Bip01_Spine2",
		{ Vector(0, 4, 12),                                  Angle(180, 180, 0) },
		{ "models/props_c17/SuitCase_Passenger_Physics.mdl", Vector(6, 4, 8),   Angle(0, 0, 0) },
	},
	[PLUGIN.HOLSTER_SLOT_PISTOL] = {
		"ValveBiped.Bip01_R_Thigh",
		Vector(-1.5, 1.5, -0.75),
		{ "models/weapons/w_eq_eholster_elite.mdl", Vector(0, 8, -4), Angle(90, 0, 90) },
	},
	[PLUGIN.HOLSTER_SLOT_GEAR] = {
		"ValveBiped.Bip01_Pelvis",
		Vector(0, 10, 0),
		{ "models/weapons/w_defuser.mdl", Vector(0, -10, -8), Angle(-90, -90, 0) },
	},
	[PLUGIN.HOLSTER_SLOT_SPECIAL] = {
		"ValveBiped.Bip01_Spine2",
		Vector(0, 4, 4),
		{ "models/props_c17/SuitCase_Passenger_Physics.mdl", Vector(6, 4, 8), Angle(0, 0, 0) },
	},
}

PLUGIN.BlindFireNetBits     = 3

PLUGIN.BLINDFIRE_NONE       = 0
PLUGIN.BLINDFIRE_UP         = 1
PLUGIN.BLINDFIRE_LEFT       = 2
PLUGIN.BLINDFIRE_RIGHT      = 3
PLUGIN.BLINDFIRE_KYS        = 4 -- You should kill yourself... NOW!

PLUGIN.MuzzleEffects        = {
	"muzzleflash_smg",
	"muzzleflash_smg_bizon",
	"muzzleflash_shotgun",
	"muzzleflash_slug",
	"muzzleflash_slug_flame",
	"muzzleflash_pistol",
	"muzzleflash_pistol_cleric",
	"muzzleflash_pistol_deagle",
	"muzzleflash_suppressed",
	"muzzleflash_mp5",
	"muzzleflash_MINIMI",
	"muzzleflash_m79",
	"muzzleflash_m14",
	"muzzleflash_ak47",
	"muzzleflash_ak74",
	"muzzleflash_m82",
	"muzzleflash_m3",
	"muzzleflash_famas",
	"muzzleflash_g3",
	"muzzleflash_1",
	"muzzleflash_3",
	"muzzleflash_4",
	"muzzleflash_5",
	"muzzleflash_6",
}
PLUGIN.MuzzleEffectsLookup  = {}
for k, v in ipairs(PLUGIN.MuzzleEffects) do
	PLUGIN.MuzzleEffectsLookup[v] = k
end

PLUGIN.AreTheGrenadeAnimsReadyYet = true

PLUGIN.FACTION_NEUTRAL = 0
PLUGIN.FACTION_COALITION = 1
PLUGIN.FACTION_MILITIA = 2

PLUGIN.FactionToPhrase = {
	[PLUGIN.FACTION_NEUTRAL] = "faction.neutral",
	[PLUGIN.FACTION_COALITION] = "faction.coalition",
	[PLUGIN.FACTION_MILITIA] = "faction.militia",
}

PLUGIN.BALANCE_AUTO = -1
PLUGIN.BALANCE_RP = 0
PLUGIN.BALANCE_SBOX = 1
PLUGIN.BALANCE_TTT = 2
PLUGIN.BALANCE_PVE = 3
PLUGIN.BALANCE_OLDSCHOOL = 4

function PLUGIN.GetBalanceMode()
	local i = PLUGIN.ConVars["balance"]:GetInt()
	if i == PLUGIN.BALANCE_AUTO then
		if engine.ActiveGamemode() == "terrortown" then
			return PLUGIN.BALANCE_TTT
		elseif DarkRP or ix then
			return PLUGIN.BALANCE_RP
		else
			return PLUGIN.BALANCE_SBOX
		end
	else
		return i
	end
end

PLUGIN.BalanceUseTiers = {
	[PLUGIN.BALANCE_RP] = true,
	[PLUGIN.BALANCE_PVE] = true,
}

PLUGIN.BalanceDefaults = {
	[PLUGIN.BALANCE_SBOX] = {
	},
	[PLUGIN.BALANCE_PVE] = {
		RecoilVisualKick = 0.75,
		BodyDamageMultipliers = {
			[HITGROUP_HEAD] = 1.5,
			[HITGROUP_CHEST] = 1,
			[HITGROUP_STOMACH] = 1,
			[HITGROUP_LEFTARM] = 1,
			[HITGROUP_RIGHTARM] = 1,
			[HITGROUP_LEFTLEG] = 0.75,
			[HITGROUP_RIGHTLEG] = 0.75,
			[HITGROUP_GEAR] = 0.75
		}
	},
	[PLUGIN.BALANCE_OLDSCHOOL] = {
		RecoilVisualKick = 0,

		MoveSpreadPenalty = 0,
		HipFireSpreadPenalty = 0.007,

		MeleeSpeedMult = 1,
		ShootingSpeedMult = 1,
		SightedSpeedMult = 1,
		ReloadSpeedMult = 1,
		MidAirSpreadPenalty = 0.025
	},
}

function PLUGIN.UseTiers()
	return PLUGIN.BalanceUseTiers[PLUGIN.GetBalanceMode()]
end

PLUGIN.AmmoJamMSB = {
	["pistol"] = 30,
	["smg1"] = 25,
	["ar2"] = 20,
	["357"] = 10,
	["buckshot"] = 15,
	["SniperPenetratedRound"] = 15,
}

PLUGIN.HoldTypeSightedLookup = {
	["revolver"] = "revolver",
	["smg"] = "rpg",
	["ar2"] = "rpg",
	["shotgun"] = "rpg",
}

PLUGIN.ShellTypes = {
	[1] = {
		Model = "models/tacint/shells/pistol_shell.mdl",
		Sounds = {
			"TacRP/shells/shell_drop-1.wav",
			"TacRP/shells/shell_drop-2.wav",
			"TacRP/shells/shell_drop-3.wav",
			"TacRP/shells/shell_drop-4.wav",
			"TacRP/shells/shell_drop-5.wav",
		}
	},
	[2] = {
		Model = "models/tacint/shells/rifle_shell.mdl",
		Sounds = {
			"TacRP/shells/shell_drop-1.wav",
			"TacRP/shells/shell_drop-2.wav",
			"TacRP/shells/shell_drop-3.wav",
			"TacRP/shells/shell_drop-4.wav",
			"TacRP/shells/shell_drop-5.wav",
		}
	},
	[3] = {
		Model = "models/tacint/shells/shotgun_shell.mdl",
		Sounds = {
			"TacRP/shells/shotshell_drop-1.wav",
			"TacRP/shells/shotshell_drop-2.wav",
			"TacRP/shells/shotshell_drop-3.wav",
			"TacRP/shells/shotshell_drop-4.wav",
			"TacRP/shells/shotshell_drop-5.wav",
		}
	},
	[4] = {
		Model = "models/tacint/shells/ks23_shell.mdl",
		Sounds = {
			"TacRP/shells/shotshell_drop-1.wav",
			"TacRP/shells/shotshell_drop-2.wav",
			"TacRP/shells/shotshell_drop-3.wav",
			"TacRP/shells/shotshell_drop-4.wav",
			"TacRP/shells/shotshell_drop-5.wav",
		}
	},
}
hook.Add("InitPostEntity", "tacrp_shelleffect", function()
	hook.Run("TacRP_LoadShellEffects", PLUGIN.ShellTypes)

	if GetConVar("tacrp_phystweak"):GetBool() then
		local v = physenv.GetPerformanceSettings().MaxVelocity
		if v < 10000 then
			physenv.SetPerformanceSettings({ MaxVelocity = 10000 })
			print("[TacRP] Increasing MaxVelocity for projectiles to behave as intendednot (" .. v .. "-> 10000)")
			print("[TacRP] Disable this behavior with 'tacrp_phystweak 0'.")
		end
	end
end)
