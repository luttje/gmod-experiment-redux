local PLUGIN = PLUGIN

local SPRITESHEET_MATERIAL_BASIC = Material("experiment-redux/designer/basic_spritesheet.png")

PLUGIN:RegisterSpriteType({
	type = "basic_rectangle",
	name = "Rectangle",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_BASIC, 128, 0, 0),
	category = "shapes",
	keywords = "square box rect"
})

PLUGIN:RegisterSpriteType({
	type = "basic_circle",
	name = "Circle",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_BASIC, 128, 1, 0),
	category = "shapes",
	keywords = "round ball"
})

PLUGIN:RegisterSpriteType({
	type = "basic_triangle",
	name = "Triangle",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_BASIC, 128, 2, 0),
	category = "shapes",
	keywords = "tri point"
})

PLUGIN:RegisterSpriteType({
	type = "basic_diamond",
	name = "Diamond",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_BASIC, 128, 3, 0),
	category = "shapes",
	keywords = "rhombus gem"
})

PLUGIN:RegisterSpriteType({
	type = "basic_star",
	name = "Star",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_BASIC, 128, 4, 0),
	category = "shapes",
	keywords = "asterisk rating"
})

PLUGIN:RegisterSpriteType({
	type = "basic_heart",
	name = "Heart",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_BASIC, 128, 5, 0),
	category = "shapes",
	keywords = "love like"
})

PLUGIN:RegisterSpriteType({
	type = "basic_arrow",
	name = "Arrow",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_BASIC, 128, 0, 1),
	category = "arrows",
	keywords = "direction right east"
})

PLUGIN:RegisterSpriteType({
	type = "basic_chevron",
	name = "Chevron",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_BASIC, 128, 1, 1),
	category = "arrows",
	keywords = "direction right east"
})

PLUGIN:RegisterSpriteType({
	type = "basic_cross",
	name = "Cross",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_BASIC, 128, 2, 1),
	category = "symbols",
	keywords = "x delete remove"
})

PLUGIN:RegisterSpriteType({
	type = "basic_check",
	name = "Check",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_BASIC, 128, 3, 1),
	category = "symbols",
	keywords = "tick yes confirm ok"
})

PLUGIN:RegisterSpriteType({
	type = "basic_lightning",
	name = "Lightning",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_BASIC, 128, 4, 1),
	category = "symbols",
	keywords = "zap electric shock"
})

PLUGIN:RegisterSpriteType({
	type = "basic_question",
	name = "Question",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_BASIC, 128, 5, 1),
	category = "symbols",
	keywords = "help unknown ask"
})

PLUGIN:RegisterSpriteType({
	type = "basic_exclamation",
	name = "Exclamation",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_BASIC, 128, 6, 1),
	category = "symbols",
	keywords = "alert warning caution"
})

--[[
	Colored Sprites (Premium)
--]]

-- TODO: Compress this PNG so it isn't too large
-- TODO: Download these assets not on join, but after the loading screen when the player is already creating/selecting their character.
local SPRITESHEET_MATERIAL_COLORED = Material("experiment-redux/designer/colored_spritesheet.png") -- 8x8 = 64 sprites

PLUGIN:RegisterSpriteType({
	type = "premium_skull",
	name = "Skull",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 0, 0),
	category = "colored",
	keywords = "death danger",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_nanobot",
	name = "Nanobot",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 1, 0),
	category = "colored",
	keywords = "robot technology",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_satellite",
	name = "Satellite",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 2, 0),
	category = "colored",
	keywords = "space communication",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_radar_dish",
	name = "Radar Dish",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 3, 0),
	category = "colored",
	keywords = "signal scan",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_drone",
	name = "Drone",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 4, 0),
	category = "colored",
	keywords = "aerial surveillance",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_circuit_chip",
	name = "Circuit Chip",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 5, 0),
	category = "colored",
	keywords = "electronics computing",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_ai_brain",
	name = "AI Brain",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 6, 0),
	category = "colored",
	keywords = "artificial intelligence",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_network",
	name = "Network",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 7, 0),
	category = "colored",
	keywords = "connection data",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_tall_smokestack",
	name = "Tall smokestack",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 0, 1),
	category = "colored",
	keywords = "factory pollution",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_transmission_tower",
	name = "Transmission Tower",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 1, 1),
	category = "colored",
	keywords = "broadcast radio",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_watchtower",
	name = "Watchtower",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 2, 1),
	category = "colored",
	keywords = "observation guard",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_laurel_wreath",
	name = "Laurel wreath",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 3, 1),
	category = "colored",
	keywords = "victory honor",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_bolts",
	name = "Bolts",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 4, 1),
	category = "colored",
	keywords = "hardware fasteners",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_barcode",
	name = "Barcode",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 5, 1),
	category = "colored",
	keywords = "scan commerce",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_knife_a",
	name = "Knife A",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 6, 1),
	category = "colored",
	keywords = "weapon blade",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_knife_b",
	name = "Knife B",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 7, 1),
	category = "colored",
	keywords = "weapon blade",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})
PLUGIN:RegisterSpriteType({
	type = "premium_shooting_star",
	name = "Shooting Star",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 0, 2),
	category = "colored",
	keywords = "wish meteor",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_star_jagged",
	name = "Star with jagged edges",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 1, 2),
	category = "colored",
	keywords = "burst explosion",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_target",
	name = "Target",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 2, 2),
	category = "colored",
	keywords = "aim bullseye",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_barbed_wire",
	name = "Barbed Wire",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 3, 2),
	category = "colored",
	keywords = "fence security",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_serpent_rod",
	name = "Serpent around a rod",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 4, 2),
	category = "colored",
	keywords = "medicine healing",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_pyramid",
	name = "Pyramid",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 5, 2),
	category = "colored",
	keywords = "egypt ancient",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_broken_halo",
	name = "Broken Halo",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 6, 2),
	category = "colored",
	keywords = "fallen angel",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_eye",
	name = "Eye",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 7, 2),
	category = "colored",
	keywords = "vision watch",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_eye_triangle",
	name = "Eye in Triangle",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 0, 3),
	category = "colored",
	keywords = "illuminati secret",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_mechanical_eye",
	name = "Mechanical eye",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 1, 3),
	category = "colored",
	keywords = "cybernetic vision",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_swirl",
	name = "Swirl",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 2, 3),
	category = "colored",
	keywords = "spiral vortex",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_hourglass",
	name = "Hourglass",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 3, 3),
	category = "colored",
	keywords = "time sand",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_three_lines",
	name = "Three parallel lines",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 4, 3),
	category = "colored",
	keywords = "symbol minimal hamburger",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_fragmented_circle",
	name = "Fragmented Circle",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 5, 3),
	category = "colored",
	keywords = "broken shape chart",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_tower",
	name = "Tower",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 6, 3),
	category = "colored",
	keywords = "fortress stronghold",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_torch",
	name = "Torch",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 7, 3),
	category = "colored",
	keywords = "flame light",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})
PLUGIN:RegisterSpriteType({
	type = "premium_fist",
	name = "Fist",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 0, 4),
	category = "colored",
	keywords = "power strength",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_gauntlet",
	name = "Gauntlet",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 1, 4),
	category = "colored",
	keywords = "armor glove",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_robotic_hand_globe",
	name = "Robotic hand gripping globe",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 2, 4),
	category = "colored",
	keywords = "technology control",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_chains_circle",
	name = "Chains forming a circle",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 3, 4),
	category = "colored",
	keywords = "unity bondage",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_broken_chain",
	name = "Broken chain link",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 4, 4),
	category = "colored",
	keywords = "freedom escape",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_shield_skyline",
	name = "Shield with city skyline",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 5, 4),
	category = "colored",
	keywords = "protection urban",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_helmet",
	name = "Helmet",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 6, 4),
	category = "colored",
	keywords = "armor protection",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_gas_mask",
	name = "Gas Mask",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 7, 4),
	category = "colored",
	keywords = "toxic protection",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_cogs",
	name = "Cogs",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 0, 5),
	category = "colored",
	keywords = "gears machinery",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_broken_cog",
	name = "Broken Cog",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 1, 5),
	category = "colored",
	keywords = "damage malfunction",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_vault",
	name = "Vault",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 2, 5),
	category = "colored",
	keywords = "security storage door",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_mechanical_wing",
	name = "Mechanical wing",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 3, 5),
	category = "colored",
	keywords = "flight machine",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_candle",
	name = "Candle",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 4, 5),
	category = "colored",
	keywords = "light flame",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_campfire",
	name = "Campfire",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 5, 5),
	category = "colored",
	keywords = "fire outdoors",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_hammer",
	name = "Hammer",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 6, 5),
	category = "colored",
	keywords = "tool strike",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_sickle",
	name = "Sickle",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 7, 5),
	category = "colored",
	keywords = "harvest farming",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_roots",
	name = "Roots",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 0, 6),
	category = "colored",
	keywords = "growth nature",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_tree",
	name = "Tree",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 1, 6),
	category = "colored",
	keywords = "forest nature",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_droplet_soil",
	name = "Droplet on barren soil",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 2, 6),
	category = "colored",
	keywords = "drought water",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_rising_tide",
	name = "Rising tide wave",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 3, 6),
	category = "colored",
	keywords = "ocean flood",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_pile_rocks",
	name = "Pile of rocks",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 4, 6),
	category = "colored",
	keywords = "stones rubble",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_mountain_a",
	name = "Mountain A",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 5, 6),
	category = "colored",
	keywords = "peak summit nature",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_mountain_b",
	name = "Mountain B",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 6, 6),
	category = "colored",
	keywords = "peak summit nature",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_eclipse",
	name = "Eclipse",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 7, 6),
	category = "colored",
	keywords = "sun moon",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_raven",
	name = "Raven",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 0, 7),
	category = "colored",
	keywords = "bird omen",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_hawk",
	name = "Hawk",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 1, 7),
	category = "colored",
	keywords = "bird predator",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_howling_wolf",
	name = "Howling Wolf",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 2, 7),
	category = "colored",
	keywords = "wolf moon",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_wolf_print",
	name = "Wolf print",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 3, 7),
	category = "colored",
	keywords = "paw track",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_snake",
	name = "Snake",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 4, 7),
	category = "colored",
	keywords = "serpent reptile",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_bear",
	name = "Bear",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 5, 7),
	category = "colored",
	keywords = "animal strength",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_antler_left",
	name = "Antler Left",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 6, 7),
	category = "colored",
	keywords = "deer horn",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})

PLUGIN:RegisterSpriteType({
	type = "premium_antler_right",
	name = "Antler Right",
	icon = PLUGIN:Icon(SPRITESHEET_MATERIAL_COLORED, 512, 7, 7),
	category = "colored",
	keywords = "deer horn",
	defaultColor = color_white,
	premiumKey = "sprites_colored"
})
