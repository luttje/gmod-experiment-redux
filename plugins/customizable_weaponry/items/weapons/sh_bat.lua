local PLUGIN = PLUGIN

local ITEM = ITEM

ITEM.name = "Louisville Slugger TPX"
ITEM.description = "Aluminum baseball bat, good for hitting home runs or cracking skulls."
ITEM.price = 100
ITEM.shipmentSize = 5
ITEM.model = "models/weapons/tacint_melee/w_bat.mdl"
ITEM.width = 1
ITEM.height = 2
ITEM.category = "Melee"
ITEM.weaponCategory = "melee"
ITEM.class = "exp_tacrp_m_bat"

ITEM.isAttachment = true
ITEM.attachmentBone = "ValveBiped.Bip01_Spine"
ITEM.attachmentOffsetAngles = Angle(200, 200, 0)
ITEM.attachmentOffsetVector = Vector(0, 5, 2)

ITEM.mergeIntoSwep = {
	MeleeRange = 64,
}
