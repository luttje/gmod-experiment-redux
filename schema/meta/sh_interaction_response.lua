--- @realm shared
--- @alias InteractionResponseTextCallback fun(response: InteractionResponse, player: Player, npcEntity: Entity): string

--- @realm shared
--- @alias InteractionResponseCheckCallback fun(response: InteractionResponse, player: Player, npcEntity: Entity): boolean

--- @realm shared
--- @alias InteractionResponseCallback fun(response: InteractionResponse, player: Player, npcEntity: Entity): string?

--- @realm shared
--- @class InteractionResponseInfo
--- @field answer string|InteractionResponseTextCallback|table The text that the player can choose to respond with.
---
--- @field next? string The uniqueID of the next interactionResponse that will be started if the player chooses this response.
---
--- @field checkCanChoose? InteractionResponseCheckCallback A function that determines if the player can choose this response
--- @field serverOnChoose? InteractionResponseCallback Called when the player chooses a response. Can override the next interaction by returning a uniqueID of an interaction.

--- @realm shared
--- @class InteractionResponse : InteractionResponseInfo
---
--- @field private index? number The index of this response in the interactionResponse's responses table. (This is set by the interactionResponse)
--- @field private conditions? NpcCondition[] Conditions that must be met for this response to be selectable.
--- @field private effects? NpcEffectInfo[] Effects that are executed when the player chooses this response.
local META = Schema.meta.interactionResponse or {}
Schema.meta.interactionResponse = META

META.__index = META

--- Metamethod to style how the interactionResponse is displayed when printed as a string.
--- @return string
--- @realm shared
function META:__tostring()
	return ("interactionResponse[#%i](%s)"):format(self.index, self.answer)
end

--- Gets the index of the response in the parent interaction responses table.
--- @return number
--- @realm shared
function META:GetIndex()
	return self.index
end

--- Sets the index of the response in the parent interaction responses table.
--- This is used internally and you should not call this unless you know what
--- you are doing.
--- @param index number
--- @realm shared
function META:SetIndex(index)
	self.index = index
end

--- Gets the text that the player can choose to respond with.
--- @param player Player
--- @param npcEntity Entity
--- @return string
--- @realm shared
function META:GetAnswer(player, npcEntity)
	if (isfunction(self.answer)) then
		return self.answer(self, player, npcEntity)
	end

	if (istable(self.answer)) then
		local randomIndex = math.random(1, #self.answer)
		local textOrFunction = self.answer[randomIndex]

		if (isfunction(textOrFunction)) then
			return textOrFunction(self, player, npcEntity)
		end

		return textOrFunction
	end

	--- @type string
	return self.answer
end

--- Gets the uniqueID of the next interaction that will be started if the player chooses this response.
--- @return string
--- @realm shared
function META:GetNextInteraction()
	return self.next
end

--- Checks if the player can choose this response.
--- @param player Player
--- @param npcEntity Entity
--- @return boolean
--- @realm shared
function META:CheckCanChoose(player, npcEntity)
	if (not self.checkCanChoose) then
		-- Check if dynamically created interaction sets have conditions. Only on the server since that is
		-- where the full data is.
		if (SERVER and not Schema.npcCondition.CheckPass(self.conditions, player, npcEntity)) then
			return false
		end

		return true
	end

	return self.checkCanChoose(self, player, npcEntity)
end

if (SERVER) then
	--- Calls the serverOnChoose callback for this response.
	--- @param player Player
	--- @param npcEntity Entity
	--- @return string? The uniqueID of the next interaction, if it should be overridden.
	--- @realm server
	function META:OnChooseNextInteraction(player, npcEntity)
		if (not self.serverOnChoose) then
			Schema.npcEffect.Execute(self.effects, player, npcEntity)

			return
		end

		return self.serverOnChoose(self, player, npcEntity)
	end
end
