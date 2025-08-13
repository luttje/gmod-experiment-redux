-- New system - Dr. Lila Hart Medic NPC with Mission Trackers
local PLUGIN = PLUGIN

--- @type ExperimentNpc
--- @diagnostic disable-next-line: assign-type-mismatch
local NPC = NPC

-- NPC Configuration
NPC.name = "Dr. Lila Hart"
NPC.description = "A compassionate medic with a soothing presence."
NPC.model = "models/Humans/Group03m/Female_02.mdl"
NPC.voicePitch = 100

-- Mission Configuration
NPC.missionIntervalInMinutes = 60 * 24 -- 24 hours
NPC.missionOneHealAmount = 10
NPC.missionThreeHealAmount = 50

-- Progression Keys
NPC.PROGRESSION_MISSION_ONE_ACCEPTED = "mission_one_accepted"
NPC.PROGRESSION_MISSION_ONE_COMPLETED = "mission_one_completed"
NPC.PROGRESSION_MISSION_ONE_HEALED_COUNT = "mission_one_healed_count"
NPC.PROGRESSION_MISSION_TWO_ACCEPTED = "mission_two_accepted"
NPC.PROGRESSION_MISSION_TWO_COMPLETED = "mission_two_completed"
NPC.PROGRESSION_MISSION_THREE_ACCEPTED = "mission_three_accepted"
NPC.PROGRESSION_MISSION_THREE_COMPLETED = "mission_three_completed"
NPC.PROGRESSION_MISSION_THREE_HEALED_COUNT = "mission_three_healed_count"
NPC.PROGRESSION_MISSIONS_COMPLETED = "missions_completed"
NPC.PROGRESSION_NEXT_MISSION_TIME = "next_mission_time"

-- Attribute Rewards
NPC.missionOneAttributeRewards = {
	["medical"] = 1.5,
}
NPC.missionTwoAttributeRewards = {
	["medical"] = 2,
}
NPC.attributeThreeRewards = {
	["medical"] = 10,
}

--[[
	Mission 1 Tracker - Heal X characters
--]]

NPC.MISSION_ONE_TRACKER = Schema.progression.RegisterTracker({
	--- Which scope is the progression in? This NPC in this case.
	scope = NPC.uniqueID,

	--- The unique identifier for this tracker, must be unique over all trackers.
	uniqueID = NPC.uniqueID .. "#healMission1",

	--- Name shown in the UI for this tracker (mission/quest)
	name = "Medical Assistance I",

	--- The key that marks this goal as completed, will be a boolean value.
	completedKey = NPC.PROGRESSION_MISSION_ONE_COMPLETED,

	--- The key that marks this goal as in-progress, will be a boolean value.
	isInProgress = NPC.PROGRESSION_MISSION_ONE_ACCEPTED,
})

--- This will be shown in the mission interface as a goal we are tracking.
NPC.MISSION_ONE_TRACKER_GOAL = NPC.MISSION_ONE_TRACKER:RegisterGoal({
	--- The key of the progression this goal tracks
	key = NPC.PROGRESSION_MISSION_ONE_HEALED_COUNT,

	--- The name of the goal shown in the UI
	name = "Heal Different Characters",

	--- The type of this progression
	type = "number",

	--- The function that determines the progress of this goal and how to
	--- display it in the UI. It is called on both the client and server.
	---
	--- @param goal ProgressionTrackerGoal
	--- @param player Player
	--- @param progression number
	--- @return number|boolean, any, any
	getProgress = function(goal, player, progression)
		local totalRequired = NPC.missionOneHealAmount
		local healed = progression or 0

		return math.min(healed / totalRequired, 1), totalRequired, healed
	end,
})

--[[
	Mission 2 Tracker - Resurrect a character
--]]

NPC.MISSION_TWO_TRACKER = Schema.progression.RegisterTracker({
	scope = NPC.uniqueID,
	uniqueID = NPC.uniqueID .. "#resurrectMission",
	name = "Life Saver",
	completedKey = NPC.PROGRESSION_MISSION_TWO_COMPLETED,
	isInProgress = NPC.PROGRESSION_MISSION_TWO_ACCEPTED,
})

NPC.MISSION_TWO_TRACKER_GOAL = NPC.MISSION_TWO_TRACKER:RegisterGoal({
	--- For resurrection mission, we track completion as a boolean
	key = NPC.PROGRESSION_MISSION_TWO_COMPLETED,
	name = "Resurrect Someone",
	type = "boolean",

	getProgress = function(goal, player, progression)
		local isCompleted = progression or false
		return isCompleted, "1", isCompleted and "1" or "0"
	end,
})

--[[
	Mission 3 Tracker - Heal Y characters (larger amount)
--]]

NPC.MISSION_THREE_TRACKER = Schema.progression.RegisterTracker({
	scope = NPC.uniqueID,
	uniqueID = NPC.uniqueID .. "#healMission3",
	name = "Medical Assistance II",
	completedKey = NPC.PROGRESSION_MISSION_THREE_COMPLETED,
	isInProgress = NPC.PROGRESSION_MISSION_THREE_ACCEPTED,
})

NPC.MISSION_THREE_TRACKER_GOAL = NPC.MISSION_THREE_TRACKER:RegisterGoal({
	key = NPC.PROGRESSION_MISSION_THREE_HEALED_COUNT,
	name = "Heal Different Characters (Advanced)",
	type = "number",

	getProgress = function(goal, player, progression)
		local totalRequired = NPC.missionThreeHealAmount
		local healed = progression or 0

		return math.min(healed / totalRequired, 1), totalRequired, healed
	end,
})

-- Helper function to check if player can start a new mission
local function canStartNewMission(player)
	local missionsCompleted = Schema.progression.Get(player, NPC.uniqueID, NPC.PROGRESSION_MISSIONS_COMPLETED) or 0
	local nextMissionTime = Schema.progression.Get(player, NPC.uniqueID, NPC.PROGRESSION_NEXT_MISSION_TIME) or 0

	return missionsCompleted < 3 and CurTime() >= nextMissionTime
end

-- Helper function to get current mission number
local function getCurrentMissionNumber(player)
	return (Schema.progression.Get(player, NPC.uniqueID, NPC.PROGRESSION_MISSIONS_COMPLETED) or 0) + 1
end

if (CLIENT) then
	--- Having this function will cause the npc to have a mission marker over their head
	--- Return false to show to unavailable marker and true to show the available marker.
	--- This is only called on the client.
	---
	--- @param npcEntity Entity
	--- @return boolean?
	function NPC:ClientGetAvailable(npcEntity)
		-- Check if any mission is in progress
		if (Schema.progression.Check(self.uniqueID, NPC.PROGRESSION_MISSION_ONE_ACCEPTED, true) and
				not Schema.progression.Check(self.uniqueID, NPC.PROGRESSION_MISSION_ONE_COMPLETED, true)) then
			-- Mission 1 in progress
			return false
		end

		if (Schema.progression.Check(self.uniqueID, NPC.PROGRESSION_MISSION_TWO_ACCEPTED, true) and
				not Schema.progression.Check(self.uniqueID, NPC.PROGRESSION_MISSION_TWO_COMPLETED, true)) then
			-- Mission 2 in progress
			return false
		end

		if (Schema.progression.Check(self.uniqueID, NPC.PROGRESSION_MISSION_THREE_ACCEPTED, true) and
				not Schema.progression.Check(self.uniqueID, NPC.PROGRESSION_MISSION_THREE_COMPLETED, true)) then
			-- Mission 3 in progress
			return false
		end

		-- If all missions are completed, don't show marker
		local missionsCompleted = Schema.progression.Get(self.uniqueID, NPC.PROGRESSION_MISSIONS_COMPLETED) or 0
		if (missionsCompleted >= 3) then
			return nil
		end

		-- Check if on cooldown
		local nextMissionTime = Schema.progression.Get(self.uniqueID, NPC.PROGRESSION_NEXT_MISSION_TIME) or 0
		if (CurTime() < nextMissionTime) then
			return false -- Show unavailable marker during cooldown
		end

		-- Show available marker if can start new mission
		return true
	end
end

--[[
    Main Interaction Set - Determines which mission to offer
--]]

local INTERACTION_SET = NPC:RegisterInteractionSet({
	uniqueID = "medic_missions",

	serverCheckShouldStart = function(interactionSet, player, npcEntity)
		return true -- Always allow interaction
	end,
})

--[[
    All Missions Completed Response
--]]

local INTERACTION_ALL_COMPLETED = INTERACTION_SET:RegisterInteraction({
	uniqueID = "allMissionsCompleted",

	text = function(interaction, player, npcEntity)
		local responses = {
			"You've done a great job! You've completed all the missions I had for you.",
			player:Name() .. ", you've done a great job! You've completed all the missions I had for you.",
			"I'm proud of you, " .. player:Name() .. "! You've completed all the missions I had for you.",
			"Your help is greatly appreciated, " .. player:Name() .. "! You've completed all the missions I had for you.",
		}
		return table.Random(responses)
	end,

	serverCheckShouldStart = function(interaction, player, npcEntity)
		local missionsCompleted = Schema.progression.Get(player, NPC.uniqueID, NPC.PROGRESSION_MISSIONS_COMPLETED) or 0
		return missionsCompleted >= 3
	end,
})

INTERACTION_ALL_COMPLETED:RegisterResponse({
	answer = "Thank you for everything!",
})

--[[
    Mission Cooldown Response
--]]

local INTERACTION_COOLDOWN = INTERACTION_SET:RegisterInteraction({
	uniqueID = "missionCooldown",

	text = function(interaction, player, npcEntity)
		local nextMissionTime = Schema.progression.Get(
		-- player, -- Only LocalPlayer on client
			NPC.uniqueID,
			NPC.PROGRESSION_NEXT_MISSION_TIME
		) or 0
		local timeRemaining = math.ceil(nextMissionTime - CurTime())

		return player:Name() .. ", you've already completed a mission recently. You can come back in "
			.. string.NiceTime(timeRemaining) .. "."
	end,

	serverCheckShouldStart = function(interaction, player, npcEntity)
		local missionsCompleted = Schema.progression.Get(player, NPC.uniqueID, NPC.PROGRESSION_MISSIONS_COMPLETED) or 0
		local nextMissionTime = Schema.progression.Get(player, NPC.uniqueID, NPC.PROGRESSION_NEXT_MISSION_TIME) or 0

		return missionsCompleted < 3 and CurTime() < nextMissionTime
	end,
})

INTERACTION_COOLDOWN:RegisterResponse({
	answer = "I'll come back later.",
})

--[[
    Mission 1: Heal X characters
--]]

local INTERACTION_MISSION_ONE = INTERACTION_SET:RegisterInteraction({
	uniqueID = "missionOne",

	text = [[
        We have many injured people around, and I could use your help.
        Can you assist me by bandaging and healing ]] ..
		NPC.missionOneHealAmount .. [[ different characters around the city?

        <b>Make sure you have enough medical supplies before starting.</b>
    ]],

	serverCheckShouldStart = function(interaction, player, npcEntity)
		local currentMission = getCurrentMissionNumber(player)
		return currentMission == 1 and canStartNewMission(player)
			and not Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_ONE_ACCEPTED, true)
	end,
})

INTERACTION_MISSION_ONE:RegisterResponse({
	answer = "I'm ready to help!",
	next = "missionOneStarted",

	serverOnChoose = function(response, player, npcEntity)
		Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_ONE_ACCEPTED, true)
		Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_ONE_HEALED_COUNT, 0)
	end,
})

INTERACTION_MISSION_ONE:RegisterResponse({
	answer = "I'm not ready yet.",
})

local INTERACTION_MISSION_ONE_STARTED = INTERACTION_SET:RegisterInteraction({
	uniqueID = "missionOneStarted",

	text = [[
        <b>Great! Remember, you need to bandage and heal ]] ..
		NPC.missionOneHealAmount .. [[ <u>different</u> characters.</b>

        Thank you for your help! Remember, you can always come back to me for more missions.
    ]],

	serverCheckShouldStart = function(interaction, player, npcEntity)
		return false -- Only accessed via response
	end,
})

INTERACTION_MISSION_ONE_STARTED:RegisterResponse({
	answer = "I'll be back soon!",
})

local INTERACTION_MISSION_ONE_PROGRESS = INTERACTION_SET:RegisterInteraction({
	uniqueID = "missionOneInProgress",

	text = function(interaction, player, npcEntity)
		local healedCount = Schema.progression.Get(
		-- player, -- Only LocalPlayer on client
			NPC.uniqueID,
			NPC.PROGRESSION_MISSION_ONE_HEALED_COUNT
		) or 0

		if (healedCount >= NPC.missionOneHealAmount) then
			return "You've done a great job healing the injured!"
		end

		return "You have healed " ..
			healedCount ..
			" out of " ..
			NPC.missionOneHealAmount .. " characters so far. Your help is greatly appreciated! Keep up the good work."
	end,

	serverCheckShouldStart = function(interaction, player, npcEntity)
		local accepted = Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_ONE_ACCEPTED, true)
		local healedCount = Schema.progression.Get(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_ONE_HEALED_COUNT) or 0
		local completed = Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_ONE_COMPLETED, true)

		return accepted and (healedCount < NPC.missionOneHealAmount or not completed)
	end,

	serverOnStart = function(interaction, player, npcEntity)
		-- Check if mission is now complete
		local healedCount = Schema.progression.Get(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_ONE_HEALED_COUNT) or 0

		if (healedCount >= NPC.missionOneHealAmount) then
			-- Complete the mission
			Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_ONE_COMPLETED, true)
			Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_MISSIONS_COMPLETED, function(value)
				return (value or 0) + 1
			end)
			Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_NEXT_MISSION_TIME,
				CurTime() + (NPC.missionIntervalInMinutes * 60))

			-- Give rewards
			local character = player:GetCharacter()
			if character then
				for attribute, reward in pairs(NPC.missionOneAttributeRewards) do
					character:UpdateAttrib(attribute, reward)
				end
			end

			player:Notify("You've completed the mission and received a medical skill boost.")

			npcEntity:PrintChat(
				player:Name() ..
				", you've done a great job! You've healed " .. NPC.missionOneHealAmount .. " characters in need."
			)
		end
	end,
})

INTERACTION_MISSION_ONE_PROGRESS:RegisterResponse({
	answer = "I'm still working on it.",
})

--[[
    Mission 2: Resurrect a character
--]]

local INTERACTION_MISSION_TWO = INTERACTION_SET:RegisterInteraction({
	uniqueID = "missionTwo",

	text = [[
        In this chaotic city there's always a critical situation! Someone is certain to be in need of your help.
        I need you to bring this person back to life by resurrecting them.

        <b>You'll need the Phoenix Tamer perk to be able to resurrect them.</b>

        Are you ready to take on this mission?
    ]],

	serverCheckShouldStart = function(interaction, player, npcEntity)
		local currentMission = getCurrentMissionNumber(player)
		return currentMission == 2 and canStartNewMission(player)
			and not Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_TWO_ACCEPTED, true)
	end,
})

INTERACTION_MISSION_TWO:RegisterResponse({
	answer = "Yes, I'm ready!",
	next = "missionTwoStarted",

	serverOnChoose = function(response, player, npcEntity)
		Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_TWO_ACCEPTED, true)
	end,
})

INTERACTION_MISSION_TWO:RegisterResponse({
	answer = "Give me a moment to prepare.",
})

local INTERACTION_MISSION_TWO_STARTED = INTERACTION_SET:RegisterInteraction({
	uniqueID = "missionTwoStarted",

	text = [[
        <b>My hero! Remember, you need to resurrect one person to complete this mission.</b>
    ]],

	serverCheckShouldStart = function(interaction, player, npcEntity)
		return false -- Only accessed via response
	end,
})

INTERACTION_MISSION_TWO_STARTED:RegisterResponse({
	answer = "I'll be back soon!",
})

local INTERACTION_MISSION_TWO_PROGRESS = INTERACTION_SET:RegisterInteraction({
	uniqueID = "missionTwoInProgress",

	text = [[
        What are you waiting for? Someone's life is on the line!

        <b>Find someone to resurrect and I'll be waiting for you here.</b>
    ]],

	serverCheckShouldStart = function(interaction, player, npcEntity)
		local accepted = Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_TWO_ACCEPTED, true)
		local completed = Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_TWO_COMPLETED, true)

		return accepted and not completed
	end,
})

INTERACTION_MISSION_TWO_PROGRESS:RegisterResponse({
	answer = "Alright, I'll get to it.",
})

--[[
    Mission 3: Heal Y characters
--]]

local INTERACTION_MISSION_THREE = INTERACTION_SET:RegisterInteraction({
	uniqueID = "missionThree",

	text = [[
        It's a mad house out there. We need continuous medical support.
        Can you commit to healing ]] .. NPC.missionThreeHealAmount .. [[ different characters around the city?

        <b>This is a big responsibility, are you sure you're up for it?</b>
    ]],

	serverCheckShouldStart = function(interaction, player, npcEntity)
		local currentMission = getCurrentMissionNumber(player)
		return currentMission == 3 and canStartNewMission(player)
			and not Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_THREE_ACCEPTED, true)
	end,
})

INTERACTION_MISSION_THREE:RegisterResponse({
	answer = "I'll take on this responsibility!",
	next = "missionStartedThree",

	serverOnChoose = function(response, player, npcEntity)
		Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_THREE_ACCEPTED, true)
		Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_THREE_HEALED_COUNT, 0)
	end,
})

INTERACTION_MISSION_THREE:RegisterResponse({
	answer = "I need more time to prepare.",
})

local INTERACTION_MISSION_THREE_STARTED = INTERACTION_SET:RegisterInteraction({
	uniqueID = "missionStartedThree",

	text = [[
        <b>Thank you for your commitment! Remember, you need to heal ]] ..
		NPC.missionThreeHealAmount .. [[ <u>different</u> characters.</b>

        Your help is greatly appreciated! Keep up the good work.
    ]],

	serverCheckShouldStart = function(interaction, player, npcEntity)
		return false -- Only accessed via response
	end,
})

INTERACTION_MISSION_THREE_STARTED:RegisterResponse({
	answer = "I'll be back soon!",
})

local INTERACTION_MISSION_THREE_PROGRESS = INTERACTION_SET:RegisterInteraction({
	uniqueID = "missionThreeInProgress",

	text = function(interaction, player, npcEntity)
		local healedCount = Schema.progression.Get(
		-- player, -- Only LocalPlayer on client
			NPC.uniqueID,
			NPC.PROGRESSION_MISSION_THREE_HEALED_COUNT
		) or 0

		if (healedCount >= NPC.missionThreeHealAmount) then
			return "You've done a great job healing the injured again!"
		end

		return "You have healed " ..
			healedCount ..
			" out of " ..
			NPC.missionThreeHealAmount .. " characters so far. Your help is greatly appreciated! Keep up the good work."
	end,

	serverCheckShouldStart = function(interaction, player, npcEntity)
		local accepted = Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_THREE_ACCEPTED, true)
		local healedCount = Schema.progression.Get(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_THREE_HEALED_COUNT) or
			0
		local completed = Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_THREE_COMPLETED, true)

		return accepted and (healedCount < NPC.missionThreeHealAmount or not completed)
	end,

	serverOnStart = function(interaction, player, npcEntity)
		-- Check if mission is now complete
		local healedCount = Schema.progression.Get(
			player,
			NPC.uniqueID,
			NPC.PROGRESSION_MISSION_THREE_HEALED_COUNT
		) or 0

		if (healedCount >= NPC.missionThreeHealAmount) then
			-- Complete the mission
			Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_THREE_COMPLETED, true)
			Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_MISSIONS_COMPLETED, function(value)
				return (value or 0) + 1
			end)

			-- Give rewards
			local character = player:GetCharacter()
			if character then
				for attribute, reward in pairs(NPC.attributeThreeRewards) do
					character:UpdateAttrib(attribute, reward)
				end
			end

			player:Notify("You've completed the mission and received a medical skill boost.")

			npcEntity:PrintChat(player:Name() ..
				", you've done a great job! You've healed " .. NPC.missionThreeHealAmount .. " characters in need.")
		end
	end,
})

INTERACTION_MISSION_THREE_PROGRESS:RegisterResponse({
	answer = "I'm still working on it.",
})

--[[
    Hook Functions - Handle mission progress
--]]

function NPC:HandleHealMissionOne(player, target)
	if not Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_ONE_ACCEPTED, true) then
		return
	end

	if player == target then
		return
	end

	-- Increment heal count
	Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_ONE_HEALED_COUNT, function(value)
		return (value or 0) + 1
	end)
end

function NPC:HandleResurrectMissionTwo(player, target)
	if not Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_TWO_ACCEPTED, true) then
		return
	end

	if player == target then
		return
	end

	-- Complete mission 2
	Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_TWO_COMPLETED, true)
	Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_MISSIONS_COMPLETED, function(value)
		return (value or 0) + 1
	end)
	Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_NEXT_MISSION_TIME,
		CurTime() + (NPC.missionIntervalInMinutes * 60))

	-- Give rewards
	local character = player:GetCharacter()
	if character then
		for attribute, reward in pairs(NPC.missionTwoAttributeRewards) do
			character:UpdateAttrib(attribute, reward)
		end
	end

	player:Notify("You've completed the mission and received a medical skill boost.")
end

function NPC:HandleHealMissionThree(player, target)
	if not Schema.progression.Check(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_THREE_ACCEPTED, true) then
		return
	end

	if player == target then
		return
	end

	-- Increment heal count
	Schema.progression.Change(player, NPC.uniqueID, NPC.PROGRESSION_MISSION_THREE_HEALED_COUNT, function(value)
		return (value or 0) + 1
	end)
end

-- Hook into the game events
function NPC.hooks:PlayerHealed(client, target, item, healAmount)
	if (healAmount <= 0) then
		return
	end

	self:HandleHealMissionOne(client, target)
	self:HandleHealMissionThree(client, target)
end

function NPC.hooks:PlayerResurrectedTarget(client, target)
	self:HandleResurrectMissionTwo(client, target)
end
