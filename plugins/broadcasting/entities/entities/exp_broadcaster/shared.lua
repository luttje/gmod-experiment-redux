ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Experiment Redux"
ENT.PrintName = "Broadcaster"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.UsableInVehicle = true
ENT.PhysgunDisabled = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", "TurnedOff")
	self:NetworkVar("String", "ItemID")
end

function ENT:GetItemTable()
	return ix.item.list[self:GetItemID()]
end
