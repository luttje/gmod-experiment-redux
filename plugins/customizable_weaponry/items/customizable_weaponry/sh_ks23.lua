local PLUGIN = PLUGIN

local ITEM = ITEM

ITEM.name = "KS-23"
ITEM.description =
"Made from recycled aircraft gun barrels, this heavy shotgun fires shells with twice the diameter of typical shotshells and can easily tear apart anything it's vaguely pointed at."
ITEM.price = 1750
ITEM.shipmentSize = 5
ITEM.class = "exp_tacrp_ks23"
ITEM.weaponCategory = "primary"
ITEM.model = "models/weapons/tacint/w_ks23.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.forcedWeaponCalibre = "23x75mmR"
ITEM.requiresGunsmith = true

ITEM.mergeIntoSwep = {
	-- Spread = 0.03, (spread radius)
	ShotgunPelletSpread = 0.2, -- was 0.02 (deviation from spread, even going out of spread radius)
}
