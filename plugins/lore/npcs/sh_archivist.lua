local PLUGIN = PLUGIN

--- @type ExperimentNpc
--- @diagnostic disable-next-line: assign-type-mismatch
local NPC = NPC

NPC.name = "Principal Archivist"
NPC.description = "A wise looking man, who seems to know more than he lets on."
NPC.model = "models/Humans/Group03/male_08.mdl"
NPC.voicePitch = 95

NPC.rewardMoney = 2500

-- Progression constants
NPC.PROGRESSION_FIRST_MEETING_COMPLETED = "firstMeetingCompleted"
NPC.PROGRESSION_COLLECTION_ACCEPTED = "collectionAccepted"

local INTERACTION_SET = NPC:RegisterInteractionSet({
	--- The unique identifier for this interaction set.
	uniqueID = "archivist_Start",

	--- A function that determines if the player should start with this interaction set based on their inventory, progression, etc.
	--- This is called on the server, and should return a boolean.
	--- @param interactionSet InteractionSet
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interactionSet, player, npcEntity)
		-- Always allow interaction with the archivist
		return true
	end,
})

--[[
	First meeting with the archivist
--]]

local INTERACTION_FIRST_MEETING = INTERACTION_SET:RegisterInteraction({
	--- Uniquely identifies the interaction. Is used to know where the player is in the conversation.
	uniqueID = "firstMeeting",

	text = [[
		Hi! Nice to meet you
	]],

	--- Determines if the NPC will start with this interaction when the player interacts with them.
	--- @param interaction Interaction
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Start this interaction if the player has never met the archivist before
		return not Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_FIRST_MEETING_COMPLETED, true)
	end,
})

INTERACTION_FIRST_MEETING:RegisterResponse({
	answer = "Nice to meet you, what do you have to tell me?",
	next = "introResponse",

	--- Called when the player chooses this response. This is called on the server.
	--- @param response InteractionResponse
	--- @param player Player
	--- @param npcEntity Entity
	--- @return string? # Can override the next interaction to start with a different one
	serverOnChoose = function(response, player, npcEntity)
		-- Mark first meeting as completed
		Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_FIRST_MEETING_COMPLETED, true)
	end,
})

INTERACTION_FIRST_MEETING:RegisterResponse({
	answer = "I'm not interested.",

	--- Called when the player chooses this response. This is called on the server.
	--- @param response InteractionResponse
	--- @param player Player
	--- @param npcEntity Entity
	--- @return string? # Can override the next interaction to start with a different one
	serverOnChoose = function(response, player, npcEntity)
		-- Mark first meeting as completed even if they declined
		Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_FIRST_MEETING_COMPLETED, true)

		-- Choose random goodbye message
		local goodbyes = {
			"Goodbye then",
			"Goodbye",
			"Goodbye, and good luck",
			"Goodbye, and remember what I told you",
			"Goodbye, and remember what you've learned",
			"Goodbye, and remember what you've seen",
			"I'll be here when you're ready",
			"I will be waiting for you",
		}

		npcEntity:PrintChat(goodbyes[math.random(#goodbyes)])
	end,
})

--[[
	Consequent meetings with the archivist
--]]

local INTERACTION_CONSEQUENT_MEETING = INTERACTION_SET:RegisterInteraction({
	uniqueID = "consequentMeeting",

	--- The text can be a function that returns different messages
	text = function(interaction, player, npcEntity)
		local messages = {
			"Hey you, come here. I have something to tell you.",
			"Hello, I have some information that you might find useful.",
			"Hey, I have some information that you might find interesting.",
			"Hi, I have some information that you might find useful.",
		}
		return messages[math.random(#messages)]
	end,

	--- Determines if the NPC will start with this interaction when the player interacts with them.
	--- @param interaction Interaction
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Start this interaction if the player has met the archivist before but hasn't accepted the collection mission
		return Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_FIRST_MEETING_COMPLETED, true)
			and not Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_COLLECTION_ACCEPTED, true)
	end,
})

INTERACTION_CONSEQUENT_MEETING:RegisterResponse({
	answer = "What do you have to tell me?",
	next = "introResponse",
})

INTERACTION_CONSEQUENT_MEETING:RegisterResponse({
	answer = "I'm not interested.",
})

--[[
	Introduction response about the world not being what it seems
--]]

local INTERACTION_INTRO_RESPONSE = INTERACTION_SET:RegisterInteraction({
	uniqueID = "introResponse",

	text = [[
		Things are not what they seem. The world is not as it appears.
	]],

	--- Determines if the NPC will start with this interaction when the player interacts with them.
	--- @param interaction Interaction
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Never start this interaction directly, it only follows other interactions
		return false
	end,
})

INTERACTION_INTRO_RESPONSE:RegisterResponse({
	answer = "What do you mean? What's going on?",
	next = "whatIsGoingOn",
})

INTERACTION_INTRO_RESPONSE:RegisterResponse({
	answer = "Okay wacko, I'm out of here.",
})

--[[
	Explanation of what's going on
--]]

local INTERACTION_WHAT_IS_GOING_ON = INTERACTION_SET:RegisterInteraction({
	uniqueID = "whatIsGoingOn",

	text = [[
		There are things happening that you cannot see, but there's a way to see them.
		If you're interested, I can show you how to see the world as it truly is.
	]],

	--- Determines if the NPC will start with this interaction when the player interacts with them.
	--- @param interaction Interaction
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Never start this interaction directly, it only follows other interactions
		return false
	end,
})

INTERACTION_WHAT_IS_GOING_ON:RegisterResponse({
	answer = "I'm interested, show me.",
	next = "collectionAccepted",
})

INTERACTION_WHAT_IS_GOING_ON:RegisterResponse({
	answer = "I'm not interested.",
})

--[[
	Collection mission accepted
--]]

local INTERACTION_COLLECTION_ACCEPTED = INTERACTION_SET:RegisterInteraction({
	uniqueID = "collectionAccepted",

	text = [[
		I can show you how to see the world as it truly is, but you must be willing to learn.
		Collect as much information as you can, and I will show you the way.

		<b>Throughout this city you'll find diaries, notes, and other documents</b> that will help uncover the truth.

		<b>Bring me the information you find, and I will show you the way.</b>
	]],

	--- Determines if the NPC will start with this interaction when the player interacts with them.
	--- @param interaction Interaction
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Never start this interaction directly, it only follows other interactions
		return false
	end,
})

INTERACTION_COLLECTION_ACCEPTED:RegisterResponse({
	answer = "Alright I'll do it.",
	next = "collectionAcceptResponse",

	--- Called when the player chooses this response. This is called on the server.
	--- @param response InteractionResponse
	--- @param player Player
	--- @param npcEntity Entity
	--- @return string? # Can override the next interaction to start with a different one
	serverOnChoose = function(response, player, npcEntity)
		-- Mark collection as accepted
		Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_COLLECTION_ACCEPTED, true)
	end,
})

INTERACTION_COLLECTION_ACCEPTED:RegisterResponse({
	answer = "Figure it out yourself!",
})

--[[
	Response to accepting collection mission
--]]

local INTERACTION_COLLECTION_ACCEPT_RESPONSE = INTERACTION_SET:RegisterInteraction({
	uniqueID = "collectionAcceptResponse",

	text = [[
		Good, I will be waiting for you.
	]],

	--- Determines if the NPC will start with this interaction when the player interacts with them.
	--- @param interaction Interaction
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Never start this interaction directly, it only follows other interactions
		return false
	end,
})

INTERACTION_COLLECTION_ACCEPT_RESPONSE:RegisterResponse({
	answer = "I'll be back.",
})

--[[
	Continue collection - checking if player has lore items
--]]

local function hasLoreItems(inventory)
	for _, itemInstance in pairs(inventory) do
		if itemInstance.isLoreItem then
			return true
		end
	end
	return false
end

local INTERACTION_CONTINUE_COLLECTION = INTERACTION_SET:RegisterInteraction({
	uniqueID = "continueCollection",

	text = [[
		Did you find anything interesting?
	]],

	--- Determines if the NPC will start with this interaction when the player interacts with them.
	--- @param interaction Interaction
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Start this interaction if the player has accepted the collection mission
		return Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_COLLECTION_ACCEPTED, true)
	end,
})

INTERACTION_CONTINUE_COLLECTION:RegisterResponse({
	answer = "Yes, I found something. (Give lore item)",
	next = "foundLoreItem",

	--- Determines if the player can choose this response. This is called on the client AND server.
	--- @param response InteractionResponse
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	checkCanChoose = function(response, player, npcEntity)
		-- Only allow this option if the player has lore items
		return hasLoreItems(player:GetCharacter():GetInventory():GetItems())
	end,

	--- Called when the player chooses this response. This is called on the server.
	--- @param response InteractionResponse
	--- @param client Player
	--- @param npcEntity Entity
	--- @return string? # Can override the next interaction to start with a different one
	serverOnChoose = function(response, client, npcEntity)
		-- Remove lore items from the player's inventory and give money
		local inventory = client:GetCharacter():GetInventory():GetItems()
		local count = 0

		for _, itemInstance in pairs(inventory) do
			if itemInstance.isLoreItem then
				itemInstance:Remove()
				count = count + 1
			end
		end

		if count > 0 then
			client:Notify(
				"You have given the Archivist " .. count .. " " .. Schema.util.Pluralize("lore item", count) .. "."
			)
			npcEntity:EmitSound("items/battery_pickup.wav", 50, 150)
			client:GetCharacter():GiveMoney(count * NPC.rewardMoney)
		end
	end,
})

INTERACTION_CONTINUE_COLLECTION:RegisterResponse({
	answer = "I need more time.",
})

--[[
	Response to player giving lore items
--]]

local INTERACTION_FOUND_LORE_ITEM = INTERACTION_SET:RegisterInteraction({
	uniqueID = "foundLoreItem",

	text = [[
		Wonderful! I'll take that off your hands.

		<b>Here's some bolts for your trouble. Keep up the good work, and bring me more information.</b>
	]],

	--- Determines if the NPC will start with this interaction when the player interacts with them.
	--- @param interaction Interaction
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Never start this interaction directly, it only follows other interactions
		return false
	end,
})

INTERACTION_FOUND_LORE_ITEM:RegisterResponse({
	answer = "I'll be back.",
})
