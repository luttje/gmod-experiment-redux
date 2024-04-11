local ITEM = ITEM

ITEM.name = "Junk"
ITEM.model = "models/props_interiors/pot02a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Just some junk. Perhaps it can be recycled to scrap."
ITEM.scrapAmount = 1

function ITEM:GetFilters()
	return {
		["Is junk"] = "checkbox"
	}
end

function ITEM:GetScrapAmount(client)
	return self.scrapAmount
end

ITEM.functions.Scrap = {
	name = "Scrap",
	tip = "Scrap this item",
	icon = "icon16/wrench.png",
	OnRun = function(item)
		local client = item.player

		client:Notify("You scrapped the item.")
		client:GetCharacter():GetInventory():Add("scrap", item:GetScrapAmount(client))

		return true
	end
}
