local ITEM = ITEM

ITEM.name = "Melon"
ITEM.price = 30
ITEM.model = "models/props_junk/watermelon01.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Consumables"
ITEM.description = "A green fruit, it has a hard outer shell."
ITEM.attributeBoosts = {
	["acrobatics"] = {
		amount = 2,
		duration = 600,
	},
	["agility"] = {
		amount = 2,
		duration = 600,
	},
}

function ITEM:OnRegistered()
    self.functions.Consume.name = "Eat"
end

function ITEM:OnBoosted()
	local client = self.player
	client:SetHealth(math.Clamp(client:Health() + 10, 0, client:GetMaxHealth()))
end

function ITEM:GetEmitBoostSound()
	return "npc/barnacle/barnacle_crunch" .. math.random(2, 3) .. ".wav", 50, 155, 0.2
end
