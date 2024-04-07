local PLUGIN = PLUGIN

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
				character = client,
			})
		end
	end
end

function PLUGIN:GetRadioEntityToSetFrequency(client, frequency)
	local trace = client:GetEyeTraceNoCursor()

    if (not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "exp_stationary_radio") then
		return
	end

    if (trace.HitPos:Distance(client:GetShootPos()) > 192) then
        ix.util.Notify("This stationary radio is too far away!", client)
        return
    end

	return trace.Entity
end
