local PLUGIN = PLUGIN

local ITEM = ITEM

ITEM.name = "Hammer"
ITEM.description = "When you have a hammer, everything looks like a nail..."
ITEM.price = 80
ITEM.shipmentSize = 5
ITEM.model = "models/weapons/tacint_melee/w_hammer.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Melee"
ITEM.weaponCategory = "melee"
ITEM.class = "exp_tacrp_m_hamma"

ITEM.isAttachment = true
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis"
ITEM.attachmentOffsetAngles = Angle(0, 180, 87)
ITEM.attachmentOffsetVector = Vector(0, 0, -7.2)

ITEM.mergeIntoSwep = {
	MeleeRange = 50,
}
