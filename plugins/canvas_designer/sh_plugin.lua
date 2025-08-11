local PLUGIN = PLUGIN

PLUGIN.name = "Canvas Designer"
PLUGIN.author = "Experiment Redux"
PLUGIN.description =
"Allows players to design and customize images on canvases. Can be used for things like an Alliance logo."

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

PLUGIN.CANVAS_ITEM_ID = "canvas"

-- Canvas constants
PLUGIN.CANVAS_DEFAULT_WIDTH = 400
PLUGIN.CANVAS_DEFAULT_HEIGHT = 400
PLUGIN.CANVAS_MINIMUM_WIDTH = 100
PLUGIN.CANVAS_MINIMUM_HEIGHT = 100
PLUGIN.CANVAS_MAX_WIDTH = 800
PLUGIN.CANVAS_MAX_HEIGHT = 800

PLUGIN.CANVAS_WIDTH_BITS = 10  -- Max 1023
PLUGIN.CANVAS_HEIGHT_BITS = 10 -- Max 1023

PLUGIN.MIN_MAX_ELEMENTS = 10
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

	if (type(spriteData.icon.material) ~= "string") then
		ix.util.SchemaError("RegisterSpriteType: 'icon.material' must be a string upon registration")
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

	if (SERVER) then
		local path = spriteData.icon.material

		resource.AddFile("materials/" .. path)
	end

	spriteData.icon.material = Material(spriteData.icon.material)

	spriteData.keywords = spriteData.keywords or ""

	table.insert(PLUGIN.SPRITE_TYPES, spriteData)

	-- Add to lookup table
	PLUGIN.SPRITES_BY_TYPE[spriteData.type] = spriteData

	if (not table.HasValue(PLUGIN.SHAPE_CATEGORIES, spriteData.category)) then
		table.insert(PLUGIN.SHAPE_CATEGORIES, spriteData.category)
	end
end

ix.util.IncludeDir(PLUGIN.folder .. "/sprite_types", true)

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

--[[
	Hooks
--]]

function PLUGIN:GetMaximumElements(client)
	local maxElements = PLUGIN.MIN_MAX_ELEMENTS
	local premiumPackages = client:GetPremiumPackages()

	for packageKey, _ in pairs(premiumPackages) do
		local package = Schema.GetPremiumPackage(packageKey)

		if (package and package.additionalElementSlots) then
			local additionalSlots = package.additionalElementSlots or 0
			maxElements = maxElements + additionalSlots
		end
	end

	return maxElements
end

--[[
	Commands
--]]

do
	local COMMAND = {}

	COMMAND.description = "Remove all graffiti and other art expressions in the world."
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, name)
		local worldCanvases = ents.FindByClass("exp_world_canvas_viewer")

		for _, canvas in ipairs(worldCanvases) do
			canvas:Remove()
		end

		client:Notify("All world canvases have been removed.")
	end

	ix.command.Add("WorldCanvasRemoveAll", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Remove a graffiti or other art expressions in the world near where you are looking."
	COMMAND.arguments = {
		bit.bor(ix.type.number, ix.type.optional),
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, range)
		local trace = client:GetEyeTrace()
		local entities = ents.FindInSphere(trace.HitPos, range or 100)
		local removeCount = 0

		for _, entity in ipairs(entities) do
			if (IsValid(entity) and entity:GetClass() == "exp_world_canvas_viewer") then
				entity:Remove()
				removeCount = removeCount + 1
			end
		end

		client:Notify("Removed " .. removeCount .. " world canvases near where you are looking.")
	end

	ix.command.Add("WorldCanvasRemove", COMMAND)
end
