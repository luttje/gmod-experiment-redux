local PLUGIN = PLUGIN

util.AddNetworkString("expSetMonitorTarget")
util.AddNetworkString("expMonitorsPrintPresets")
util.AddNetworkString("expSetMonitorVgui")
util.AddNetworkString("expPlayNemesisAudio")
util.AddNetworkString("expPlayNemesisSentences")

resource.AddFile("materials/experiment-redux/arrow.png")
resource.AddFile("materials/experiment-redux/arrow_forward.png")
resource.AddFile("materials/experiment-redux/arrow_backward.png")
resource.AddSingleFile("materials/experiment-redux/combinescanline.vmt")

function PLUGIN:RegisterSentence(uniqueID, sentence, parts)
    self.registeredSentences[uniqueID] = {
        sentence = sentence,
		parts = parts,
	}
end

ix.util.Include("sv_nemesis.lua")

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

function PLUGIN:GenerateSpeech(text, callback)
    if (self.disabled) then
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

-- lua_run ix.plugin.Get("nemesis_ai"):PlayNemesisSentences("nemesis_downfall", nil, "Jonathan")
function PLUGIN:PlayNemesisSentences(uniqueID, clients, ...)
    local data = self.registeredSentences[uniqueID]

    if (not data) then
		ix.util.SchemaErrorNoHalt("The sentence with the unique ID '" .. tostring(uniqueID) .. "' does not exist.")
        return
    end

	local sentence = data.sentence

    self:GenerateSentences(data.parts, function(audioWithPauses)
        net.Start("expPlayNemesisSentences")
		net.WriteString(sentence)
        net.WriteTable(audioWithPauses)

        if (istable(clients)) then
            net.Send(clients)
        else
            net.Broadcast()
        end
    end, ...)
end

function PLUGIN:SpawnMonitor(parent, monitor)
    local monitorEnt = ents.Create("exp_monitor")
    monitorEnt:SetMonitorWidth(monitor.width)
    monitorEnt:SetMonitorHeight(monitor.height)
    monitorEnt:SetMonitorScale(monitor.scale or 1)
    monitorEnt:ConfigureParent(parent, monitor.offsetPosition, monitor.offsetAngles)
    monitorEnt:Spawn()
    monitorEnt:SetPoweredOn(false)

    return monitorEnt
end

function PLUGIN:SetupParentEntity(parent, preset)
	parent:SetModel(preset.model)
	parent:SetModelScale(preset.modelScale or 1)
end

function PLUGIN:DramaticDelayEachMonitor(callback)
	local monitorEntities = ents.FindByClass("exp_monitor")

	for i = 1, #monitorEntities do
		local monitor = monitorEntities[i]

		timer.Simple(math.Rand(0, 1) * i, function()
			if (IsValid(monitor)) then
				callback(monitor)
			end
		end)
	end
end

function PLUGIN:SetTarget(entity)
	net.Start("expSetMonitorTarget")
	net.WriteEntity(entity)
	net.Broadcast()

	-- Dramatically turn on all monitors with delay
	self:DramaticDelayEachMonitor(function(monitor)
		monitor:SetPoweredOn(true)
	end)
end

function PLUGIN:RelateMonitorToParent(monitor, parent)
	parent._relatedMonitors = parent._relatedMonitors or {}
	parent._relatedMonitors[#parent._relatedMonitors + 1] = monitor

	if (not parent._uniqueNameForSaving) then
		PLUGIN.lastUniqueName = (PLUGIN.lastUniqueName or 0) + 1
		parent._uniqueNameForSaving = util.Base64Encode(os.time() .. "#" .. PLUGIN.lastUniqueName)
	end

	monitor._parentUniqueName = parent._uniqueNameForSaving
end

function PLUGIN:SaveData()
	local entities = {}

	local parentEntities = {}

	for _, monitor in ipairs(ents.FindByClass("exp_monitor")) do
		if (not IsValid(monitor) or not monitor._parentUniqueName) then
			continue
		end

		local data = {
			width = monitor:GetMonitorWidth(),
			height = monitor:GetMonitorHeight(),
			scale = monitor:GetMonitorScale(),
			parentName = monitor._parentUniqueName,
			angles = monitor:GetLocalAngles(),
			pos = monitor:GetLocalPos(),
		}

		parentEntities[monitor._parentUniqueName] = parentEntities[monitor._parentUniqueName] or monitor:GetParent()

		entities[#entities + 1] = data
	end

	local parentEntitiesData = {}

	for uniqueName, parentEntity in pairs(parentEntities) do
		if (not IsValid(parentEntity)) then
			continue
		end

		local data = {
			name = parentEntity._uniqueNameForSaving,
			model = parentEntity:GetModel(),
			scale = parentEntity:GetModelScale(),
			pos = parentEntity:GetPos(),
			angles = parentEntity:GetAngles()
		}

		local physicsObject = parentEntity:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			data.movable = physicsObject:IsMoveable()
		end

		parentEntitiesData[uniqueName] = data
	end

	self:SetData({
		entities = entities,
		parentEntities = parentEntitiesData
	})
end

function PLUGIN:LoadData()
	local data = self:GetData()

	if (not data) then
		return
	end

	-- Place the parent entities
	local parentEntities = {}

	for uniqueName, parentData in pairs(data.parentEntities or {}) do
		local parent = ents.Create("prop_physics")
        PLUGIN:SetupParentEntity(parent, {
            model = parentData.model,
            modelScale = parentData.scale,
		})
		parent:SetPos(parentData.pos)
		parent:SetAngles(parentData.angles)
		parent:Spawn()

		local physicsObject = parent:GetPhysicsObject()

		if (IsValid(physicsObject) and parentData.movable) then
			physicsObject:EnableMotion(parentData.movable)
		else
			parent:SetMoveType(MOVETYPE_NONE)
		end

		parent._uniqueNameForSaving = uniqueName
		parent._relatedMonitors = {}

		parentEntities[uniqueName] = parent
	end

	-- Place the monitors
	for _, monitorData in ipairs(data.entities or {}) do
		local parent = parentEntities[monitorData.parentName]

		if (not IsValid(parent)) then
			continue
		end

        self:SpawnMonitor(parent, {
			width = monitorData.width,
			height = monitorData.height,
			scale = monitorData.scale,
			offsetPosition = monitorData.pos,
            offsetAngles = monitorData.angles,
		})
	end
end
