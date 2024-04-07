local PLUGIN = PLUGIN

PLUGIN.name = "Radioing"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds stationary and handheld radios that can be used to communicate with others over frequencies."

ix.util.Include("sv_hooks.lua")
ix.util.Include("sh_commands.lua")

ix.chat.Register("radio", {
	CanHear = function(self, speaker, listener)
		local listenerCharacter = listener:GetCharacter()

		if (not listenerCharacter) then
			return false
		end

		local speakerFrequency

		if (speaker:IsPlayer()) then
			local speakerCharacter = speaker:GetCharacter()
			speakerFrequency = speakerCharacter:GetData("frequency")
		elseif (speaker:GetClass() == "exp_stationary_radio") then
			speakerFrequency = speaker:GetFrequency()
		end

		if (listenerCharacter:GetInventory():HasItem("handheld_radio")) then
			local listenerFrequency = listenerCharacter:GetData("frequency")

			if (listenerFrequency and listenerFrequency == speakerFrequency) then
				return true
			end
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

			if (not character) then
				return false
			end

			if (not character:GetInventory():HasItem("handheld_radio")) then
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

	OnChatAdd = function(self, speaker, text, anonymous, data)
		if (not speaker:IsPlayer()) then
			speaker = data.character
		end

		chat.AddText("(Radio) ", Color(75, 150, 50, 255), speaker:Name() .. " radios in \"" .. text .. "\"")
	end,

	prefix = { "/R", "/Radio" },
	indicator = "chatRadioing",
})

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
