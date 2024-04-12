local ITEM = ITEM

ITEM.name = "Scrap"
ITEM.model = "models/gibs/metal_gib4.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "This is scrap, it can power Bolt Control Units."

function ITEM:GetFilters()
	return {
		["Is scrap"] = "checkbox"
	}
end

ITEM.functions.Combine = {
	tip = "Combine",
	icon = "icon16/arrow_in.png",
	OnRun = function(item)
		local client = item.player
		local inventory = client:GetCharacter():GetInventory()
		local scrap = inventory:GetItemsByUniqueID("scrap")
		local amalgamAmount = ix.config.Get("scrapAmalgamAmount")

		if #scrap < amalgamAmount then
			client:Notify("You need at least 5 scrap to combine.")
			return false
		end

        for i, scrapItem in ipairs(scrap) do
            scrapItem:Remove()

			if i >= amalgamAmount then
				break
			end
		end

		inventory:Add("scrap_amalgam", 1)

		return false
	end,
	OnCanRun = function(item)
		local amalgamAmount = ix.config.Get("scrapAmalgamAmount")
		return item.player:GetCharacter():GetInventory():GetItemCount("scrap") >= amalgamAmount
	end
}
