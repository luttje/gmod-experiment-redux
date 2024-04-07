local ITEM = ITEM

ITEM.name = "Skull Mask"
ITEM.price = 300
ITEM.model = "models/gibs/hgibs.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Clothing"
ITEM.outfitCategory = "mask"
ITEM.description = "A skull mask that can conceal your identity while wearing it."
ITEM.pacData = {
	[1] = {
		["children"] = {
			[1] = {
				["children"] = {
				},
				["self"] = {
					["Angles"] = Angle(12.919322967529, 6.5696062847564e-006, -1.0949343050015e-005),
					["Position"] = Vector(-2.099609375, 0.019973754882813, 1.3180969238281),
					["UniqueID"] = "4249811628",
					["Size"] = 1.25,
					["Bone"] = "eyes",
					["Model"] = "models/Gibs/HGIBS.mdl",
					["ClassName"] = "model",
				},
			},
		},
		["self"] = {
			["ClassName"] = "group",
			["UniqueID"] = "907159817",
			["EditorExpand"] = true,
		},
	},
}

function ITEM:CanEquipOutfit()
	local client = self.player
	local character = client:GetCharacter()

	if (character:GetData("skullMask")) then
		client:Notify("You are already wearing a skull mask!")

		return false
	end

	return true
end

function ITEM:OnLoadout()
	if (self:GetData("equip")) then
		self:OnEquipped()
	end
end

function ITEM:OnEquipped()
	local client = self.player
	local character = client:GetCharacter()

	character:SetData("skullMask", true)
	client:SetCharacterNWBool("expSkullMask", true)
end

function ITEM:OnUnequipped()
	local client = self.player
	local character = client:GetCharacter()

	character:SetData("skullMask", nil)
	client:SetCharacterNWBool("expSkullMask", false)
end
