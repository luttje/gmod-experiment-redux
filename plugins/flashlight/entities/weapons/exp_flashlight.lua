if (SERVER) then
	AddCSLuaFile()
end

if (CLIENT) then
	SWEP.Slot = 0
	SWEP.SlotPos = 6
	SWEP.DrawAmmo = false
	SWEP.PrintName = "Flashlight"
	SWEP.DrawCrosshair = true
end

SWEP.Instructions = "Primary Fire: Toggle."
SWEP.Contact = ""
SWEP.Purpose = "Helps you see better dark areas."
SWEP.Author = "Experiment Redux"

SWEP.ViewModel = Model("models/weapons/c_slam.mdl")
SWEP.WorldModel = ""
SWEP.UseHands = true

SWEP.IsAlwaysRaised = true
SWEP.HoldType = "slam"

SWEP.AdminSpawnable = false
SWEP.Spawnable = false

SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = ""

SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Ammo = ""

SWEP.FlashlightModel = "models/maxofs2d/lamp_flashlight.mdl"
SWEP.FlashlightAttachmentBone = "ValveBiped.Bip01_R_Hand"
SWEP.FlashlightAttachmentOffset = Vector(4.5 ,2.5, -.5)
SWEP.FlashlightAttachmentAngle = Angle(5, 45, 180)
SWEP.FlashlightAttachmentScale = 0.5

-- Hide the entire left hand and arm + detonator + slam
SWEP.HiddenBones = {
	"ValveBiped.Bip01_L_Clavicle",
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_L_Finger4",
	"ValveBiped.Bip01_L_Finger41",
	"ValveBiped.Bip01_L_Finger42",
	"ValveBiped.Bip01_L_Finger3",
	"ValveBiped.Bip01_L_Finger31",
	"ValveBiped.Bip01_L_Finger32",
	"ValveBiped.Bip01_L_Finger2",
	"ValveBiped.Bip01_L_Finger21",
	"ValveBiped.Bip01_L_Finger22",
	"ValveBiped.Bip01_L_Finger1",
	"ValveBiped.Bip01_L_Finger11",
	"ValveBiped.Bip01_L_Finger12",
	"ValveBiped.Bip01_L_Finger0",
	"ValveBiped.Bip01_L_Finger01",
	"ValveBiped.Bip01_L_Finger02",
	"Detonator",
	"Slam_base",
	"Slam_panel"
}

local function hideBonesIfNeeded(weapon, entity)
    if (weapon.expBonesHidden) then
        return
    end

    local bonesBefore = {}

    for _, bone in ipairs(weapon.HiddenBones) do
        local boneIndex = entity:LookupBone(bone)

        if (boneIndex) then
            bonesBefore[boneIndex] = {
                scale = entity:GetManipulateBoneScale(boneIndex),
                position = entity:GetManipulateBonePosition(boneIndex)
            }

            entity:ManipulateBoneScale(boneIndex, Vector(0, 0, 0))
            entity:ManipulateBonePosition(boneIndex, Vector(0, 0, -100))
        end
    end

    weapon.expBonesHidden = bonesBefore
	weapon.expBonesHiddenOnEntity = entity
end

local function drawFlashlightModel(weapon, entity)
    -- Draw the flashlight model on the right hand attachment
    local boneIndex = entity:LookupBone(weapon.FlashlightAttachmentBone)

    if (not boneIndex) then
        return
    end

    local matrix = entity:GetBoneMatrix(boneIndex)

    if (not matrix) then
        return
    end

    local position = matrix:GetTranslation()
    local angles = matrix:GetAngles()

    local flashlight = weapon.expFlashlightClientsideModel

    if (not flashlight) then
        flashlight = ClientsideModel(weapon.FlashlightModel, RENDERGROUP_BOTH)
        flashlight:SetNoDraw(true)
        weapon.expFlashlightClientsideModel = flashlight
    end

    local newPosition = position + (angles:Forward() * weapon.FlashlightAttachmentOffset.x)
        + (angles:Right() * weapon.FlashlightAttachmentOffset.y)
        + (angles:Up() * weapon.FlashlightAttachmentOffset.z)

    local newAngles = angles

    newAngles:RotateAroundAxis(angles:Right(), weapon.FlashlightAttachmentAngle.p)
    newAngles:RotateAroundAxis(angles:Up(), weapon.FlashlightAttachmentAngle.y)
    newAngles:RotateAroundAxis(angles:Forward(), weapon.FlashlightAttachmentAngle.r)

    flashlight:SetModelScale(weapon.FlashlightAttachmentScale)
    flashlight:SetPos(newPosition)
    flashlight:SetAngles(newAngles)
    flashlight:DrawModel()
end

local function cleanupFlashlightAndBones(weapon)
	if (IsValid(weapon.expFlashlightClientsideModel)) then
		weapon.expFlashlightClientsideModel:Remove()
	end

	weapon.expFlashlightClientsideModel = nil
	local entity = weapon.expBonesHiddenOnEntity

    if (weapon.expBonesHidden and IsValid(entity)) then
		for boneIndex, data in pairs(weapon.expBonesHidden) do
			entity:ManipulateBoneScale(boneIndex, data.scale)
			entity:ManipulateBonePosition(boneIndex, data.position)
		end
	end

	weapon.expBonesHidden = nil
end

function SWEP:PreDrawViewModel(entity, weapon, client)
    hideBonesIfNeeded(self, entity)
	drawFlashlightModel(self, entity)
end

function SWEP:Deploy()
    if (not SERVER or not IsValid(self.Owner)) then
        return
    end

    self.Owner:AddPart("expFlashLightWorldModelPacData")
end

function SWEP:OnRemove()
    if (CLIENT and IsValid(self.Owner)) then
		cleanupFlashlightAndBones(self)
    end
end

function SWEP:Holster()
	self:SendWeaponAnim(ACT_VM_HOLSTER)

    if (CLIENT and IsValid(self.Owner)) then
		cleanupFlashlightAndBones(self)
    end

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
