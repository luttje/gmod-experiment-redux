local ITEM = ITEM

ITEM.name = "Milk Carton"
ITEM.price = 15
ITEM.model = "models/props_junk/garbage_milkcarton002a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Consumables"
ITEM.description = "A carton filled with delicious milk. Drinking this will temporarily enhance your endurance and strength."
ITEM.attributeBoosts = {
	["endurance"] = {
		amount = 1,
		duration = 600,
    },
	["strength"] = {
		amount = 1,
		duration = 600,
	},
}

function ITEM:GetEmitBoostSound()
    return "npc/barnacle/barnacle_gulp" .. math.random(1, 2) .. ".wav"
end

function ITEM:OnRegistered()
    self.functions.Consume.name = "Drink"
end

function ITEM:OnBoosted()
	local client = self.player
	client:SetHealth(math.Clamp(client:Health() + 1, 0, client:GetMaxHealth()))
end
