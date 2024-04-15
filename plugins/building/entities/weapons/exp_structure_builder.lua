local PLUGIN = PLUGIN

if (SERVER) then
	AddCSLuaFile()
end

if (CLIENT) then
	SWEP.Slot = 0
	SWEP.SlotPos = 6
	SWEP.DrawAmmo = false
	SWEP.PrintName = "Blueprint Builder"
	SWEP.DrawCrosshair = true
end

SWEP.Instructions = "Primary Fire: Build.\nSecondary Fire: Rotate (Hold Sprint-button to snap)."
SWEP.Contact = ""
SWEP.Purpose = "Construct structures."
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

local function cleanupBones(weapon)
	local entity = weapon.expBonesHiddenOnEntity

	if (weapon.expBonesHidden and IsValid(entity)) then
		for boneIndex, data in pairs(weapon.expBonesHidden) do
			entity:ManipulateBoneScale(boneIndex, data.scale)
			entity:ManipulateBonePosition(boneIndex, data.position)
		end
	end

	weapon.expBonesHidden = nil
end

local wireframeMaterial = Material("models/wireframe")

function SWEP:PreDrawViewModel(entity, weapon, client)
	hideBonesIfNeeded(self, entity)
end

function SWEP:PostDrawViewModel(entity, weapon, client)
end

hook.Add("InputMouseApply", "expStructureBuilderHandleInput", function(userCommand, x, y, angle)
	local client = LocalPlayer()
	local weapon = client:GetActiveWeapon()

    if (not IsValid(weapon) or weapon:GetClass() ~= "exp_structure_builder") then
        return
    end

	local isSpeedDown = client:KeyDown(IN_SPEED)

    if (client:KeyDown(IN_ATTACK2)) then
        userCommand:SetMouseX(0)
        userCommand:SetMouseY(0)

        local rotateY = x * FrameTime() * 10
        local rotateP = y * FrameTime() * 10

        weapon.expRotationUnboundedY = (weapon.expRotationUnboundedY or weapon.expRotation.y) + rotateY
        weapon.expRotationUnboundedP = (weapon.expRotationUnboundedP or weapon.expRotation.p) + rotateP

        weapon.expRotation.y = weapon.expRotation.y + rotateY
        weapon.expRotation.p = weapon.expRotation.p + rotateP

        if (isSpeedDown) then
            local snapAngleDegrees = 45

            weapon.expRotation.y = math.Round(weapon.expRotationUnboundedY / snapAngleDegrees) * snapAngleDegrees
            weapon.expRotation.p = math.Round(weapon.expRotationUnboundedP / snapAngleDegrees) * snapAngleDegrees
        end

        return true
    end

    -- if (client:KeyDown(IN_USE)) then
	-- 	userCommand:SetMouseX(0)
	-- 	userCommand:SetMouseY(0)

	-- 	local moveZ = -y * FrameTime() * 10
    --     local moveX = x * FrameTime() * 10

	-- 	weapon.expPositionOffset = weapon.expPositionOffset or Vector(0, 0, 0)

    --     weapon.expPositionOffset.z = math.Clamp(weapon.expPositionOffset.z + moveZ, -100, 100)
    --     weapon.expPositionOffset.x = math.Clamp(weapon.expPositionOffset.x + moveX, -100, 100)

    --     if (isSpeedDown) then
	-- 		weapon.expPositionSnap = 10
	-- 	end

    --     return true
    -- else
	-- 	weapon.expPositionSnap = nil
	-- end
end)

hook.Add("PostDrawOpaqueRenderables", "expStructureBuilderDrawStructure", function(depth, isDrawingSkybox)
	if (isDrawingSkybox) then
		return
	end

	local client = LocalPlayer()

	if (not IsValid(client)) then
		return
	end

	local weapon = client:GetActiveWeapon()

    if (not IsValid(weapon) or weapon:GetClass() ~= "exp_structure_builder") then
        return
    end

    local position, angles = PLUGIN:GetPlacementTrace(client)
    weapon.expRotation = weapon.expRotation or angles

    -- if (weapon.expPositionOffset) then
	-- 	local aim = client:EyeAngles()
    --     local offset =
	-- 		aim:Forward() * weapon.expPositionOffset.x
	-- 		-- + aim:Up() * weapon.expPositionOffset.z

    -- 	position = position + offset
	-- end

	-- Draw all the structure parts, positioning them relative to the placement trace
	for _, structure in ipairs(weapon.expClientSideModels or {}) do
		local structurePosition, structureAngles = LocalToWorld(
			structure.part.position,
			structure.part.angles,
			position,
            weapon.expRotation)

		-- if (weapon.expPositionSnap) then
		-- 	structurePosition = Vector(
		-- 		math.Round(structurePosition.x / weapon.expPositionSnap) * weapon.expPositionSnap,
		-- 		math.Round(structurePosition.y / weapon.expPositionSnap) * weapon.expPositionSnap,
		-- 		math.Round(structurePosition.z / weapon.expPositionSnap) * weapon.expPositionSnap
		-- 	)
		-- end

        weapon.expLastStructurePosition = structurePosition
		weapon.expLastStructureAngles = structureAngles

		structure.entity:SetPos(weapon.expLastStructurePosition)
		structure.entity:SetAngles(weapon.expLastStructureAngles)

		render.SuppressEngineLighting(true)
		render.MaterialOverride(wireframeMaterial)
		structure.entity:DrawModel()
		render.MaterialOverride()
		render.SuppressEngineLighting(false)
	end
end)

function SWEP:SetItemTable(itemTable)
	self.expItemTable = itemTable

	self:SetNetVar("itemID", itemTable.uniqueID)
end

function SWEP:GetItemTable()
	if (SERVER) then
		return self.expItemTable
	end

	local itemID = self:GetNetVar("itemID")

	if (not itemID) then
		return
	end

	return ix.item.list[itemID]
end

function SWEP:BuildStructureIfNotExists(client, itemTable)
	if (not CLIENT) then
		return
	end

	if (self.expStructureBuilt) then
		return
	end

	local structure = itemTable:GetStructure(client)

	self.expClientSideModels = self.expClientSideModels or {}

	for _, structurePart in ipairs(structure) do
		local structureEntity = ClientsideModel(structurePart.model, RENDERGROUP_OPAQUE)
		structureEntity:SetNoDraw(true)
		self.expClientSideModels[#self.expClientSideModels + 1] = {
			entity = structureEntity,
			part = structurePart
		}
		structureEntity:SetModel(structurePart.model)
		structureEntity:Spawn()
		structureEntity:Activate()
	end

	self.expStructureBuilt = true
end

function SWEP:Think()
	if (not CLIENT) then
		return
	end

	local itemTable = self:GetItemTable()

	if (not itemTable) then
		return
	end

	self:BuildStructureIfNotExists(client, itemTable)
end

function SWEP:OnRemove()
	if (CLIENT) then
		if (IsValid(self.Owner)) then
			cleanupBones(self)
		end

		for _, structure in ipairs(self.expClientSideModels or {}) do
			structure.entity:Remove()
		end
	end
end

function SWEP:Holster()
    local client = self.Owner

	self:SendWeaponAnim(ACT_VM_HOLSTER)

	if (CLIENT and IsValid(client)) then
		cleanupBones(self)
	end

    -- if (not SERVER or not IsValid(client)) then
    --     return true
    -- end

	-- local character = client:GetCharacter()
	-- local uniqueID = self:GetNetVar("itemID")
    -- local item = character:GetInventory():HasItem(uniqueID)

    -- if (not item) then
    --     client:Notify("You do not have the required blueprint.")
	-- 	client:StripWeapon(self:GetClass())
    --     return true
    -- end

	-- -- Would unequp the item
	-- -- item:Unequip(client, true)

	return true
end

function SWEP:PrimaryAttack()
	if (SERVER) then
		return
	end

	PLUGIN:RequestBuildStructure(self.expLastStructurePosition, self.expLastStructureAngles)
end

function SWEP:SecondaryAttack()
	if (not SERVER) then
		return
	end
end
