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

	self:LockerRotThink()
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

-- Ensure that everyone gets the target added to PVS when the target is set.
function PLUGIN:SetupPlayerVisibility(client)
    if (not IsValid(self.currentTarget)) then
        return
	end

	local targetPosition = self.currentTarget:GetPos()

    -- "If we don't test if the PVS is already loaded, it could crash the server."
	-- According to: https://wiki.facepunch.com/gmod/Global.AddOriginToPVS
	if (not client:TestPVS(targetPosition)) then
		AddOriginToPVS(targetPosition)
	end
end
