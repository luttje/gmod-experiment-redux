local PLUGIN = PLUGIN

PLUGIN.registeredSentences = {}

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
		{ 2, "You can't escape the game." },
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

-- Some sentences about completing bounties, with a placeholder for the player's name. The tone should still be dominating (e.g: my little puppet).
PLUGIN.bountySentences = {
	PLUGIN:RegisterSentence(
		"bounty:completed:1",
		"Ah, %s, you've done well. You're my little puppet now.",
		{
			{ 2, "Ah, %s," },
			{ 2, "you've done well." },
			{ 2, "You're my little puppet now." },
		}
	),
	PLUGIN:RegisterSentence(
		"bounty:completed:2",
		"Congratulations, %s. You've proven your worth. For now.",
		{
			{ 2, "Congratulations, %s." },
			{ 2, "You've proven your worth." },
			{ 2, "For now." },
		}
	),
	PLUGIN:RegisterSentence(
		"bounty:completed:3",
		"Your success is noted, %s. You're still just a pawn.",
		{
			{ 2, "Your success is noted, %s." },
			{ 2, "You're still just a pawn." },
		}
	),
	PLUGIN:RegisterSentence(
		"bounty:completed:4",
		"Your victory is temporary, %s. I'll be watching.",
		{
			{ 2, "Your victory is temporary, %s." },
			{ 2, "I'll be watching." },
		}
	),
}

--
-- The Nemesis AI will taunt those leading in the metrics, setting bounties on them. The taunts are generated based on the metrics.
--

local metricTaunts = {}

local function addMetricTaunt(metric, uniqueID)
    if (not metricTaunts[metric]) then
        metricTaunts[metric] = {}
    end

    metricTaunts[metric][#metricTaunts + 1] = uniqueID
end

addMetricTaunt(
	"Bolts Generated",
	PLUGIN:RegisterSentence(
		"taunt:Bolts Generated:1",
		"%s, your bolts are a testament to your greed. I'll make sure you pay for it.",
		{
			{ 2, "Your bolts are a testament to your greed." },
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
			{ 2, "Your bolts reveal your greed." },
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
			{ 2, "Your defenses are a sign of your weakness." },
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
			{ 2, "You think your defenses will save you?" },
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
			{ 2, "Your healing is a sign of weakness." },
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
			{ 2, "Your healing is in vain." },
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
			{ 2, "Your reliance on others to heal you is a weakness." },
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
			{ 2, "You sure do rely on others to heal you." },
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
			{ 2, "Your spending habits are a sign of your greed." },
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
			{ 2, "You spend your bolts like they're nothing." },
			{ 2, "I'll make sure you pay for it." },
		}
	)
)

addMetricTaunt(
	"Bounty Kills",
	PLUGIN:RegisterSentence(
		"taunt:Bounty Kills:1",
		"%s, irony is a cruel mistress. Let's see how you like being hunted.",
		{
			{ 2, "Irony is a cruel mistress." },
			{ 2, "Let's see how you like being hunted." },
		}
	)
)

addMetricTaunt(
	"Monster Damage",
	PLUGIN:RegisterSentence(
		"taunt:Monster Damage:1",
		"%s, your attacks against my failed experiments won't save you from my wrath.",
		{
			{ 2, "Your attacks against my failed experiments" },
			{ 2, "won't save you from my wrath." },
		}
	)
)

-- Check if any of the top characters are online. If so, taunt them and set a bounty.
function PLUGIN:OnNemesisThink()
    local interval = ix.config.Get("nemesisAiBountyIntervalSeconds")

    if (Schema.util.Throttle("NemesisMetricBounties", interval)) then
        return
    end

    local leaderboardsPlugin = ix.plugin.Get("leaderboards")
    local onlineCharactersByID = {}

    for _, client in ipairs(player.GetAll()) do
        if (client:GetCharacter()) then
            onlineCharactersByID[client:GetCharacter():GetID()] = client
        end
    end

    leaderboardsPlugin:GetTopCharacters(function(metricInfo)
        local availableBounties = {}

        for metricID, info in pairs(metricInfo) do
            local metricName = tostring(info.name)
            local taunts = metricTaunts[metricName]

            if (not taunts) then
                ix.util.SchemaErrorNoHalt("No taunt sentence registered for metric '" .. metricName .. "'.")
                continue
            end

            local topCharacters = info.topCharacters

            for _, data in ipairs(topCharacters) do
                local characterID = data.character_id
                local client = onlineCharactersByID[characterID]

                if (not IsValid(client)) then
                    continue
                end

                local existingBounty = client:GetCharacter():GetData("nemesisBounty")

				if (existingBounty and existingBounty.endsAt > os.time()) then
					continue
				end

				availableBounties[#availableBounties + 1] = {
					client = client,
					value = data.value,
					metricName = metricName,
					taunts = taunts,
				}
            end
        end

        -- Pick a random bounty and taunt them.
        if (#availableBounties == 0) then
            return
        end

        local bounty = availableBounties[math.random(#availableBounties)]
        local tauntUniqueID = bounty.taunts[math.random(#bounty.taunts)]

        self:PlayNemesisSentences(tauntUniqueID, nil, bounty.client:GetCharacter():GetName())
        self:SetBounty(bounty.client, bounty.value, bounty.metricName)
    end)
end
