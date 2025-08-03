--[[
	Based on this code:
	https://steamcommunity.com/sharedfiles/filedetails/?id=476160373
--]]

AddCSLuaFile()

SWEP.PrintName = "Base Melee"
SWEP.Author = "Experiment Redux"
SWEP.Purpose = "Base weapon for melee weapons with custom models"
SWEP.Instructions = "Left click to attack"

SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.Category = "Base Weapons"
SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 70
SWEP.ViewModelElements = {}
SWEP.WorldModelElements = {}
SWEP.ViewModelBoneModifications = {}
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false
SWEP.HitDistance = 48

-- Sounds
SWEP.SwingSound = Sound("WeaponFrag.Throw")
SWEP.HitSound = Sound("Flesh.ImpactHard")

-- Animation sequences
SWEP.AttackAnimations = { "fists_left", "fists_right" }
SWEP.IdleAnimations = { "fists_idle_01", "fists_idle_02" }
SWEP.DeployAnimation = "fists_draw"

-- Basic attack settings
SWEP.AttackDamage = { 8, 12 }
SWEP.AttackDelay = 0.2
SWEP.AttackCooldown = 0.1

local tableFullCopy

--- Fully copies the table, meaning all tables, vectors and angles inside this table are copied too and so on
--- (normal table.Copy copies only their reference). Does not copy entities, only copies their reference.
--- WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
function tableFullCopy(sourceTable)
	if (not sourceTable) then return nil end

	local result = {}
	for key, value in pairs(sourceTable) do
		if (type(value) == "table") then
			result[key] = tableFullCopy(value) -- recursion
		elseif (type(value) == "Vector") then
			result[key] = Vector(value.x, value.y, value.z)
		elseif (type(value) == "Angle") then
			result[key] = Angle(value.p, value.y, value.r)
		else
			result[key] = value
		end
	end

	return result
end

function SWEP:Initialize()
	self:SetHoldType("fist")

	if (not CLIENT) then
		return
	end

	-- Create a new table for every weapon instance
	self.ViewModelElements = tableFullCopy(self.ViewModelElements)
	self.WorldModelElements = tableFullCopy(self.WorldModelElements)
	self.ViewModelBoneModifications = tableFullCopy(self.ViewModelBoneModifications)

	self:CreateModels(self.ViewModelElements)
	self:CreateModels(self.WorldModelElements)

	-- Init view model bone build function
	if (IsValid(self:GetOwner())) then
		local viewModel = self:GetOwner():GetViewModel()
		if (IsValid(viewModel)) then
			self:ResetBonePositions(viewModel)

			-- Init viewmodel visibility
			if (self.ShowViewModel == nil or self.ShowViewModel) then
				viewModel:SetColor(Color(255, 255, 255, 255))
			else
				viewModel:SetColor(Color(255, 255, 255, 0))
			end
		end
	end
end

function SWEP:Holster()
	if (CLIENT and IsValid(self:GetOwner())) then
		local viewModel = self:GetOwner():GetViewModel()
		if (IsValid(viewModel)) then
			self:ResetBonePositions(viewModel)
		end
	end

	self:SetNextMeleeAttack(0)
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", "NextMeleeAttack")
	self:NetworkVar("Float", "NextIdle")
end

function SWEP:UpdateNextIdle()
	local viewModel = self:GetOwner():GetViewModel()
	self:SetNextIdle(CurTime() + viewModel:SequenceDuration() / viewModel:GetPlaybackRate())
end

function SWEP:PrimaryAttack()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	local randomAttack = math.random(0, 1)
	local animationName = ""

	if (randomAttack == 1) then
		animationName = self.AttackAnimations[2] -- right attack
	else
		animationName = self.AttackAnimations[1] -- left attack
	end

	local viewModel = self:GetOwner():GetViewModel()
	viewModel:SendViewModelMatchingSequence(viewModel:LookupSequence(animationName))

	self:EmitSound(self.SwingSound)

	self:UpdateNextIdle()
	self:SetNextMeleeAttack(CurTime() + self.AttackDelay)
	self:SetNextPrimaryFire(CurTime() + self.AttackCooldown)
	self:SetNextSecondaryFire(CurTime() + 0)
end

function SWEP:DealDamage()
	local physicsForceScale = GetConVar("phys_pushscale")

	self:GetOwner():LagCompensation(true)

	local trace = util.TraceLine({
		start = self:GetOwner():GetShootPos(),
		endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.HitDistance,
		filter = self:GetOwner(),
		mask = MASK_SHOT_HULL
	})

	if (not IsValid(trace.Entity)) then
		trace = util.TraceHull({
			start = self:GetOwner():GetShootPos(),
			endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.HitDistance,
			filter = self:GetOwner(),
			mins = Vector(-10, -10, -8),
			maxs = Vector(10, 10, 8),
			mask = MASK_SHOT_HULL
		})
	end

	-- We need the second part for single player because SWEP:Think is ran shared in SP
	if (trace.Hit and not (game.SinglePlayer() and CLIENT)) then
		self:EmitSound(self.HitSound)
	end

	local scale = physicsForceScale:GetFloat()

	if (SERVER and IsValid(trace.Entity) and (trace.Entity:IsNPC() or trace.Entity:IsPlayer() or trace.Entity:Health() > 0)) then
		local damageInfo = DamageInfo()

		local attacker = self:GetOwner()
		if (not IsValid(attacker)) then attacker = self end
		damageInfo:SetAttacker(attacker)
		damageInfo:SetInflictor(self)

		-- Basic damage calculation
		damageInfo:SetDamage(math.random(self.AttackDamage[1], self.AttackDamage[2]))
		damageInfo:SetDamageForce(self:GetOwner():GetUp() * 4912 * scale +
			self:GetOwner():GetForward() * 9998 * scale)

		SuppressHostEvents(NULL) -- Let the breakable gibs spawn in multiplayer on client
		trace.Entity:TakeDamageInfo(damageInfo)
		SuppressHostEvents(self:GetOwner())
	end

	-- Apply physics force to objects
	if (IsValid(trace.Entity)) then
		local physicsObject = trace.Entity:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:ApplyForceOffset(self:GetOwner():GetAimVector() * 800 * physicsObject:GetMass() * scale,
				trace.HitPos)
		end
	end

	self:GetOwner():LagCompensation(false)
end

function SWEP:Deploy()
	local speed = GetConVar("sv_defaultdeployspeed"):GetInt()

	local viewModel = self:GetOwner():GetViewModel()
	viewModel:SendViewModelMatchingSequence(viewModel:LookupSequence(self.DeployAnimation))
	viewModel:SetPlaybackRate(speed)

	self:SetNextPrimaryFire(CurTime() + viewModel:SequenceDuration() / speed)
	self:SetNextSecondaryFire(CurTime() + viewModel:SequenceDuration() / speed)
	self:UpdateNextIdle()

	return true
end

function SWEP:Think()
	local viewModel = self:GetOwner():GetViewModel()
	local idleTime = self:GetNextIdle()
	local currentTime = CurTime()

	if (idleTime > 0 and currentTime > idleTime) then
		local randomIdle = math.random(1, #self.IdleAnimations)
		viewModel:SendViewModelMatchingSequence(viewModel:LookupSequence(self.IdleAnimations[randomIdle]))
		self:UpdateNextIdle()
	end

	local meleeTime = self:GetNextMeleeAttack()
	if (meleeTime > 0 and currentTime > meleeTime) then
		self:DealDamage()
		self:SetNextMeleeAttack(0)
	end

	if (CLIENT) then
		self:ViewModelDrawn()
	end
end

function SWEP:SecondaryAttack()
	-- Override this in derived weapons
end

if (CLIENT) then
	SWEP.viewRenderOrder = nil

	function SWEP:ViewModelDrawn()
		local viewModel = self:GetOwner():GetViewModel()

		if (not IsValid(viewModel)) then return end
		if (not self.ViewModelElements) then return end

		self:UpdateBonePositions(viewModel)

		if (not self.viewRenderOrder) then
			-- we build a render order because sprites need to be drawn after models
			self.viewRenderOrder = {}

			for key, element in pairs(self.ViewModelElements) do
				if (element.type == "Model") then
					table.insert(self.viewRenderOrder, 1, key)
				elseif (element.type == "Sprite" or element.type == "Quad") then
					table.insert(self.viewRenderOrder, key)
				end
			end
		end

		for _, name in ipairs(self.viewRenderOrder) do
			local element = self.ViewModelElements[name]
			if (not element) then
				self.viewRenderOrder = nil
				break
			end
			if (element.hide) then continue end

			local model = element.modelEnt
			local sprite = element.spriteMaterial

			if (not element.bone) then continue end

			local position, angle = self:GetBoneOrientation(self.ViewModelElements, element, viewModel)
			if (not position) then continue end

			if (element.type == "Model" and IsValid(model)) then
				model:SetPos(
					position + angle:Forward() * element.pos.x + angle:Right() * element.pos.y
					+ angle:Up() * element.pos.z
				)
				angle:RotateAroundAxis(angle:Up(), element.angle.y)
				angle:RotateAroundAxis(angle:Right(), element.angle.p)
				angle:RotateAroundAxis(angle:Forward(), element.angle.r)

				model:SetAngles(angle)
				local matrix = Matrix()
				matrix:Scale(element.size)
				model:EnableMatrix("RenderMultiply", matrix)

				if (element.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() ~= element.material) then
					model:SetMaterial(element.material)
				end

				if (element.skin and element.skin ~= model:GetSkin()) then
					model:SetSkin(element.skin)
				end

				if (element.bodygroup) then
					for bodyGroupIndex, bodyGroupValue in pairs(element.bodygroup) do
						if (model:GetBodygroup(bodyGroupIndex) ~= bodyGroupValue) then
							model:SetBodygroup(bodyGroupIndex, bodyGroupValue)
						end
					end
				end

				if (element.suppressLighting) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(element.color.r / 255, element.color.g / 255, element.color.b / 255)
				render.SetBlend(element.color.a / 255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (element.suppressLighting) then
					render.SuppressEngineLighting(false)
				end
			elseif (element.type == "Sprite" and sprite) then
				local drawPosition = position + angle:Forward() * element.pos.x + angle:Right() * element.pos.y +
					angle:Up() * element.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawPosition, element.size.x, element.size.y, element.color)
			elseif (element.type == "Quad" and element.draw_func) then
				local drawPosition = position + angle:Forward() * element.pos.x + angle:Right() * element.pos.y +
					angle:Up() * element.pos.z
				angle:RotateAroundAxis(angle:Up(), element.angle.y)
				angle:RotateAroundAxis(angle:Right(), element.angle.p)
				angle:RotateAroundAxis(angle:Forward(), element.angle.r)

				cam.Start3D2D(drawPosition, angle, element.size)
				element.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	SWEP.worldRenderOrder = nil

	function SWEP:DrawWorldModel()
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end

		if (not self.WorldModelElements) then
			return
		end

		if (not self.worldRenderOrder) then
			self.worldRenderOrder = {}

			for key, element in pairs(self.WorldModelElements) do
				if (element.type == "Model") then
					table.insert(self.worldRenderOrder, 1, key)
				elseif (element.type == "Sprite" or element.type == "Quad") then
					table.insert(self.worldRenderOrder, key)
				end
			end
		end

		-- when the weapon is dropped
		local boneEntity = self

		if (IsValid(self:GetOwner())) then
			boneEntity = self:GetOwner()
		end

		for _, name in pairs(self.worldRenderOrder) do
			local element = self.WorldModelElements[name]

			if (not element) then
				self.worldRenderOrder = nil
				break
			end

			if (element.hide) then
				continue
			end

			local position, angle

			if (element.bone) then
				position, angle = self:GetBoneOrientation(self.WorldModelElements, element, boneEntity)
			else
				position, angle = self:GetBoneOrientation(self.WorldModelElements, element, boneEntity,
					"ValveBiped.Bip01_R_Hand")
			end

			if (not position) then
				continue
			end

			local model = element.modelEnt
			local sprite = element.spriteMaterial

			if (element.type == "Model" and IsValid(model)) then
				model:SetPos(
					position + angle:Forward() * element.pos.x + angle:Right() * element.pos.y
					+ angle:Up() * element.pos.z
				)
				angle:RotateAroundAxis(angle:Up(), element.angle.y)
				angle:RotateAroundAxis(angle:Right(), element.angle.p)
				angle:RotateAroundAxis(angle:Forward(), element.angle.r)

				model:SetAngles(angle)
				local matrix = Matrix()
				matrix:Scale(element.size)
				model:EnableMatrix("RenderMultiply", matrix)

				if (element.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() ~= element.material) then
					model:SetMaterial(element.material)
				end

				if (element.skin and element.skin ~= model:GetSkin()) then
					model:SetSkin(element.skin)
				end

				if (element.bodygroup) then
					for bodyGroupIndex, bodyGroupValue in pairs(element.bodygroup) do
						if (model:GetBodygroup(bodyGroupIndex) ~= bodyGroupValue) then
							model:SetBodygroup(bodyGroupIndex, bodyGroupValue)
						end
					end
				end

				if (element.suppressLighting) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(element.color.r / 255, element.color.g / 255, element.color.b / 255)
				render.SetBlend(element.color.a / 255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (element.suppressLighting) then
					render.SuppressEngineLighting(false)
				end
			elseif (element.type == "Sprite" and sprite) then
				local drawPosition = position + angle:Forward() * element.pos.x + angle:Right() * element.pos.y +
					angle:Up() * element.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawPosition, element.size.x, element.size.y, element.color)
			elseif (element.type == "Quad" and element.draw_func) then
				local drawPosition = position + angle:Forward() * element.pos.x + angle:Right() * element.pos.y +
					angle:Up() * element.pos.z
				angle:RotateAroundAxis(angle:Up(), element.angle.y)
				angle:RotateAroundAxis(angle:Right(), element.angle.p)
				angle:RotateAroundAxis(angle:Forward(), element.angle.r)

				cam.Start3D2D(drawPosition, angle, element.size)
				element.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	function SWEP:GetBoneOrientation(baseTable, element, entity, boneOverride)
		local bone, position, angle

		if (element.rel and element.rel ~= "") then
			local relativeElement = baseTable[element.rel]
			if (not relativeElement) then return end

			-- Technically, if there exists an element with the same name as a bone
			-- you can get in an infinite loop. Let's just hope nobody's that stupid.
			position, angle = self:GetBoneOrientation(baseTable, relativeElement, entity)
			if (not position) then return end

			position = position + angle:Forward() * relativeElement.pos.x + angle:Right() * relativeElement.pos.y +
				angle:Up() * relativeElement.pos.z
			angle:RotateAroundAxis(angle:Up(), relativeElement.angle.y)
			angle:RotateAroundAxis(angle:Right(), relativeElement.angle.p)
			angle:RotateAroundAxis(angle:Forward(), relativeElement.angle.r)
		else
			bone = entity:LookupBone(boneOverride or element.bone)
			if (not bone) then return end

			position, angle = Vector(0, 0, 0), Angle(0, 0, 0)
			local matrix = entity:GetBoneMatrix(bone)
			if (matrix) then
				position, angle = matrix:GetTranslation(), matrix:GetAngles()
			end

			if (IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and
					entity == self:GetOwner():GetViewModel() and self.ViewModelFlip) then
				angle.r = -angle.r -- Fixes mirrored models
			end
		end

		return position, angle
	end

	function SWEP:CreateModels(elementTable)
		if (not elementTable) then return end

		-- Create the clientside models here because we shouldn't do it in the render hook
		for _, element in pairs(elementTable) do
			if (element.type == "Model" and element.model and element.model ~= "" and (not IsValid(element.modelEnt) or element.createdModel ~= element.model) and
					string.find(element.model, ".mdl") and file.Exists(element.model, "GAME")) then
				element.modelEnt = ClientsideModel(element.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(element.modelEnt)) then
					element.modelEnt:SetPos(self:GetPos())
					element.modelEnt:SetAngles(self:GetAngles())
					element.modelEnt:SetParent(self)
					element.modelEnt:SetNoDraw(true)
					element.createdModel = element.model
				else
					element.modelEnt = nil
				end
			elseif (element.type == "Sprite" and element.sprite and element.sprite ~= "" and (not element.spriteMaterial or element.createdSprite ~= element.sprite)
					and file.Exists("materials/" .. element.sprite .. ".vmt", "GAME")) then
				local name = element.sprite .. "-"
				local params = { ["$basetexture"] = element.sprite }

				-- Make sure we create a unique name based on the selected options
				local optionsToCheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }

				for _, option in pairs(optionsToCheck) do
					if (element[option]) then
						params["$" .. option] = 1
						name = name .. "1"
					else
						name = name .. "0"
					end
				end

				element.createdSprite = element.sprite
				element.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
			end
		end
	end

	local allBones

	function SWEP:UpdateBonePositions(viewModel)
		if (self.ViewModelBoneModifications) then
			if (not viewModel:GetBoneCount()) then
				return
			end

			allBones = {}

			for i = 0, viewModel:GetBoneCount() do
				local boneName = viewModel:GetBoneName(i)
				if (self.ViewModelBoneModifications[boneName]) then
					allBones[boneName] = self.ViewModelBoneModifications[boneName]
				else
					allBones[boneName] = {
						scale = Vector(1, 1, 1),
						pos = Vector(0, 0, 0),
						angle = Angle(0, 0, 0)
					}
				end
			end

			for boneName, boneData in pairs(allBones) do
				local bone = viewModel:LookupBone(boneName)

				if (not bone) then
					continue
				end

				local scale = Vector(boneData.scale.x, boneData.scale.y, boneData.scale.z)
				local position = Vector(boneData.pos.x, boneData.pos.y, boneData.pos.z)
				local matrixScale = Vector(1, 1, 1)

				local currentBone = viewModel:GetBoneParent(bone)

				while (currentBone >= 0) do
					local parentScale = allBones[viewModel:GetBoneName(currentBone)].scale
					matrixScale = matrixScale * parentScale
					currentBone = viewModel:GetBoneParent(currentBone)
				end

				scale = scale * matrixScale

				if (viewModel:GetManipulateBoneScale(bone) ~= scale) then
					viewModel:ManipulateBoneScale(bone, scale)
				end
				if (viewModel:GetManipulateBoneAngles(bone) ~= boneData.angle) then
					viewModel:ManipulateBoneAngles(bone, boneData.angle)
				end
				if (viewModel:GetManipulateBonePosition(bone) ~= position) then
					viewModel:ManipulateBonePosition(bone, position)
				end
			end
		else
			self:ResetBonePositions(viewModel)
		end
	end

	function SWEP:ResetBonePositions(viewModel)
		if (not viewModel:GetBoneCount()) then return end

		for i = 0, viewModel:GetBoneCount() do
			viewModel:ManipulateBoneScale(i, Vector(1, 1, 1))
			viewModel:ManipulateBoneAngles(i, Angle(0, 0, 0))
			viewModel:ManipulateBonePosition(i, Vector(0, 0, 0))
		end
	end
end
