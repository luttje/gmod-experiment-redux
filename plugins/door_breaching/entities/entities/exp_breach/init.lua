AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_wasteland/prison_padlock001a.mdl")

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetSolid(SOLID_VPHYSICS)

	local physicsObject = self:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		physicsObject:Wake()
		physicsObject:EnableMotion(true)
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:CreateDummyBreach()
	local entity = ents.Create("prop_physics")

	entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	entity:SetAngles(self:GetAngles())
	entity:SetModel("models/props_wasteland/prison_padlock001b.mdl")
	entity:SetPos(self:GetPos())

	entity:Spawn()

	if (IsValid(entity)) then
		Schema.DecayEntity(entity, 30)
	end
end

function ENT:SetBreachEntity(entity, trace)
	local position = trace.HitPos
	local angles = trace.HitNormal:Angle()

	self.entity = entity
	self.entity:DeleteOnRemove(self)

	self:SetPos(position)
	self:SetAngles(angles)
	self:SetParent(entity)

	entity.breach = self
	self:SetHealth(5)
end

function ENT:BreachEntity(activator)
	hook.Run("EntityBreached", self.entity, activator, self)
	self:RemoveWithEffect()
end

function ENT:OnTakeDamage(damageInfo)
	self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

	if (self:Health() <= 0) then
		self:CreateDummyBreach()
		self:BreachEntity(damageInfo:GetAttacker())
	end
end
