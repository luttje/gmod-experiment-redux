if (SERVER) then
	AddCSLuaFile()
end

if (CLIENT) then
    SWEP.Slot = 0
    SWEP.SlotPos = 6
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

--[[
	This is a base weapon that can be used to hide certain bones and place an alternative model in the player's hand.
]]

SWEP.PrintName = "Base Holder"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Author = "Experiment Redux"

SWEP.WorldModel = ""
SWEP.UseHands = true

SWEP.IsAlwaysRaised = true

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

-- SWEP.HoldingModel = "models/maxofs2d/lamp_flashlight.mdl"
-- SWEP.HoldingAttachmentBone = "ValveBiped.Bip01_R_Hand"
-- SWEP.HoldingAttachmentOffset = Vector(4.5 ,2.5, -.5)
-- SWEP.HoldingAttachmentAngle = Angle(5, 45, 180)
-- SWEP.HoldingAttachmentScale = 0.5

-- Hides the entire left hand and arm + detonator + slam
SWEP.ViewModel = Model("models/weapons/c_slam.mdl")
SWEP.HoldType = "slam"
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

    if (DEBUG_LIST_ALL_BONES) then
        timer.Simple(0, function()
            if (not IsValid(entity)) then
                return
            end

			for i = 0, entity:GetBoneCount() - 1 do
				print(i, entity:GetBoneName(i))
			end
		end)
	end

    local hiddenBones = {}

    for _, bone in ipairs(weapon.HiddenBones) do
        local boneIndex = entity:LookupBone(bone)

		if (boneIndex) then
			hiddenBones[#hiddenBones + 1] = boneIndex
            entity:ManipulateBoneScale(boneIndex, Vector(0, 0, 0))
            entity:ManipulateBonePosition(boneIndex, Vector(0, 0, -100))
        end
    end

    weapon.expBonesHidden = hiddenBones
	weapon.expBonesHiddenOnEntity = entity
end

local function drawHoldingModel(weapon, entity)
    if (not weapon.HoldingModel) then
        return
    end

    local boneIndex = entity:LookupBone(weapon.HoldingAttachmentBone)

    if (not boneIndex) then
        return
    end

    local matrix = entity:GetBoneMatrix(boneIndex)

    if (not matrix) then
        return
    end

    local position = matrix:GetTranslation()
    local angles = matrix:GetAngles()

    local flashlight = weapon.expHoldingClientsideModel

    if (not flashlight) then
        flashlight = ClientsideModel(weapon.HoldingModel, RENDERGROUP_BOTH)
        flashlight:SetNoDraw(true)
        weapon.expHoldingClientsideModel = flashlight
    end

    local newPosition = position + (angles:Forward() * weapon.HoldingAttachmentOffset.x)
        + (angles:Right() * weapon.HoldingAttachmentOffset.y)
        + (angles:Up() * weapon.HoldingAttachmentOffset.z)

    local newAngles = angles

    newAngles:RotateAroundAxis(angles:Right(), weapon.HoldingAttachmentAngle.p)
    newAngles:RotateAroundAxis(angles:Up(), weapon.HoldingAttachmentAngle.y)
    newAngles:RotateAroundAxis(angles:Forward(), weapon.HoldingAttachmentAngle.r)

    flashlight:SetModelScale(weapon.HoldingAttachmentScale)
    flashlight:SetPos(newPosition)
    flashlight:SetAngles(newAngles)
    flashlight:DrawModel()
end

local function cleanupHoldingAndBones(weapon)
    if (IsValid(weapon.expHoldingClientsideModel)) then
        weapon.expHoldingClientsideModel:Remove()
    end

    weapon.expHoldingClientsideModel = nil
    local entity = weapon.expBonesHiddenOnEntity

    if (weapon.expBonesHidden and IsValid(entity)) then
        for _, boneIndex in ipairs(weapon.expBonesHidden) do
            entity:ManipulateBoneScale(boneIndex, Vector(1, 1, 1))
			entity:ManipulateBonePosition(boneIndex, Vector(0, 0, 0))
        end
    end

    weapon.expBonesHidden = nil
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:PreDrawViewModel(entity, weapon, client)
    hideBonesIfNeeded(self, entity)
	drawHoldingModel(self, entity)
end

function SWEP:OnRemove()
    if (CLIENT) then
		cleanupHoldingAndBones(self)
    end
end

function SWEP:Holster()
    if (CLIENT) then
		cleanupHoldingAndBones(self)
    end

	-- This will glitch out the next weapon, so dont anim holster
	-- self:SendWeaponAnim(ACT_VM_HOLSTER)

	return true
end
