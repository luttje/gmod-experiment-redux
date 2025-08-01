SWEP.Base = "tacrp_p90"
SWEP.Spawnable = true

AddCSLuaFile()

// names and stuff
SWEP.PrintName = "FN PS90"
SWEP.AbbrevName = "PS90"
SWEP.Category = "Tactical RP"

SWEP.SubCatTier = "3Security"
SWEP.SubCatType = "5Sporter Carbine"

SWEP.Description = "Semi-automatic variation of a futuristic PDW.\nUses reduced capacity magazines."

SWEP.Trivia_Caliber = "5.7x28mm"
SWEP.Trivia_Manufacturer = "FN Herstal"
SWEP.Trivia_Year = "1990"

SWEP.Faction = TacRP.FACTION_NEUTRAL
SWEP.Credits = "Assets: Tactical Intervention \nModel Edit: speedonerd (it was sooooo hard lol)"

SWEP.ViewModel = "models/weapons/tacint/v_ps90.mdl"
SWEP.WorldModel = "models/weapons/tacint/w_p90.mdl"

SWEP.Slot = 2

SWEP.BalanceStats = {
    [TacRP.BALANCE_SBOX] = {
        Description = "Semi-automatic model of a futuristic PDW. Fine tuned for precision shooting.",

        Damage_Max = 17,
        Damage_Min = 14,

        Recoil_Kick = 0.5,
        Spread = 0.001,
    },
    [TacRP.BALANCE_TTT] = {
        Description = "Semi-automatic model of a futuristic PDW. Fine tuned for precision shooting.",

        Damage_Max = 16,
        Damage_Min = 14,
        Range_Min = 1500,
        Range_Max = 2500,

        RPM = 330,

        BodyDamageMultipliers = {
            [HITGROUP_HEAD] = 3,
            [HITGROUP_CHEST] = 1.25,
            [HITGROUP_STOMACH] = 1,
            [HITGROUP_LEFTARM] = 1,
            [HITGROUP_RIGHTARM] = 1,
            [HITGROUP_LEFTLEG] = 0.75,
            [HITGROUP_RIGHTLEG] = 0.75,
            [HITGROUP_GEAR] = 0.9
        },
    },
    [TacRP.BALANCE_PVE] = {
        Description = "Semi-automatic model of a futuristic PDW. Fine tuned for precision shooting.",

        Damage_Max = 10,
        Damage_Min = 8,
        RPM = 600,

        Recoil_Kick = 0.5,
        Spread = 0.001,
    },
    [TacRP.BALANCE_OLDSCHOOL] = {
        RecoilMaximum = 20,
        RecoilSpreadPenalty = 0.003,
    }
}

SWEP.TTTReplace = {}

SWEP.Range_Min = 1200
SWEP.Range_Max = 4000

SWEP.RPM = 600
SWEP.RPMMultSemi = 0.7

SWEP.Firemode = 1
SWEP.Firemodes = false

SWEP.ClipSize = 30

SWEP.FreeAimMaxAngle = 3.25

SWEP.Attachments = {
    [1] = {
        PrintName = "Optic",
        Category = {"optic_cqb", "optic_medium", "optic_sniper"},
        Bone = "p90_ROOT",
        AttachSound = "tacrp/weapons/optic_on.wav",
        DetachSound = "tacrp/weapons/optic_off.wav",
        InstalledElements = {"optic"},
        Pos_VM = Vector(-5.2, 0, 6.5),
        Pos_WM = Vector(8, 1.5, -7),
        Ang_VM = Angle(90, 0, 0),
        Ang_WM = Angle(0, -3.5, 180),
    },
    [2] = {
        PrintName = "Muzzle",
        Category = "silencer",
        Bone = "p90_ROOT",
        AttachSound = "tacrp/weapons/silencer_on.wav",
        DetachSound = "tacrp/weapons/silencer_off.wav",
        Pos_VM = Vector(-1.85, 0, 20),
        Pos_WM = Vector(16, 2.25, -3.5),
        Ang_VM = Angle(90, 0, 0),
        Ang_WM = Angle(0, -3.5, 180),
    },
    [3] = {
        PrintName = "Tactical",
        Category = "tactical",
        Bone = "p90_ROOT",
        AttachSound = "tacrp/weapons/flashlight_on.wav",
        DetachSound = "tacrp/weapons/flashlight_off.wav",
        InstalledElements = {"rail"},
        Pos_VM = Vector(-4.35, -0.6, 7.6),
        Pos_WM = Vector(10, 1.3, -4),
        Ang_VM = Angle(90, 0, -90),
        Ang_WM = Angle(0, -3.5, -90),
    },
    [4] = {
        PrintName = "Accessory",
        Category = {"acc", "acc_sling", "acc_duffle", "acc_extmag_smg"},
        AttachSound = "tacrp/weapons/flashlight_on.wav",
        DetachSound = "tacrp/weapons/flashlight_off.wav",
    },
    [5] = {
        PrintName = "Bolt",
        Category = {"bolt_automatic"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [6] = {
        PrintName = "Trigger",
        Category = {"trigger_semi"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [7] = {
        PrintName = "Ammo",
        Category = {"ammo_rifle"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [8] = {
        PrintName = "Perk",
        Category = {"perk", "perk_melee", "perk_shooting", "perk_reload"},
        AttachSound = "tacrp/weapons/flashlight_on.wav",
        DetachSound = "tacrp/weapons/flashlight_off.wav",
    },
}