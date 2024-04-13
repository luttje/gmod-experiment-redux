local NPC = NPC

NPC.name = "Principal Archivist"
NPC.description = "A wise looking man, who seems to know more than he lets on."
NPC.model = "models/Humans/Group03/male_08.mdl"

local firstMeeting = NPC:RegisterInteraction("firstMeeting", {
	text = "Hi! Nice to meet you",
	responses = {
		{
			text = "Nice to meet you, what do you have to tell me?",
			next = "introResponse",
		},
		{
			text = "I'm not interested.",
		},
	}
}, true)

local consequentMeeting = NPC:RegisterInteraction("consequentMeeting", {
	text = {
		"Hey you, come here. I have something to tell you.",
		"Hello, I have some information that you might find useful.",
		"Hey, I have some information that you might find interesting.",
		"Hi, I have some information that you might find useful.",
	},
	responses = {
		{
			text = "What do you have to tell me?",
			next = "introResponse",
		},
		{
			text = "I'm not interested.",
		},
	}
})

local introResponse = NPC:RegisterInteraction("introResponse", {
	text = "Things are not what they seem. The world is not as it appears.",
	responses = {
		{
			text = "What do you mean? What's going on?",
			next = "whatIsGoingOn",
		},
		{
			text = "Okay wacko, I'm out of here.",
		},
	}
})

local whatIsGoingOn = NPC:RegisterInteraction("whatIsGoingOn", {
	text = [[
		There are things happening that you cannot see, but there's a way to see them.
		If you're interested, I can show you how to see the world as it truly is.
	]],
	responses = {
		{
			text = "I'm interested, show me.",
			next = "collectionAccepted",
        },
		{
			text = "I'm not interested.",
		},
	}
})

local collectionAccepted = NPC:RegisterInteraction("collectionAccepted", {
	text = [[
		I can show you how to see the world as it truly is, but you must be willing to learn.
		Collect as much information as you can, and I will show you the way.

		<b>Througout this city you'll find diaries, notes, and other documents</b> that will help uncover the truth.

		<b>Bring me the information you find, and I will show you the way.</b>
	]],
	responses = {
		{
			text = "Alright I'll do it.",
			next = "collectionAcceptResponse",
		},
		{
			text = "Figure it out yourself!",
		},
	}
}, true)

local collectionAcceptResponse = NPC:RegisterInteraction("collectionAcceptResponse", {
	text = [[
		Good, I will be waiting for you.
	]],
	responses = {
		{
			text = "I'll be back.",
		},
	}
})

local continueCollection = NPC:RegisterInteraction("continueCollection", {
	text = [[
		Did you find anything interesting?
	]],
	responses = function(client, npcEntity, answersPanel)
        local responses = {}

        -- If we have a lore item, we can show the response
        local character = client:GetCharacter()
        local inventory = character:GetInventory()

		for _, item in pairs(inventory:GetItems()) do
			if (item.isLoreItem) then
				responses[#responses + 1] = {
                    text = "Yes, I found something. (Give lore item)",
					color = derma.GetColor("Success", answersPanel),
					next = "foundLoreItem",
				}
				break
			end
		end

		responses[#responses + 1] = {
			text = "I need more time.",
		}

		return responses
	end,
})

local foundLoreItem = NPC:RegisterInteraction("foundLoreItem", {
	text = [[
		Wonderful! I'll take that off your hands.

		<b>Here's some bolts for your trouble. Keep up the good work, and bring me more information.</b>
	]],
	responses = {
        {
			text = "I'll be back.",
		},
	}
})

function NPC:OnInteract(client, npcEntity, desiredInteraction)
    if (desiredInteraction == nil) then
        if (not Schema.npc.HasCompletedInteraction(client, firstMeeting, self.uniqueID)) then
            return firstMeeting
        end

		if (Schema.npc.HasCompletedInteraction(client, collectionAccepted, self.uniqueID)) then
			return continueCollection
		end
    end

    if (desiredInteraction == foundLoreItem) then
        -- Remove any lore items from the player's inventory
        local character = client:GetCharacter()
        local inventory = character:GetInventory()
        local count = 0

        for _, item in pairs(inventory:GetItems()) do
            if (item.isLoreItem) then
                item:Remove()
                count = count + 1
            end
        end

        client:Notify("You have given the Archivist " .. count .. " lore items.")
        npcEntity:EmitSound("items/battery_pickup.wav", 50, 150)

        character:GiveMoney(count * 50)

        return foundLoreItem
    end

    return desiredInteraction
end

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

function NPC:OnEnd(client, npcEntity)
	npcEntity:PrintChat(goodbyes[math.random(#goodbyes)])
end
