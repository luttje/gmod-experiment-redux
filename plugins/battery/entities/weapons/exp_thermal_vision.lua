local PLUGIN = PLUGIN

if (SERVER) then
	AddCSLuaFile()
end

if (CLIENT) then
	SWEP.Slot = 1
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = false
	SWEP.PrintName = "Thermal Vision"
	SWEP.DrawCrosshair = true
end

SWEP.Instructions = "Primary Fire: Toggle."
SWEP.Purpose = "See everyone clear as day, even if they've activated stealth cammo."
SWEP.Contact = ""
SWEP.Author = "Experiment Redux"

SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""

SWEP.FireWhenLowered = true
SWEP.NeverRaised = true
SWEP.HoldType = "fist"

SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = ""

SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Ammo	= ""

function SWEP:PrimaryAttack()
	if (SERVER) then
		self.Owner:ToggleThermal()
	end

	self:SetNextPrimaryFire(CurTime() + 2)

	return false
end

function SWEP:SecondaryAttack() end
