local ITEM = ITEM

ITEM.name = "Junk (Material)"
ITEM.model = "models/gibs/scanner_gib02.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Junk that can be scrapped into useful materials."
ITEM.scrapMaterials = {
    -- ["material_plastic"] = 1,
    -- ["material_metal"] = 1,
	-- ["material_wood"] = 1
}

function ITEM:GetFilters()
	return {
		["Is junk"] = "checkbox"
	}
end

function ITEM:GetScrapMaterials(client)
	return self.scrapMaterials
end

ITEM.functions.Scrap = {
	name = "Scrap",
	tip = "Scrap this item",
	icon = "icon16/wrench.png",
	OnRun = function(item)
        local client = item.player
		local character = client:GetCharacter()
        local scrapMaterials = item:GetScrapMaterials(client)

		client:Notify("You scrapped the item for materials.")

		for materialItem, amount in pairs(scrapMaterials) do
			character:GetInventory():Add(materialItem, amount)
		end
	end
}
