local PLUGIN = PLUGIN

local FADE_TIME = 1

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

	self:FadeOutSoundPatches(function()
		client.expSoundPatchesInfo = {}
		client.expPlayRandom = {}

		self:CreateSoundscapeSoundPatches(customSoundscapes, soundscapeKey)
	end)
end

function PLUGIN:PlaySoundPatch(name, parentDSP, parentVolume, parentPitch, fadeInTime)
	local client = LocalPlayer()
	local soundPatchInfo = client.expSoundPatchesInfo[name]

	fadeInTime = fadeInTime or 0
	parentVolume = parentVolume or 1
	parentPitch = parentPitch or 100
	parentDSP = parentDSP or 0

	-- We always overwrite the sound, so a random value will be picked from table the tables of sound files, volumes and pitches provided to sound.Add
	local soundPatch = CreateSound(client, name)
	client.expSoundPatchesInfo[name] = {
		soundPatch = soundPatch,
		fadeInTime = fadeInTime,
		originalVolume = parentVolume,
		originalPitch = parentPitch,
	}

	soundPatch:SetDSP(parentDSP)

	if (not fadeInTime) then
		soundPatch:PlayEx(parentVolume, parentPitch)
	else
		soundPatch:PlayEx(0, parentPitch)
		soundPatch:ChangeVolume(parentVolume, fadeInTime)
	end

	return soundPatchInfo
end

--- @param callback function
--- @param fadeTime? number
function PLUGIN:FadeOutSoundPatches(callback, fadeTime)
	local client = LocalPlayer()

	fadeTime = fadeTime or FADE_TIME

	-- Clear all previous sound patches
	for soundName, soundPatchInfo in pairs(client.expSoundPatchesInfo or {}) do
		soundPatchInfo.soundPatch:FadeOut(fadeTime)
	end

	timer.Create("expCustomSoundscapesFadeOut", fadeTime, 1, function()
		if (IsValid(client)) then
			callback()
		end
	end)
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

	if (not customSoundscape) then
		self:PlaySoundPatch(soundscapeKey, parentDSP, parentVolume, parentPitch, FADE_TIME)
		return
	end

	for ruleIndex, rule in ipairs(customSoundscape.rules) do
		if (rule.rule == "playsoundscape") then
			local volume, pitch
			local ruleVolume = self:NormalizeNumbers(rule.volume or 1, true)
			local rulePitch = self:NormalizeNumbers(rule.pitch or 100, true)

			if (parentVolume) then
				volume = parentVolume * ruleVolume
			else
				volume = ruleVolume
			end

			if (parentPitch) then
				pitch = parentPitch * rulePitch
			else
				pitch = rulePitch
			end

			self:CreateSoundscapeSoundPatches(
				customSoundscapes,
				rule.name,
				parentDSP,
				parentVolume,
				parentPitch
			)
		elseif (rule.rule == "playlooping") then
			local name = self:GetCustomSoundscapeName(soundscapeKey, ruleIndex)
			self:PlaySoundPatch(
				name,
				parentDSP,
				parentVolume,
				parentPitch,
				FADE_TIME
			)
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

	if (not IsValid(client)) then
		return
	end

	local character = client:GetCharacter()

	if (character and Schema.perk.GetOwned("earplugs")) then
		return
	end

	if (not client.expPlayRandom) then
		return
	end

	for i, randomSound in ipairs(client.expPlayRandom) do
		if (CurTime() < randomSound.playAt) then
			continue
		end

		self:PlaySoundPatch(randomSound.name, randomSound.parentDSP, randomSound.parentVolume, randomSound.parentPitch)

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

	local customSoundscapes = PLUGIN:GetCustomSoundscapes()
	PLUGIN:SetupSoundPatches(customSoundscapes, soundscapeKey)
end)
