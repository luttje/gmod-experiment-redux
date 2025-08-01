local PLUGIN = PLUGIN

local ITEM = ITEM

ITEM.name = "Molot TGS-12"
ITEM.description = "Short barrel pistol grip shotgun. High mobility and recoil, and most effective at close range."
ITEM.price = 2000
ITEM.shipmentSize = 5
ITEM.class = "exp_tacrp_tgs12"
ITEM.weaponCategory = "primary"
ITEM.model = "models/weapons/tacint/w_tgs12.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.forcedWeaponCalibre = "12 Gauge"
ITEM.requiresGunsmith = true

ITEM.mergeIntoSwep = {
	-- Spread = 0.025, (spread radius)
	ShotgunPelletSpread = 0.2, -- was 0.02 (deviation from spread, even going out of spread radius)
}
