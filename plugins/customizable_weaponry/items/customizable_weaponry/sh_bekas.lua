local PLUGIN = PLUGIN

local ITEM = ITEM

ITEM.name = "Molot Bekas-16M"
ITEM.description = "Accurate hunting shotgun with a low fire rate.\nLimited effectiveness against armor."
ITEM.price = 2250
ITEM.shipmentSize = 5
ITEM.class = "exp_tacrp_bekas"
ITEM.weaponCategory = "primary"
ITEM.model = "models/weapons/tacint/w_bekas.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.forcedWeaponCalibre = "16 Gauge"
ITEM.requiresGunsmith = true

ITEM.mergeIntoSwep = {
	-- Spread = 0.02, (spread radius)
	ShotgunPelletSpread = 0.05, -- was 0.005 (deviation from spread, even going out of spread radius)
}
