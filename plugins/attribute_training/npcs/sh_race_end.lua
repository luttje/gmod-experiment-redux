local PLUGIN = PLUGIN

--- @type ExperimentNpc
--- @diagnostic disable-next-line: assign-type-mismatch
local NPC = NPC

-- NPC Configuration
NPC.name = "Enda Bolt"
NPC.description = "A spirited figure waiting eagerly at the finish line of a race."
NPC.model = "models/humans/group02/female_02.mdl"
NPC.voicePitch = 105
NPC.entryFeeRewardFactor = 0.75
NPC.attributeRewards = {
	["stamina"] = 1,
	["endurance"] = 0.5,
}

local noRaceStartedMessages = {
	"No race has been started yet! Find my colleague Leo Usain to join in. I'll be waiting here at the finish line.",
	"You're at the finish line, but there's no started race you're participating in. Go see Leo Usain to join in!",
	"Are you sure you're in the right place? This is the finish line, but you haven't spoken to Leo Usain to join the race!",
	"You're eager to cross this finish line, but you're not part of the race. Go see Leo Usain to join in!",
	"Your enthusiasm is admirable, but the race hasn't begun. Go see Leo Usain to join in! I'll be waiting here at the finish line.",
}

local INTERACTION_SET = NPC:RegisterInteractionSet({
	uniqueID = "raceFinish_Main",

	serverCheckShouldStart = function(interactionSet, player, npcEntity)
		-- Always allow this interaction set
		return true
	end,
})

--[[
	Race finish interaction - when player finishes the race
--]]
local INTERACTION_RACE_FINISH = INTERACTION_SET:RegisterInteraction({
	uniqueID = "raceFinish",

	text = function(interaction, player, npcEntity)
		-- This text will be dynamically set in serverOnStart
		return "Congratulations on finishing the race!"
	end,

	serverCheckShouldStart = function(interaction, player, npcEntity)
		local startEntity = START_NPC_ENTITY

		-- Check if there's a valid race and player is part of it
		if not startEntity or not IsValid(startEntity) then
			return false
		end

		if not startEntity.expRaceData or not startEntity.expRaceData.runners or not startEntity.expRaceData.runners[player] then
			return false
		end

		-- Check if race has actually started
		if not startEntity.expRaceData.raceStartedAt then
			return false
		end

		return true
	end,

	serverOnStart = function(interaction, player, npcEntity)
		local curTime = CurTime()
		local startEntity = START_NPC_ENTITY

		if not startEntity or not IsValid(startEntity) then
			return
		end

		local raceData = startEntity.expRaceData.runners[player]
		local raceStartedAt = startEntity.expRaceData.raceStartedAt

		if not raceStartedAt then
			player:Notify("What the heck? The race hasn't even started yet! This shouldn't happen!")
			ix.util.SchemaErrorNoHalt("Player " ..
				player:Name() .. " tried to finish without the racing having started!\n")
			return
		end

		local elapsedTime = curTime - raceStartedAt
		local finishTime = string.NiceTime(math.ceil(elapsedTime))

		-- Initialize race end data
		npcEntity.expRaceEndData = npcEntity.expRaceEndData or {}
		startEntity.expRaceData.runners[player] = nil

		npcEntity.expRaceEndData.entryFeeSum = (npcEntity.expRaceEndData.entryFeeSum or 0) + raceData.entryFee

		npcEntity.expRaceEndData.finishTimes = npcEntity.expRaceEndData.finishTimes or {}
		npcEntity.expRaceEndData.finishTimes[#npcEntity.expRaceEndData.finishTimes + 1] = {
			client = player,
			time = finishTime,
		}

		player:SetCharacterNetVar("expRaceStartedAt")

		-- Count remaining players
		local remainingPlayers = 0
		for runner, data in pairs(startEntity.expRaceData.runners) do
			if not IsValid(runner) then
				startEntity.expRaceData.runners[runner] = nil
				continue
			end
			remainingPlayers = remainingPlayers + 1
		end

		if remainingPlayers == 0 then
			-- All players finished, determine winner
			local winner

			npcEntity:PrintChat(
				player:Name()
				.. ", you've finished the race in " .. finishTime
				.. ". I'll now announce who won the race..."
			)

			-- Find the first valid winner
			for _, data in ipairs(npcEntity.expRaceEndData.finishTimes) do
				if IsValid(data.client) then
					winner = data
					break
				end
			end

			if winner then
				local character = winner.client:GetCharacter()
				local prize = math.ceil(npcEntity.expRaceEndData.entryFeeSum * NPC.entryFeeRewardFactor)
				local winnerName = winner.client:Name()

				timer.Simple(3, function()
					if IsValid(npcEntity) then
						npcEntity:PrintChat("Drumroll please...")
					end
				end)

				timer.Simple(5, function()
					if IsValid(npcEntity) then
						npcEntity:PrintChat("And the winner is...")
					end
				end)

				timer.Simple(8, function()
					if IsValid(npcEntity) then
						npcEntity:PrintChat(winnerName .. "!")

						local randomCheers = {
							"vo/coast/odessa/female01/nlo_cheer01.wav",
							"vo/coast/odessa/female01/nlo_cheer02.wav",
							"vo/coast/odessa/female01/nlo_cheer03.wav",
						}

						npcEntity:SpeakFromSet(randomCheers)
					end
				end)

				timer.Simple(10, function()
					if IsValid(npcEntity) then
						npcEntity:PrintChat(winnerName .. " finished the race in " .. winner.time .. "! Well done.")

						if IsValid(winner.client) then
							winner.client:Notify("You've won " ..
								ix.currency.Get(prize) ..
								" for finishing the race. Your stamina and endurance have improved.")
						end
					end
				end)

				if character then
					character:GiveMoney(prize)

					for attribute, reward in pairs(NPC.attributeRewards) do
						character:UpdateAttrib(attribute, reward)
					end
				end
			else
				npcEntity:PrintChat("I can't believe it! No one finished the race, so there's no winner!")
			end

			-- Clean up
			npcEntity.expRaceEndData = nil
			startEntity.expRaceData = nil
		else
			-- More players still racing
			npcEntity:PrintChat(
				player:Name()
				.. ", you've finished the race in " .. finishTime
				.. ". Let's see who else of the "
				.. remainingPlayers
				.. " remaining runners will finish!"
			)
		end
	end,
})

-- Response for finishing race
INTERACTION_RACE_FINISH:RegisterResponse({
	answer = "Thanks for organizing this!",
})

--[[
	No race started interaction
--]]
local INTERACTION_NO_RACE = INTERACTION_SET:RegisterInteraction({
	uniqueID = "noRaceStarted",

	text = function(interaction, player, npcEntity)
		return noRaceStartedMessages[math.random(#noRaceStartedMessages)]
	end,

	serverCheckShouldStart = function(interaction, player, npcEntity)
		local startEntity = START_NPC_ENTITY

		-- Show this if no race exists or player isn't part of any race
		if not startEntity or not IsValid(startEntity) then
			return true
		end

		if not startEntity.expRaceData or not startEntity.expRaceData.runners or not startEntity.expRaceData.runners[player] then
			return true
		end

		-- Show this if race hasn't started yet
		if not startEntity.expRaceData.raceStartedAt then
			return true
		end

		return false
	end,
})

-- Response for no race
INTERACTION_NO_RACE:RegisterResponse({
	answer = "I'll go find Leo then.",
})

INTERACTION_NO_RACE:RegisterResponse({
	answer = "Maybe later.",
})

-- Goodbye messages
local goodbyes = {
	"Fantastic effort!",
	"Speedy as the wind!",
	"Well done!",
	"Impressive!",
	"Swift as a coursing river!",
}

function NPC:OnEnd(client, npcEntity)
	npcEntity:PrintChat(goodbyes[math.random(#goodbyes)])
end

-- Client-side functions
if CLIENT then
	function NPC:ClientGetAvailable(npcEntity)
		local client = LocalPlayer()
		local raceStartedAt = client:GetCharacterNetVar("expRaceStartedAt")
		return raceStartedAt ~= nil
	end
end
