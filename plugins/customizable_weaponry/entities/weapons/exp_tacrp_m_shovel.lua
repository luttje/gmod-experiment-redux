local PLUGIN = PLUGIN

SWEP.Base = "exp_tacrp_base_knife"
SWEP.Spawnable = true

AddCSLuaFile()

-- names and stuff
SWEP.PrintName = "Shovel"
SWEP.Category = "Tactical RP (Special)"

SWEP.SubCatTier = "9Special"
SWEP.SubCatType = "8Blunt Melee"

SWEP.Description =
"An old army shovel, designed to quickly dig trenches. Works great as a crude melee weapon, having both a blunt face and a sharp edge."
SWEP.Description_Quote = "Maggots!"

SWEP.Credits = "Assets: Day of Defeat: Source"

SWEP.ViewModel = "models/weapons/tacint_melee/v_shovel.mdl"
SWEP.WorldModel = "models/weapons/tacint_melee/w_shovel.mdl"

SWEP.Slot = 0

SWEP.MeleeDamage = 52
SWEP.MeleeAttackTime = 0.6
SWEP.MeleeRange = 90
SWEP.MeleeAttackMissTime = 0.7

SWEP.MeleeDamageType = DMG_CLUB

SWEP.MeleeThrowForce = 900

SWEP.MeleePerkStr = 0.5
SWEP.MeleePerkAgi = 0.25
SWEP.MeleePerkInt = 0.65

-- hold types

SWEP.HoldType = "melee"
SWEP.HoldTypeSprint = "knife"

SWEP.GestureShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
SWEP.GestureReload = ACT_HL2MP_GESTURE_RELOAD_PISTOL
SWEP.GestureBash = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.GestureBash2 = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE

SWEP.MidAirSpreadPenalty = 0

SWEP.PassiveAng = Angle(-4, 0, -1)
SWEP.PassivePos = Vector(1, 0, -5)

SWEP.SprintAng = Angle(0, 0, 0)
SWEP.SprintPos = Vector(2, 0, -5)

SWEP.CustomizeAng = Angle(0, 25, 0)
SWEP.CustomizePos = Vector(2, 0, -12)

SWEP.SprintMidPoint = {
  Pos = Vector(2, 0, -5),
  Ang = Angle(0, 0, 0)
}

SWEP.HolsterVisible = false
SWEP.HolsterSlot = PLUGIN.HOLSTER_SLOT_GEAR
SWEP.HolsterPos = Vector(2, 0, 0)
SWEP.HolsterAng = Angle(-90, -90, 15)

-- sounds

local path = "tacrp/weapons/knife/"
local path1 = "tacint_shark/weapons/melee/"

SWEP.AnimationTranslationTable = {
  ["deploy"] = "deploy",
  ["melee"] = { "slash_left1", "slash_left2", "slash_right1", "slash_right2" },
  ["melee2"] = { "slash_forward1", "slash_forward2" },
  ["meleethrow"] = { "knifethrow" },
}

SWEP.Sound_MeleeHit = {
  path1 .. "shovel_hitworld_1.wav",
  path1 .. "shovel_hitworld_2.wav",
  path1 .. "shovel_hitworld_3.wav",
}

SWEP.Sound_MeleeHitBody = {
  path1 .. "shovel_hitbody_1.wav",
  path1 .. "shovel_hitbody_2.wav",
  path1 .. "shovel_hitbody_3.wav",
}

SWEP.Sound_MeleeSwing = "weapons/iceaxe/iceaxe_swing1.wav"

-- attachments

SWEP.Attachments = {
  [1] = {
    PrintName = "Technique",
    Category = "melee_tech",
    AttachSound = "TacRP/weapons/flashlight_on.wav",
    DetachSound = "TacRP/weapons/flashlight_off.wav",
  },
  [2] = {
    PrintName = "Special",
    Category = "melee_spec",
    AttachSound = "TacRP/weapons/flashlight_on.wav",
    DetachSound = "TacRP/weapons/flashlight_off.wav",
  },
}

SWEP.FreeAim = false

SWEP.DrawCrosshair = true
SWEP.DrawCrosshairInSprint = true
SWEP.CrosshairStatic = true

local function addsound(name, spath)
  sound.Add({
    name = name,
    channel = 16,
    volume = 1.0,
    sound = spath
  })
end

addsound("tacint_knife2.deploy", "tacrp/magtap.ogg")

function SWEP:PrimaryAttack()
  local stop = self:RunHook("Hook_PreShoot")
  if stop then return end

  self:Melee()
  return
end

function SWEP:ThinkSprint()
end

function SWEP:ThinkSights()
end

SWEP.AutoSpawnable = false
