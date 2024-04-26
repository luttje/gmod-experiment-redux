Schema.npc = ix.util.GetOrCreateCommonLibrary("NPC", function() return setmetatable({}, Schema.meta.npc) end)

ix.chat.Register("npc", {
	CanSay = function(self, speaker, text)
		return not IsValid(speaker)
	end,
	OnChatAdd = function(self, speaker, text, anonymous, data)
		local format = data.yelling and "%s yells \"%s\"" or "%s says \"%s\""

		chat.AddText(Color(255, 255, 255), format:format(data.name, text))
	end,
})

--- Checks if a player has completed an interaction, optionally within a scope (e.g: belonging to a quest/npc)
--- @param client Player
--- @param interaction any
--- @param scope? any
--- @return boolean
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
