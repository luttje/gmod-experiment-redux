SWEP.Base = "tacrp_base"
SWEP.Spawnable = true

AddCSLuaFile()

// names and stuff
SWEP.PrintName = "AI AS50"
SWEP.AbbrevName = "AS50"
SWEP.Category = "Tactical RP"

SWEP.SubCatTier = "1Elite"
SWEP.SubCatType = "9Anti-Materiel Rifle"

SWEP.Description = "Semi-automatic anti-materiel rifle that can easily decimate any person at any distance.\nEquipped with a 12x scope by default.\nFar too heavy to swing, so bashing is out of the question."

SWEP.Trivia_Caliber = ".50 BMG"
SWEP.Trivia_Manufacturer = "Accuracy International"
SWEP.Trivia_Year = "2005"

SWEP.Faction = TacRP.FACTION_COALITION
SWEP.Credits = "Assets: Tactical Intervention"

SWEP.ViewModel = "models/weapons/tacint/v_as50_hq.mdl"
SWEP.WorldModel = "models/weapons/tacint/w_as50.mdl"

SWEP.Slot = 2
SWEP.SlotAlt = 3

SWEP.BalanceStats = {
    [TacRP.BALANCE_SBOX] = {
        Description = "Semi-automatic anti-materiel rifle with integral bipod.\nEquipped with a 12x scope by default.\nFar too heavy to swing, so bashing is out of the question.",

        Damage_Max = 70,
        Damage_Min = 140,

        Range_Min = 900,
        Range_Max = 5000,
    },
    [TacRP.BALANCE_TTT] = { // this is a buyable weapon in TTT
        Description = "Semi-automatic anti-materiel rifle with integral bipod.\nCan kill in up to 2 shots regardless of distance.\nEquipped with a 12x scope by default.",

        Damage_Max = 80,
        Damage_Min = 150,
        Range_Min = 500,
        Range_Max = 4000,
        RPM = 180,

        Penetration = 50,

        BodyDamageMultipliers = {
            [HITGROUP_HEAD] = 5,
            [HITGROUP_CHEST] = 1.25,
            [HITGROUP_STOMACH] = 1,
            [HITGROUP_LEFTARM] = 1,
            [HITGROUP_RIGHTARM] = 1,
            [HITGROUP_LEFTLEG] = 0.675,
            [HITGROUP_RIGHTLEG] = 0.675,
            [HITGROUP_GEAR] = 0.6
        },
    },
    [TacRP.BALANCE_PVE] = {
        Description = "Semi-automatic anti-materiel rifle with integral bipod.\nEquipped with a 12x scope by default.",

        Damage_Max = 120,
        Damage_Min = 92,
        Range_Min = 4000,
        Range_Max = 8000,
    },
    [TacRP.BALANCE_OLDSCHOOL] = {
        RecoilDissipationRate = 3,
        RecoilMaximum = 20,
        RecoilSpreadPenalty = 0.03,

        HipFireSpreadPenalty = 0.025,
    }
}

// "ballistics"

SWEP.Damage_Max = 150
SWEP.Damage_Min = 110
SWEP.Range_Min = 1200
SWEP.Range_Max = 8000
SWEP.Penetration = 30
SWEP.ArmorPenetration = 1.5
SWEP.ArmorBonus = 6

SWEP.BodyDamageMultipliers = {
    [HITGROUP_HEAD] = 5, // nobody is surviving this
    [HITGROUP_CHEST] = 1,
    [HITGROUP_STOMACH] = 1,
    [HITGROUP_LEFTARM] = 1,
    [HITGROUP_RIGHTARM] = 1,
    [HITGROUP_LEFTLEG] = 0.9,
    [HITGROUP_RIGHTLEG] = 0.9,
    [HITGROUP_GEAR] = 0.75
}

SWEP.MuzzleVelocity = 20000

// misc. shooting

SWEP.Firemode = 1

SWEP.RPM = 200

SWEP.Spread = 0
SWEP.RecoilSpreadPenalty = 0.075
SWEP.HipFireSpreadPenalty = 0.1
SWEP.PeekPenaltyFraction = 0.2

SWEP.RecoilPerShot = 1
SWEP.RecoilMaximum = 2
SWEP.RecoilResetTime = 0.25
SWEP.RecoilDissipationRate = 3
SWEP.RecoilFirstShotMult = 1
// SWEP.RecoilCrouchMult = 0.25

SWEP.RecoilVisualKick = 4
SWEP.RecoilKick = 12
SWEP.RecoilStability = 0.6

SWEP.CanBlindFire = true

// handling

SWEP.MoveSpeedMult = 0.85
SWEP.ShootingSpeedMult = 0.4
SWEP.SightedSpeedMult = 0.5

SWEP.ReloadSpeedMult = 0.2

SWEP.AimDownSightsTime = 0.75
SWEP.SprintToFireTime = 0.65 // multiplies how long it takes to recover from sprinting

SWEP.Sway = 3
SWEP.ScopedSway = 0.25
// SWEP.SwayCrouchMult = 0.15

SWEP.FreeAimMaxAngle = 10

SWEP.Bipod = true
SWEP.BipodRecoil = 0.25
SWEP.BipodKick = 0.35

// hold types

SWEP.HoldType = "ar2"
SWEP.HoldTypeSprint = "passive"
SWEP.HoldTypeBlindFire = false

SWEP.GestureShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW
SWEP.GestureReload = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.PassiveAng = Angle(0, 0, 0)
SWEP.PassivePos = Vector(2, -2, -6)

SWEP.BlindFireAng = Angle(0, 15, 0)
SWEP.BlindFirePos = Vector(2, -2, -4)

SWEP.BlindFireSuicideAng = Angle(0, 135, 0)
SWEP.BlindFireSuicidePos = Vector(-3, 47, -29)

SWEP.CustomizeAng = Angle(50, 15, 0)
SWEP.CustomizePos = Vector(12, 6, -8)

SWEP.SprintAng = Angle(40, -15, 0)
SWEP.SprintPos = Vector(5, 0, -4)

SWEP.SightAng = Angle(0, 0, 0)
SWEP.SightPos = Vector(-4.485, -7.5, -5.16)

SWEP.CorrectivePos = Vector(0.03, 0, 0.1)
SWEP.CorrectiveAng = Angle(0, 0, 0)

SWEP.HolsterVisible = true
SWEP.HolsterSlot = TacRP.HOLSTER_SLOT_BACK2
SWEP.HolsterPos = Vector(5, 4, -6)
SWEP.HolsterAng = Angle(0, 0, 0)

// scope

SWEP.Scope = true
SWEP.ScopeOverlay = Material("tacrp/scopes/sniper.png", "mips smooth") // Material("path/to/overlay")
SWEP.ScopeFOV = 90 / 12
SWEP.ScopeLevels = 1 // 2 = like CS:S
SWEP.ScopeHideWeapon = true

SWEP.CanMeleeAttack = false

// reload

SWEP.ClipSize = 5
SWEP.Ammo = "357"
SWEP.AmmoTTT = "ti_sniper"

SWEP.ReloadTimeMult = 1
SWEP.DropMagazineImpact = "metal"
SWEP.DropMagazineModel = "models/weapons/tacint/magazines/uratio.mdl"

SWEP.ReloadUpInTime = 2.2
SWEP.DropMagazineTime = 0.8

// sounds

local path = "TacRP/weapons/as50/"

SWEP.Sound_Shoot = "^" .. path .. "fire-1.wav"
SWEP.Sound_Shoot_Silenced = path .. "fire_silenced-1.wav"

SWEP.Vol_Shoot = 130
SWEP.ShootPitchVariance = 2.5 // amount to vary pitch by each shot

// effects

// the .qc attachment for the muzzle
SWEP.QCA_Muzzle = 1
// ditto for shell
SWEP.QCA_Eject = 2

SWEP.MuzzleEffect = "muzzleflash_1" // "muzzleflash_m82"
SWEP.EjectEffect = 2

// anims

SWEP.AnimationTranslationTable = {
    ["deploy"] = "draw",
    ["fire"] = {"shoot1", "shoot2"},
    ["blind_fire"] = {"blind_shoot1", "blind_shoot2"}
}

// attachments

SWEP.AttachmentElements = {
    ["optic"] = {
        BGs_VM = {
            {1, 1}
        },
        BGs_WM = {
            {1, 1}
        },
        SortOrder = 1
    },
    ["irons"] = {
        BGs_VM = {
            {1, 2}
        },
        SortOrder = 2
    },
}

SWEP.Attachments = {
    [1] = {
        PrintName = "Optic",
        Category = {"ironsights_sniper", "optic_cqb", "optic_medium", "optic_sniper"},
        Bone = "ValveBiped._ROOT_AS50",
        WMBone = "Box01",
        AttachSound = "TacRP/weapons/optic_on.wav",
        DetachSound = "TacRP/weapons/optic_off.wav",
        InstalledElements = {"optic"},
        Pos_VM = Vector(-6.4, -0.1, 7),
        Ang_VM = Angle(90, 0, 0),
        Pos_WM = Vector(0, 5, 1.75),
        Ang_WM = Angle(0, -90, 0),
    },
    [2] = {
        PrintName = "Muzzle",
        Category = "barrel",
        Bone = "ValveBiped._ROOT_AS50",
        AttachSound = "tacrp/weapons/silencer_on.wav",
        DetachSound = "tacrp/weapons/silencer_off.wav",
        Pos_VM = Vector(-3.7, 0, 18.5),
        Ang_VM = Angle(90, 0, 0),
        Pos_WM = Vector(23, 1, -4.5),
        Ang_WM = Angle(0, 0, 180),
    },
    [3] = {
        PrintName = "Tactical",
        Category = "tactical",
        Bone = "ValveBiped._ROOT_AS50",
        WMBone = "Box01",
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
        InstalledElements = {"tactical"},
        VMScale = 1.25,
        Pos_VM = Vector(-4, -1.6, 18),
        Pos_WM = Vector(1.5, 16, -0.5),
        Ang_VM = Angle(90, 0, -90),
        Ang_WM = Angle(0, -90, -90),
    },
    [4] = {
        PrintName = "Accessory",
        Category = {"acc", "acc_extmag_sniper", "acc_sling", "acc_duffle"},
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
        Category = {"ammo_amr"},
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

local function addsound(name, spath)
    sound.Add({
        name = name,
        channel = 16,
        volume = 1.0,
        sound = spath
    })
end

addsound("TacInt_as50.Clip_Out", path .. "clip_out.wav")
addsound("TacInt_as50.Clip_In", path .. "clip_in.wav")
addsound("TacInt_as50.Bolt_Back", path .. "bolt_back.wav")
addsound("TacInt_as50.bolt_forward", path .. "bolt_forward.wav")

if engine.ActiveGamemode() == "terrortown" then
    SWEP.AutoSpawnable = false
    SWEP.Kind = WEAPON_HEAVY
    SWEP.CanBuy = { ROLE_TRAITOR, ROLE_DETECTIVE }
    SWEP.EquipMenuData = {
        type = "Weapon",
        desc = "Semi-automatic anti-materiel rifle.\nComes with 10 rounds.\n\nBEWARE: May be visible while holstered!",
    }

    function SWEP:TTTBought(buyer)
        buyer:GiveAmmo(5, "ti_sniper")
    end
end