SWEP.Base = "tacrp_base"
SWEP.Spawnable = true

AddCSLuaFile()

// names and stuff
SWEP.PrintName = "C4 Detonator"
SWEP.Category = "Tactical RP (Special)"

SWEP.SubCatTier = "9Special"
SWEP.SubCatType = "9Equipment"

SWEP.Description = "Device for touching off C4 charges or other types of remote explosives."

SWEP.ViewModel = "models/weapons/tacint/v_c4.mdl"
SWEP.WorldModel = "models/weapons/tacint/w_c4_det.mdl"

SWEP.NoRanger = true
SWEP.NoStatBox = true


SWEP.ArcadeStats = {
    MeleeSpeedMult = 1,
}

SWEP.Slot = 4

SWEP.NPCUsable = false

// misc. shooting

SWEP.Firemode = 1

SWEP.RPM = 120

SWEP.CanBlindFire = false

SWEP.Ammo = "ti_c4"
SWEP.ClipSize = -1
SWEP.Primary.ClipSize = -1
SWEP.SupplyAmmoAmount = 3

// handling

SWEP.MoveSpeedMult = 1


SWEP.MeleeSpeedMultTime = 2 // seconds to apply slow down for

SWEP.SprintToFireTime = 0.25

SWEP.Scope = false

// hold types

SWEP.HoldType = "normal"
SWEP.HoldTypeSprint = "normal"

SWEP.GestureShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
SWEP.GestureReload = ACT_HL2MP_GESTURE_RELOAD_PISTOL

SWEP.PassiveAng = Angle(0, 0, 0)
SWEP.PassivePos = Vector(1, -2, -5)

SWEP.SprintAng = Angle(0, 30, 0)
SWEP.SprintPos = Vector(2, 0, -12)

SWEP.HolsterVisible = true
SWEP.HolsterSlot = TacRP.HOLSTER_SLOT_GEAR
SWEP.HolsterPos = Vector(2, 0, 0)
SWEP.HolsterAng = Angle(-90, -90, 15)

// sounds

local path = "TacRP/weapons/c4/"

SWEP.AnimationTranslationTable = {
    ["deploy"] = "deploy",
    ["melee"] = {"melee1", "melee2"}
}

// attachments

SWEP.Attachments = {
    [1] = {
        PrintName = "Accessory",
        Category = {"acc_holster"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    },
    [2] = {
        PrintName = "Perk",
        Category = {"perk_melee", "perk_throw"},
        AttachSound = "TacRP/weapons/flashlight_on.wav",
        DetachSound = "TacRP/weapons/flashlight_off.wav",
    }
}

SWEP.FreeAim = false

SWEP.AttachmentCapacity = 30 // amount of "Capacity" this gun can accept

SWEP.DrawCrosshair = false

local function addsound(name, spath)
    sound.Add({
        name = name,
        channel = 16,
        volume = 1.0,
        sound = spath
    })
end

addsound("TacInt_C4_Detonator.Detonator_Press", path .. "detonator_press.wav")
addsound("TacInt_C4_Detonator.antenna_open", path .. "antenna_open.wav")

function SWEP:PrimaryAttack()
    if self:GetValue("Melee") then
        if self:GetOwner():KeyDown(IN_USE) then
            self.Primary.Automatic = true
            self:Melee()
            return
        end
    end

    if self:StillWaiting() then return end

    self:SetBaseSettings()

    self:PlayAnimation("detonate")

    for i, k in pairs(ents.FindByClass("tacrp_proj_nade_*")) do
        if (k:GetOwner() == self:GetOwner() or k.Attacker == self:GetOwner()) and k.RemoteFuse then
            k:RemoteDetonate()
        end
    end

    self:SetNextPrimaryFire(CurTime() + (60 / self:GetValue("RPM")))
end

function SWEP:SecondaryAttack()
    local nade = self:GetOwner():GetNWInt("ti_nade")
    if nade != 11 and nade != 6 then
        self:GetOwner():SetNWInt("ti_nade", 11)
    end
    self:PrimeGrenade()
end

SWEP.AutoSpawnable = false

if engine.ActiveGamemode() == "terrortown" then
    SWEP.AutoSpawnable = false
    SWEP.HolsterVisible = false
    SWEP.Kind = WEAPON_EQUIP
    SWEP.Slot = 6
    SWEP.CanBuy = { ROLE_TRAITOR }
    SWEP.EquipMenuData = {
        type = "Weapon",
        desc = "A remote detonator for C4s and Breaching Charges.\nComes with 1 C4 and 3 Breaching Charges.",
    }

    function SWEP:TTTBought(buyer)
        buyer:GiveAmmo(1, "ti_c4")
        buyer:GiveAmmo(3, "ti_charge")
    end
end