ENT.Type = "anim"
ENT.Model = "models/props_combine/combine_mine01.mdl"
ENT.PrintName = "Bolt Generator"
ENT.IsBoltGenerator = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", "Power")
	self:NetworkVar("String", "ItemID")
end

function ENT:GetItemTable()
	return ix.item.list[self:GetItemID()]
end
