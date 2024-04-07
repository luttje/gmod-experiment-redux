include("shared.lua")

ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(tooltip)
	local item = self:GetItemTable()

	if (not item) then
		return
	end

	-- ix.hud.PopulateItemTooltip(tooltip, item)
end

function ENT:GetEntityMenu(client)
	local itemTable = self:GetItemTable()
	local options = {}

	if (not itemTable) then
		return false
	end

	itemTable.player = client
	itemTable.entity = self

	options[L("pickup")] = function() end

	itemTable.player = nil
	itemTable.entity = nil

	return options
end
