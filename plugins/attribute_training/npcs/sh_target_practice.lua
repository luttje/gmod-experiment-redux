local PLUGIN = PLUGIN

--- @type ExperimentNpc
--- @diagnostic disable-next-line: assign-type-mismatch
local NPC = NPC

-- NPC Properties
NPC.name = "Jeff Atkinson"
NPC.description = "A stern looking fellow, he's got a hard look in his eyes."
NPC.model = "models/Humans/Group03/male_09.mdl"
NPC.voicePitch = 95

NPC.trainingDuration = 30
NPC.trainingIntervalInMinutes = 15
NPC.attributeRewards = {
	["dexterity"] = 1,
}

-- Progression keys
NPC.PROGRESSION_NEXT_CHALLENGE_START = "nextChallengeStart"

local INTERACTION_SET = NPC:RegisterInteractionSet({
	--- The unique identifier for this interaction set.
	uniqueID = "jeffAtkinson_DexterityTraining",

	--- A function that determines if the player should start with this interaction set
	--- @param interactionSet InteractionSet
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interactionSet, player, npcEntity)
		-- Always allow access to this interaction set
		return true
	end,
})

--[[
	Challenge start interaction
--]]

local INTERACTION_CHALLENGE_START = INTERACTION_SET:RegisterInteraction({
	uniqueID = "challengeStart",

	text = [[
		Hey you want to practice your dexterity? I can help you with that.

		<b>Ensure you have enough ammo for your weapon, and we'll start the challenge.</b>
	]],

	--- @param interaction Interaction
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Check if player is not in cooldown and no challenge is currently active
		local nextChallengeStart = Schema.progression.Get(
			player,
			NPC.uniqueID,
			NPC.PROGRESSION_NEXT_CHALLENGE_START
		) or 0
		local currentTime = CurTime()

		-- Don't start if in cooldown
		if nextChallengeStart > currentTime then
			return false
		end

		-- Don't start if there's already a challenge running
		if npcEntity.expCurrentChallenge then
			return false
		end

		return true
	end,
})

INTERACTION_CHALLENGE_START:RegisterResponse({
	answer = "I'm ready!",
	next = "challengeStarted",

	--- @param response InteractionResponse
	--- @param player Player
	--- @param npcEntity Entity
	--- @return string?
	serverOnChoose = function(response, player, npcEntity)
		-- Set up the challenge
		npcEntity.expCurrentChallenge = {
			client = player,
			startAt = CurTime() + 10,
			duration = NPC.trainingDuration,
		}

		player:SetCharacterNetVar("targetPracticeChallenger", npcEntity)

		-- Send chat message
		npcEntity:PrintChat("Alright " .. player:Name() .. ", let's get started!")
	end,
})

INTERACTION_CHALLENGE_START:RegisterResponse({
	answer = "I'm not ready yet.",
})

--[[
	Challenge started interaction
--]]

local INTERACTION_CHALLENGE_STARTED = INTERACTION_SET:RegisterInteraction({
	uniqueID = "challengeStarted",

	text = [[
		If you look over to my right, there's a couple big contraptions on top of the train station.

		In a moment I'll have some balloons pop out from them. Shoot them as fast as you can!

		I'll count down from 3, and then we'll start.
	]],

	--- @param interaction Interaction
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Never start this directly, it only follows other interactions
		return false
	end,
})

INTERACTION_CHALLENGE_STARTED:RegisterResponse({
	answer = "Alright, let me get to shooting!",
})

--[[
	Challenge already started (same player)
--]]

local INTERACTION_CHALLENGE_ALREADY_STARTED_SELF = INTERACTION_SET:RegisterInteraction({
	uniqueID = "challengeAlreadyStartedSelf",

	text = "You're already in the middle of a challenge. Focus on that first!",

	--- @param interaction Interaction
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Check if this player has an active challenge
		return npcEntity.expCurrentChallenge and npcEntity.expCurrentChallenge.client == player
	end,
})

-- No responses for this interaction (player should focus on current challenge)

--[[
	Challenge already started (other player)
--]]

local INTERACTION_CHALLENGE_ALREADY_STARTED_OTHER = INTERACTION_SET:RegisterInteraction({
	uniqueID = "challengeAlreadyStartedOther",

	text = "We're in the middle of a challenge right now. You'll have to wait until it's over.",

	--- @param interaction Interaction
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Check if there's an active challenge but not for this player
		return npcEntity.expCurrentChallenge and npcEntity.expCurrentChallenge.client ~= player
	end,
})

INTERACTION_CHALLENGE_ALREADY_STARTED_OTHER:RegisterResponse({
	answer = "I'll come back later then",
})

--[[
	Challenge recently completed (cooldown)
--]]

local INTERACTION_CHALLENGE_RECENTLY_STARTED = INTERACTION_SET:RegisterInteraction({
	uniqueID = "challengeRecentlyStarted",

	--- Dynamic text based on remaining cooldown time
	text = function(interaction, player, npcEntity)
		local nextChallengeStart = Schema.progression.Get(
		-- player, -- Only LocalPlayer on client
			NPC.uniqueID,
			NPC.PROGRESSION_NEXT_CHALLENGE_START
		) or 0
		local curTime = CurTime()
		local nextChallengeStartRemaining = string.NiceTime(math.ceil(nextChallengeStart - curTime))

		return "Sorry, you can only do this challenge every "
			.. NPC.trainingIntervalInMinutes .. " minutes, come back in "
			.. nextChallengeStartRemaining .. "!"
	end,

	--- @param interaction Interaction
	--- @param player Player
	--- @param npcEntity Entity
	--- @return boolean
	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Check if player is in cooldown
		local nextChallengeStart = Schema.progression.Get(
			player,
			NPC.uniqueID,
			NPC.PROGRESSION_NEXT_CHALLENGE_START
		) or 0
		local currentTime = CurTime()

		-- Start this interaction if in cooldown and no active challenge
		return nextChallengeStart > currentTime and not npcEntity.expCurrentChallenge
	end,
})

INTERACTION_CHALLENGE_RECENTLY_STARTED:RegisterResponse({
	answer = "I might come back later then",
})

function NPC:OnThink(npcEntity)
	self:HandleChallengeLogic(npcEntity)
end

function NPC:HandleChallengeLogic(npcEntity)
	local curTime = CurTime()

	if (not npcEntity.expCurrentChallenge) then
		return
	end

	local challenge = npcEntity.expCurrentChallenge

	if (challenge.startAt <= curTime) then
		if (challenge.finishAt and challenge.finishAt <= curTime) then
			local client = challenge.client
			local character = client:GetCharacter()
			local score = client:GetCharacterNetVar("targetPracticeScore", 0)

			for attribute, reward in pairs(NPC.attributeRewards) do
				character:UpdateAttrib(attribute, reward * score)
			end

			client:Notify(
				"You've finished the challenge! Your dexterity has improved."
			)

			npcEntity.expCurrentChallenge = nil
			client:SetCharacterNetVar("targetPracticeChallenger", nil)

			-- Set cooldown using progression system
			Schema.progression.Change(
				client,
				NPC.uniqueID,
				NPC.PROGRESSION_NEXT_CHALLENGE_START,
				curTime + (NPC.trainingIntervalInMinutes * 60)
			)

			return
		end

		if (not challenge.finishAt) then
			challenge.finishAt = curTime + challenge.duration
			npcEntity:PrintChat("Go! Shoot the balloons as fast as you can!")

			local trainees = { challenge.client }
			local spawners = ents.FindByClass("exp_target_practice_spawn")

			for _, spawner in ipairs(spawners) do
				spawner:StartSpawningForTrainees(trainees, challenge.duration)
			end
		end

		return
	end

	if (challenge.startAt > curTime) then
		local remaining = math.ceil(challenge.startAt - curTime)

		if (remaining == 3) then
			npcEntity:PrintChat("3...", true)
		elseif (remaining == 2) then
			npcEntity:PrintChat("2...", true)
		elseif (remaining == 1) then
			npcEntity:PrintChat("1...", true)
		end
	end
end

-- Client-side HUD (this might need to be handled differently in the new system)
if (CLIENT) then
	function NPC:HUDPaint(npcEntity)
		local client = LocalPlayer()
		local score = client:GetCharacterNetVar("targetPracticeScore", 0)

		Schema.draw.DrawLabeledValue("Score:", math.Round(score, 2))
	end
end
