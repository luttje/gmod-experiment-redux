local PERK = PERK

PERK.name = "Cashback"
PERK.price = 3000
PERK.foregroundImage = {
	spritesheet = "experiment-redux/flatmsicons32.png",
	x = 18,
	y = 16,
	size = 32,
}
PERK.returnFraction = 0.25
PERK.description = "You can cash in items in your inventory for 25% of their original price."

if (SERVER) then
	util.AddNetworkString("expCashbackRequest")

	net.Receive("expCashbackRequest", function(len, client)
		local itemID = net.ReadUInt(32)
        local character = client:GetCharacter()
		local inventory = character:GetInventory()
		local item = inventory:GetItemByID(itemID)

		if (Schema.util.Throttle("expCashbackRequest", 1, client)) then
			client:Notify("You are performing this action too quickly!")
			return
		end

		if (not item) then
			client:Notify("You do not have this item anymore!")
			return
		end

		if (not item.price or item.noBusiness) then
			client:Notify("You cannot sell this item!")
			return
		end

		local price = math.ceil(item.price * PERK.returnFraction)

        if (price < 1) then
            client:Notify("This item is not worth anything!")
            return
        end

		--[[
		Issue: https://github.com/luttje/gmod-experiment-redux/issues/117

		I feel like this may be caused by items with the same id existing. I'm not sure where this is
		happening, but it may be the monster, or scavenging system. I'll investigate.

		I'm leaving the error here and some debug code for possible future reference and debugging.

			[ERROR] gamemodes/helix/plugins/logging.lua:220: attempt to index local 'item' (a nil value)
			1. v - gamemodes/helix/plugins/logging.lua:220
			2. Run - gamemodes/helix/gamemode/core/libs/sh_plugin.lua:347
				3. Remove - gamemodes/helix/gamemode/core/meta/sh_inventory.lua:369
				4. func - gamemodes/experiment-redux/schema/perks/sh_cashback.lua:44
				5. unknown - lua/includes/extensions/net.lua:38

		--]]
		if (not ix.item.instances[itemID]) then
			ix.util.SchemaErrorNoHalt(
                "(Debugging) Item instance not found for item ID "
                .. tostring(itemID) .. "\n"
                .. "User: " .. tostring(client) .. " (" .. tostring(client:SteamID()) .. ")\n"
                .. "Item name: " .. tostring(item.name) .. "\n"
				.. "Inventory: " .. tostring(inventory) .. "\n"
            )
            PrintTable(item)

			client:Notify("An error occurred trying to cashback this item. Please contact a developer.")

			return
		end

		inventory:Remove(itemID)
		character:GiveMoney(price)

        client:EmitSound("buttons/button19.wav", 55, 150 * math.Rand(0.8, 1.2))

		ix.log.Add(client, "playerCashbackPerk", price)
	end)
end
