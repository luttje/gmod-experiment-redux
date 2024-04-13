local INTERACTION = {}

INTERACTION.npcIdentity = {
	name = "Principal Archivist",
	description = "A wise looking man, who seems to know more than he lets on.",
}

INTERACTION.npcAppearance = {
	model = "models/Humans/Group03/male_08.mdl",
}

local firstMeeting = {
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
}

local consequentMeeting = {
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
}

local introResponse = {
	text = "Things are not what they seem. The world is not as it appears.",
	responses = {
		{
			text = "What do you mean?",
			next = "todo",
		},
		{
			text = "Okay wacko, I'm out of here.",
		},
	}
}

function INTERACTION:OnInteract(client, npc, desiredInteraction)
	if (desiredInteraction == nil) then
		if (not Schema.npc.HasCompletedInteraction(client, "meeting", self.uniqueID)) then
			Schema.npc.CompleteInteraction(client, "meeting", self.uniqueID)
			return firstMeeting
		end

		return consequentMeeting
	end

	if (desiredInteraction == "introResponse") then
		return introResponse
	end

	return {
		text = "I have nothing more to say to you.",
	}
end

function INTERACTION:OnEnd(client, npc)
	npc:PrintChat("Goodbye then")
end

Schema.npc.RegisterInteraction(INTERACTION, "archivist")
