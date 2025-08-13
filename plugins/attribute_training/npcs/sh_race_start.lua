local PLUGIN = PLUGIN

--- @type ExperimentNpc
--- @diagnostic disable-next-line: assign-type-mismatch
local NPC = NPC

-- NPC Configuration
NPC.name = "Leo Usain"
NPC.description = "An athletic looking man, who seems eager to help you train."
NPC.model = "models/humans/group01/male_03.mdl"
NPC.voicePitch = 90

-- Race Configuration
NPC.raceStartCost = 100
NPC.raceStartsAfterSeconds = 30
NPC.raceIntervalInMinutes = 15
NPC.raceStartDistanceLimit = 256

-- Progression Keys
NPC.PROGRESSION_RACE_JOINED = "raceJoined"
NPC.PROGRESSION_RACE_STARTED = "raceStarted"

local INTERACTION_SET = NPC:RegisterInteractionSet({
	uniqueID = "raceStart_Main",

	serverCheckShouldStart = function(interactionSet, player, npcEntity)
		-- Always allow this interaction set
		return true
	end,
})

--[[
	Main race start interaction
--]]
local INTERACTION_RACE_START = INTERACTION_SET:RegisterInteraction({
	uniqueID = "raceStart",

	text = [[
		Hey there! I'm Leo Usain.

		You know that running is a great way to train your stamina and endurance, right? That's something you'll surely need in this
		forsaken place.

		I organize a race where you run from here to the finish line across the city. My colleague Enda Bolt will be waiting there for you.
		Other racers might join in, and the first one to talk to Enda Bolt at the finish line wins!

		<b>I only charge a small fee for our services. Do you want to race?</b>
	]],

	serverCheckShouldStart = function(interaction, player, npcEntity)
		local curTime = CurTime()
		local currentRaceStart = npcEntity:GetNetVar("expCurrentRaceStart", 0)
		local nextRaceStart = npcEntity:GetNetVar("expNextRaceStart", 0)

		-- Check if player already joined current race
		if npcEntity.expRaceData and npcEntity.expRaceData.runners and npcEntity.expRaceData.runners[player] then
			return false
		end

		-- Check if race already started
		if currentRaceStart > 0 and currentRaceStart - curTime <= NPC.raceStartsAfterSeconds then
			return false
		end

		-- Check if we need to wait for next race
		if nextRaceStart > 0 and nextRaceStart - curTime > 0 then
			return false
		end

		return true
	end,
})

-- Response: Join race (with money)
INTERACTION_RACE_START:RegisterResponse({
	answer = function(response, player, npcEntity)
		local character = player:GetCharacter()
		if character and character:HasMoney(NPC.raceStartCost) then
			return "Yes, I want to race! (Costs " .. ix.currency.Get(NPC.raceStartCost) .. ")"
		else
			return nil -- Hide this option if no money
		end
	end,

	next = "raceJoined",

	checkCanChoose = function(response, player, npcEntity)
		local character = player:GetCharacter()
		return character and character:HasMoney(NPC.raceStartCost)
	end,

	serverOnChoose = function(response, player, npcEntity)
		local character = player:GetCharacter()
		local entryFee = NPC.raceStartCost
		local curTime = CurTime()

		-- Take money
		character:TakeMoney(entryFee)

		-- Set race timing
		npcEntity:SetNetVar("expCurrentRaceStart", curTime + NPC.raceStartsAfterSeconds)
		npcEntity:SetNetVar("expNextRaceStart", curTime + (NPC.raceIntervalInMinutes * 60))

		-- Add player to race
		player:SetCharacterNetVar("expRaceJoined", npcEntity)
		npcEntity.expRaceData = npcEntity.expRaceData or {}
		npcEntity.expRaceData.runners = npcEntity.expRaceData.runners or {}
		npcEntity.expRaceData.runners[player] = {
			name = player:Name(),
			joinedAt = curTime,
			entryFee = entryFee,
		}

		-- Set global reference for finish line
		START_NPC_ENTITY = npcEntity

		-- Announce
		npcEntity:PrintChat("Stay close to me, " .. player:Name() .. ". I'll count down from 3 soon!")

		local contestantCount = table.Count(npcEntity.expRaceData.runners)
		if contestantCount > 1 then
			npcEntity:PrintChat("We have " .. contestantCount .. " contestants in the race now!")
		else
			npcEntity:PrintChat("You're the first contestant in the race. If you have friends, tell them to join!")
		end
	end,
})

-- Response: No money
INTERACTION_RACE_START:RegisterResponse({
	answer = function(response, player, npcEntity)
		local character = player:GetCharacter()
		if not character or not character:HasMoney(NPC.raceStartCost) then
			return "I don't have enough money..."
		else
			return nil -- Hide this option if they have money
		end
	end,

	checkCanChoose = function(response, player, npcEntity)
		local character = player:GetCharacter()
		return not character or not character:HasMoney(NPC.raceStartCost)
	end,
})

-- Response: Not interested
INTERACTION_RACE_START:RegisterResponse({
	answer = "No thanks.",
})

--[[
	Race joined interaction
--]]
local INTERACTION_RACE_JOINED = INTERACTION_SET:RegisterInteraction({
	uniqueID = "raceJoined",

	text = function(interaction, player, npcEntity)
		return [[
			Other runners can still join in. Stay close to me or I'll consider you forfeiting.

			The race will start somewhere within the next ]] .. string.NiceTime(NPC.raceStartsAfterSeconds) .. [[. Stay alert!
		]]
	end,

	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Check if player already joined and race hasn't started yet
		if npcEntity.expRaceData and npcEntity.expRaceData.runners and npcEntity.expRaceData.runners[player] then
			local currentRaceStart = npcEntity:GetNetVar("expCurrentRaceStart", 0)
			local curTime = CurTime()
			return currentRaceStart > 0 and currentRaceStart - curTime > 0 and not npcEntity.expRaceData.raceStartedAt
		end
		return false
	end,
})

INTERACTION_RACE_JOINED:RegisterResponse({
	answer = "Alright, I'll prepare myself",
})

--[[
	Race already joined interaction
--]]
local INTERACTION_RACE_ALREADY_JOINED = INTERACTION_SET:RegisterInteraction({
	uniqueID = "raceAlreadyJoined",

	text = function(interaction, player, npcEntity)
		local currentRaceStart = npcEntity:GetNetVar("expCurrentRaceStart", 0)
		local curTime = CurTime()

		if currentRaceStart > 0 and currentRaceStart - curTime > 0 then
			return "You've already joined the race, wait for it to start!"
		end

		return "The race has already started! Quick, run to the other side of the city and talk to Enda Bolt!"
	end,

	serverCheckShouldStart = function(interaction, player, npcEntity)
		-- Show this if player already joined and race has started
		if npcEntity.expRaceData and npcEntity.expRaceData.runners and npcEntity.expRaceData.runners[player] then
			return npcEntity.expRaceData.raceStartedAt ~= nil
		end
		return false
	end,
})

-- No responses needed for this interaction

--[[
	Race already started (can't join)
--]]
local INTERACTION_RACE_ALREADY_STARTED = INTERACTION_SET:RegisterInteraction({
	uniqueID = "raceAlreadyStarted",

	text = "Sorry, the race has already started. You can't join now.\n\nWe race every " ..
		NPC.raceIntervalInMinutes .. " minutes, come back later!",

	serverCheckShouldStart = function(interaction, player, npcEntity)
		local currentRaceStart = npcEntity:GetNetVar("expCurrentRaceStart", 0)
		local curTime = CurTime()

		-- Show if race started and player not in race
		if currentRaceStart > 0 and currentRaceStart - curTime <= NPC.raceStartsAfterSeconds then
			return not (npcEntity.expRaceData and npcEntity.expRaceData.runners and npcEntity.expRaceData.runners[player])
		end

		return false
	end,
})

INTERACTION_RACE_ALREADY_STARTED:RegisterResponse({
	answer = "I might come back later then"
})

INTERACTION_RACE_ALREADY_STARTED:RegisterResponse({
	answer = "Whatever, I don't care"
})

--[[
	Race recently started (cooldown)
--]]
local INTERACTION_RACE_RECENTLY_STARTED = INTERACTION_SET:RegisterInteraction({
	uniqueID = "raceRecentlyStarted",

	text = function(interaction, player, npcEntity)
		local nextRaceStart = npcEntity:GetNetVar("expNextRaceStart", 0)
		local curTime = CurTime()
		local raceStartRemaining = string.NiceTime(math.ceil(nextRaceStart - curTime))

		return "Sorry, we just had a race. We have one every " ..
			NPC.raceIntervalInMinutes .. " minutes, come back in " .. raceStartRemaining .. "!"
	end,

	serverCheckShouldStart = function(interaction, player, npcEntity)
		local nextRaceStart = npcEntity:GetNetVar("expNextRaceStart", 0)
		local curTime = CurTime()

		return nextRaceStart > 0 and nextRaceStart - curTime > 0
	end,
})

INTERACTION_RACE_RECENTLY_STARTED:RegisterResponse({
	answer = "I might come back later then"
})

-- NPC Think function (converted from OnThink)
function NPC:OnThink(npcEntity)
	local curTime = CurTime()
	local currentRaceStart = npcEntity:GetNetVar("expCurrentRaceStart", 0)

	if currentRaceStart == 0 then
		return
	end

	if npcEntity.expRaceData and npcEntity.expRaceData.runners and self:CheckRunners(npcEntity) == 0 then
		if npcEntity.expRaceData.raceStartedAt then
			return
		end

		npcEntity:PrintChat("I can't believe it! No one finished, so there's no winner!")
		npcEntity:SetNetVar("expCurrentRaceStart", 0)
		npcEntity.expRaceData = nil
		return
	end

	if curTime > currentRaceStart then
		npcEntity.expRaceData = npcEntity.expRaceData or {}
		npcEntity.expRaceData.countdown = npcEntity.expRaceData.countdown or 4

		if npcEntity.expRaceData.countdown > 0 then
			if npcEntity.expRaceData.countdown == 4 then
				local names = ""
				for runner, data in pairs(npcEntity.expRaceData.runners) do
					names = names .. data.name .. ", "
				end
				npcEntity:PrintChat("Get ready, " .. string.sub(names, 1, -3) .. "!", true)
			elseif npcEntity.expRaceData.countdown == 3 then
				npcEntity:PrintChat("3...", true)
			elseif npcEntity.expRaceData.countdown == 2 then
				npcEntity:PrintChat("2...", true)
			elseif npcEntity.expRaceData.countdown == 1 then
				npcEntity:PrintChat("1...", true)
			end

			npcEntity.expRaceData.countdown = npcEntity.expRaceData.countdown - 1
		else
			npcEntity:PrintChat("GO!", true)
			npcEntity:SetNetVar("expCurrentRaceStart", 0)
			npcEntity.expRaceData.countdown = nil
			npcEntity.expRaceData.raceStartedAt = curTime

			-- Hide the distance limit for the runners
			for runner, data in pairs(npcEntity.expRaceData.runners) do
				runner:SetCharacterNetVar("expRaceJoined", NULL)
				runner:SetCharacterNetVar("expRaceStartedAt", curTime)
			end
		end

		return
	end
end

-- Check runners function (preserved from original)
function NPC:CheckRunners(npcEntity)
	local runnerCount = 0

	for runner, data in pairs(npcEntity.expRaceData.runners) do
		if not IsValid(runner) or not runner:GetCharacter() then
			npcEntity.expRaceData.runners[runner] = nil
			continue
		end

		local distance = runner:GetPos():Distance(npcEntity:GetPos())

		if distance > NPC.raceStartDistanceLimit then
			npcEntity:PrintChat(npcEntity.expRaceData.runners[runner].name .. " has forfeited the race!", true)
			npcEntity.expRaceData.runners[runner] = nil
			runner:SetCharacterNetVar("expRaceJoined", NULL)
			continue
		end

		runnerCount = runnerCount + 1
	end

	return runnerCount
end

-- Goodbye messages
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

-- Client-side HUD functions
if CLIENT then
	function NPC:HUDPaintStarted()
		local client = LocalPlayer()
		local raceStartedAt = client:GetCharacterNetVar("expRaceStartedAt")
		if not raceStartedAt then return end

		local raceTime = string.FormattedTime(CurTime() - raceStartedAt, "%02i:%02i.%02i")
		Schema.draw.DrawLabeledValue("Race Time:", raceTime)
	end

	function NPC:HUDPaintBeforeStart(npcEntity)
		local client = LocalPlayer()
		local raceEntityPosition = npcEntity:GetPos()
		local distance = client:GetPos():Distance(raceEntityPosition)

		if distance >= NPC.raceStartDistanceLimit then
			return
		end

		local position = (raceEntityPosition + Vector(0, 0, 52)):ToScreen()
		local limitInMeters = math.floor(Schema.util.UnitToCentimeters(NPC.raceStartDistanceLimit) / 100)
		local distanceInMeters = math.ceil(Schema.util.UnitToCentimeters(distance) / 100)

		if not position.visible then
			return
		end

		local color = distanceInMeters > (limitInMeters * .8) and Color(255, 50, 50) or Color(90, 140, 90)

		draw.SimpleTextOutlined("Stay within " .. limitInMeters .. "m to stay in race.", "ixSmallFont", position.x,
			position.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		draw.SimpleTextOutlined("Distance: " .. distanceInMeters .. "m", "ixBigFont", position.x, position.y + 8,
			color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	end
end
