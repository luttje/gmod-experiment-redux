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
	local toBeRemoved = {}

    function helperMetaTable:Add(data)
        table.insert(self, data)
    end

    function helperMetaTable:Remove(uniqueID)
        table.insert(toBeRemoved, uniqueID)
    end

	function helperMetaTable:RemoveQueued()
        for _, uniqueID in ipairs(toBeRemoved) do
            for i, data in ipairs(self) do
                if (data.uniqueID == uniqueID) then
                    table.remove(self, i)
                end
            end
        end

		toBeRemoved = {}
	end

	self.allowedProps = setmetatable({}, helperMetaTable)

    hook.Run("AdjustAllowedProps", self.allowedProps)

	self.allowedProps:RemoveQueued()

	-- Register the allowed props as blueprint items
	for _, data in ipairs(self.allowedProps) do
		local ITEM = ix.item.Register("blueprint_" .. string.lower(data.uniqueID), "base_blueprints", false, nil, true)

		table.Merge(ITEM, data, true)

		ITEM.structureModel = data.model
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
	allowedProps:Add({
		uniqueID = "blue_barrel",
		name = "Blue Barrel",
		description = "A blue barrel.",
		price = 100,
		health = 100,
		model = "models/props_borealis/bluebarrel001.mdl",
		constructionMaterials = {
			["material_plastic"] = 5,
			["material_metal"] = 1
		}
    })

	--[[
		Hard metal props
	--]]
	allowedProps:Add({
		uniqueID = "storefront_bars",
		name = "Storefront Bars",
		description = "Strong bars to protect your storefront.",
		price = 200,
		health = 200,
		model = "models/props_building_details/Storefront_Template001a_Bars.mdl",
		constructionMaterials = {
			["material_metal"] = 10
		}
    })

    allowedProps:Add({
        uniqueID = "blast_door",
        name = "Blast Door",
        description = "A blast door to protect your base.",
        price = 200,
        health = 200,
        model = "models/props_lab/blastdoor001b.mdl",
		constructionMaterials = {
			["material_metal"] = 15
		}
    })

	-- Commented because we should only provide small to medium props (in order to prevent prop climbing to high places)
	-- allowedProps:Add({
	-- 	uniqueID = "blast_door_double",
	-- 	name = "Welded Double Blast Door",
	-- 	description = "Double blast doors welded together.",
	-- 	price = 400,
	-- 	health = 400,
	-- 	model = "models/props_lab/blastdoor001c.mdl",
	-- 	constructionMaterials = {
	-- 		["material_metal"] = 25
	-- 	}
	-- })

	--[[
		Wooden props
	--]]
	allowedProps:Add({
		uniqueID = "furniture_shelf",
		name = "Shelf",
		description = "A shelf to store your items.",
		price = 150,
		health = 150,
		model = "models/props_c17/FurnitureShelf001a.mdl",
		constructionMaterials = {
			["material_wood"] = 10
		}
	})

	allowedProps:Add({
		uniqueID = "furniture_table",
		name = "Table",
		description = "A table to place your items.",
		price = 150,
		health = 150,
		model = "models/props_c17/FurnitureTable001a.mdl",
		constructionMaterials = {
			["material_wood"] = 10
		}
	})

	allowedProps:Add({
		uniqueID = "oil_drum",
		name = "Oil Drum",
		description = "A barrel to store oil.",
		price = 100,
		health = 100,
		model = "models/props_c17/oildrum001.mdl",
		constructionMaterials = {
			["material_metal"] = 5
		}
	})
end
