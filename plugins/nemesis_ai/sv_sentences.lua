local PLUGIN = PLUGIN

util.AddNetworkString("expPlayNemesisAudio")
util.AddNetworkString("expPlayNemesisSentences")

PLUGIN.registeredSentences = {}

function PLUGIN:RegisterSentence(uniqueID, sentence, parts)
    self.registeredSentences[uniqueID] = {
        sentence = sentence,
		parts = parts,
    }

	return uniqueID
end

PLUGIN:RegisterSentence(
    "intro",
	"In this world, only the strongest survive. Prove your worth or perish.",
	{
		{ 2,   "In this world" },
		{ 3,   "only the strongest survive." },
		{ 1.5,   "Prove your worth" },
		{ 0.5, "or" },
		{ 1,   "perish." },
	}
)

PLUGIN:RegisterSentence(
	"betrayal",
	"Betrayal is the only currency that holds value here.",
	{
		{ 2, "Betrayal is the only currency" },
		{ 1, "that holds value here." },
	}
)

PLUGIN:RegisterSentence(
	"fight",
	"Fight or face a fate worse than death.",
	{
		{ 1, "Fight" },
		{ 1.5, "or face a fate" },
		{ 1, "worse than death." },
	}
)

PLUGIN:RegisterSentence(
    "arena",
	"In this arena, mercy is a weakness.",
	{
		{ 2, "In this arena" },
		{ 1, "mercy" },
		{ 2, "is a weakness." },
	}
)

PLUGIN:RegisterSentence(
    "downfall",
	"I've orchestrated your downfall, %s, before you even knew it began.",
	{
		{ 1.85, "I've orchestrated your downfall" },
		{ 1.5, "%s" },
		{ 3, "before you even knew it began." },
	}
)

PLUGIN:RegisterSentence(
    "pawns",
	"You're nothing but pawns in my game...",
	{
		{ 2, "You're nothing but pawns" },
		{ 0.8, "in my!" },
		{ 1, "gayme..." }, -- 'game' is pronounced too short, this is a workaround
	}
)

PLUGIN:RegisterSentence(
    "sacrifice",
	"Every sacrifice is a step towards victory.",
	{
		{ 3, "Each of you has something to lose." },
		{ 2, "Let's see who values theirs the most." },
	}
)

PLUGIN:RegisterSentence(
    "alliance",
	"Every alliance is temporary. Remember that.",
	{
		{ 2, "Every alliance is temporary." },
		{ 2, "Remember that." },
	}
)

PLUGIN:RegisterSentence(
    "escape",
	"You can't escape the game. Play, or die.",
	{
		{ 2, "You can't escape the gayme." },
		{ 1, "Play, or die." },
	}
)

PLUGIN:RegisterSentence(
    "fight",
	"The fight is inevitable. Embrace the chaos.",
	{
		{ 2, "The fight is inevitable." },
		{ 2, "Embrace the chaos." },
	}
)

-- Sentences about locker rot having been released into a single player's locker.
PLUGIN.lockerRotStartTaunts = {
	PLUGIN:RegisterSentence(
		"locker_rot:1",
		"Let's play a game. I've released the Locker Rot Virus into a test subject's locker. Find out if it's yours, and complete the task to save your items.",
		{
			{ 2, "Let's play a gayme." },
			{ .8, "I've released" },
			{ .8, "the Locker" },
			{ .5, "Rot" },
			{ 1, "Virus" },
			{ 3, "into a test subject's locker." },
			{ 4, "Go to your locker to find out if it's yours." },
		}
    ),
	PLUGIN:RegisterSentence(
		"locker_rot:2",
		"My Locker Rot Virus has been released into a locker. Better check if it's your locker that's infected.",
		{
			{ .8, "My Locker" },
			{ .5, "Rot" },
			{ .8, "Virus" },
			{ 3, "has been released into a locker." },
			{ 4, "Better check if it's your locker that's infected." },
		}
    ),
	PLUGIN:RegisterSentence(
		"locker_rot:3",
		"The Locker Rot Virus I've released will destroy items in a locker. You had better check if it's your locker that's infected.",
		{
			{ .8, "The Locker" },
			{ .5, "Rot" },
			{ .8, "Virus" },
			{ 1.5, "I've released" },
			{ 3, "will destroy items in a locker." },
			{ 4, "You had better check if it's your locker that's infected." },
		}
	),
}

-- Some sentences about completing bounties, %s will be the attacker's name.
PLUGIN.lockerRotCompleteTaunts = {
	PLUGIN:RegisterSentence(
		"locker_rot:completed:1",
		"%s, you've done well. You're my little puppet now.",
		{
			{ 2, "%s" },
			{ 2, "you've done well." },
			{ 2, "You're my little puppet now." },
		}
	),
	PLUGIN:RegisterSentence(
		"locker_rot:completed:2",
		"Congratulations, %s. You've proven your worth. For now.",
		{
			{ 2, "Congratulations, %s." },
			{ 2, "You've proven your worth." },
			{ 2, "For now." },
		}
	),
	PLUGIN:RegisterSentence(
		"locker_rot:completed:3",
		"Your success is noted, %s. You're still just a pawn.",
		{
			{ 2, "Your success is noted, %s." },
			{ 2, "You're still just a pawn." },
		}
	),
	PLUGIN:RegisterSentence(
		"locker_rot:completed:4",
		"Your victory is temporary, %s. I'll be watching.",
		{
			{ 2, "Your victory is temporary, %s." },
			{ 2, "I'll be watching." },
		}
	),
}

-- In case the player dies, but no attacker is found, we taunt them with the victim's name.
PLUGIN.lockerRotCompleteNoAttackerTaunts = {
	PLUGIN:RegisterSentence(
		"locker_rot:completed:anonymous:1",
		"The death of %s is noted. Their items now lay with their corpse. They were weak.",
		{
			{ 2, "The death of %s is noted." },
			{ 3, "Their items now lay with their corpse." },
			{ 2, "They were weak." },
		}
	),
	PLUGIN:RegisterSentence(
		"locker_rot:completed:anonymous:2",
		"%s has fallen. The rats will feast on their corpse. Who will rush to claim their items?",
		{
			{ 2, "%s has fallen." },
			{ 3, "The rats will feast on their corpse." },
			{ 2, "Who will rush to claim their items?" },
		}
	),
}

-- In case the target fails to complete the task in time, but nobody killed them either.
PLUGIN.lockerRotFailedTaunts = {
	PLUGIN:RegisterSentence(
		"locker_rot:failed:1",
		"Pathetic. %s failed to complete the task in time and nobody claimed their items. They're all weak!",
		{
			{ 2, "Pathetic." },
			{ 3, "%s failed to complete the task in time" },
			{ 2, "and nobody claimed their items." },
			{ 2, "They're all weak!" },
		}
	),
	PLUGIN:RegisterSentence(
		"locker_rot:failed:2",
		"Disappointing. %s couldn't complete the task in time and nobody claimed their items. They're all weak!",
		{
			{ 2, "Disappointing." },
			{ 2, "%s couldn't complete the task in time" },
			{ 2, "and nobody claimed their items." },
			{ 2, "They're all weak!" },
		}
	),
}

-- In case the target completes the task, but any attackers fail to claim the items.
PLUGIN.lockerRotCompleteAntiVirusTaunt = {
	PLUGIN:RegisterSentence(
		"locker_rot:completed:anti_virus",
		"The anti-virus has been found. %s's items are safe... for now.",
		{
			{ 3, "The anti-virus has been found." },
			{ 2, "%s's items are safe..." },
			{ 2, "for now." },
		}
	),
	PLUGIN:RegisterSentence(
		"locker_rot:completed:anti_virus:2",
		"%s has found the anti-virus. Their items are safe... for now.",
		{
			{ 3, "%s has found the anti-virus." },
			{ 2, "Their items are safe..." },
			{ 2, "for now." },
		}
	),
}

--
-- The Nemesis AI will taunt those leading in the metrics, setting bounties on them. The taunts are generated based on the metrics.
--

PLUGIN.metricTaunts = {}

local function addMetricTaunt(metric, uniqueID)
    if (not PLUGIN.metricTaunts[metric]) then
        PLUGIN.metricTaunts[metric] = {}
    end

    PLUGIN.metricTaunts[metric][#PLUGIN.metricTaunts + 1] = uniqueID
end

addMetricTaunt(
	"Bolts Generated",
	PLUGIN:RegisterSentence(
		"taunt:Bolts Generated:1",
		"%s, your bolts are a testament to your greed. I'll make sure you pay for it.",
		{
			{ 3, "%s, your bolts are a testament to your greed." },
			{ 2, "I'll make sure you pay for it." },
		}
    )
)

addMetricTaunt(
	"Bolts Generated",
	PLUGIN:RegisterSentence(
		"taunt:Bolts Generated:2",
		"%s, your bolts reveal your greed. Prepare to pay for it.",
		{
			{ 3, "%s, your bolts reveal your greed." },
			{ 2, "Prepare to pay for it." },
		}
	)
)

addMetricTaunt(
	"Successfully Defended",
	PLUGIN:RegisterSentence(
		"taunt:Successfully Defended:1",
		"%s, your defenses are a sign of your weakness. They won't save you from my wrath.",
		{
			{ 3, "%s, your defenses are a sign of your weakness." },
			{ 2, "They won't save you from my wrath." },
		}
	)
)

addMetricTaunt(
	"Successfully Defended",
	PLUGIN:RegisterSentence(
		"taunt:Successfully Defended:2",
		"%s, you think your defenses will save you? Watch me unleash the dogs of war.",
		{
			{ 4, "%s, you think your defenses will save you?" },
			{ 2, "Watch me unleash the dogs of war." },
		}
	)
)

addMetricTaunt(
	"Healing Done",
	PLUGIN:RegisterSentence(
		"taunt:Healing Done:1",
		"%s, your healing is a sign of weakness. You can't heal your way out of this.",
		{
			{ 3, "%s, your healing is a sign of weakness." },
			{ 2, "You can't heal your way out of this." },
		}
	)
)

addMetricTaunt(
	"Healing Done",
	PLUGIN:RegisterSentence(
		"taunt:Healing Done:2",
		"%s, your abundant healing is in vain. You'll pay with your life.",
		{
			{ 2, "%s, your healing is in vain." },
			{ 2, "You'll pay with your life." },
		}
	)
)

addMetricTaunt(
	"Healing Received",
	PLUGIN:RegisterSentence(
		"taunt:Healing Received:1",
		"%s, your reliance on others to heal you is a weakness. I'll exploit it.",
		{
			{ 4, "%s, your reliance on others to heal you is a weakness." },
			{ 2, "I'll exploit it." },
		}
	)
)

addMetricTaunt(
	"Healing Received",
	PLUGIN:RegisterSentence(
		"taunt:Healing Received:2",
		"%s, you sure do rely on others to heal you. They won't be able to heal your corpse.",
		{
			{ 4, "%s, you sure do rely on others to heal you." },
			{ 2, "They won't be able to heal your corpse." },
		}
	)
)

addMetricTaunt(
	"Bolts Spent",
	PLUGIN:RegisterSentence(
		"taunt:Bolts Spent:1",
		"%s, your spending habits are a sign of your greed. I'll make sure you pay for it.",
		{
			{ 4, "%s, your spending habits are a sign of your greed." },
			{ 2, "I'll make sure you pay for it." },
		}
	)
)

addMetricTaunt(
	"Bolts Spent",
	PLUGIN:RegisterSentence(
		"taunt:Bolts Spent:2",
		"%s, you spend your bolts like they're nothing. I'll make sure you pay for it.",
		{
			{ 3, "%s, you spend your bolts like they're nothing." },
			{ 2, "I'll make sure you pay for it." },
		}
	)
)

addMetricTaunt(
	"Locker Rot Kills",
	PLUGIN:RegisterSentence(
		"taunt:Locker Rot Kills:1",
		"%s, irony is a cruel mistress. Let's see how you like being hunted.",
		{
			{ 2, "%s, irony is a cruel mistress." },
			{ 3, "Let's see how you like being hunted." },
		}
	)
)

addMetricTaunt(
	"Monster Damage",
	PLUGIN:RegisterSentence(
		"taunt:Monster Damage:1",
		"%s, your attacks against my failed experiments won't save you from my wrath.",
		{
			{ 3, "%s, your attacks against my failed experiments" },
			{ 2, "won't save you from my wrath." },
		}
	)
)
