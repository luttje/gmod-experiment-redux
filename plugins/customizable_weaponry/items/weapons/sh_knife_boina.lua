local ITEM = ITEM

ITEM.name = "Cudeman Boina Verde"
ITEM.description = "Sturdy, oversized survival knife."
ITEM.price = 400
ITEM.model = "models/weapons/tacint_melee/w_boina.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Melee"
ITEM.weaponCategory = "melee"
ITEM.class = "tacrp_m_boina"

ITEM.isAttachment = true
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis"
ITEM.attachmentOffsetAngles = Angle(0, 180, 87)
ITEM.attachmentOffsetVector = Vector(0, 0, -7.2)

ITEM.mergeIntoSwep = {
	MeleeRange = 64,
}
