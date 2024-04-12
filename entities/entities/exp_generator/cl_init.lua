include("shared.lua")

ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(tooltip)
	local ownerName = self:GetOwnerName() or "Unnamed"
	local upgrades = self:GetUpgrades() or 0

	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText(ownerName)
    name:SizeToContents()

    local itemTable = self:GetItemTable()

	if (not itemTable) then
		return
	end

	local description = tooltip:AddRow("description")
	description:SetText("Upgrades: " .. upgrades .. "/" .. #itemTable.generator.upgrades)
    description:SizeToContents()

	local teleportEarnings = ix.config.Get("teleportGeneratorEarnings")

	if (not teleportEarnings) then
		local earnings = tooltip:AddRow("earnings")
		earnings:SetText("Earnings: " .. ix.currency.Get(self:GetHeldBolts() or 0))
		earnings:SizeToContents()
	end
end

function ENT:GetEntityMenu(client)
	local itemTable = self:GetItemTable()
	local options = {}

	if (not itemTable) then
		return false
	end

	local owner = self:GetItemOwner()

	itemTable.entity = self
    itemTable.player = client

	if (IsValid(owner) and owner == client) then
        options[L("pickup")] = function() end
	end

	local nextUpgrade, upgradeLabel = self:GetNextUpgrade()

	if (nextUpgrade) then
		options[upgradeLabel] = function() end
	end

	local teleportEarnings = ix.config.Get("teleportGeneratorEarnings")

    if (not teleportEarnings) then
		local heldBolts = self:GetHeldBolts() or 0

		if (heldBolts > 0) then
        	options[L("withdraw", heldBolts)] = function() end
		end
    end

	itemTable.player = nil
    itemTable.entity = nil

	return options
end
