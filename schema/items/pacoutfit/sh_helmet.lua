local ITEM = ITEM

ITEM.name = "Helmet"
ITEM.price = 180
ITEM.model = "models/props_junk/metalbucket01a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Clothing"
ITEM.damageScale = 0.25
ITEM.outfitCategory = "helmet"
ITEM.description = "When hit in the head, you will take 75%% less damage. The helmet will break immediately after taking damage."
ITEM.pacData = {}

function ITEM:OnEquipped()
	local client = self.player
	local character = client:GetCharacter()
	character:SetData("helmet", self.id)
end

function ITEM:OnUnequipped()
	local client = self.player

	if (not IsValid(client)) then
		return
	end

	local character = client:GetCharacter()
	character:SetData("helmet", nil)
end

function ITEM:OnLoadout()
	if (self:GetData("equip")) then
		local client = self.player
		local character = client:GetCharacter()
		character:SetData("helmet", self.id)
	end
end
