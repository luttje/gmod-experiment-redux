AddCSLuaFile()

SWEP.Base = "tacrp_base_nade"
SWEP.Spawnable = TacRP.AreTheGrenadeAnimsReadyYet
SWEP.IconOverride = "entities/tacrp_ammo_smoke.png"

// names and stuff
SWEP.PrintName = "Smoke Grenade"
SWEP.Category = "Tactical RP (Special)"

SWEP.ViewModel = "models/weapons/tacint/v_throwable_smoke.mdl"
SWEP.WorldModel = "models/weapons/tacint/w_smoke.mdl"

SWEP.ViewModelFOV = 65

SWEP.Slot = 4

SWEP.PrimaryGrenade = "smoke"

SWEP.FiremodeName = "Throw"

SWEP.AnimationTranslationTable = {
    ["prime_grenade"] = "pullpin",
    ["throw_grenade"] = "throw",
    ["throw_grenade_underhand"] = "throw",
}

SWEP.TTTReplace = {["weapon_ttt_smokegrenade"] = 1}

SWEP.Attachments = {}

SWEP.HoldType = "melee"
SWEP.HoldTypeSprint = "normal"
SWEP.HoldTypeBlindFire = false