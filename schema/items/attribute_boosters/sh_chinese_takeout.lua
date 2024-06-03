local ITEM = ITEM

ITEM.name = "Chinese Takeout"
ITEM.price = 20
ITEM.model = "models/props_junk/garbage_takeoutcarton001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Consumables"
ITEM.description = "A takeout carton, it's filled with cold noodles. Eating this might make you feel more enduring."
ITEM.attributeBoosts = {
	["endurance"] = {
		amount = 2,
		duration = 600
	}
}

function ITEM:OnRegistered()
    self.functions.Consume.name = "Eat"
end

function ITEM:OnBoosted()
	local client = self.player
	client:SetHealth(math.Clamp(client:Health() + 1, 0, client:GetMaxHealth()))
end

function ITEM:GetEmitBoostSound()
	return "npc/barnacle/barnacle_crunch" .. math.random(2, 3) .. ".wav", 50, 155, 0.2
end

