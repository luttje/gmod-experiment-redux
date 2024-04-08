local ITEM = ITEM

ITEM.name = "Canned Beans"
ITEM.price = 15
ITEM.model = "models/props_lab/jar01b.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Consumables"
ITEM.description = "A tinned can, it slushes when you shake it."
ITEM.boostAttribs = {
	["end"] = {
		amount = 1,
		duration = 600
	}
}

function ITEM:OnRegistered()
    self.functions.Consume.name = "Eat"
end

function ITEM:OnBoosted()
	local client = self.player
	client:SetHealth(math.Clamp(client:Health() + 5, 0, client:GetMaxHealth()))
end

function ITEM:GetEmitBoostSound()
	return "npc/barnacle/barnacle_crunch" .. math.random(2, 3) .. ".wav", 50, 155, 0.2
end
