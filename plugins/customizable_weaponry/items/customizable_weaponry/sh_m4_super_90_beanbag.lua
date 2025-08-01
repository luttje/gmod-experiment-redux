local PLUGIN = PLUGIN
local ITEM = ITEM

ITEM.name = "Benelli M4 Super 90 (Non-Lethal)"
ITEM.description = "A shotgun-like weapon which fires beanbags. This weapon utilises beanbag ammo"
ITEM.price = 5500
ITEM.shipmentSize = 5
ITEM.class = "exp_beanbag_shotgun"
ITEM.weaponCategory = "primary"
ITEM.model = "models/weapons/tacint/w_m4star10.mdl"
ITEM.width = 2
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
ITEM.requiresGunsmith = true

ITEM.mergeIntoSwep = {
	-- Spread = 0.03 (spread radius, if ShotgunPelletSpread is super low, pellets will circle around this radius perimeter)
	ShotgunPelletSpread = 0.1, -- was 0.01 (deviation from spread, even going out of spread radius)
}
