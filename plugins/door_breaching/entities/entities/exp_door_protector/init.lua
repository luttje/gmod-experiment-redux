local PLUGIN = PLUGIN

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_combine/breenlight.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetHealth(25)
	self:SetSolid(SOLID_VPHYSICS)

	local physicsObject = self:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		physicsObject:Wake()
		physicsObject:EnableMotion(true)
	end
end

function ENT:SetupDoorProtector(client)
	self.expClient = client
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:Think()
    local doorCount = 0
	local position = self:GetPos()

    for _, entity in ipairs(ents.FindInSphere(position, PLUGIN.doorProtectorRange)) do
        if (string.lower(entity:GetClass()) == "prop_door_rotating") then
            doorCount = doorCount + 1
        end
    end

	self:SetProtectedCount(doorCount)

    self:NextThink(CurTime() + 2)
    return true
end

function ENT:OnTakeDamage(damageInfo)
	self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

	if (self:Health() <= 0) then
		self:RemoveWithEffect()
	end
end
