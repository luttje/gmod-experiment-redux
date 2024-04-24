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
		local item = character:GetInventory():GetItemByID(itemID)

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

		character:GetInventory():Remove(itemID)
		character:GiveMoney(price)

		client:EmitSound("buttons/button19.wav", 55, 150 * math.Rand(0.8, 1.2))
	end)
end
