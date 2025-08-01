local PLUGIN = PLUGIN

ITEM.name = "Benelli M4 Super 90"
ITEM.description = "Semi-automatic shotgun with very high damage output. Reloading may be a chore."
ITEM.price = 3300
ITEM.shipmentSize = 5
ITEM.class = "exp_tacrp_m4star10"
ITEM.weaponCategory = "primary"
ITEM.model = "models/weapons/tacint/w_m4star10.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(-55, 450, 0),
	ang = Angle(0, 276, 0),
	fov = 5.55
}

ITEM.forcedWeaponCalibre = "12 Gauge"
ITEM.requiresGunsmith = true

ITEM.mergeIntoSwep = {
	-- Spread = 0.03 (spread radius)
	ShotgunPelletSpread = 0.1, -- was 0.01 (deviation from spread, even going out of spread radius)
}
