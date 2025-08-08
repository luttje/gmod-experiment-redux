local PLUGIN = PLUGIN

PLUGIN.name = "Canvas Designer"
PLUGIN.author = "Experiment Redux"
PLUGIN.description =
"Allows players to design and customize images on canvases. Can be used for things like an Alliance logo."

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

-- Canvas constants
PLUGIN.CANVAS_DEFAULT_WIDTH = 400
PLUGIN.CANVAS_DEFAULT_HEIGHT = 400
PLUGIN.CANVAS_MINIMUM_WIDTH = 100
PLUGIN.CANVAS_MINIMUM_HEIGHT = 100
PLUGIN.CANVAS_MAX_WIDTH = 800
PLUGIN.CANVAS_MAX_HEIGHT = 800

PLUGIN.CANVAS_WIDTH_BITS = 10  -- Max 1023
PLUGIN.CANVAS_HEIGHT_BITS = 10 -- Max 1023

PLUGIN.MAX_ELEMENTS = 10
PLUGIN.GRID_SIZE = 20

function PLUGIN:Icon(material, spriteSize, x, y)
	return {
		material = material,
		size = spriteSize,
		x = x or 0,
		y = y or 0
	}
end

PLUGIN.SPRITE_TYPES = {}
PLUGIN.SHAPE_CATEGORIES = { "all" }
PLUGIN.SPRITES_BY_TYPE = {}

--- Registers a new sprite type with validation
function PLUGIN:RegisterSpriteType(spriteData)
	if (not spriteData) then
		ix.util.SchemaError("RegisterSpriteType: spriteData is required")
	end

	if (not spriteData.type or type(spriteData.type) ~= "string" or spriteData.type == "") then
		ix.util.SchemaError("RegisterSpriteType: 'type' must be a non-empty string")
	end

	if (not spriteData.name or type(spriteData.name) ~= "string" or spriteData.name == "") then
		ix.util.SchemaError("RegisterSpriteType: 'name' must be a non-empty string")
	end

	if (not spriteData.icon) then
		ix.util.SchemaError("RegisterSpriteType: 'icon' is required")
	end

	if (not spriteData.category or type(spriteData.category) ~= "string" or spriteData.category == "") then
		ix.util.SchemaError("RegisterSpriteType: 'category' must be a non-empty string")
	end

	-- Validate keywords (optional but must be string if provided)
	if (spriteData.keywords and type(spriteData.keywords) ~= "string") then
		ix.util.SchemaError("RegisterSpriteType: 'keywords' must be a string if provided")
	end

	-- Validate premiumKey (optional but must be string if provided)
	if (spriteData.premiumKey and type(spriteData.premiumKey) ~= "string") then
		ix.util.SchemaError("RegisterSpriteType: 'premiumKey' must be a string if provided")
	end

	if (PLUGIN.SPRITES_BY_TYPE[spriteData.type]) then
		ix.util.SchemaError("RegisterSpriteType: sprite type '" .. spriteData.type .. "' is already registered")
	end

	-- Create a copy of the sprite data to avoid external modifications
	local sprite = {
		type = spriteData.type,
		name = spriteData.name,
		icon = spriteData.icon,
		category = spriteData.category,
		keywords = spriteData.keywords or "",
		defaultColor = spriteData.defaultColor,
		premiumKey = spriteData.premiumKey
	}

	table.insert(PLUGIN.SPRITE_TYPES, sprite)

	-- Add to lookup table
	PLUGIN.SPRITES_BY_TYPE[sprite.type] = sprite

	if (not table.HasValue(PLUGIN.SHAPE_CATEGORIES, sprite.category)) then
		table.insert(PLUGIN.SHAPE_CATEGORIES, sprite.category)
	end
end

ix.util.Include("sh_sprite_types.lua")

-- Theme colors
PLUGIN.THEME = {
	background = Color(45, 45, 48),
	surface = Color(60, 60, 65),
	panel = Color(55, 55, 60),
	primary = Color(0, 122, 255),
	secondary = Color(88, 166, 255),
	success = Color(40, 167, 69),
	warning = Color(255, 193, 7),
	danger = Color(220, 53, 69),
	text = Color(240, 240, 240),
	textSecondary = Color(180, 180, 180),
	border = Color(80, 80, 85),
	hover = Color(70, 70, 75),
	underline = Color(255, 255, 255),
}
