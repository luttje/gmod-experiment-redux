ix.currency.symbol = ""
ix.currency.singular = "bolt"
ix.currency.plural = "bolts"
ix.currency.model = "models/props_lab/exp01a.mdl"

ix.config.SetDefault("intro", false)
ix.config.SetDefault("music", "music/HL2_song23_SuitSong3.mp3")
ix.config.SetDefault("maxAttributes", 100)

ix.config.Add("allianceCost", 10000, "How much an alliance costs to create.", nil, {
	data = { min = 0, max = 1000000 },
	category = "alliances"
})

ix.config.Add("incomeMultiplier", 1, "The income multiplier for generators and salary", nil, {
	data = {min = 0, max = 100, decimals = 1}
})

ix.config.Add("armorEffectiveness", 0.75, "How much damage armor will prevent, for example 0.75 will let a quarter of the damage through.", nil, {
	data = {min = 0, max = 1, decimals = 2}
})

ix.config.Add("beanbagRagdollDuration", 15, "How long players knocked out by beanbags will be ragdolled for.", nil, {
	data = {min = 0, max = 600}
})

ix.config.Add("requiredGraceAfterDamage", 60, "How long after taking damage a player can disconnect without dropping everything.", nil, {
	data = { min = 0, max = 300 },
	category = "moderation"
})

ix.config.Add("grenadeTrailsEnabled", true, "Whether or not grenades leave a colored trail behind them.", nil, {
	category = "grenades"
})

ix.config.Add("grenadeTrailColor", Color(255, 100, 0), "The color of the grenade trail.", nil, {
	category = "grenades"
})

ix.config.Add("grenadeTrailMaxLifetime", 10, "How long the grenade trail lasts for (-1 means for as long as the grenade exists).", nil, {
	data = {min = -1, max = 10, decimals = 0},
	category = "grenades"
})
