local ITEM = ITEM

ITEM.name = "Machete"
ITEM.description = "Versatile blade that can be used as an agricultural tool, a weapon of war or as a navigational aid when deep in the bush."
ITEM.price = 100
ITEM.model = "models/weapons/tacint_melee/w_machete.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Melee"
ITEM.weaponCategory = "melee"
ITEM.class = "tacrp_m_shovel"

ITEM.isAttachment = true
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis"
ITEM.attachmentOffsetAngles = Angle(0, 180, 87)
ITEM.attachmentOffsetVector = Vector(0, 0, -7.2)

ITEM.mergeIntoSwep = {
	MeleeRange = 64,
}
