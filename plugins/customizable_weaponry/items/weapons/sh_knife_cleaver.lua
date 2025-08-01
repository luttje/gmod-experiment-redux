local PLUGIN = PLUGIN

local ITEM = ITEM

ITEM.name = "Meat Cleaver"
ITEM.description = "Large, sturdy blade made for chopping meat, be that animal meat or human meat."
ITEM.price = 95
ITEM.shipmentSize = 5
ITEM.model = "models/weapons/tacint_melee/w_cleaver.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Melee"
ITEM.weaponCategory = "melee"
ITEM.class = "exp_tacrp_m_cleaver"

ITEM.isAttachment = true
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis"
ITEM.attachmentOffsetAngles = Angle(0, 180, 87)
ITEM.attachmentOffsetVector = Vector(0, 0, -7.2)

ITEM.mergeIntoSwep = {
  MeleeRange = 64,
}
