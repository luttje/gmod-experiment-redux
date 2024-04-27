local PLUGIN = PLUGIN

function PLUGIN:NormalizeNumbers(numbers, returnRandomIfTable)
	local numbersTable

	if (isstring(numbers)) then
	 	numbersTable = string.Split(numbers, ",")
	elseif (istable(numbers)) then
		numbersTable = numbers
	elseif (isnumber(numbers)) then
		numbersTable = { numbers }
	end

	if (#numbersTable == 1) then
		return tonumber(numbersTable[1])
	end

	for i = 1, #numbersTable do
		numbersTable[i] = tonumber(numbersTable[i]) or 0
	end

	if (returnRandomIfTable) then
		return math.Rand(numbersTable[1], numbersTable[2])
	end

	return numbersTable
end

function PLUGIN:CreateSoundscapeSounds()
	local customSoundscapes = self:GetCustomSoundscapes()

	for soundscapeKey, customSoundscape in pairs(customSoundscapes) do
		for ruleIndex, rule in ipairs(customSoundscape.rules) do
			if (rule.rule ~= "playrandom" and rule.rule ~= "playlooping") then
				continue
			end

			local newSound = {
				name = self:GetCustomSoundscapeName(soundscapeKey, ruleIndex),

				-- ? are these ignored by CreateSound? v
				channel = rule.channel or CHAN_STATIC,
				level = rule.soundlevel or SNDLVL_NONE,
				volume = self:NormalizeNumbers(rule.volume),
				pitch = self:NormalizeNumbers(rule.pitch),
				-- ? ^

				sound = rule.wave or rule.waves,
			}

			sound.Add(newSound)
		end
	end
end

--- Will create soundpatches stored on the LocalPlayer() entity.
--- This makes sure there are enough for all the rules in the custom soundscapes.
--- @param customSoundscapes table
--- @param soundscapeKey string
function PLUGIN:SetupSoundPatches(customSoundscapes, soundscapeKey)
	local client = LocalPlayer()

	-- Clear all previous sound patches
	for soundName, soundPatch in pairs(client.expSoundPatches or {}) do
		soundPatch:Stop()
	end

	client.expSoundPatches = {}
	client.expPlayRandom = {}

	self:CreateSoundscapeSoundPatches(customSoundscapes, soundscapeKey)
end

function PLUGIN:GetOrCreateSoundPatch(name, parentDSP)
	local client = LocalPlayer()
	local soundPatch = client.expSoundPatches[name]

	if (not soundPatch) then
		soundPatch = CreateSound(client, name)
		client.expSoundPatches[name] = soundPatch
	else
		soundPatch:Stop()
	end

	soundPatch:SetDSP(parentDSP or 0)

	return soundPatch
end

function PLUGIN:CreateRandomSoundInfo(name, rule, parentDSP, parentVolume, parentPitch)
	if (not rule.time) then
		PrintTable(rule)
		ix.util.SchemaError("Missing time for playrandom rule %s", rule.rule)
	end

	local randomSound = {
		rule = rule,
		name = name,
		parentDSP = parentDSP,
		parentVolume = parentVolume,
		parentPitch = parentPitch,
		playAt = CurTime() + self:NormalizeNumbers(rule.time, true),
	}

	return randomSound
end

--- Creates a soundpatch for a specific rule in a soundscape.
--- If it's a "playsoundscape" rule, it will recursively call this function.
--- @param customSoundscapes table
--- @param soundscapeKey string
--- @param parentDSP? number
--- @param parentVolume? number # When a playsoundscape specifies volume, child sounds should be multiplied by this.
--- @param parentPitch? number # When a playsoundscape specifies pitch, child sounds should be multiplied by this.
function PLUGIN:CreateSoundscapeSoundPatches(customSoundscapes, soundscapeKey, parentDSP, parentVolume, parentPitch)
	local customSoundscape = customSoundscapes[soundscapeKey]
	local client = LocalPlayer()

	parentDSP = parentDSP or customSoundscape.dsp
	parentVolume = parentVolume or 1
	parentPitch = parentPitch or 100

	if (not customSoundscape) then
		local soundPatch = self:GetOrCreateSoundPatch(soundscapeKey, parentDSP)
		soundPatch:PlayEx(parentVolume, parentPitch)
		return
	end

	for ruleIndex, rule in ipairs(customSoundscape.rules) do
		if (rule.rule == "playsoundscape") then
			self:CreateSoundscapeSoundPatches(
				customSoundscapes,
				rule.name,
				parentDSP,
				parentVolume,
				parentPitch
			)
		elseif (rule.rule == "playlooping") then
			local name = self:GetCustomSoundscapeName(soundscapeKey, ruleIndex)
			local soundPatch = self:GetOrCreateSoundPatch(name, parentDSP)
			soundPatch:PlayEx(parentVolume, parentPitch)
		elseif (rule.rule == "playrandom") then
			local name = self:GetCustomSoundscapeName(soundscapeKey, ruleIndex)

			client.expPlayRandom = client.expPlayRandom or {}
			client.expPlayRandom[#client.expPlayRandom + 1] = self:CreateRandomSoundInfo(
				name, rule, parentDSP, parentVolume, parentPitch
			)
		else
			ix.util.SchemaErrorNoHalt("Unknown soundscape rule", rule.rule)
			PrintTable(rule)
		end
	end
end

function PLUGIN:PlayerSecondElapsed()
	local client = LocalPlayer()

	if (not IsValid(client) or not client.expPlayRandom) then
		return
	end

	for i, randomSound in ipairs(client.expPlayRandom) do
		if (CurTime() < randomSound.playAt) then
			continue
		end

		local soundPatch = self:GetOrCreateSoundPatch(randomSound.name, randomSound.parentDSP)
		soundPatch:PlayEx(randomSound.parentVolume, randomSound.parentPitch)

		client.expPlayRandom[i] = self:CreateRandomSoundInfo(
			randomSound.name,
			randomSound.rule,
			randomSound.parentDSP,
			randomSound.parentVolume,
			randomSound.parentPitch
		)
	end
end

net.Receive("expSetCustomSoundscape", function()
	local soundscapeKey = net.ReadString()
	local client = LocalPlayer()

	if (not IsValid(client)) then
		return
	end

	if (client.expSoundscapeKey == soundscapeKey) then
		return
	end

	client.expSoundscapeKey = soundscapeKey

	print("Set current soundscape", soundscapeKey)

	local customSoundscapes = PLUGIN:GetCustomSoundscapes()
	PLUGIN:SetupSoundPatches(customSoundscapes, soundscapeKey)
end)
