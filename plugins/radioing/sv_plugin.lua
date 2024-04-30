local PLUGIN = PLUGIN

local playerMeta = FindMetaTable("Player")

function playerMeta:IsCharacterOnFrequency(frequencyOrFrequencies)
    local character = self:GetCharacter()

	if (not character) then
		return false
	end

	local frequencies = type(frequencyOrFrequencies) == "table" and frequencyOrFrequencies or { frequencyOrFrequencies }
	local localFrequencies = PLUGIN:GetCharacterFrequencies(character)

    for _, characterFrequency in ipairs(localFrequencies) do
		for _, frequency in ipairs(frequencies) do
			if (characterFrequency == frequency) then
				return true
			end
		end
	end

	return false
end

local relevantChatTypeDistances = {
	ic = 256,
	w = 128,
	radio = 256,
	y = 512,
}

function PLUGIN:PostPlayerSay(client, chatType, message, anonymous)
	if (not relevantChatTypeDistances[chatType]) then
		return
	end

	local distance = relevantChatTypeDistances[chatType]
	local entities = ents.FindInSphere(client:GetPos(), distance)
	local handledFrequencies = {}

	for _, entity in ipairs(entities) do
		if (entity:GetClass() == "exp_stationary_radio" and not entity:GetTurnedOff()) then
			local frequency = entity:GetFrequency()

			if (handledFrequencies[frequency]) then
				continue
			end

			handledFrequencies[frequency] = true

			ix.chat.Send(entity, "radio", message, false, nil, {
				realSpeaker = client,
			})
		end
	end
end
