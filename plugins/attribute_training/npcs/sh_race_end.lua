local NPC = NPC

NPC.name = "Enda Bolt"
NPC.description = "A spirited figure waiting eagerly at the finish line of a race."
NPC.model = "models/humans/group02/female_02.mdl"
NPC.voicePitch = 105
NPC.entryFeeRewardFactor = 0.75
NPC.staminaReward = 1

local noRaceStartedMessages = {
	"No race has been started yet! I can't help you.",
	"Sorry, but there's no started race you're participating in.",
	"Are you sure you're in the right place?",
	"It seems you're ahead of the game. No race has started yet!",
	"You're eager to run, but alas, the race has not yet commenced.",
	"Your enthusiasm is admirable, but the race hasn't begun.",
	"No need to stretch those muscles yet—the race hasn't started.",
}

local notPartOfRaceMessages = {
	"You're not part of the race. Go see Leo Usain to join in!",
	"Sorry, but you're not part of the race. Go see Leo on the other side of the city!",
	"Looks like you missed signing up for the race. Don't worry, Leo can still get you in!",
	"Seems like you forgot to register for the race. Head over to Leo's spot and get yourself enrolled!",
	"The race is off-limits for you at the moment. Make sure to talk to Leo to get in on the action!",
	"You haven't joined the footrace yet. Don't delay, go find Leo and get yourself registered!",
	"Not seeing your name on the participant list? That means you haven't joined yet. Visit Leo and get yourself sorted!",
	"You're not on the roster for the race. Swing by Leo's place and get yourself added!",
	"Seems like you haven't signed up for the race yet. Don't miss out, go chat with Leo!",
}

function NPC:OnInteract(client, npcEntity)
	local curTime = CurTime()
	local startEntity = START_NPC_ENTITY

	if (not startEntity or not IsValid(startEntity)) then
		npcEntity:PrintChat(noRaceStartedMessages[math.random(#noRaceStartedMessages)])
		return
	end

	if (not startEntity.expRaceData or not startEntity.expRaceData.runners or not startEntity.expRaceData.runners[client]) then
		npcEntity:PrintChat(notPartOfRaceMessages[math.random(#notPartOfRaceMessages)])
		return
	end

	local raceData = startEntity.expRaceData.runners[client]
	local raceStartedAt = startEntity.expRaceData.raceStartedAt

	if (not raceStartedAt) then
		client:Notify("What the heck? The race hasn't even started yet! This shouldn't happen!")
		ErrorNoHalt("Player " .. client:Name() .. " tried to finish without the racing having started!\n")
		return
	end

	local elapsedTime = curTime - raceStartedAt
	local finishTime = string.NiceTime(math.ceil(elapsedTime))

	npcEntity.expRaceEndData = npcEntity.expRaceEndData or {}
	startEntity.expRaceData.runners[client] = nil

	npcEntity.expRaceEndData.entryFeeSum = (npcEntity.expRaceEndData.entryFeeSum or 0) + raceData.entryFee

	npcEntity.expRaceEndData.finishTimes = npcEntity.expRaceEndData.finishTimes or {}
	npcEntity.expRaceEndData.finishTimes[#npcEntity.expRaceEndData.finishTimes + 1] = {
		client = client,
		time = finishTime,
	}

	-- Track remaining players
	local remainingPlayers = 0

	for runner, data in pairs(startEntity.expRaceData.runners) do
		if (not IsValid(data.client)) then
			startEntity.expRaceData.runners[runner] = nil
			continue
		end

		remainingPlayers = remainingPlayers + 1
	end

	if (remainingPlayers == 0) then
		local winner

		npcEntity:PrintChat(
			client:Name()
			.. ", you've finished the race in " .. finishTime
			.. ". I'll now announce who won the race..."
		)

		-- Loop until we find the winner that is still valid
		for _, data in ipairs(npcEntity.expRaceEndData.finishTimes) do
			if (IsValid(data.client)) then
				winner = data
				break
			end
		end

		if (winner) then
			local character = winner.client:GetCharacter()
			local prize = npcEntity.expRaceEndData.entryFeeSum * NPC.entryFeeRewardFactor
			local winnerName = winner.client:Name()

			timer.Simple(3, function()
				npcEntity:PrintChat("Drumroll please...")
			end)

			timer.Simple(5, function()
				npcEntity:PrintChat("And the winner is...")
			end)

			timer.Simple(8, function()
				npcEntity:PrintChat(winnerName .. "!")

				local randomCheers = {
					"vo/coast/odessa/female01/nlo_cheer01.wav",
					"vo/coast/odessa/female01/nlo_cheer02.wav",
					"vo/coast/odessa/female01/nlo_cheer03.wav",
				}

				npcEntity:SpeakFromSet(randomCheers)
			end)

			timer.Simple(10, function()
				npcEntity:PrintChat(winnerName .. " finished the race in " .. winner.time .. "! Well done.")

				if (IsValid(winner.client)) then
					winner.client:Notify("You've won " .. ix.currency.Get(prize) .. " for finishing the race and your stamina has improved.")
				end
			end)

			character:GiveMoney(prize)
			character:UpdateAttrib("stm", NPC.staminaReward)
		else
			npcEntity:PrintChat("I can't believe it! No one finished the race, so there's no winner!")
		end

		npcEntity.expRaceEndData = nil
		startEntity.expRaceData = nil

		return
	end

	npcEntity:PrintChat(
		client:Name()
		.. ", you've finished the race in " .. finishTime
		.. ". Let's see who else of the "
		.. remainingPlayers
		.. " remaining runners will finish!"
	)
end

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