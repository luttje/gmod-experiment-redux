ENT.Type = "anim"
ENT.Model = "models/props_combine/combine_mine01.mdl"
ENT.PrintName = "Bolt Generator"
ENT.IsBoltGenerator = true

function ENT:SetupDataTables()
    self:NetworkVar("String", "ItemID")

    self:NetworkVar("Int", "Power")
    self:NetworkVar("Int", "Upgrades")

	self:NetworkVar("Entity", "ItemOwner")
    self:NetworkVar("String", "OwnerName")
end

function ENT:GetItemTable()
	return ix.item.list[self:GetItemID()]
end

function ENT:GetNextUpgrade(client)
	local itemTable = self:GetItemTable()

	if (not itemTable) then
		return false
	end

    local nextUpgrade = itemTable:GetNextUpgrade(self)

    if (not nextUpgrade) then
        return false
    end

    local label

	if (SERVER) then
		label = L("upgrade", client, nextUpgrade.name, ix.currency.Get(nextUpgrade.price))
	else
		label = L("upgrade", nextUpgrade.name, ix.currency.Get(nextUpgrade.price))
	end

	return nextUpgrade, label
end
