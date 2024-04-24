local ITEM = ITEM

ITEM.name = "Pipe Wrench"
ITEM.description = "Sturdy wrench designed for tightening water and gas pipes.  All-iron construction makes it quite the blunt weapon."
ITEM.price = 100
ITEM.model = "models/weapons/tacint_melee/w_wrench.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Melee"
ITEM.weaponCategory = "melee"
ITEM.class = "tacrp_m_wrench"

ITEM.isAttachment = true
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis"
ITEM.attachmentOffsetAngles = Angle(0, 180, 87)
ITEM.attachmentOffsetVector = Vector(0, 0, -7.2)

ITEM.mergeIntoSwep = {
	MeleeRange = 50,
}
