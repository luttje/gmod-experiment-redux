local PLUGIN = PLUGIN

local SPRITESHEET = "experiment-redux/designer/basic_spritesheet.png"

PLUGIN:RegisterSpriteType({
	type = "basic_rectangle",
	name = "Rectangle",
	icon = PLUGIN:Icon(SPRITESHEET, 128, 0, 0),
	category = "shapes",
	keywords = "square box rect"
})

PLUGIN:RegisterSpriteType({
	type = "basic_circle",
	name = "Circle",
	icon = PLUGIN:Icon(SPRITESHEET, 128, 1, 0),
	category = "shapes",
	keywords = "round ball"
})

PLUGIN:RegisterSpriteType({
	type = "basic_triangle",
	name = "Triangle",
	icon = PLUGIN:Icon(SPRITESHEET, 128, 2, 0),
	category = "shapes",
	keywords = "tri point"
})

PLUGIN:RegisterSpriteType({
	type = "basic_diamond",
	name = "Diamond",
	icon = PLUGIN:Icon(SPRITESHEET, 128, 3, 0),
	category = "shapes",
	keywords = "rhombus gem"
})

PLUGIN:RegisterSpriteType({
	type = "basic_star",
	name = "Star",
	icon = PLUGIN:Icon(SPRITESHEET, 128, 4, 0),
	category = "shapes",
	keywords = "asterisk rating"
})

PLUGIN:RegisterSpriteType({
	type = "basic_heart",
	name = "Heart",
	icon = PLUGIN:Icon(SPRITESHEET, 128, 5, 0),
	category = "shapes",
	keywords = "love like"
})

PLUGIN:RegisterSpriteType({
	type = "basic_arrow",
	name = "Arrow",
	icon = PLUGIN:Icon(SPRITESHEET, 128, 0, 1),
	category = "arrows",
	keywords = "direction right east"
})

PLUGIN:RegisterSpriteType({
	type = "basic_chevron",
	name = "Chevron",
	icon = PLUGIN:Icon(SPRITESHEET, 128, 1, 1),
	category = "arrows",
	keywords = "direction right east"
})

PLUGIN:RegisterSpriteType({
	type = "basic_cross",
	name = "Cross",
	icon = PLUGIN:Icon(SPRITESHEET, 128, 2, 1),
	category = "symbols",
	keywords = "x delete remove"
})

PLUGIN:RegisterSpriteType({
	type = "basic_check",
	name = "Check",
	icon = PLUGIN:Icon(SPRITESHEET, 128, 3, 1),
	category = "symbols",
	keywords = "tick yes confirm ok"
})

PLUGIN:RegisterSpriteType({
	type = "basic_lightning",
	name = "Lightning",
	icon = PLUGIN:Icon(SPRITESHEET, 128, 4, 1),
	category = "symbols",
	keywords = "zap electric shock"
})

PLUGIN:RegisterSpriteType({
	type = "basic_question",
	name = "Question",
	icon = PLUGIN:Icon(SPRITESHEET, 128, 5, 1),
	category = "symbols",
	keywords = "help unknown ask"
})

PLUGIN:RegisterSpriteType({
	type = "basic_exclamation",
	name = "Exclamation",
	icon = PLUGIN:Icon(SPRITESHEET, 128, 6, 1),
	category = "symbols",
	keywords = "alert warning caution"
})
