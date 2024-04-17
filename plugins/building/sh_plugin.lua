local PLUGIN = PLUGIN

PLUGIN.name = "Building"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Restricts construction to only allowed props. Requiring blueprints and materials to build."

ix.util.Include("sv_plugin.lua")

ix.config.Add("maxBuildGroundLevel", 2, "The maximum distance from the ground players can build (in structures on top of structures).", nil, {
	data = {min = 0, max = 100, decimals = 0},
	category = "Building"
})

if (CLIENT) then
	function PLUGIN:RequestBuildStructure(position, angles)
		net.Start("ixBuildingRequestBuildStructure")
		net.WriteVector(position)
		net.WriteAngle(angles)
		net.SendToServer()
	end
end

function PLUGIN:InitializedPlugins()
	local helperMetaTable = {}
	helperMetaTable.__index = helperMetaTable

	function helperMetaTable:AddProp(data)
		table.insert(self, data)
	end

	self.allowedProps = setmetatable({}, helperMetaTable)

	hook.Run("AdjustAllowedProps", self.allowedProps)

	-- Register the allowed props as blueprint items
	for _, data in ipairs(self.allowedProps) do
		local ITEM = ix.item.Register("blueprint_" .. string.lower(data.uniqueID), "base_blueprints", false, nil, true)

		ITEM.name = data.name
		ITEM.model = data.model
        ITEM.health = data.health
		ITEM.structureModel = data.model
		ITEM.price = data.priceOfBlueprint
        ITEM.description = data.description
		ITEM.constructionMaterials = data.materials
	end
end

function PLUGIN:GetPlacementTrace(client)
    local maxDistance = 100
    local eyesPosition = client:EyePos()
    local trace = util.TraceLine({
        start = eyesPosition,
        endpos = eyesPosition + (client:GetAimVector() * maxDistance),
        filter = client
    })

    return trace.HitPos, Angle(0, client:EyeAngles().y, 0)
end

function PLUGIN:GetPlacementValid(client, position, angles)
	-- Allow buildings to clip by a margin
	local clipMargin = 10
    local maxDistance = clipMargin + 10
	local groundTrace = util.TraceLine({
		start = position + Vector(0, 0, clipMargin),
		endpos = position - Vector(0, 0, maxDistance),
		filter = client
	})

    if (groundTrace.HitWorld) then
        return true
    end

    if (IsValid(groundTrace.Entity) and (groundTrace.Entity.IsStructure or groundTrace.Entity.IsStructurePart)) then
		-- Limit how far up players can build upon structures
        local maxBuildGroundLevel = ix.config.Get("maxBuildGroundLevel")

		if (groundTrace.Entity.IsStructure or groundTrace.Entity.IsStructurePart) then
			local groundLevel = groundTrace.Entity:GetGroundLevel()

			if (groundLevel >= maxBuildGroundLevel) then
				return false
			end
		end

		return true, groundTrace.Entity
	end

	return false
end

function PLUGIN:AdjustAllowedProps(allowedProps)
	--[[
		Plastic props
	--]]
	allowedProps:AddProp({
		uniqueID = "blue_barrel",
		name = "Blue Barrel",
		description = "A blue barrel.",
		priceOfBlueprint = 100,
		health = 100,
		model = "models/props_borealis/bluebarrel001.mdl",
		materials = {
			["material_plastic"] = 5,
			["material_metal"] = 1
		}
    })

	--[[
		Hard metal props
	--]]
	allowedProps:AddProp({
		uniqueID = "storefront_bars",
		name = "Storefront Bars",
		description = "Strong bars to protect your storefront.",
		priceOfBlueprint = 200,
		health = 200,
		model = "models/props_building_details/Storefront_Template001a_Bars.mdl",
		materials = {
			["material_metal"] = 10
		}
    })

    allowedProps:AddProp({
        uniqueID = "blast_door",
        name = "Blast Door",
        description = "A blast door to protect your base.",
        priceOfBlueprint = 200,
        health = 200,
        model = "models/props_lab/blastdoor001b.mdl",
		materials = {
			["material_metal"] = 15
		}
    })

	-- Commented because we should only provide small to medium props (in order to prevent prop climbing to high places)
	-- allowedProps:AddProp({
	-- 	uniqueID = "blast_door_double",
	-- 	name = "Welded Double Blast Door",
	-- 	description = "Double blast doors welded together.",
	-- 	priceOfBlueprint = 400,
	-- 	health = 400,
	-- 	model = "models/props_lab/blastdoor001c.mdl",
	-- 	materials = {
	-- 		["material_metal"] = 25
	-- 	}
	-- })

	--[[
		Wooden props
	--]]
	allowedProps:AddProp({
		uniqueID = "furniture_shelf",
		name = "Shelf",
		description = "A shelf to store your items.",
		priceOfBlueprint = 150,
		health = 150,
		model = "models/props_c17/FurnitureShelf001a.mdl",
		materials = {
			["material_wood"] = 10
		}
	})

	allowedProps:AddProp({
		uniqueID = "furniture_table",
		name = "Table",
		description = "A table to place your items.",
		priceOfBlueprint = 150,
		health = 150,
		model = "models/props_c17/FurnitureTable001a.mdl",
		materials = {
			["material_wood"] = 10
		}
	})

	allowedProps:AddProp({
		uniqueID = "oil_drum",
		name = "Oil Drum",
		description = "A barrel to store oil.",
		priceOfBlueprint = 100,
		health = 100,
		model = "models/props_c17/oildrum001.mdl",
		materials = {
			["material_metal"] = 5
		}
	})
end
