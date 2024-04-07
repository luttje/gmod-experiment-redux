local PLUGIN = PLUGIN

if (SERVER) then
	AddCSLuaFile()
end

if (CLIENT) then
	SWEP.Slot = 1
	SWEP.SlotPos = 4
	SWEP.DrawAmmo = false
	SWEP.PrintName = "Tactical Goggles"
	SWEP.DrawCrosshair = true
end

SWEP.Instructions = "Primary Fire: Toggle."
SWEP.Purpose = "Stay connected with your team through radio frequencies, enhancing coordination with real-time updates."
SWEP.Contact = ""
SWEP.Author	= ""

SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""

SWEP.FireWhenLowered = true
SWEP.NeverRaised = true
SWEP.HoldType = "fist"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.Delay = 0.75

SWEP.Secondary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= ""

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:PrimaryAttack()
	if (SERVER) then
		self.Owner:ToggleTacticalGoggles()
	end

	self:SetNextPrimaryFire(CurTime() + 2)

	return false
end

function SWEP:SecondaryAttack()
end
