local ITEM = ITEM

ITEM.name = "Scrap Amalgam"
ITEM.model = "models/props_phx/gears/bevel9.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "An amalgamation of scrap metal, its easier to carry than individual pieces of scrap."

function ITEM:GetFilters()
	return {
		["Is scrap"] = "checkbox"
	}
end

ITEM.functions.Split = {
	tip = "Split",
	icon = "icon16/arrow_out.png",
	OnRun = function(item)
		local client = item.player
		local inventory = client:GetCharacter():GetInventory()
		local amalgamAmount = ix.config.Get("scrapAmalgamAmount")

		inventory:Add("scrap", amalgamAmount)
	end,
}
