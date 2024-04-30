local PLUGIN = PLUGIN

PLUGIN.name = "Radioing"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds stationary and handheld radios that can be used to communicate with others over frequencies."

ix.util.Include("sv_plugin.lua")
ix.util.Include("sh_commands.lua")

CHAT_RECOGNIZED = CHAT_RECOGNIZED or {}
CHAT_RECOGNIZED["radio"] = true

ix.chat.Register("radio", {
	prefix = { "/R", "/Radio" },
    indicator = "chatRadioing",

	OnChatAdd = function(self, speaker, text, anonymous, data)
        if (not speaker:IsPlayer()) then
            speaker = data.realSpeaker

			if (speaker == LocalPlayer())then
				return
			end
        end

		local name = anonymous and
			L"someone" or hook.Run("GetCharacterName", speaker, "radio") or
			(IsValid(speaker) and speaker:Name() or "Console")

		chat.AddText("(Radio) ", Color(75, 150, 50, 255), name .. " radios in \"" .. text .. "\"")
    end,

    CanHear = function(self, speaker, listener)
		local listenerCharacter = listener:GetCharacter()

		if (not listenerCharacter) then
			return false
		end

        local speakerFrequencies = {}


		if (speaker:IsPlayer()) then
            speakerFrequencies = PLUGIN:GetCharacterFrequencies(speaker:GetCharacter())
		elseif (speaker:GetClass() == "exp_stationary_radio") then
            speakerFrequencies = { speaker:GetFrequency() }
		end

		-- If the listener has handheld radios with the same frequency as the speaker, they can hear them.
		if (listener:IsCharacterOnFrequency(speakerFrequencies)) then
			return true
		end

		-- If the listener is near a stationary radio, they can hear the speaker if they're on the same frequency.
		local entities = ents.FindInSphere(listener:GetPos(), 256)

		for _, entity in ipairs(entities) do
			if (entity:GetClass() == "exp_stationary_radio" and not entity:GetTurnedOff()) then
				local frequency = entity:GetFrequency()

                if (frequency == speakerFrequency) then
					return true
				end
			end
		end

		return false
	end,

	CanSay = function(self, speaker, text)
		if (speaker:IsPlayer()) then
			local character = speaker:GetCharacter()

			if (not character or not character:GetInventory():HasItem("handheld_radio")) then
				return false
			end

			return true
		end

        local isStationaryRadio = speaker:GetClass() == "exp_stationary_radio"

		if (not isStationaryRadio) then
			return false
		end

		return true
    end,
})

--- Finds the frequencies a character is listening to by handheld radios they have in their inventory
--- @param character table The character to get the frequencies of.
function PLUGIN:GetCharacterFrequencies(character)
	local handheldRadios = character:GetInventory():GetItemsByUniqueID("handheld_radio")
	local frequencies = {}

	for _, item in pairs(handheldRadios) do
		local frequency = item:GetData("frequency", "101.1")
		table.insert(frequencies, frequency)
	end

	return frequencies
end

function PLUGIN:ValidateFrequency(frequency)
	if (not string.find(frequency, "^%d%d%d%.%d$")) then
		return false, "The radio frequency must look like xxx.x!"
	end

	local start, finish, decimal = string.match(frequency, "(%d)%d(%d)%.(%d)")

	start = tonumber(start)
	finish = tonumber(finish)
	decimal = tonumber(decimal)

	local isValidFrequency = start == 1 and finish > 0 and finish < 10 and decimal > 0 and decimal < 10

    if (not isValidFrequency) then
        return false, "The radio frequency must be between 101.1 and 199.9!"
    end

	return true
end
