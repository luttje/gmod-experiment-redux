--[[
	Based on this code:
	https://steamcommunity.com/sharedfiles/filedetails/?id=476160373
--]]

AddCSLuaFile()

SWEP.Base = "exp_base_melee"

SWEP.PrintName = "Boxing Gloves"
SWEP.Author = "Experiment Redux"
SWEP.Purpose = "A pair of boxing gloves for stylish punching, perfect for training strength."
SWEP.Instructions = "Left click to punch, Right click to block"

SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.Category = "Boxing Gloves"
SWEP.Spawnable = true

-- Custom sounds for boxing gloves
SWEP.SwingSound = Sound("WeaponFrag.Throw")
SWEP.HitSound = Sound("Flesh.ImpactHard")

-- Boxing glove models and positioning
SWEP.ViewModelElements = {
	["rightGlove"] = {
		type = "Model",
		model = "models/right_boxing_glove.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		rel = "",
		pos = Vector(3.635, 2.596, -1.201),
		angle = Angle(-104.027, 29.221, -101.689),
		size = Vector(0.755, 0.755, 0.755),
		color = Color(150, 0, 0, 255),
		suppressLighting = false,
		material = "models/weapons/boxing_gloves",
		skin = 0,
		bodygroup = {}
	},
	["leftGlove"] = {
		type = "Model",
		model = "models/left_boxing_glove.mdl",
		bone = "ValveBiped.Bip01_L_Hand",
		rel = "",
		pos = Vector(3.635, 1.557, 2.596),
		angle = Angle(108.7, -50.26, -1.17),
		size = Vector(0.755, 0.755, 0.755),
		color = Color(150, 0, 0, 255),
		suppressLighting = false,
		material = "models/weapons/boxing_gloves",
		skin = 0,
		bodygroup = {}
	}
}

SWEP.WorldModelElements = {
	["rightGlove"] = {
		type = "Model",
		model = "models/right_boxing_glove.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		rel = "",
		pos = Vector(7.791, 2.596, -0.519),
		angle = Angle(-101.689, 180, 43.247),
		size = Vector(1.08, 1.08, 1.08),
		color = Color(150, 0, 0, 255),
		suppressLighting = false,
		material = "models/weapons/boxing_gloves",
		skin = 0,
		bodygroup = {}
	},
	["leftGlove"] = {
		type = "Model",
		model = "models/left_boxing_glove.mdl",
		bone = "ValveBiped.Bip01_L_Hand",
		rel = "",
		pos = Vector(7.791, 1.557, 1),
		angle = Angle(90, -90, 59.61),
		size = Vector(1.08, 1.08, 1.08),
		color = Color(150, 0, 0, 255),
		suppressLighting = false,
		material = "models/weapons/boxing_gloves",
		skin = 0,
		bodygroup = {}
	}
}

-- Hide the fingers when wearing boxing gloves
SWEP.ViewModelBoneModifications = {
	["ValveBiped.Bip01_R_Finger1"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger4"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(-0.556, 0.185, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger0"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger2"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_Spine4"] = { scale = Vector(1, 1, 1), pos = Vector(-3.889, 0.185, -1.668), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger3"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Finger1"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0.555, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_L_Finger0"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(1.667, 0, 0), angle = Angle(134.444, 0, 0) }
}

-- Boxing-specific attack settings
SWEP.AttackAnimations = { "fists_left", "fists_right" }
SWEP.SpecialAttackAnimation = "fists_uppercut"
SWEP.IdleAnimations = { "fists_idle_01", "fists_idle_02" }
SWEP.DeployAnimation = "fists_draw"

-- Boxing damage and combo system
SWEP.AttackDamage = { 3, 4 }
SWEP.SpecialAttackDamage = { 8, 10 }
SWEP.AttackDelay = 0.2
SWEP.AttackCooldown = 0.5
SWEP.SpecialAttackCooldown = 0.9
SWEP.ComboThreshold = 9
SWEP.PhysicsPushScale = 0.1
SWEP.StaminaUse = 2

-- Blocking variables
SWEP.BlockingSpeedMultiplier = 0.4
SWEP.IsBlocking = false
SWEP.BlockTransitionSpeed = 8.0

-- Blocking view offset and angle
SWEP.BlockViewOffset = Vector(0, 0, -5) -- Move viewmodel down slightly
SWEP.BlockViewAngle = Angle(-30, 0, 0)  -- Tilt viewmodel up (hands closer to face)

function SWEP:SetupDataTables()
	self.BaseClass.SetupDataTables(self)
	self:NetworkVar("Int", 3, "Combo")
	self:NetworkVar("Float", 4, "BlockTransition") -- 0 = normal, 1 = blocking
end

function SWEP:Initialize()
	self.BaseClass.Initialize(self)
	self.IsBlocking = false
	if SERVER then
		self:SetBlockTransition(0)
	end
end

function SWEP:CalcViewModelView(viewModel, oldEyePos, oldEyeAng, eyePos, eyeAng)
	local transition = self:GetBlockTransition()

	if transition > 0 then
		-- Interpolate position offset
		local posOffset = self.BlockViewOffset * transition

		-- Interpolate angle offset
		local angOffset = self.BlockViewAngle * transition

		-- Apply the offsets
		local newPos = eyePos + eyeAng:Forward() * posOffset.x + eyeAng:Right() * posOffset.y + eyeAng:Up() * posOffset
			.z
		local newAng = eyeAng + angOffset

		return newPos, newAng
	end

	-- Return original values if not blocking
	return eyePos, eyeAng
end

function SWEP:OnDrop()
	self:Remove() -- You can't drop fists
end

function SWEP:PrimaryAttack()
	-- Don't attack while blocking
	if (self.IsBlocking) then
		return
	end

	local client = self:GetOwner()
	local canAttack = client:GetStamina() >= self.StaminaUse

	if (not canAttack) then
		if (CLIENT and not client.expIsBreathingSound) then
			client.expIsBreathingSound = true
			client:EmitSound("player/breathe1.wav", 40, 100, 0.3)
		end

		return
	end

	client:SetAnimation(PLAYER_ATTACK1)

	local randomAttack = math.random(0, 1)
	local animationName = ""

	if (randomAttack == 1) then
		animationName = self.AttackAnimations[2] -- right attack
	else
		animationName = self.AttackAnimations[1] -- left attack
	end

	-- Check for special attack
	if (self:GetCombo() >= self.ComboThreshold) then
		animationName = self.SpecialAttackAnimation
	end

	local viewModel = client:GetViewModel()
	viewModel:SendViewModelMatchingSequence(viewModel:LookupSequence(animationName))

	self:EmitSound(self.SwingSound)

	self:UpdateNextIdle()
	self:SetNextMeleeAttack(CurTime() + self.AttackDelay)

	if (animationName == self.SpecialAttackAnimation) then
		self:SetNextPrimaryFire(CurTime() + self.SpecialAttackCooldown)
	else
		self:SetNextPrimaryFire(CurTime() + self.AttackCooldown)
	end

	self:SetNextSecondaryFire(CurTime() + 0)
end

function SWEP:DealDamage()
	local client = self:GetOwner()
	local animationName = self:GetSequenceName(client:GetViewModel():GetSequence())

	client:LagCompensation(true)

	local trace = util.TraceLine({
		start = client:GetShootPos(),
		endpos = client:GetShootPos() + client:GetAimVector() * self.HitDistance,
		filter = client,
		mask = MASK_SHOT_HULL
	})

	if (not IsValid(trace.Entity)) then
		trace = util.TraceHull({
			start = client:GetShootPos(),
			endpos = client:GetShootPos() + client:GetAimVector() * self.HitDistance,
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

	local wasHit = false
	local scale = self.PhysicsPushScale

	if (SERVER and IsValid(trace.Entity) and (trace.Entity:IsNPC() or trace.Entity:IsPlayer() or trace.Entity:Health() > 0)) then
		local damageInfo = DamageInfo()

		local attacker = client
		if (not IsValid(attacker)) then attacker = self end
		damageInfo:SetAttacker(attacker)
		damageInfo:SetInflictor(self)

		-- Calculate damage based on attack type
		if (animationName == self.SpecialAttackAnimation) then
			damageInfo:SetDamage(math.random(self.SpecialAttackDamage[1], self.SpecialAttackDamage[2]))
			damageInfo:SetDamageForce(client:GetUp() * 7000 * scale +
				client:GetForward() * 10000 * scale)

			if (trace.Entity:IsPlayer()) then
				trace.Entity:SetViewPunchVelocity(Angle(-5000, 0, 0))
			end
		else
			damageInfo:SetDamage(math.random(self.AttackDamage[1], self.AttackDamage[2]))
			damageInfo:SetDamageForce(client:GetUp() * 4912 * scale +
				client:GetForward() * 9998 * scale)

			-- Apply different view punch for different attacks
			if (trace.Entity:IsPlayer()) then
				if (animationName == self.AttackAnimations[1]) then -- left attack
					trace.Entity:SetViewPunchVelocity(Angle(-10, 100, 40))
				elseif (animationName == self.AttackAnimations[2]) then -- right attack
					trace.Entity:SetViewPunchVelocity(Angle(10, -100, -40))
				end
			end
		end

		SuppressHostEvents(NULL) -- Let the breakable gibs spawn in multiplayer on client
		trace.Entity:TakeDamageInfo(damageInfo)
		SuppressHostEvents(client)

		wasHit = true
	end

	-- Apply physics force to objects
	if (IsValid(trace.Entity)) then
		local physicsObject = trace.Entity:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:ApplyForceOffset(
				client:GetAimVector() * 800 * physicsObject:GetMass() * scale,
				trace.HitPos
			)
		end

		if (SERVER and trace.Entity:GetClass() == "exp_boxing_bag") then
			trace.Entity:OnHitWithBoxingGloves(client, animationName == self.SpecialAttackAnimation)

			wasHit = true
		end
	end

	-- Update combo counter
	if (SERVER) then
		Schema.buff.SetActive(client, "tired")
		client:ConsumeStamina(self.StaminaUse)

		if (wasHit and animationName ~= self.SpecialAttackAnimation) then
			self:SetCombo(self:GetCombo() + 1)
		else
			if (animationName == self.SpecialAttackAnimation) then
				client:ConsumeStamina(self.StaminaUse)
			end

			self:SetCombo(0)
		end
	end

	client:LagCompensation(false)
end

function SWEP:Deploy()
	local result = self.BaseClass.Deploy(self)

	if (SERVER) then
		self:SetCombo(0)
		self:SetBlockTransition(0)
	end

	return result
end

function SWEP:Think()
	self.BaseClass.Think(self)

	-- Handle blocking transitions
	local client = self:GetOwner()
	if not IsValid(client) then
		return
	end

	local canAttack = client:GetStamina() >= self.StaminaUse

	if (CLIENT and canAttack and client.expIsBreathingSound) then
		client.expIsBreathingSound = false
		client:StopSound("player/breathe1.wav")
	end

	local targetTransition = 0
	local isPressingBlock = client:KeyDown(IN_ATTACK2)

	-- Handle blocking state changes
	if client:KeyReleased(IN_ATTACK2) then
		if self.IsBlocking then
			client:SetWalkSpeed(client:GetWalkSpeed() / self.BlockingSpeedMultiplier)
			client:SetRunSpeed(client:GetRunSpeed() / self.BlockingSpeedMultiplier)
			self.IsBlocking = false
		end
		targetTransition = 0
	elseif client:KeyPressed(IN_ATTACK2) then
		if not self.IsBlocking then
			client:SetWalkSpeed(client:GetWalkSpeed() * self.BlockingSpeedMultiplier)
			client:SetRunSpeed(client:GetRunSpeed() * self.BlockingSpeedMultiplier)
			self.IsBlocking = true
		end
		targetTransition = 1
	elseif isPressingBlock then
		targetTransition = 1
	end

	-- Smooth transition
	if SERVER then
		local currentTransition = self:GetBlockTransition()
		local newTransition = math.Approach(currentTransition, targetTransition, FrameTime() * self.BlockTransitionSpeed)
		self:SetBlockTransition(newTransition)
	end

	-- Reset combo after period of inactivity
	if (SERVER and CurTime() > self:GetNextPrimaryFire() + 3) then
		self:SetCombo(0)
	end
end

function SWEP:SecondaryAttack()
	-- Prevent melee attacks while blocking
	self:SetNextMeleeAttack(math.huge)
end

function SWEP:Holster()
	local client = self:GetOwner()

	-- Reset movement speed when holstering
	if (self.IsBlocking and IsValid(client)) then
		client:SetWalkSpeed(client:GetWalkSpeed() / self.BlockingSpeedMultiplier)
		client:SetRunSpeed(client:GetRunSpeed() / self.BlockingSpeedMultiplier)
		self.IsBlocking = false
	end

	return self.BaseClass.Holster(self)
end
