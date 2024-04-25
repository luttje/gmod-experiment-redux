local MAP = MAP

MAP.name = "City 18"
MAP.mapName = "rp_c18_v2"

MAP.waitingPosition = Vector(4284.469238, 1271.594116, 1974.027466)
MAP.waitingAngles = Angle(-2.494961, 54.302872, 0)

if (CLIENT) then
    MAP.backgroundMaterial = Material("experiment-redux/maps/rp_c18_v2_feathered_black.png")
    MAP.backgroundOriginalWidth = 1050
    MAP.backgroundOriginalHeight = 774

    function MAP:TransformSpawnPositionToUI(position, mapWidth, mapHeight)
        -- TODO: Make a tool for creating the screenshot, and automatically capturing these bounds
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
    resource.AddFile("materials/experiment-redux/maps/rp_c18_v2_feathered_black.png")

    -- Improved (quieter) soundscapes
    resource.AddFile("scripts/soundscapes_rp_c18_v2.txt")
end

-- Note that I made the keys lowercase to prevent mistakes.
MAP.soundscapeReplacements = {
	["d1_trainstation.terminalsquare"] = "experiment.PlazaSquare",
	["d1_trainstation.appartments"] = "experiment.Apartments",
    ["d1_trainstation.quietcourtyard"] = "experiment.QuietCourtyard",
    -- ["prison.util_louder_cellblock"] = "", -- Fine as is, its just: ambient/atmosphere/underground.wav
	["d3_citadel.breen_hall"] = "experiment.BreenHall",
    ["d3_citadel.breen_office"] = "experiment.BreenOffice",
    ["d1_trainstation.turnstyle"] = "experiment.TurnStyle",
	["d1_canals.waterpuzzleroom"] = "experiment.WaterPuzzleRoom",
}

-- Override specific entity keyvalues
function MAP:EntityKeyValue(entity, key, value)
	local class = entity:GetClass()
    local entityIndex = entity:EntIndex()

	-- Remove the judgement waiver and camera buttons, and monitor and camera
    if (class == "point_camera" or class == "func_monitor"
	or entityIndex == 140 or entityIndex == 142) then
        if (IsValid(entity)) then
            entity:Remove()
        end

        return
    end

    if (class ~= "env_soundscape") then
        return
    end

    if (key:lower() ~= "soundscape") then
        return
    end

	return self.soundscapeReplacements[value:lower()]
end
