local NPC = NPC

NPC.name = "Leo Usain"
NPC.description = "An athletic looking man, who seems eager to help you train."
NPC.model = "models/humans/group01/male_03.mdl"
NPC.voicePitch = 90

NPC.raceStartCost = 100
NPC.raceStartsAfterSeconds = 10
NPC.raceIntervalInMinutes = 2
NPC.raceStartDistanceLimit = 256

local raceStart = NPC:RegisterInteraction("raceStart", {
	text = [[
		Hey there! I'm Leo Usain.

		You know that running is a great way to train your stamina, right?

		How about you show me what you've got? I'll time you as you run from here to the finish line across the city.

		<b>I only charge a small fee. Do you want to race?</b>

		Other racers might join in, and the winner takes a prize!
	]],
	responses = function(client, npcEntity, answersPanel)
		local responses = {}

		-- If we have enough money, we can show the response
		local character = client:GetCharacter()

		if (character:HasMoney(NPC.raceStartCost)) then
			responses[#responses + 1] = {
				text = "Yes, I want to race! (Costs " .. ix.currency.Get(NPC.raceStartCost) .. ")",
				color = derma.GetColor("Success", answersPanel),
				next = "raceJoined",
			}
		end

		responses[#responses + 1] = {
			text = "No thanks.",
		}

		return responses
	end,
})

local raceJoined = NPC:RegisterInteraction("raceJoined", {
	text = function(client, npcEntity, answersPanel)
		return [[
			Other players can still join in. Stay close to me or I'll consider you forfeiting.

			The race will start soon. Get ready!"
		]]
	end,
	responses = {
		{
			text = "I'm ready!",
		},
	}
})

local raceAlreadyJoined = NPC:RegisterInteraction("raceAlreadyJoined", {
	text = function(client, npcEntity, answersPanel)
		-- Show a response, depending on if the race has started or not
		local currentRaceStart = npcEntity:GetNWInt("expCurrentRaceStart", 0)
		local curTime = CurTime()

		if (currentRaceStart > 0 and currentRaceStart - curTime > 0) then
			return "You've already joined the race, wait for it to start!"
		end

		return "You've already joined the race, which has already started! Quick, run to the other side of the city!"
	end,
	responses = {}
})

local raceAlreadyStarted = NPC:RegisterInteraction("raceAlreadyStarted", {
	text = "Sorry, the race has already started. You can't join now.\n\nWe race every " ..
		NPC.raceIntervalInMinutes .. " minutes, come back later!",
	responses = {
		{
			text = "I might come back later then"
		},
	}
})

local raceRecentlyStarted = NPC:RegisterInteraction("raceRecentlyStarted", {
	text = function(client, npcEntity, answersPanel)
		local nextRaceStart = npcEntity:GetNWInt("expNextRaceStart", 0)
		local curTime = CurTime()
		local raceStartRemaining = string.NiceTime(math.ceil(nextRaceStart - curTime))

		return "Sorry, we just had a race. We have a every " ..
			NPC.raceIntervalInMinutes .. " minutes, come back in " .. raceStartRemaining .. "!"
	end,
	responses = {
		{
			text = "I might come back later then"
		},
	}
})

function NPC:OnInteract(client, npcEntity, desiredInteraction)
	local currentRaceStart = npcEntity:GetNWInt("expCurrentRaceStart", 0)
	local curTime = CurTime()

	if (npcEntity.expRaceData and npcEntity.expRaceData.runners and npcEntity.expRaceData.runners[client]) then
		return raceAlreadyJoined
	end

	if (currentRaceStart > 0) then
		if (currentRaceStart - curTime > NPC.raceStartsAfterSeconds) then
			return raceAlreadyStarted
		end
	end

	local nextRaceStart = npcEntity:GetNWInt("expNextRaceStart", 0)

	if (nextRaceStart > 0) then
		if (nextRaceStart - curTime > 0) then
			return raceRecentlyStarted
		end
	end

	if (desiredInteraction == nil) then
		return raceStart
	end

	if (desiredInteraction == raceJoined) then
		local character = client:GetCharacter()
		local entryFee = NPC.raceStartCost

		if (not character:HasMoney(entryFee)) then
			client:Notify("You don't have enough money to start!")
			return
		end

		character:TakeMoney(entryFee)
		npcEntity:SetNWInt("expCurrentRaceStart", curTime + NPC.raceStartsAfterSeconds)
		npcEntity:SetNWInt("expNextRaceStart", curTime + (NPC.raceIntervalInMinutes * 60))
		client:SetNWEntity("expRaceJoined", npcEntity)
		npcEntity.expRaceData = npcEntity.expRaceData or {}
		npcEntity.expRaceData.runners = npcEntity.expRaceData.runners or {}
		npcEntity.expRaceData.runners[client] = {
			joinedAt = curTime,
			entryFee = entryFee,
		}

		START_NPC_ENTITY = npcEntity

		npcEntity:PrintChat("Get ready to race " .. client:Name() .. "! I'll count down from 3 soon!")

		return raceJoined
	end

	return desiredInteraction
end

function NPC:OnThink(npcEntity)
	local curTime = CurTime()
	local currentRaceStart = npcEntity:GetNWInt("expCurrentRaceStart", 0)

	if (currentRaceStart == 0) then
		return
	end

	if (npcEntity.expRaceData and npcEntity.expRaceData.runners and self:CheckRunners(npcEntity) == 0) then
		if (npcEntity.expRaceData.raceStartedAt) then
			return
		end

		npcEntity:PrintChat("I can't believe it! No one finished, so there's no winner!")
		npcEntity:SetNWInt("expCurrentRaceStart", 0)
		npcEntity.expRaceData = nil
		return
	end

	if (curTime > currentRaceStart) then
		npcEntity.expRaceData = npcEntity.expRaceData or {}
		npcEntity.expRaceData.countdown = npcEntity.expRaceData.countdown or 3

		if (npcEntity.expRaceData.countdown > 0) then
			if (npcEntity.expRaceData.countdown == 3) then
				npcEntity:PrintChat("3...", true)
			elseif (npcEntity.expRaceData.countdown == 2) then
				npcEntity:PrintChat("2...", true)
			elseif (npcEntity.expRaceData.countdown == 1) then
				npcEntity:PrintChat("1...", true)
			end

			npcEntity.expRaceData.countdown = npcEntity.expRaceData.countdown - 1
		else
			npcEntity:PrintChat("GO!", true)
			npcEntity:SetNWInt("expCurrentRaceStart", 0)
			npcEntity.expRaceData.countdown = nil
			npcEntity.expRaceData.raceStartedAt = curTime

			-- Hide the distance limit for the runners
			for runner, data in pairs(npcEntity.expRaceData.runners) do
				runner:SetNWEntity("expRaceJoined", NULL)
			end
		end

		return
	end
end

-- Checks that the runners haven't moved further than limit or have become invalid
function NPC:CheckRunners(npcEntity)
	local runnerCount = 0

	for runner, data in pairs(npcEntity.expRaceData.runners) do
		if (not IsValid(runner) or not runner:GetCharacter()) then
			npcEntity.expRaceData.runners[runner] = nil
			continue
		end

		local distance = runner:GetPos():Distance(npcEntity:GetPos())

		if (distance > NPC.raceStartDistanceLimit) then
			npcEntity:PrintChat(runner:Name() .. " has forfeited the race!", true)
			npcEntity.expRaceData.runners[runner] = nil

			runner:SetNWEntity("expRaceJoined", NULL)
			continue
		end

		runnerCount = runnerCount + 1
	end

	return runnerCount
end

local goodbyes = {
	"Catch you later!",
	"Stay safe!",
	"Good luck!",
	"See you soon!",
	"Take care!",
}

function NPC:OnEnd(client, npcEntity)
	npcEntity:PrintChat(goodbyes[math.random(#goodbyes)])
end
