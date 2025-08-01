local PLUGIN = PLUGIN

AddCSLuaFile()

SWEP.Base = "exp_tacrp_base_nade"
SWEP.Spawnable = PLUGIN.AreTheGrenadeAnimsReadyYet
SWEP.IconOverride = "entities/tacrp_ammo_gas.png"

-- names and stuff
SWEP.PrintName = "CS Gas Grenade"
SWEP.Category = "Tactical RP (Special)"

SWEP.ViewModel = "models/weapons/tacint/v_throwable_csgas.mdl"
SWEP.WorldModel = "models/weapons/tacint/w_smoke.mdl"

SWEP.ViewModelFOV = 65

SWEP.Slot = 4

SWEP.PrimaryGrenade = "gas"

SWEP.FiremodeName = "Throw"

SWEP.AnimationTranslationTable = {
	["prime_grenade"] = "pullpin",
	["throw_grenade"] = "throw",
	["throw_grenade_underhand"] = "throw",
}


SWEP.Attachments = {}

SWEP.HoldType = "melee"
SWEP.HoldTypeSprint = "normal"
SWEP.HoldTypeBlindFire = false
