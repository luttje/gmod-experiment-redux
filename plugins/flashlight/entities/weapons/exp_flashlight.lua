if (SERVER) then
    AddCSLuaFile()
end

DEFINE_BASECLASS("exp_base_holder")

SWEP.Base = "exp_base_holder"
SWEP.PrintName = "Flashlight"
SWEP.Instructions = "Primary Fire: Toggle."
SWEP.Purpose = "Helps you see better dark areas."

SWEP.HoldingModel = "models/maxofs2d/lamp_flashlight.mdl"
SWEP.HoldingAttachmentBone = "ValveBiped.Bip01_R_Hand"
SWEP.HoldingAttachmentOffset = Vector(4.5 ,2.5, -.5)
SWEP.HoldingAttachmentAngle = Angle(5, 45, 180)
SWEP.HoldingAttachmentScale = 0.5

function SWEP:Deploy()
    if (not SERVER or not IsValid(self.Owner)) then
        return
    end

    self.Owner:AddPart("expFlashLightWorldModelPacData")
end

function SWEP:Holster()
	BaseClass.Holster(self)

	if (not SERVER or not IsValid(self.Owner)) then
		return true
	end

    self.Owner:RemovePart("expFlashLightWorldModelPacData")

	return true
end

function SWEP:PrimaryAttack()
    if (not SERVER) then
        return
    end

	if (self.Owner:FlashlightIsOn()) then
		self.Owner:Flashlight(false)
	else
		self.Owner:Flashlight(true)
	end
end

function SWEP:SecondaryAttack() end
