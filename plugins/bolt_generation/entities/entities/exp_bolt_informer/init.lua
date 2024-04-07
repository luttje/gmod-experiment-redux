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

function ENT:SetupBoltInformer(client)
	self.expClient = client
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:Think()
    local count = 0
	local position = self:GetPos()

    for _, entity in ipairs(ents.FindInSphere(position, PLUGIN.boltProtectorRange)) do
        if (entity.IsBoltGenerator) then
            count = count + 1
        end
    end

	self:SetProtectedCount(count)

    self:NextThink(CurTime() + 2)
    return true
end

function ENT:OnTakeDamage(damageInfo)
	self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

	if (self:Health() <= 0) then
		self:RemoveWithEffect()
	end
end

function ENT:OnOptionSelected(client, option, data)
	if (option == L("pickup", client)) then
		local character = client:GetCharacter()
		local inventory = character:GetInventory()
		inventory:Add("bolt_informer")
		self:Remove()
	end
end
