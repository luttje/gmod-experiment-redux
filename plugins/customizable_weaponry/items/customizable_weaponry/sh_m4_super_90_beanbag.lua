local PLUGIN = PLUGIN
local ITEM = ITEM

ITEM.name = "Benelli M4 Super 90 (Non-Lethal)"
ITEM.description = "A shotgun-like weapon which fires beanbags. This weapon utilises beanbag ammo"
ITEM.price = 11000
ITEM.class = "exp_beanbag_shotgun"
ITEM.weaponCategory = "primary"
ITEM.model = "models/weapons/tacint/w_m4star10.mdl"
ITEM.width = 3
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(-55, 450, 0),
	ang = Angle(0, 276, 0),
	fov = 5.55
}
ITEM.isAttachment = true
ITEM.hasFlashlight = true
ITEM.attachmentBone = "ValveBiped.Bip01_Spine"
ITEM.requiresGunsmith = true
ITEM.attachmentOffsetAngles = Angle(0, 0, 0)
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97)

ITEM.forcedWeaponCalibre = "beanbag"
