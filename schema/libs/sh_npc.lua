Schema.npc = Schema.npc or {}
Schema.npc.stored = Schema.npc.stored or {}

ix.chat.Register("npc", {
	CanSay = function(self, speaker, text)
		return not IsValid(speaker)
	end,
	OnChatAdd = function(self, speaker, text, anonymous, data)
		chat.AddText(Color(255, 255, 255), ("%s says \"%s\""):format(data[1], text))
	end,
})

function Schema.npc.LoadFromDir(directory)
    local oldGlobal = NPC

    for _, fileName in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local uniqueID = string.lower(fileName:sub(4, -5))

        NPC = Schema.npc.stored[uniqueID] or setmetatable({}, Schema.meta.npc)
        NPC.uniqueID = uniqueID

        ix.util.Include(directory .. "/" .. fileName, "shared")

        Schema.npc.stored[NPC.uniqueID] = NPC
    end

	NPC = oldGlobal
end

function Schema.npc.Get(uniqueID)
	return Schema.npc.stored[uniqueID]
end

function Schema.npc.GetAll()
	return Schema.npc.stored
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
