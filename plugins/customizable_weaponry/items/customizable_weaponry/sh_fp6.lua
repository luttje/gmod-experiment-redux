local ITEM = ITEM

ITEM.name = "HK FABARM FP6"
ITEM.description = "Combat shotgun with high fire rate and capacity."
ITEM.price = 2000
ITEM.shipmentSize = 5
ITEM.class = "tacrp_fp6"
ITEM.weaponCategory = "primary"
ITEM.model = "models/weapons/tacint/w_fp6.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.forcedWeaponCalibre = "12 Gauge"
ITEM.requiresGunsmith = true

ITEM.mergeIntoSwep = {
	-- Spread = 0.03, (spread radius)
	ShotgunPelletSpread = 0.05, -- was 0.005 (deviation from spread, even going out of spread radius)
}
