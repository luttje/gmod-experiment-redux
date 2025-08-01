SWEP.Base = "tacrp_base"
SWEP.Spawnable = false

AddCSLuaFile()

// names and stuff
SWEP.PrintName = "Base Knife"
SWEP.Category = "Tactical RP (Special)"

SWEP.SubCatTier = "9Special"
SWEP.SubCatType = "8Melee Weapon"

SWEP.ViewModel = "models/weapons/tacint/v_knife.mdl"
SWEP.WorldModel = "models/weapons/tacint/w_knife.mdl"

SWEP.NoRanger = true
SWEP.NoStatBox = false

SWEP.Slot = 0

SWEP.NPCUsable = false

SWEP.PrimaryMelee = true

SWEP.MeleeDamage = 35
SWEP.MeleeAttackTime = 0.4
SWEP.MeleeRange = 72
SWEP.MeleeAttackMissTime = 0.5
SWEP.MeleeDelay = 0.15

SWEP.MeleeThrowForce = 2000

SWEP.MeleeDamageType = DMG_SLASH

SWEP.MeleeRechargeRate = 1

SWEP.MeleePerkStr = 0.5
SWEP.MeleePerkAgi = 0.5
SWEP.MeleePerkInt = 0.5

SWEP.Lifesteal = 0
SWEP.DamageCharge = 0

SWEP.Firemode = 0

SWEP.RPM = 120

SWEP.CanBlindFire = false

SWEP.Ammo = ""
SWEP.ClipSize = -1
SWEP.Primary.ClipSize = -1

// handling

SWEP.MoveSpeedMult = 1

SWEP.MeleeSpeedMult = 1
SWEP.MeleeSpeedMultTime = 0.5

SWEP.SprintToFireTime = 0.25

SWEP.QuickNadeTimeMult = 0.8

SWEP.Scope = false

SWEP.Sway = 0

// hold types

SWEP.HoldType = "knife"
SWEP.HoldTypeSprint = "knife"

SWEP.GestureShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
SWEP.GestureReload = ACT_HL2MP_GESTURE_RELOAD_PISTOL
SWEP.GestureBash = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
SWEP.GestureBash2 = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE

SWEP.MidAirSpreadPenalty = 0

SWEP.PassiveAng = Angle(-2.5, 0, 0)
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
SWEP.HolsterSlot = TacRP.HOLSTER_SLOT_GEAR
SWEP.HolsterPos = Vector(2, 0, 0)
SWEP.HolsterAng = Angle(-90, -90, 15)

// attachments

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
    [3] = {
        PrintName = "Boost",
        Category = "melee_boost",
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
}

SWEP.FreeAim = false

SWEP.DrawCrosshair = true
SWEP.DrawCrosshairInSprint = true
SWEP.CrosshairStatic = true

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

function SWEP:ThinkHoldBreath()
    local ret = self:RunHook("Hook_Recharge")
    if ret then return end
    local f = 10 - math.min(self:GetValue("MeleePerkInt"), 0.5) * 2 - math.max((self:GetValue("MeleePerkInt") - 0.5) * 2, 0) * 6
    self:SetBreath(math.min(1, self:GetBreath() + FrameTime() / f * self:GetValue("MeleeRechargeRate")))
end

SWEP.NoBreathBar = false
SWEP.BreathSegmentSize = 0

local breath_a = 0
local last = 1
local lastt = 0
function SWEP:DrawBreathBar(x, y, w, h)
    if self:GetValue("NoBreathBar") then return end
    local seg = self:GetValue("BreathSegmentSize")
    if CurTime() > lastt + 1 then
        breath_a = math.Approach(breath_a, 0, FrameTime() * 2)
    elseif breath_a < 1 then
        breath_a = math.Approach(breath_a, 1, FrameTime())
    end
    local breath = self:GetBreath()
    if last != self:GetBreath() then
        lastt = CurTime()
        last = breath
    end
    if breath_a == 0 then return end

    x = x - w / 2
    y = y - h / 2

    surface.SetDrawColor(90, 90, 90, 200 * breath_a)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2, 1)
    surface.SetDrawColor(0, 0, 0, 75 * breath_a)
    surface.DrawRect(x, y, w, h)

    if seg > 0 then
        local segcount = math.ceil(1 / seg)
        surface.SetDrawColor(255, 255, 255, 200 * breath_a)
        for i = 1, segcount - 1 do
            local d = i / segcount
            surface.DrawLine(x + w * d, y, x + w * d, y + h)
        end
    end

    if seg > 0 and breath < seg then
        surface.SetDrawColor(255, 128, 0, 150 * breath_a)
    else
        surface.SetDrawColor(255, 255, 255, 150 * breath_a)
    end

    surface.DrawRect(x, y, w * breath, h)
end

function SWEP:CalcView(ply, pos, ang, fov)
    return pos, ang, fov
end

SWEP.AutoSpawnable = false