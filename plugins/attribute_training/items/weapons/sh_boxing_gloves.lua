local ITEM = ITEM

ITEM.name = "Boxing Gloves"
ITEM.model = "models/right_boxing_glove.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.class = "exp_boxing_gloves"
ITEM.weaponCategory = "melee"
ITEM.description = "A pair of boxing gloves for stylish punching, perfect for training strength."
ITEM.chanceToScavenge = Schema.RARITY_GIGA_RARE

if (SERVER) then
	resource.AddFile("materials/models/boxing_gloves.vmt")
	resource.AddFile("materials/models/weapons/boxing_gloves.vmt")
	resource.AddFile("models/left_boxing_glove.mdl")
	resource.AddFile("models/right_boxing_glove.mdl")
end
