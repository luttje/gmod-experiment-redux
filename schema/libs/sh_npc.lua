Schema.npc = Schema.npc or {}
Schema.npc.interactions = Schema.npc.interactions or {}

ix.chat.Register("npc", {
	CanSay = function(self, speaker, text)
		return not IsValid(speaker)
	end,
	OnChatAdd = function(self, speaker, text, anonymous, data)
		chat.AddText(Color(255, 255, 255), ("%s says \"%s\""):format(data[1], text))
	end,
})

function Schema.npc.RegisterInteraction(interaction, uniqueID)
	interaction.uniqueID = uniqueID
	Schema.npc.interactions[uniqueID] = interaction
end

function Schema.npc.GetInteraction(uniqueID)
	return Schema.npc.interactions[uniqueID]
end

function Schema.npc.GetInteractions()
	return Schema.npc.interactions
end

--- Checks if a player has completed an interaction, optionally within a scope (e.g: belonging to a quest/npc)
---@param client any
---@param interaction any
---@param scope? any
---@return boolean
function Schema.npc.HasCompletedInteraction(client, interaction, scope)
	local character = client:GetCharacter()

	if (character) then
		local completed = character:GetData("npcInteractions", {})

		if (scope) then
			if (completed[interaction] and completed[interaction][scope]) then
				return true
			end
		else
			if (completed[interaction]) then
				return true
			end
		end
	end

	return false
end
