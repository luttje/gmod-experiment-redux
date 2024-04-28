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

	-- Remove the monitor and camera
	if (class == "point_camera" or class == "func_monitor") then
		if (IsValid(entity)) then
			entity:Remove()
		end

		return
	end
end

-- This provides which soundscapes to replace and what to replace them with
-- This function is called once when the map is loaded (SERVER) and everytime a player
-- walks into the trigger zone of a soundscape (CLIENT). Keep it as fast as possible.
function MAP:AdjustCustomSoundscapes(customSoundscapes)
	customSoundscapes["experiment.UtilCity"] = {
		dsp = "129",
		rules = {
			{
				rule = "playrandom",
				time = "10,45",
				volume = "0.02,0.08",
				pitch = "100",
				-- position = "random", -- Not implemented
				soundlevel = SNDLVL_20dB,
				waves = {
					"ambient/machines/heli_pass1.wav",
					"ambient/machines/aircraft_distant_flyby1.wav",
					"ambient/machines/aircraft_distant_flyby3.wav",
				},
			},
			-- {
			-- 	rule = "playrandom",
			-- 	time = "10,30",
			-- 	volume = "0.01,0.05",
			-- 	pitch = "80,120",
			-- 	-- position = "random", -- Not implemented
			-- 	soundlevel = SNDLVL_20dB,
			-- 	waves = {
			-- 		"ambient/atmosphere/city_truckpass1.wav",
			-- 		"ambient/atmosphere/city_skypass1.wav",
			-- 	},
			-- },
			-- {
			-- 	rule = "playrandom",
			-- 	time = "10,60",
			-- 	volume = "0.01,0.05",
			-- 	pitch = "95,105",
			-- 	-- position = "random", -- Not implemented
			-- 	soundlevel = SNDLVL_20dB,
			-- 	waves = {
			-- 		"ambient/machines/truck_pass_distant1.wav",
			-- 		"ambient/machines/truck_pass_distant2.wav",
			-- 		"ambient/machines/truck_pass_distant3.wav",
			-- 		"ambient/machines/truck_pass_overhead1.wav",
			-- 	},
			-- },
		},
	}

	customSoundscapes["d1_trainstation.TerminalSquare"] = {
		dsp = "1",
		-- dsp_volume = "1.0", -- Not implemented

		rules = {
			{
				rule = "playsoundscape",
				name = "experiment.UtilCity",
				volume = "1.0",
			},
			{
				rule = "playlooping",
				volume = "0.2",
				wave = "*ambient/atmosphere/plaza_amb.wav",
				pitch = "100",
				-- attenuation = "0", -- Not implemented
			},
		},
	}

	customSoundscapes["d1_trainstation.Appartments"] = {
		rules = {
			{
				rule = "playlooping",
				volume = "0.5",
				wave = "*ambient/atmosphere/town_ambience.wav",
				pitch = "95",
				-- attenuation = "0", -- Not implemented
				soundlevel = SNDLVL_20dB,
			},
			{
				rule = "playrandom",
				time = "5,25",
				volume = "0.1,0.2",
				pitch = "95,105",
				-- position = "random", -- Not implemented
				soundlevel = SNDLVL_40dB,
				waves = {
					"ambient/materials/squeeker2.wav",
					"ambient/materials/squeekyfloor1.wav",
					"ambient/materials/squeekyfloor2.wav",
					"ambient/materials/flush1.wav",
					"ambient/materials/flush2.wav",
					"ambient/materials/footsteps_wood1.wav",
					"ambient/materials/footsteps_wood2.wav",
					"ambient/materials/rustypipes1.wav",
					"ambient/materials/rustypipes2.wav",
					"ambient/materials/rustypipes3.wav",
				},
			},
			{
				rule = "playrandom",
				time = "10,60",
				volume = "0.1,0.15",
				pitch = "95,105",
				-- position = "random", -- Not implemented
				soundlevel = SNDLVL_30dB,
				waves = {
					"physics/wood/wood_box_impact_hard3.wav",
					"physics/body/body_medium_impact_hard1.wav",
					"physics/body/body_medium_impact_soft1.wav",
					"physics/body/body_medium_impact_soft2.wav",
					"physics/body/body_medium_impact_soft3.wav",
					"physics/body/body_medium_impact_soft4.wav",
					"physics/body/body_medium_impact_soft5.wav",
					"physics/body/body_medium_impact_soft6.wav",
					"physics/body/body_medium_impact_soft7.wav",
				},
			},
		},
	}

	customSoundscapes["d1_trainstation.QuietCourtyard"] = {
		dsp = "1",
		-- dsp_volume = "1.0", -- Not implemented

		rules = {
			{
				rule = "playsoundscape",
				name = "experiment.UtilCity",
				volume = "0.6",
			},
			{
				rule = "playlooping",
				volume = "0.1",
				wave = "*ambient/atmosphere/plaza_amb.wav",
				pitch = "100",
				-- attenuation = "0", -- Not implemented
			},
		},
	}

	customSoundscapes["d3_citadel.breen_hall"] = {
		dsp = "25",
		rules = {
			{
				rule = "playlooping",
				volume = "0.1",
				pitch = "100",
				wave = "ambient/atmosphere/quiet_cellblock_amb.wav",
			},
		},
	}

	customSoundscapes["d3_citadel.breen_office"] = {
		dsp = "25",
		rules = {
			{
				rule = "playlooping",
				volume = "0.08",
				pitch = "100",
				wave = "ambient/atmosphere/quiet_cellblock_amb.wav",
			},
		},
	}

	customSoundscapes["d1_trainstation.Turnstyle"] = {
		dsp = "1",
		-- dsp_volume = "0.7", -- Not implemented

		rules = {
			{
				rule = "playsoundscape",
				name = "experiment.UtilCity",
				volume = "0.2",
			},
			{
				rule = "playlooping",
				volume = "0.15",
				wave = "*ambient/atmosphere/plaza_amb.wav",
				pitch = "100",
				-- attenuation = "0", -- Not implemented
			},
		},
	}

	customSoundscapes["d1_canals.waterpuzzleroom"] = {
		dsp = "1",
		rules = {
			{
				rule = "playsoundscape",
				name = "d1_canals.util_fardrips",
				volume = "0.15",
			},
			{
				rule = "playlooping",
				volume = "0.1",
				wave = "ambient/water/drip_loop1.wav",
				pitch = "100",
			},
			{
				rule = "playlooping",
				volume = "0.15",
				wave = "ambient/atmosphere/corridor2.wav",
				pitch = "100",
			},
			{
				rule = "playlooping",
				volume = "0.05",
				wave = "ambient/atmosphere/cargo_hold2.wav",
				pitch = "100",
			},
		},
	}
end
