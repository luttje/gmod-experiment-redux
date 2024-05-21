local MAP = MAP

MAP.name = "City 18"
MAP.mapName = "rp_c18_v2"

MAP.waitingPosition = Vector(4284.469238, 1271.594116, 1974.027466)
MAP.waitingAngles = Angle(89.000000, 89.056053, 0.000000)

if (CLIENT) then
    MAP.backgroundMaterial = Material("experiment-redux/maps/rp_c18_v2_feathered_black.png")
    MAP.backgroundOriginalWidth = 1050
    MAP.backgroundOriginalHeight = 774

    function MAP:TransformSpawnPositionToUI(position, mapWidth, mapHeight)
        -- https://developer.valvesoftware.com/wiki/Creating_a_working_mini-map_for_CS:GO
		-- See exp_c18_v1 for a better example
        local mapMin = Vector(-3900, 6633, 0)
        local mapMax = Vector(5300, -5700, 0)

        -- Note that mapX = worldY and mapY = worldX
        local mapSizeX = mapMax.y - mapMin.y
        local mapSizeY = mapMax.x - mapMin.x

        local xNormalized = (position.y - mapMin.y) / mapSizeX
        local yNormalized = (position.x - mapMin.x) / mapSizeY

        local x = xNormalized * mapWidth
        local y = (1 - yNormalized) * mapHeight

        return x, y
    end
else
	if (game.GetMap() == "rp_c18_v2") then
		resource.AddFile("materials/experiment-redux/maps/rp_c18_v2_feathered_black.png")

		-- rp_c18_v2 (https://steamcommunity.com/sharedfiles/filedetails/?id=132937160)
		resource.AddWorkshop("132937160")
	end
end

-- Override specific entity keyvalues
function MAP:EntityKeyValue(entity, key, value)
	local class = entity:GetClass()
	local entityIndex = entity:EntIndex()

	-- Remove the monitor and camera and ambient alarm sounds, also judgement waiver timer
	if (class == "point_camera" or class == "func_monitor" or class == "ambient_generic" or class == "logic_timer") then
		if (IsValid(entity)) then
			entity:Remove()
		end

        return
    elseif (class == "logic_relay") then
        local bannedNames = {
			["jw_start"] = true,
            ["jw_end"] = true,
			["logic_tv_turnon"] = true,
			["logic_tv_camswitch"] = true,
			["logic_tv_camswitch2"] = true,
			-- ["ration_open"] = true, -- Terminal
			-- ["ration_close"] = true,
        }

		if (bannedNames[entity:GetName():lower()]) then
			if (IsValid(entity)) then
				entity:Remove()
			end
		end
	end
end
