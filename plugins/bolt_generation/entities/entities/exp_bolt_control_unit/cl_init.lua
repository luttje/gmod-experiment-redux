include("shared.lua")

DEFINE_BASECLASS("exp_generator")

function ENT:OnPopulateEntityInfo(tooltip)
	BaseClass.OnPopulateEntityInfo(self, tooltip)

	local ownerName = self:GetOwnerName() or "Unnamed"
	local upgrades = self:GetUpgrades() or 0

	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText(ownerName)
	name:SizeToContents()

	local description = tooltip:AddRow("description")
	description:SetText("Upgrades: " .. upgrades)
	description:SizeToContents()
end

function ENT:GetEntityMenu(client)
	local itemTable = self:GetItemTable()
	local options = {}

	if (not itemTable) then
		return false
	end

	itemTable.player = client
	itemTable.entity = self

	options[L("upgrade")] = function() end

	itemTable.player = nil
	itemTable.entity = nil

	table.Merge(options, BaseClass.GetEntityMenu(self, client))

	return options
end
