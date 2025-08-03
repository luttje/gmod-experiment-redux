if (SERVER) then
	AddCSLuaFile()
end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Experiment Redux"
ENT.PrintName = "Attack Handle"
ENT.Spawnable = false
ENT.AdminOnly = true

ENT.IsAttackHandle = true

function ENT:SetupDataTables()
	self:NetworkVar("Float", "SphereSize")
end

function ENT:CanTool(client, trace, toolName, tool, button)
	return false
end

if (not SERVER) then
	function ENT:Draw()
		-- Don't draw anything - this entity should be invisible

		-- Debug visualization (commented to prevent them visible through walls)
		-- if (GetConVar("developer"):GetInt() > 0) then
		-- 	local pos = self:GetPos()
		-- 	local size = self:GetSphereSize()
		-- 	render.SetColorMaterial()
		-- 	render.DrawSphere(pos, size, 10, 10, Color(255, 0, 0, 100))
		-- end
	end

	return
end

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	-- Make it invisible but keep collision
	self:SetNoDraw(false)
	self:SetNotSolid(false)

	self:SetSize(6) -- Default size for the handle

	-- Enable touch detection
	self:SetTrigger(true)

	-- Track what we're currently touching
	self.touchingEntities = {}

	-- Track if we're currently in an attack state
	self.isAttacking = false

	-- Reference to the monster that owns this handle
	self.ownerMonster = nil

	-- Attack data from the current attack
	self.attackData = nil
end

function ENT:SetSize(size)
	self.expSize = size

	self:SetSphereSize(size)

	-- Set up collision bounds - small sphere around the attachment point
	self:SetCollisionBounds(Vector(-size, -size, -size), Vector(size, size, size))
end

function ENT:SetOwnerMonster(monster)
	self.ownerMonster = monster
end

function ENT:GetOwnerMonster()
	return self.ownerMonster
end

function ENT:SetAttackData(attackData)
	self.attackData = attackData
end

function ENT:StartAttack(attackData)
	self.isAttacking = true
	self.attackData = attackData
end

function ENT:EndAttack()
	self.isAttacking = false
	self.attackData = nil
end

function ENT:IsValidTarget(entity)
	if not IsValid(entity) then
		return false
	end

	if not IsValid(self.ownerMonster) then
		return false
	end

	-- Use the monster's enemy detection logic
	return self.ownerMonster:IsValidTarget(entity)
end

function ENT:StartTouch(entity)
	if not self:IsValidTarget(entity) then
		return
	end

	self.touchingEntities[entity] = true

	-- If we're currently attacking, apply damage immediately
	if (self.isAttacking and self.attackData) then
		self:ApplyDamageToEntity(entity)
	end
end

function ENT:EndTouch(entity)
	self.touchingEntities[entity] = nil
end

function ENT:ApplyDamageToEntity(entity)
	if not IsValid(entity) or not IsValid(self.ownerMonster) then
		return
	end

	if not self.attackData then
		return
	end

	-- Apply damage
	local damage = self.attackData.damage or 10
	local damageType = self.attackData.damageType or DMG_SLASH

	if (entity:IsDoor()) then
		self.ownerMonster:SpeakFromTypedVoiceSet("AttackHitDoor", nil, true)
		self.ownerMonster:HandleDoorAttack(entity)
		return
	end

	self.ownerMonster:SpeakFromTypedVoiceSet("AttackHit", nil, true)

	-- Create damage info for more control
	local dmgInfo = DamageInfo()
	dmgInfo:SetDamage(damage)
	dmgInfo:SetDamageType(damageType)
	dmgInfo:SetAttacker(self.ownerMonster)
	dmgInfo:SetInflictor(self)
	dmgInfo:SetDamagePosition(entity:GetPos())

	-- Calculate damage force direction (from monster to target)
	local forceDir = (entity:GetPos() - self.ownerMonster:GetPos()):GetNormalized()
	dmgInfo:SetDamageForce(forceDir * 200)

	entity:TakeDamageInfo(dmgInfo)
end

function ENT:Think()
	-- Clean up invalid entities from touching list
	for entity, _ in pairs(self.touchingEntities) do
		if not IsValid(entity) then
			self.touchingEntities[entity] = nil
		end
	end

	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:OnRemove()
	-- Clean up
	self.touchingEntities = {}
end
