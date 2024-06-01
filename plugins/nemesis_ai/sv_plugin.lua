local PLUGIN = PLUGIN

local API_KEY, APP_URL, AUDIO_URL

-- On loading the plugin we will get the API_KEY that we can use to authenticate with the moderation API.
function PLUGIN:OnLoaded()
    local envFile = file.Read(PLUGIN.folder .. "/voice-generator/.env", "LUA")

    if (not envFile) then
        ix.util.SchemaErrorNoHalt("The .env file is missing from the web folder for Nemesis AI.")
        self.disabled = true
        return
    end

    local variables = Schema.util.EnvToTable(envFile)

    -- An API key to authenticate with the voice generation API
    API_KEY = variables.API_SECRET

    -- The URL of the voice generation API
    APP_URL = Schema.util.ForceEndPath(variables.APP_URL)

    -- Where the audio files are stored. An idea is to reuse the FastDL server for this.
    AUDIO_URL = Schema.util.ForceEndPath(variables.AUDIO_URL)
end

function PLUGIN:SaveData()
    self:SaveMonitorData()
end

function PLUGIN:LoadData()
	self:LoadMonitorData()
end

-- Checks if any of the top characters are online. If so, taunt them and set a bounty in the form of the 'Locker Rot Virus'
function PLUGIN:Think()
	local isEnabled = ix.config.Get("nemesisAiEnabled")

	if (not isEnabled) then
		return
	end

	local interval = ix.config.Get("nemesisAiLockerRotIntervalSeconds")

	if (Schema.util.Throttle("NemesisMetricLockerRotGrace", interval)) then
		return
	end

	-- Don't overwhelm the server with multiple locker rot events.
	local activeLockerRotEvent = self:GetLockerRotEvent()

	if (activeLockerRotEvent) then
		return
	end

	local leaderboardsPlugin = ix.plugin.Get("leaderboards")
	local onlineCharactersByID = {}

	-- Collect online characters that qualify to become locker rot victims.
	for _, client in ipairs(player.GetAll()) do
		local character = client:GetCharacter()

		if (not character) then
			continue
		end

		-- Make sure all players have played for at least a couple hours on their characters
		if (character:GetCreateTime() + (60 * 2) > os.time()) then
			print("Skipping locker rot for " ..
				character:GetName() .. " because they haven't played for at least 2 hours.")
			continue
		end

		-- Make sure they've played for at least 5 minutes (so they have a chance to load into the server)
		if (client.expLastCharacterLoadedAt + (60 * 5) > CurTime()) then
			-- continue -- TODO: Uncomment this (it's commented out for testing purposes)
		end

		-- Check if the character has a locker rot cooldown, so we don't spam them with challenges.
		local lockerRotGraceEndsAt = character:GetData("nemesisLockerRotGraceEndsAt")

		if (lockerRotGraceEndsAt and lockerRotGraceEndsAt <= os.time()) then
			lockerRotGraceEndsAt = nil
			character:SetData("nemesisLockerRotGraceEndsAt", lockerRotGraceEndsAt)
		end

		if (lockerRotGraceEndsAt) then
			continue
		end

		if (not character:GetLockerInventory()) then
			-- This character has never visited their locker, so they can't have any items to infect.
			continue
		end

		onlineCharactersByID[character:GetID()] = client
	end

	-- We try to find the player that has the highest rank of all the metrics, and infect their locker.
	leaderboardsPlugin:GetTopCharacters(function(metricInfo)
		local highestRankingTargets = {}
		local highestRank = -1

		for metricID, info in pairs(metricInfo) do
			local metricName = tostring(info.name)
			local taunts = self.metricTaunts[metricName]

			if (not taunts) then
				ix.util.SchemaErrorNoHalt("No taunt sentence registered for metric '" .. metricName .. "'.")
				continue
			end

			local topCharacters = info.topCharacters

			for rank, data in ipairs(topCharacters) do
				local characterID = data.character_id
				local client = onlineCharactersByID[characterID]

				if (not IsValid(client)) then
					continue
				end

				local lockerRotEvent = {
					targetCharacter = client:GetCharacter(),
					value = data.value,
					metricName = metricName,
					taunts = taunts,
					rank = rank,
				}

				if (rank > highestRank) then
					highestRank = rank
					highestRankingTargets = { lockerRotEvent }
				elseif (rank == highestRank) then
					highestRankingTargets[#highestRankingTargets + 1] = lockerRotEvent
				end
			end
		end

		if (highestRank == -1) then
			-- None of the metrics have any top characters online.
			return
		end

		-- If there are multiple characters with the same highest rank, we pick one at random.
		local lockerRotEvent = highestRankingTargets[math.random(#highestRankingTargets)]

		self:StartLockerRotEvent(lockerRotEvent.targetCharacter, lockerRotEvent)
	end)
end

function PLUGIN:GenerateSpeech(text, callback)
    if (self.disabled) then
        return
    end

	-- lua_run DEBUG_DONT_GENERATE_SPEECH = true
    if (DEBUG_DONT_GENERATE_SPEECH) then
		callback("skipping_generating_speech_for_easy_testing.wav")
		return
	end

    local endpoint = APP_URL .. "generate-voice"

    http.Post(
        endpoint,
        {
            text = text,
            api_key = API_KEY
        },
        function(body, len, headers, code)
            if (code == 200) then
                callback(body)
            else
                ix.util.SchemaErrorNoHalt("Error fetching the .wav file:", code)
            end
        end,
        function(error)
            ix.util.SchemaErrorNoHalt("Error fetching the .wav file:", error)
        end
    )
end

-- lua_run ix.plugin.Get("nemesis_ai"):PlayNemesisAudio("Hello world!")
function PLUGIN:PlayNemesisAudio(text, clients)
	self:GenerateSpeech(text, function(body)
		local audioUrl = AUDIO_URL .. body

		net.Start("expPlayNemesisAudio")
		net.WriteString(text)
        net.WriteString(audioUrl)

		if (istable(clients)) then
			net.Send(clients)
		else
			net.Broadcast()
		end
	end)
end

function PLUGIN:GenerateSentences(parts, callback, ...)
	local args = {...}
    local audioWithPauses = {}

    local function generatePart(index)
        local part = parts[index]

        if (not part) then
            callback(audioWithPauses)
			return
		end

		local duration = part[1]
		local text = part[2]:format(unpack(args))

		self:GenerateSpeech(text, function(body)
			audioWithPauses[#audioWithPauses + 1] = {
				duration,
				AUDIO_URL .. body
			}

			generatePart(index + 1)
		end)
	end

	generatePart(1)
end

-- lua_run ix.plugin.Get("nemesis_ai"):PlayNemesisSentences("downfall", nil, "Jonathan")
function PLUGIN:PlayNemesisSentences(uniqueID, clients, character, callback)
    local data = self.registeredSentences[uniqueID]

    if (not data) then
		ix.util.SchemaErrorNoHalt("The sentence with the unique ID '" .. tostring(uniqueID) .. "' does not exist.")
        return
    end

    local sentence = data.sentence:format(character)

	ix.util.SchemaPrint("Nemesis AI: " .. tostring(sentence))

    self:GenerateSentences(data.parts, function(audioWithPauses)
        net.Start("expPlayNemesisSentences")
		net.WriteString(sentence)
        net.WriteTable(audioWithPauses)

        if (istable(clients)) then
            net.Send(clients)
        else
            net.Broadcast()
        end

		if (callback) then
			callback()
		end
    end, character)
end
