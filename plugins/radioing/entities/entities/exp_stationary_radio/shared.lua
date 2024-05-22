local PLUGIN = PLUGIN

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Experiment Redux"
ENT.PrintName = "Stationary Radio"
ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", "TurnedOff")
	self:NetworkVar("String", "ItemID")
	self:NetworkVar("String", "Frequency")
end

function ENT:GetItemTable()
	return ix.item.list[self:GetItemID()]
end
