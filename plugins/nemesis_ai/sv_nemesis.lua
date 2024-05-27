local PLUGIN = PLUGIN

PLUGIN.registeredSentences = {}

PLUGIN:RegisterSentence("nemesis_intro", {
	{ 2,   "In this world" },
	{ 3,   "only the strongest survive." },
	{ 1.5,   "Prove your worth" },
	{ 0.5, "or" },
	{ 1,   "perish." },
})

PLUGIN:RegisterSentence("nemesis_betrayal", {
	{ 2, "Betrayal is the only currency" },
	{ 1, "that holds value here." },
})

PLUGIN:RegisterSentence("nemesis_fight", {
	{ 1, "Fight" },
	{ 1.5, "or face a fate" },
	{ 1, "worse than death." },
})

PLUGIN:RegisterSentence("nemesis_arena", {
	{ 2, "In this arena" },
	{ 1, "mercy" },
	{ 2, "is a weakness." },
})

PLUGIN:RegisterSentence("nemesis_downfall", {
	{ 1.8, "I've orchestrated your downfall" },
	{ 1.5, "%s!" },
	{ 3, "before you even knew it began." },
})

PLUGIN:RegisterSentence("nemesis_pawns", {
	{ 2, "You're nothing but pawns" },
	{ 0.8, "in my!" },
	{ 1, "gayme..." }, -- 'game' is pronounced too short, this is a workaround
})

PLUGIN:RegisterSentence("nemesis_sacrifice", {
	{ 3, "Each of you has something to lose." },
	{ 2, "Let's see who values theirs the most." },
})

PLUGIN:RegisterSentence("nemesis_alliance", {
	{ 2, "Every alliance is temporary." },
	{ 2, "Remember that." },
})

PLUGIN:RegisterSentence("nemesis_escape", {
	{ 2, "You can't escape the game." },
	{ 1, "Play, or die." },
})

PLUGIN:RegisterSentence("nemesis_fight", {
	{ 2, "The fight is inevitable." },
	{ 2, "Embrace the chaos." },
})
