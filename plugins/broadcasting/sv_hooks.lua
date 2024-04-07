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

	for _, entity in ipairs(entities) do
		if (entity:GetClass() == "exp_broadcaster" and not entity:GetTurnedOff()) then
			ix.chat.Send(client, "broadcast", message)

			-- Let's just send over a single broadcaster
			break
		end
	end
end
