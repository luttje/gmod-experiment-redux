local NPC = NPC

NPC.name = "Jeff Atkinson"
NPC.description = "A stern looking fellow, he's got a hard look in his eyes."
NPC.model = "models/Humans/Group03/male_09.mdl"
NPC.voicePitch = 95

NPC.trainingDuration = 30
NPC.trainingIntervalInMinutes = 15
NPC.attributeRewards = {
	["dexterity"] = 1,
}

local challengeStart = NPC:RegisterInteraction("challengeStart", {
	text = [[
		Hey you want to practice your dexterity? I can help you with that.

		<b>Ensure you have enough ammo for your weapon, and we'll start the challenge.</b>
	]],
	responses = {
		{
			text = "I'm ready!",
			next = "challengeStarted",
		},
		{
			text = "I'm not ready yet.",
		},
	}
})

local challengeStarted = NPC:RegisterInteraction("challengeStarted", {
	text = [[
		If you look over to my right, there's a couple big contraptions on top of the train station.

		In a moment I'll have some balloons pop out from them. Shoot them as fast as you can!

		I'll count down from 3, and then we'll start.
	]],
	responses = {
		{
			text = "I'm ready!",
		},
	}
})

local challengeAlreadyStartedSelf = NPC:RegisterInteraction("challengeAlreadyStartedSelf", {
	text = "You're already in the middle of a challenge. Focus on that first!",
	responses = {}
})

local challengeAlreadyStartedOther = NPC:RegisterInteraction("challengeAlreadyStartedOther", {
	text = "We're in the middle of a challenge right now. You'll have to wait until it's over.",
	responses = {
		{
			text = "I'll come back later then"
		},
	}
})

local challengeRecentlyStarted = NPC:RegisterInteraction("challengeRecentlyStarted", {
	text = function(client, npcEntity, answersPanel)
		local character = client:GetCharacter()
		local nextChallengeStart = character:GetData("nextChallengeStart", 0)
		local curTime = CurTime()
		local nextChallengeStartRemaining = string.NiceTime(math.ceil(nextChallengeStart - curTime))

		return "Sorry, you can only do this challenge every "
			.. NPC.trainingIntervalInMinutes .. " minutes, come back in "
			.. nextChallengeStartRemaining .. "!"
	end,
	responses = {
		{
			text = "I might come back later then"
		},
	}
})

function NPC:OnInteract(client, npcEntity, desiredInteraction)
	if (npcEntity.expCurrentChallenge) then
		if (npcEntity.expCurrentChallenge.client == client) then
			return challengeAlreadyStartedSelf
		end

		return challengeAlreadyStartedOther
	end

	local character = client:GetCharacter()

	if (character:GetData("nextChallengeStart", 0) > CurTime()) then
		return challengeRecentlyStarted
	end

	if (desiredInteraction == nil) then
		return challengeStart
	end

	if (desiredInteraction == challengeStarted) then
		npcEntity.expCurrentChallenge = {
			client = client,
			startAt = CurTime() + 10,
			duration = NPC.trainingDuration,
		}

		client:SetCharacterNetVar("targetPracticeChallenger", npcEntity)

		npcEntity:PrintChat("Alright " .. client:Name() .. ", let's get started!")

		return challengeStarted
	end

	return desiredInteraction
end

function NPC:OnThink(npcEntity)
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
			character:SetData("nextChallengeStart", curTime + (NPC.trainingIntervalInMinutes * 60))

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

function NPC:OnEnd(client, npcEntity)
end

if (CLIENT) then
	function NPC:HUDPaint(npcEntity)
		local client = LocalPlayer()
		local score = client:GetCharacterNetVar("targetPracticeScore", 0)

		Schema.draw.DrawLabeledValue("Score:", math.Round(score, 2))
	end
end
