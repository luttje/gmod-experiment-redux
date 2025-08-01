TacRP.Version = "19" // 2024-04-01

TacRP.PenTable = {
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
    [MAT_TILE]        = 0.5, // you know, like ceramic armor
    [MAT_GRASS]       = 0.25,
    [MAT_VENT]        = 0.1,
    [MAT_WOOD]        = 0.25,
    [MAT_DEFAULT]     = 0.25,
    [MAT_GLASS]       = 0.1,
    [MAT_WARPSHIELD]  = 1
}

// Why the fuck is this a thing???
TacRP.CancelMultipliers = {
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

TacRP.PresetPath = "tacrp_presets/"

TacRP.OverDraw = false

TacRP.HUToM = 0.3048 / 12

TacRP.HolsterNetBits = 3
TacRP.HOLSTER_SLOT_BACK = 1
TacRP.HOLSTER_SLOT_BACK2 = 2
TacRP.HOLSTER_SLOT_PISTOL = 3
TacRP.HOLSTER_SLOT_GEAR = 4
TacRP.HOLSTER_SLOT_SPECIAL = 5

TacRP.IN_MELEE = IN_WEAPON1

TacRP.HolsterBones = {
    [TacRP.HOLSTER_SLOT_BACK] = {
        "ValveBiped.Bip01_Spine2",
        Vector(0, 0, 0),
        {"models/props_c17/SuitCase_Passenger_Physics.mdl", Vector(6, 4, 8), Angle(0, 0, 0)},
    },
    [TacRP.HOLSTER_SLOT_BACK2] = {
        "ValveBiped.Bip01_Spine2",
        {Vector(0, 4, 12), Angle(180, 180, 0)},
        {"models/props_c17/SuitCase_Passenger_Physics.mdl", Vector(6, 4, 8), Angle(0, 0, 0)},
    },
    [TacRP.HOLSTER_SLOT_PISTOL] = {
        "ValveBiped.Bip01_R_Thigh",
        Vector(-1.5, 1.5, -0.75),
        {"models/weapons/w_eq_eholster_elite.mdl", Vector(0, 8, -4), Angle(90, 0, 90)},
    },
    [TacRP.HOLSTER_SLOT_GEAR] = {
        "ValveBiped.Bip01_Pelvis",
        Vector(0, 10, 0),
        {"models/weapons/w_defuser.mdl", Vector(0, -10, -8), Angle(-90, -90, 0)},
    },
    [TacRP.HOLSTER_SLOT_SPECIAL] = {
        "ValveBiped.Bip01_Spine2",
        Vector(0, 4, 4),
        {"models/props_c17/SuitCase_Passenger_Physics.mdl", Vector(6, 4, 8), Angle(0, 0, 0)},
    },
}

TacRP.BlindFireNetBits = 3

TacRP.BLINDFIRE_NONE  = 0
TacRP.BLINDFIRE_UP    = 1
TacRP.BLINDFIRE_LEFT  = 2
TacRP.BLINDFIRE_RIGHT = 3
TacRP.BLINDFIRE_KYS   = 4 // You should kill yourself... NOW!

TacRP.MuzzleEffects = {
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
TacRP.MuzzleEffectsLookup = {}
for k, v in ipairs(TacRP.MuzzleEffects) do
    TacRP.MuzzleEffectsLookup[v] = k
end

TacRP.AreTheGrenadeAnimsReadyYet = true

TacRP.FACTION_NEUTRAL = 0
TacRP.FACTION_COALITION = 1
TacRP.FACTION_MILITIA = 2

TacRP.FactionToPhrase = {
    [TacRP.FACTION_NEUTRAL] = "faction.neutral",
    [TacRP.FACTION_COALITION] = "faction.coalition",
    [TacRP.FACTION_MILITIA] = "faction.militia",
}

function TacRP.ShouldWeFunny()
    local i = TacRP.ConVars["funny_loudnoises"]:GetInt()
    return i == 2 or (i == 1 and (os.date("%m-%d") == "04-01" or math.random() <= 0.01))
end

TacRP.BALANCE_AUTO = -1
TacRP.BALANCE_RP = 0
TacRP.BALANCE_SBOX = 1
TacRP.BALANCE_TTT = 2
TacRP.BALANCE_PVE = 3
TacRP.BALANCE_OLDSCHOOL = 4

function TacRP.GetBalanceMode()
    local i = TacRP.ConVars["balance"]:GetInt()
    if i == TacRP.BALANCE_AUTO then
        if engine.ActiveGamemode() == "terrortown" then
            return TacRP.BALANCE_TTT
        elseif DarkRP or ix then
            return TacRP.BALANCE_RP
        else
            return TacRP.BALANCE_SBOX
        end
    else
        return i
    end
end

TacRP.BalanceUseTiers = {
    [TacRP.BALANCE_RP] = true,
    [TacRP.BALANCE_PVE] = true,
}

TacRP.BalanceDefaults = {
    [TacRP.BALANCE_SBOX] = {
    },
    [TacRP.BALANCE_PVE] = {
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
    [TacRP.BALANCE_OLDSCHOOL] = {
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

function TacRP.UseTiers()
    return TacRP.BalanceUseTiers[TacRP.GetBalanceMode()]
end

TacRP.AmmoJamMSB = {
    ["pistol"] = 30,
    ["smg1"] = 25,
    ["ar2"] = 20,
    ["357"] = 10,
    ["buckshot"] = 15,
    ["SniperPenetratedRound"] = 15,
}

TacRP.HoldTypeSightedLookup = {
    ["revolver"] = "revolver",
    ["smg"] = "rpg",
    ["ar2"] = "rpg",
    ["shotgun"] = "rpg",
}

TacRP.ShellTypes = {
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
    hook.Run("TacRP_LoadShellEffects", TacRP.ShellTypes)

    if GetConVar("tacrp_phystweak"):GetBool() then
        local v = physenv.GetPerformanceSettings().MaxVelocity
        if v < 10000 then
            physenv.SetPerformanceSettings({MaxVelocity = 10000})
            print("[TacRP] Increasing MaxVelocity for projectiles to behave as intended! (" .. v .. "-> 10000)")
            print("[TacRP] Disable this behavior with 'tacrp_phystweak 0'.")
        end
    end
end)