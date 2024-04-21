if SERVER then
	AddCSLuaFile()
end

ENT.Type = "anim"
ENT.Model = "models/props_lab/huladoll.mdl"
ENT.PrintName = "Lockers (Session)"
ENT.IsLockersSession = true

if (not SERVER) then
	return
end

AccessorFunc(ENT, "expCharacter", "Character")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetNoDraw(true)

	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
end

function ENT:SetMoney(amount)
	local character = self:GetCharacter()

	character:SetData("lockersMoney", amount)
end

function ENT:GetMoney()
	local character = self:GetCharacter()

	return character:GetData("lockersMoney", 0)
end

function ENT:GetInventory()
	local character = self:GetCharacter()
	local lockerInventoryID = character:GetData("lockerID")

	return ix.item.inventories[lockerInventoryID]
end
