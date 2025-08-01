local ITEM = ITEM

ITEM.name = "Tactical Goggles"
ITEM.price = 1250
ITEM.shipmentSize = 5
ITEM.model = "models/gibs/shield_scanner_gib1.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Perpetuities"
ITEM.outfitCategory = "utility"
ITEM.description = "Tactical goggles which work with radio frequencies, it has some very interesting features."

function ITEM:OnEquipped()
	local client = self.player

	timer.Simple(1, function()
		if (not IsValid(client)) then
			return
		end

		client:AddDisplayLineFrequency(
			"Somebody has connected to the network...",
			Color(255, 100, 255, 255)
		)
		client:AddDisplayLine(
			"Welcome to the network...",
			Color(255, 100, 255, 255)
		)
	end)

	client:EnableTacticalGoggles()
end

function ITEM:OnUnequipped()
	local client = self.player

	client:AddDisplayLineFrequency(
		"Somebody has disconnected from the network...",
		Color(255, 100, 255, 255)
	)
	client:AddDisplayLine(
		"You have disconnected from the network...",
		Color(255, 100, 255, 255)
	)

	client:DisableTacticalGoggles()
end
