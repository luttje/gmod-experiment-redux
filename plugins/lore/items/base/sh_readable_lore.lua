local ITEM = ITEM

ITEM.name = "A piece of paper"
ITEM.model = Model("models/props_c17/paper01.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Some paper with writing on it."
ITEM.isLoreItem = true

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

function ITEM:OnReadLore()
	Schema.achievement.Progress(self.player, "archivist", self.uniqueID)
end

-- Only add lore to a scavenge source if it doesn't already contain a lore item
function ITEM:OnFillScavengeSource(entity, inventory)
    local hasLore = inventory:GetItemsByBase("base_readable_lore")

	return #hasLore == 0
end

if (CLIENT) then
	function ITEM:GetText()
		return [[
			There is nothing written on this piece of paper.
		]]
	end
end

ITEM.functions.Read = {
	name = "Read",
	tip = "Read what's on this piece of paper.",
	icon = "icon16/book_open.png",
	OnRun = function(item)
        local client = item.player

		item.OnReadLore(item)

		net.Start("expReadLore")
			net.WriteUInt(item:GetID(), 32)
        net.Send(client)

		return false
	end
}
