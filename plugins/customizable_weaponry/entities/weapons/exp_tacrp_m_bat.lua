local PLUGIN = PLUGIN

SWEP.Base = "exp_tacrp_base_knife"
SWEP.Spawnable = true

AddCSLuaFile()

-- names and stuff
SWEP.PrintName = "Louisville Slugger TPX"
SWEP.Category = "Tactical RP (Special)"

SWEP.SubCatTier = "9Special"
SWEP.SubCatType = "8Blunt Melee"

SWEP.Description = "Aluminum baseball bat, good for hitting home runs or cracking skulls."
SWEP.Description_Quote = "Pop quiznot How long's it take to beat a moron to death?"

SWEP.Credits = "Model & Texture: Yogensia \nAnimations: Lazarus"

SWEP.ViewModel = "models/weapons/tacint_melee/v_bat.mdl"
SWEP.WorldModel = "models/weapons/tacint_melee/w_bat.mdl"

SWEP.Slot = 0

SWEP.MeleeDamage = 40
SWEP.MeleeAttackTime = 0.42
SWEP.MeleeRange = 90
SWEP.MeleeAttackMissTime = 0.55

SWEP.MeleeDamageType = DMG_CLUB

SWEP.MeleeThrowForce = 1200

SWEP.MeleePerkStr = 0.3
SWEP.MeleePerkAgi = 0.5
SWEP.MeleePerkInt = 0.7

-- hold types

SWEP.HoldType = "melee2"
SWEP.HoldTypeSprint = "melee"

SWEP.GestureBash = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.GestureBash2 = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE

SWEP.PassiveAng = Angle(-0, 0, 0)
SWEP.PassivePos = Vector(-1, 2, -1)

SWEP.SprintAng = Angle(0, 0, 0)
SWEP.SprintPos = Vector(2, 0, -5)

SWEP.CustomizeAng = Angle(25, 20, 0)
SWEP.CustomizePos = Vector(-5, 0, -5)

SWEP.SprintMidPoint = {
	Pos = Vector(2, 0, -5),
	Ang = Angle(0, 0, 0)
}

-- sounds

local path = "tacint_shark/weapons/melee/"

SWEP.AnimationTranslationTable = {
	["deploy"] = "deploy",
	["melee"] = { "slash_left1", "slash_right1" },
	["melee2"] = "slash_forward1",
	["meleethrow"] = { "knifethrow" },
}

SWEP.DeployTimeMult = 0.85

SWEP.Sound_MeleeHit = path .. "bat_hit.wav"

SWEP.Sound_MeleeHitBody = path .. "bat_hit.wav"

SWEP.Sound_MeleeSwing = {
	"weapons/iceaxe/iceaxe_swing1.wav"
}
