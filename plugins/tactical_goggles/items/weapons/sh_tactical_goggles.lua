local ITEM = ITEM

ITEM.name = "Tactical Goggles"
ITEM.price = 2500
ITEM.model = "models/gibs/shield_scanner_gib1.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Perpetuities"
ITEM.class = "exp_tactical_goggles"
ITEM.weaponCategory = "utility"
ITEM.description = "Tactical goggles which work with radio frequencies, it has some very interesting features."

function ITEM:OnEquipped()
	local client = self.player
    local character = client:GetCharacter()

    if (not character) then
        return
    end

    local frequency = client:GetCharacter():GetData("frequency")

    if (not frequency) then
        return
    end

	client:AddDisplayLineFrequency(frequency, "Somebody has connected to the network...", Color(255, 100, 255, 255))
	client:AddDisplayLine("You have connected to the network...", Color(255, 100, 255, 255))
end

function ITEM:OnUnequipped()
	local client = self.player
    local character = client:GetCharacter()

    if (not character) then
        return
    end

    local frequency = client:GetCharacter():GetData("frequency")

    if (not frequency) then
        return
    end

    client:AddDisplayLineFrequency(frequency, "Somebody has disconnected from the network...",
        Color(255, 100, 255, 255))
	client:AddDisplayLine("You have disconnected from the network...", Color(255, 100, 255, 255))
end
