--- @realm shared
--- @alias InteractionSetCheckCallback fun(interactionSet: InteractionSet, player: Player, npcEntity: Entity): boolean

--- @realm shared
--- @class InteractionSetInfo
---
--- @field uniqueID string The unique identifier for this set of interactions
--- @field serverCheckShouldStart? InteractionSetCheckCallback A function that determines if the player should start with this interaction set based on their inventory, progression, etc.

--- @realm shared
--- @class InteractionSet : InteractionSetInfo
--- @field isDynamic? boolean Whether this interaction set is dynamically created.
--- @field interactions? Interaction[] The interactions that the player can choose from when this interaction set is started.
--- @field conditions? NpcCondition[] Conditions that must be met for this interaction set to be shown to the player.
local META = Schema.meta.interactionSet or {}
Schema.meta.interactionSet = META

META.__index = META

--- Metamethod to style how the interactionSet is displayed when printed as a string.
--- @return string
--- @realm shared
function META:__tostring()
	return "interactionSet[" .. self.uniqueID .. "]"
end

--- Gets the unique identifier for this interaction set.
--- @return string
--- @realm shared
function META:GetUniqueID()
	return self.uniqueID
end

--- Initializes the interactions for this set, or resets them if they
--- have already been initialized.
--- @realm shared
function META:InitInteractions()
	self.interactions = {}
end

--- Gets all interactions for this interaction set.
--- @return Interaction[]
--- @realm shared
function META:GetInteractions()
	return self.interactions
end

--- Registers an interaction for this interaction set. The order in which interactions are registered is
--- the order in which they will be displayed to the player. Using serverCheckShouldStart
--- you can determine which interactions should be shown to the player.
--- @param interactionInfo InteractionInfo
--- @return Interaction
--- @realm shared
function META:RegisterInteraction(interactionInfo)
	self.interactions = self.interactions or {}

	-- To support Lua refreshing, we first try to see if this interaction already exists.
	-- If it does, we update it. If it doesn't, we create it.
	local interaction = self:GetInteraction(interactionInfo.uniqueID)

	if (interaction) then
		table.Merge(interaction, interactionInfo, true)
	else
		--- @cast interactionInfo Interaction
		interaction = setmetatable(interactionInfo, Schema.meta.interaction)
		table.insert(self.interactions, interaction)
	end

	--- When Lua refreshes, we want to ensure the new responses do not
	--- append to the old responses. So we wipe the responses table.
	--- Shortly after this the responses will be re-registered anyway.
	interaction:InitResponses()

	return interaction
end

--- Gets an interaction by its uniqueID.
--- @param uniqueID string
--- @return Interaction?
--- @realm shared
function META:GetInteraction(uniqueID)
	if (not self.interactions) then
		return
	end

	for _, interaction in ipairs(self.interactions) do
		if (interaction.uniqueID == uniqueID) then
			return interaction
		end
	end
end

if (SERVER) then
	--- Checks if the player should start this interactionSet.
	--- @param player Player
	--- @param npcEntity Entity
	--- @realm server
	function META:CheckShouldStart(player, npcEntity)
		if (not self.serverCheckShouldStart) then
			-- Check if dynamically created interaction sets have conditions
			if (not Schema.npcCondition.CheckPass(self.conditions, player, npcEntity)) then
				return false
			end

			return true
		end

		return self:serverCheckShouldStart(player, npcEntity)
	end

	--- Determines a fitting interaction for the player and this interaction set.
	--- @param player Player
	--- @param npcEntity Entity
	--- @return Interaction?
	--- @realm server
	function META:GetDesiredInteraction(player, npcEntity)
		if (not self.interactions) then
			return
		end

		for _, interaction in ipairs(self.interactions) do
			local shouldStart = interaction:CheckShouldStart(player, npcEntity)

			if (DEBUG_SHOULD_START) then
				print("Interaction set", self.uniqueID, "interaction", interaction.uniqueID, "should start:", shouldStart)
			end

			if (shouldStart) then
				return interaction
			end
		end
	end
end
