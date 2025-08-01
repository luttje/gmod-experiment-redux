if engine.ActiveGamemode() != "terrortown" then return end

AddCSLuaFile()

SWEP.HoldType               = "normal"


if CLIENT then
   SWEP.PrintName           = "tacrp_bench_name"
   SWEP.Slot                = 6

   SWEP.ViewModelFOV        = 10
   SWEP.DrawCrosshair       = false

   LANG.AddToLanguage("english", "tacrp_bench_name", "Customization Bench")
   LANG.AddToLanguage("english", "tacrp_bench_help", "{primaryfire} places the Customization Bench.")
   LANG.AddToLanguage("english", "tacrp_bench_desc", [[
When near, allows for free weapon customization.
Attachments won't be required.]])

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "tacrp_bench_desc"
   };

   SWEP.Icon                = "vgui/ttt/tacrp_bench"
end

SWEP.Base                   = "weapon_tttbase"

SWEP.ViewModel              = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel             = "models/weapons/tacint/ammoboxes/ammo_box-2b.mdl"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"
SWEP.Primary.Delay          = 1.0

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.Delay        = 1.0

-- This is special equipment
SWEP.Kind                   = WEAPON_EQUIP
SWEP.CanBuy                 = {ROLE_DETECTIVE, ROLE_TRAITOR}
SWEP.LimitedStock           = false -- only buyable once

SWEP.AllowDrop              = false
SWEP.NoSights               = true

function SWEP:OnDrop()
   self:Remove()
end

function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self:HealthDrop()
end
function SWEP:SecondaryAttack()
   self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
   self:HealthDrop()
end

local throwsound = Sound( "Weapon_SLAM.SatchelThrow" )

-- ye olde droppe code
function SWEP:HealthDrop()
   if SERVER then
      local ply = self:GetOwner()
      if not IsValid(ply) then return end

      if self.Planted then return end

      local vsrc = ply:GetShootPos()
      local vang = ply:GetAimVector()
      local vvel = ply:GetVelocity()

      local vthrow = vvel + vang * 50

      local health = ents.Create("tacrp_bench")
      if IsValid(health) then
         health:SetPos(vsrc + vang * 24)
         health:SetAngles(Angle(0, ply:GetAngles().y, 0))
         health:Spawn()

         -- health:SetPlacer(ply)

         health:PhysWake()
         local phys = health:GetPhysicsObject()
         if IsValid(phys) then
            phys:SetVelocity(vthrow)
         end
         self:Remove()

         self.Planted = true
      end
   end

   self:EmitSound(throwsound)
end


function SWEP:Reload()
   return false
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self:GetOwner()) and self:GetOwner() == LocalPlayer() and self:GetOwner():Alive() then
      RunConsoleCommand("lastinv")
   end
end

if CLIENT then
   function SWEP:Initialize()
      self:AddHUDHelp("tacrp_bench_help", nil, true)

      return self.BaseClass.Initialize(self)
   end
end

function SWEP:Deploy()
   if SERVER and IsValid(self:GetOwner()) then
      self:GetOwner():DrawViewModel(false)
   end
   return true
end

function SWEP:DrawWorldModel()
end

function SWEP:DrawWorldModelTranslucent()
end