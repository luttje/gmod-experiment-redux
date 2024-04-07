ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Experiment Redux"
ENT.PrintName = "Belongings"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.UsableInVehicle = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", "ID")
	self:NetworkVar("String", "DisplayName")
end

function ENT:GetInventory()
	return ix.item.inventories[self:GetID()]
end
