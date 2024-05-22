if (SERVER) then
	AddCSLuaFile()
end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Experiment Redux"
ENT.PrintName = "Flare"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.UsableInVehicle = true

if (not SERVER) then
	return
end

function ENT:Initialize()
    self:SetModel("models/items/grenadeammo.mdl")

    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetHealth(50)
    self:SetSolid(SOLID_VPHYSICS)

    local physicsObject = self:GetPhysicsObject()

    if (IsValid(physicsObject)) then
        physicsObject:Wake()
        physicsObject:EnableMotion(true)
    end
end

function ENT:StartFlare(duration)
	timer.Simple(duration, function()
		if (IsValid(self)) then
			Schema.DecayEntity(self, 30)
		end
	end)

	local attachment = self:GetAttachment(self:LookupAttachment("fuse"))
	local position = self:GetPos()

	if (attachment) then
		position = attachment.Pos
	end

	self.flareEntity = ents.Create("env_flare")
	self.flareEntity:SetKeyValue("scale", 8)
	self.flareEntity:SetParent(self)
	self.flareEntity:SetPos(position)
    self.flareEntity:Spawn()

	self.flareEntity:Fire("Start", duration, 0)
end

function ENT:OnRemove()
	if (IsValid(self.flareEntity)) then
		self.flareEntity:Remove()
	end
end

function ENT:OnTakeDamage(damageInfo)
	self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

	if (self:Health() <= 0) then
		self:RemoveWithEffect()
	end
end
