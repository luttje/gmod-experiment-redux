local ITEM = ITEM

ITEM.base = "base_readable"
ITEM.name = "A piece of paper"
ITEM.isLoreItem = true
ITEM.noBusiness = true

if (CLIENT) then
    function ITEM:PopulateTooltip(tooltip)
		local panel = tooltip:AddRowAfter("name", "lore")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText("Lore")
		panel:SizeToContents()
    end
end

function ITEM:GetFilters()
    return {
        ["Is lore"] = "checkbox"
    }
end

function ITEM:OnRead()
	Schema.achievement.Progress("archivist", self.player, self.uniqueID)
end

-- Only add lore to a scavenge source if it doesn't already contain a lore item
function ITEM:OnFillScavengeSource(entity, inventory)
    local hasLore = inventory:GetItemsByBase("base_readable_lore")

	return #hasLore == 0
end
