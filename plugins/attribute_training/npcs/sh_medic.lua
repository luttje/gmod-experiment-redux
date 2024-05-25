local NPC = NPC

NPC.name = "Dr. Lila Hart"
NPC.description = "A compassionate medic with a soothing presence."
NPC.model = "models/Humans/Group03m/Female_02.mdl"
NPC.voicePitch = 100

NPC.missionIntervalInMinutes = 60 * 24 -- 24 hours

--[[
	Mission 1: Heal X characters
--]]
NPC.missionOneHealAmount = 10
NPC.missionOneAttributeRewards = {
    ["medical"] = 1.5,
}
local missionOne = NPC:RegisterInteraction("missionOne", {
    text = [[
        We have many injured people around, and I could use your help.
        Can you assist me by bandaging and healing ]] .. NPC.missionOneHealAmount .. [[ different characters around the city?

        <b>Make sure you have enough medical supplies before starting.</b>
    ]],
    responses = {
        {
            text = "I'm ready to help!",
            next = "missionOneStarted",
        },
        {
            text = "I'm not ready yet.",
        },
    }
})

local missionOneStarted = NPC:RegisterInteraction("missionOneStarted", {
	text = [[
		<b>Great! Remember, you need to bandage and heal ]] .. NPC.missionOneHealAmount .. [[ <u>different</u> characters.</b>

		Thank you for your help! Remember, you can always come back to me for more missions.
	]],
	responses = {
		{
			text = "I'll be back soon!",
		},
	}
})

local missionOneInProgress = NPC:RegisterInteraction("missionOneInProgress", {
	text = function(client, npcEntity, answersPanel)
		local character = client:GetCharacter()
		local medicMissionOne = character:GetData("medicMissionOne", nil)
		local charactersHealed = medicMissionOne.healed

		return "You have healed " .. #charactersHealed .. " out of " .. NPC.missionOneHealAmount .. " characters so far. Your help is greatly appreciated! Keep up the good work."
	end,
	responses = {
		{
			text = "I'm still working on it.",
		},
	}
})

--[[
	Mission 2: Resurrect a character
--]]
NPC.missionTwoAttributeRewards = {
    ["medical"] = 2,
}
local missionTwo = NPC:RegisterInteraction("missionTwo", {
    text = [[
        In this chaotic city there's always a critical situation! Someone is certain to be in need of your help.
        I need you to bring this person back to life byresurrecting them.

        <b>You'll need the Phoenix Tamer perk to be able to resurrect them.</b>

		Are you ready to take on this mission?
    ]],
    responses = {
        {
            text = "Yes, I'm ready!",
            next = "missionTwoStarted",
        },
        {
            text = "Give me a moment to prepare.",
        },
    }
})

local missionTwoStarted = NPC:RegisterInteraction("missionTwoStarted", {
	text = [[
		<b>My hero! Remember, you need to resurrect one person to complete this mission.</b>
	]],
	responses = {
		{
			text = "I'll be back soon!",
		},
	}
})

local missionTwoInProgress = NPC:RegisterInteraction("missionTwoInProgress", {
	text = function(client, npcEntity, answersPanel)
		return [[
			What are you waiting for? Someone's life is on the line!

			<b>Find someone to resurrect and I'll be waiting for you here.</b>
		]]
	end,
	responses = {
		{
			text = "Alright, I'll get to it.",
		},
	}
})

--[[
	Mission 3: Heal Y characters
--]]
NPC.missionThreeHealAmount = 50
NPC.attributeThreeRewards = {
    ["medical"] = 10,
}
local missionThree = NPC:RegisterInteraction("missionThree", {
    text = [[
    	It's a mad house out there. We need continuous medical support.
        Can you commit to healing ]] .. NPC.missionThreeHealAmount .. [[ different characters around the city?

        <b>This is a big responsibility, are you sure you're up for it?</b>
    ]],
    responses = {
        {
            text = "I'll take on this responsibility!",
            next = "missionStartedThree",
        },
        {
            text = "I need more time to prepare.",
        },
    }
})

local missionStartedThree = NPC:RegisterInteraction("missionStartedThree", {
	text = [[
		<b>Thank you for your commitment! Remember, you need to heal ]] .. NPC.missionThreeHealAmount .. [[ <u>different</u> characters.</b>

		Your help is greatly appreciated! Keep up the good work.
	]],
	responses = {
		{
			text = "I'll be back soon!",
		},
	}
})

local missionThreeInProgress = NPC:RegisterInteraction("missionThreeInProgress", {
	text = function(client, npcEntity, answersPanel)
		local character = client:GetCharacter()
		local medicMissionThree = character:GetData("medicMissionThree", nil)
        local charactersHealed = medicMissionThree.healed

		return "You have healed " .. #charactersHealed .. " out of " .. NPC.missionThreeHealAmount .. " characters so far. Your help is greatly appreciated! Keep up the good work."
	end,
	responses = {
		{
			text = "I'm still working on it.",
		},
	}
})

function NPC:OnInteract(client, npcEntity, desiredInteraction)
    local character = client:GetCharacter()
    local missionsCompleted = character:GetData("medicMissionsCompleted", 0)

    if missionsCompleted >= 3 then
        npcEntity:PrintChat(
            table.Random({
                "You've done a great job! You've completed all the missions I had for you.",
                client:Name() .. ", you've done a great job! You've completed all the missions I had for you.",
                "I'm proud of you, " .. client:Name() .. "! You've completed all the missions I had for you.",
				"Your help is greatly appreciated, " .. client:Name() .. "! You've completed all the missions I had for you.",
			})
		)
        return
    end

    local nextMission = character:GetData("medicNextMission", 0)

    if (nextMission > CurTime()) then
		npcEntity:PrintChat(
			client:Name()
			.. ", you've already completed a mission recently. You can come back in "
			.. string.NiceTime(math.ceil(nextMission - CurTime())) .. "."
		)

		return
	end

	--[[
		Mission 1: Heal X characters
	--]]
    local medicMissionOne = character:GetData("medicMissionOne", nil)

    if (medicMissionOne) then
        if (#medicMissionOne.healed < NPC.missionOneHealAmount) then
            return missionOneInProgress
        end

        character:SetData("medicNextMission", CurTime() + (self.missionIntervalInMinutes * 60))
        character:SetData("medicMissionsCompleted", missionsCompleted + 1)
        character:SetData("medicMissionOne", nil)

        npcEntity:PrintChat(
            client:Name()
            .. ", you've done a great job! You've healed " .. NPC.missionOneHealAmount .. " characters in need."
        )

        client:Notify("You've completed the mission and received a medical skill boost.")

        for attribute, reward in pairs(NPC.missionOneAttributeRewards) do
            character:UpdateAttrib(attribute, reward)
        end

        return
    end

	--[[
		Mission 2: Resurrect a character
	--]]
    local medicMissionTwo = character:GetData("medicMissionTwo", nil)

    if (medicMissionTwo) then
        if (medicMissionTwo.resurrected) then
            character:SetData("medicNextMission", CurTime() + (self.missionIntervalInMinutes * 60))
            character:SetData("medicMissionsCompleted", missionsCompleted + 1)
            character:SetData("medicMissionTwo", nil)

            npcEntity:PrintChat(
                client:Name()
                .. ", you've done a great job! You've resurrected a character in need."
            )

            client:Notify("You've completed the mission and received a medical skill boost.")

            for attribute, reward in pairs(NPC.missionTwoAttributeRewards) do
                character:UpdateAttrib(attribute, reward)
            end

            return
        end

        return missionTwoInProgress
    end

	--[[
		Mission 3: Heal Y characters
	--]]
    local medicMissionThree = character:GetData("medicMissionThree", nil)

    if (medicMissionThree) then
        if (#medicMissionThree.healed < NPC.missionThreeHealAmount) then
            return missionThreeInProgress
        end

        -- character:SetData("medicNextMission", CurTime() + (self.missionIntervalInMinutes * 60))
        character:SetData("medicMissionsCompleted", missionsCompleted + 1)
        character:SetData("medicMissionThree", nil)

        npcEntity:PrintChat(
            client:Name()
            .. ", you've done a great job! You've healed " .. NPC.missionThreeHealAmount .. " characters in need."
        )

        client:Notify("You've completed the mission and received a medical skill boost.")

        for attribute, reward in pairs(NPC.missionThreeAttributeRewards) do
            character:UpdateAttrib(attribute, reward)
        end

        return
    end

	--[[
		Select the next mission
	--]]
    local interactions = {missionOne, missionTwo, missionThree}

    if (desiredInteraction == nil or desiredInteraction == interactions[missionsCompleted + 1]) then
        return interactions[missionsCompleted + 1]
    end

	if (desiredInteraction == missionOneStarted) then
		character:SetData("medicMissionOne", {
			healed = {},
        })

		return missionOneStarted
	elseif (desiredInteraction == missionTwoStarted) then
		character:SetData("medicMissionTwo", {
			resurrected = false,
		})
	elseif (desiredInteraction == missionStartedThree) then
		character:SetData("medicMissionThree", {
			healed = {},
		})
	end

    return desiredInteraction
end

function NPC:HandleHealMissionOne(client, target)
    local medicMissionOne = client:GetCharacter():GetData("medicMissionOne", nil)

    if (not medicMissionOne) then
        return
    end

    if (client == target) then
        return
    end

    for _, data in ipairs(medicMissionOne.healed) do
        if (data == target:SteamID64()) then
            return
        end
    end

    medicMissionOne.healed[#medicMissionOne.healed + 1] = target:SteamID64()

    -- Call SetData again, so the changes are networked (Helix wont monitor the table for changes)
	client:GetCharacter():SetData("medicMissionOne", medicMissionOne)
end

function NPC:HandleResurrectMissionTwo(client, target)
    local medicMissionTwo = client:GetCharacter():GetData("medicMissionTwo", nil)

    if (not medicMissionTwo) then
        return
    end

    if (client == target) then
        return
    end

    medicMissionTwo.resurrected = true

	client:GetCharacter():SetData("medicMissionTwo", medicMissionTwo)
end

function NPC:HandleHealMissionThree(client, target)
	local medicMissionThree = client:GetCharacter():GetData("medicMissionThree", nil)

	if (not medicMissionThree) then
		return
	end

	if (client == target) then
		return
	end

	for _, data in ipairs(medicMissionThree.healed) do
		if (data == target:SteamID64()) then
			return
		end
	end

    medicMissionThree.healed[#medicMissionThree.healed + 1] = target:SteamID64()

	client:GetCharacter():SetData("medicMissionThree", medicMissionThree)
end

function NPC.hooks:PlayerHealed(client, target, item, healAmount)
    self:HandleHealMissionOne(client, target)
    self:HandleHealMissionThree(client, target)
end

function NPC.hooks:PlayerResurrectedTarget(client, target)
	self:HandleResurrectMissionTwo(client, target)
end
