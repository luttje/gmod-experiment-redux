local PLUGIN = PLUGIN

AddCSLuaFile()

SWEP.Base = "exp_tacrp_base_nade"
SWEP.Spawnable = PLUGIN.AreTheGrenadeAnimsReadyYet
SWEP.IconOverride = "entities/tacrp_ammo_frag.png"

-- names and stuff
SWEP.PrintName = "Frag Grenade"
SWEP.Category = "Tactical RP (Special)"

SWEP.ViewModel = "models/weapons/tacint/v_throwable_frag.mdl"
SWEP.WorldModel = "models/weapons/tacint/w_frag.mdl"

SWEP.ViewModelFOV = 65

SWEP.Slot = 4

SWEP.PrimaryGrenade = "frag"

SWEP.FiremodeName = "Throw"

SWEP.AnimationTranslationTable = {
	["prime_grenade"] = "pullpin",
	["throw_grenade"] = "throw",
	["throw_grenade_underhand"] = "throw",
}

SWEP.AutoSpawnable = false

SWEP.Attachments = {}

SWEP.HoldType = "melee"
SWEP.HoldTypeSprint = "normal"
SWEP.HoldTypeBlindFire = false
