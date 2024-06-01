local PLUGIN = PLUGIN

-- How many of the items in the locker are infected based on the leaderboard rank.
-- This is how many they have to move to the safe locker to save them from being lost.
PLUGIN.rankToPercentInfection = {
	[1] = 0.5, -- 50% of the items in the locker are infected
	[2] = 0.4,
	[3] = 0.3,
	[4] = 0.2,
	[5] = 0.1,
}
PLUGIN.percentInfectionLowerRanks = 0.05 -- Everyone else gets 5% of their items infected

-- How long the player is kept waiting before they're told where the anti-virus is.
-- This builds tension and makes it more challenging for higher ranks.
PLUGIN.rankToTimeBeforeAntivirusRevealSeconds = {
	[1] = 100, -- 100 seconds before the target is told at what locker the anti-virus is
	[2] = 80,
	[3] = 60,
	[4] = 40,
	[5] = 20,
}
PLUGIN.timeBeforeAntivirusRevealLowerRanks = 5 -- Everyone else gets 5 seconds before they're told where the anti-virus is

-- How many of the items that are infected are dropped when the target is killed.
-- The rest is destroyed by the 'Locker Rot Virus', this is to prevent their friends from just killing them to claim the bounty.
PLUGIN.rankToPercentItemsDropped = 0.5 -- half

function PLUGIN:GetLockerRotEvent()
    return self.lockerRotEvent
end

function PLUGIN:LockerRotThink()
	local interval = ix.config.Get("nemesisAiLockerRotIntervalSeconds")

	if (Schema.util.Throttle("NemesisMetricLockerRotGrace", interval)) then
		return
	end

	-- Don't overwhelm the server with multiple locker rot events.
	local activeLockerRotEvent = self:GetLockerRotEvent()

	if (activeLockerRotEvent) then
		return
	end

	local leaderboardsPlugin = ix.plugin.Get("leaderboards")
	local onlineCharactersByID = {}

	-- Collect online characters that qualify to become locker rot victims.
    for _, client in ipairs(player.GetAll()) do
        local character = client:GetCharacter()

        if (not character) then
            continue
        end

        -- Make sure all players have played for at least a couple hours on their characters
        if (character:GetCreateTime() + (60 * 2) > os.time()) then
            continue
        end

        -- Make sure they've played for at least 5 minutes (so they have a chance to load into the server)
        if (client.expLastCharacterLoadedAt + (60 * 5) > CurTime()) then
            continue
        end

        -- Check if the character has a locker rot cooldown, so we don't spam them with challenges.
        local lockerRotGraceEndsAt = character:GetData("nemesisLockerRotGraceEndsAt")

        if (lockerRotGraceEndsAt and lockerRotGraceEndsAt <= os.time()) then
            lockerRotGraceEndsAt = nil
            character:SetData("nemesisLockerRotGraceEndsAt", lockerRotGraceEndsAt)
        end

        if (lockerRotGraceEndsAt) then
            continue
        end

        if (not character:GetLockerInventory()) then
            -- This character has never visited their locker, so they can't have any items to infect.
            continue
        end

        onlineCharactersByID[character:GetID()] = client
    end

	-- We try to find the player that has the highest rank of all the metrics, and infect their locker.
	leaderboardsPlugin:GetTopCharacters(function(metricInfo)
		local highestRankingTargets = {}
		local highestRank = -1

		for metricID, info in pairs(metricInfo) do
			local metricName = tostring(info.name)
			local taunts = self.metricTaunts[metricName]

			if (not taunts) then
				ix.util.SchemaErrorNoHalt("No taunt sentence registered for metric '" .. metricName .. "'.")
				continue
			end

			local topCharacters = info.topCharacters

			for rank, data in ipairs(topCharacters) do
				local characterID = data.character_id
				local client = onlineCharactersByID[characterID]

				if (not IsValid(client)) then
					continue
				end

				local lockerRotEvent = {
					targetCharacter = client:GetCharacter(),
					value = data.value,
					metricName = metricName,
					taunts = taunts,
					rank = rank,
				}

				if (rank > highestRank) then
					highestRank = rank
					highestRankingTargets = { lockerRotEvent }
				elseif (rank == highestRank) then
					highestRankingTargets[#highestRankingTargets + 1] = lockerRotEvent
				end
			end
		end

		if (highestRank == -1) then
			-- None of the metrics have any top characters online.
			return
		end

		-- If there are multiple characters with the same highest rank, we pick one at random.
		local lockerRotEvent = highestRankingTargets[math.random(#highestRankingTargets)]

		self:StartLockerRotEvent(lockerRotEvent.targetCharacter, lockerRotEvent)
	end)
end

function PLUGIN:GetInfectableItems(inventory)
	local infectableItems = {}

	for _, item in pairs(inventory:GetItems()) do
		if (item.noBusiness or item.noDrop or not item.price or item.isBag) then
			continue
		end

		table.insert(infectableItems, item)
	end

	-- Sort the items by their value
	table.sort(infectableItems, function(a, b)
		return a.price > b.price
	end)

	return infectableItems
end

-- Remove the rotting items from their inventory and lockers
function PLUGIN:RemoveAllInfectedItems(character, noReplication)
	local lockerInventory = character:GetLockerInventory()
    local inventory = character:GetInventory()
	local removed = 0

	for _, item in pairs(lockerInventory:GetItems()) do
		if (item:GetData("lockerRot")) then
            item:Remove(noReplication)
			removed = removed + 1
		end
	end

    for _, item in pairs(inventory:GetItems()) do
        if (item:GetData("lockerRot")) then
            item:Remove(noReplication)
            removed = removed + 1
        end
    end

	return removed
end

function PLUGIN:ClearLockerRotNetVar(client)
	client:SetLocalVar("lockerRotAntiVirusPosition")
	client:SetLocalVar("lockerRotAntiVirusRevealTime")
	client:SetLocalVar("lockerRotAntiVirusTime")
	self:SetTarget(nil)
end

function PLUGIN:StartLockerRotEvent(targetCharacter, lockerRotEvent)
    local function checkCharacterHasItemsToInfect()
        local lockerInventory = targetCharacter:GetLockerInventory()
        local infectableItems = self:GetInfectableItems(lockerInventory)
        local infectionPercentage = self.rankToPercentInfection[lockerRotEvent.rank] or self.percentInfectionLowerRanks
        local itemsToInfect = math.Round(#infectableItems * infectionPercentage)
        local infectionCount = 0

        -- Mark the most valuable items as infected
        for itemIndex = 1, itemsToInfect do
            local randomItem = infectableItems[itemIndex]

            if (not randomItem) then
                -- The player doesn't have many items, so we can't infect more
                -- TODO: Maybe we should infect items in the player's inventory as well?
                break
            end

            randomItem:SetData("lockerRot", true)

            table.remove(infectableItems, itemIndex)

            infectionCount = infectionCount + 1
        end

        return infectionCount > 0
    end

	if (not checkCharacterHasItemsToInfect()) then
		return
	end

	-- Inform all players about the event, so they run to their lockers to check if they're infected.
	-- This brings them all out on the streets, making it harder for the target to reach the safe locker.
	local randomStartTaunt = self.lockerRotStartTaunts[math.random(#self.lockerRotStartTaunts)]
    self:PlayNemesisSentences(randomStartTaunt, nil, nil, function()
        if (not targetCharacter or not IsValid(targetCharacter:GetPlayer())) then
            -- The target player left before the AI could generate the event audio
            return
        end

        if (not checkCharacterHasItemsToInfect()) then
			-- The target player took items from their locker, before the AI could announce the event
			return
		end

        self.lockerRotEvent = lockerRotEvent

		targetCharacter:SetData("nemesisLockerRotGraceEndsAt", os.time() + ix.config.Get("nemesisAiLockerRotGraceSeconds"))

		-- We don't want players to disconnect now, since that would result in them losing their items if they have the locker rot.
		ix.chat.Send(nil,
			"nemesis_ai_locker_rot_warning",
			"Disconnecting now will result in you losing items from your locker if it has been infected by 'Locker Rot'. "
			.. "Go check if you have it in your locker and see if you can save your items!"
		)

		-- Force the event to start if the target doesn't close their locker before the time is up
		timer.Simple(25, function()
			local client = targetCharacter and targetCharacter:GetPlayer() or nil

			if (not self.lockerRotEvent or not IsValid(client)) then
				return
			end

			self:SetUpIfNeeded(client)
		end)
    end)
end

-- If the player disconnects while they have locker rot, check if they have picked up the items yet.
-- If they haven't, remove the items from their locker. If they have, remove the items from their inventory.
function PLUGIN:OnCharacterDisconnect(client, character)
	local lockerRot = self:GetLockerRotEvent()

	if (not lockerRot or lockerRot.targetCharacter ~= character) then
		return
	end

	-- Remove without replication, since the player disconnected anyway and wont be in their locker inventory
	local noReplication = true
	self:RemoveAllInfectedItems(character, noReplication)

	ix.chat.Send(nil,
		"nemesis_ai_locker_rot_hint",
		character:GetName()
		.. "has disconnected and their locker has been consumed by 'Locker Rot'. "
		.. "Their items have been lost to the void."
	)

	self.lockerRotEvent = nil
end

-- If an item is infected, it can't be transferred from a non-locker inventory (e.g: player inventory)
-- It can only be taken from the locker and brought to the safe locker (where the anti-virus will remove the rot so the items can be stored again)
function PLUGIN:CanTransferItem(item, sourceInventory, targetInventory)
	if (not item:GetData("lockerRot")) then
		return
	end

	-- Let items be added to the inventory if their coming from the world
	-- This also happens when a locker item is taken (it's first removed, then added, meaning this hook gets called twice)
	if (sourceInventory:GetID() == 0) then
		return
	end

	if (not sourceInventory.storageInfo or not sourceInventory.storageInfo.isLockersInventory) then
		return false
	end
end

function PLUGIN:CanPlayerEquipItem(client, item)
	if (item:GetData("lockerRot")) then
		client:Notify("This item can't be equipped because it's infected with Locker Rot.")
		return false
	end
end

-- Finds the locker that is furthest away from the target
function PLUGIN:FindLockerForAntiVirus(client)
    local lockers = ents.FindByClass("exp_lockers")
    local targetPos = client:GetPos()

    local furthestLocker
    local furthestDistance = 0

    for _, locker in ipairs(lockers) do
        local lockerPos = locker:GetPos()
        local distance = targetPos:DistToSqr(lockerPos)

        if (distance > furthestDistance) then
            furthestLocker = locker
            furthestDistance = distance
        end
    end

    return furthestLocker
end

-- Expire the quantum buffer immunity buff if the player has the locker rot
function PLUGIN:PlayerBuffShouldExpire(client, buffTable, buff)
    local lockerRot = self:GetLockerRotEvent()

    if (not lockerRot or lockerRot.targetCharacter ~= client:GetCharacter()) then
        return
    end

    if (buffTable.uniqueID == "quantum_buffer") then
        return true
    end
end

function PLUGIN:SetUpIfNeeded(client)
    local lockerRot = self:GetLockerRotEvent()

    if (not lockerRot or lockerRot.targetCharacter ~= client:GetCharacter()) then
        return
    end

    if (lockerRot.setupId) then
        return
    end

    lockerRot.setupId = os.time()

    local revealDelay = self.rankToTimeBeforeAntivirusRevealSeconds[lockerRot.rank] or
        self.timeBeforeAntivirusRevealLowerRanks

    ix.chat.Send(
        nil,
        "nemesis_ai_locker_rot_hint",
        "Your locker has been infected by the 'Locker Rot Virus'. "
        .. "You must bring your items to the locker with the anti-virus. "
        .. "The locker location will be revealed in "
        .. string.NiceTime(revealDelay),
        false,
        { client }
    )

	client:SetLocalVar("lockerRotAntiVirusRevealTime", CurTime() + revealDelay)

    local function getCharacterIfLockerRotStillActive()
        if (not self.lockerRotEvent) then
            return
        end

        -- A locker rot event has been started since the setupId was set, but it's not the same event
        -- This might happen if a player finishes the task, and then within the same time the task is allowed
        -- to be completed, a new event is started. However this should only happen during testing, since
		-- task time is far less than the interval between events.
		if (self.lockerRotEvent.setupId ~= lockerRot.setupId) then
			return
		end

        return IsValid(client) and client:GetCharacter() or nil
    end

    local character

    -- First we wait a moment and inform the city that the target has been infected
    -- With SetTarget with have all monitors display where the target is, so they can be hunted down.
    timer.Simple(1, function()
        character = getCharacterIfLockerRotStillActive()

        if (not character) then
            return
        end

        local randomTaunt = lockerRot.taunts[math.random(#lockerRot.taunts)]

        self:SetTarget(client)

        self:PlayNemesisSentences(randomTaunt, nil, character:GetName())

        ix.chat.Send(nil,
            "nemesis_ai_locker_rot",
            character:GetName(),
			false,
            Schema.util.AllPlayersExcept(client),
			{
				score = lockerRot.value,
				metric = lockerRot.metricName,
            }
		)
    end)

    -- After a delay (more challenging for higher ranks) we reveal where the anti-virus is
    timer.Simple(revealDelay, function()
        character = getCharacterIfLockerRotStillActive()

        if (not character) then
            return
        end

        -- Tell the target where the anti-virus is and how long they have to get there
        local secondsToComplete = ix.config.Get("nemesisAiLockerRotTaskSeconds")

        -- Find the exp_lockers furthest away from the target
        local antiVirusLocker = self:FindLockerForAntiVirus(client)
        self.lockerRotEvent.antiVirusLocker = antiVirusLocker

        local antiVirusLockerPosition = antiVirusLocker:GetPos() + (antiVirusLocker:GetUp() * 40)

        client:SetLocalVar("lockerRotAntiVirusPosition", antiVirusLockerPosition)
        client:SetLocalVar("lockerRotAntiVirusTime", CurTime() + secondsToComplete)

        ix.chat.Send(
            nil,
            "nemesis_ai_locker_rot_hint",
            "The locker with the anti-virus is revealed. A marker on screen points to it. "
            .. "Bring your items to this locker to save them from being lost forever. "
            .. "If killed by another player, they can claim some items, the rest will be lost. You have "
            .. string.NiceTime(secondsToComplete)
            .. " to do this.",
            false,
            { client }
        )

        -- After the time expires and the target hasn't reached the safe locker, they lose their items
        timer.Simple(secondsToComplete, function()
            character = getCharacterIfLockerRotStillActive()

            if (not character) then
                return
            end

            self:ClearLockerRotNetVar(client)
            local removedItemCount = self:RemoveAllInfectedItems(character)
			self.lockerRotEvent = nil

            local randomTaunt = self.lockerRotFailedTaunts[math.random(#self.lockerRotFailedTaunts)]
            self:PlayNemesisSentences(randomTaunt, nil, character:GetName())

			ix.chat.Send(nil,
				"nemesis_ai_locker_rot_warning",
				"The 'Locker Rot Virus' has consumed "
				.. tostring(removedItemCount)
				.. " items from your locker and/or inventory. "
                .. "You have failed to save them in time.",
                false,
				{ client }
			)
        end)
    end)
end

-- Once the locker is closed, take a second, then inform all players that the target has been infected.
-- Setting the target and taunting based on their metric score.
function PLUGIN:OnPlayerLockerClosed(client, lockers)
    self:SetUpIfNeeded(client)
end

-- If the client that has the locker rot event opens the locker with the anti-virus, they're safe and
-- we can clear the locker rot event, removing the locker rot from their items.
function PLUGIN:OnPlayerLockerOpened(client, lockers)
	local lockerRot = self:GetLockerRotEvent()
    local character = client:GetCharacter()

	if (not lockerRot or lockerRot.targetCharacter ~= character) then
		return
	end

    if (lockerRot.antiVirusLocker ~= lockers) then
        return
    end

    -- Grant the player immunity for a while so they don't get killed by other players while they're
	-- interacting with their locker
	Schema.buff.SetActive(client, "quantum_buffer", CurTime() + 120)

    self:ClearLockerRotNetVar(client)

    -- Clear the locker rot from the items in their inventory
	local inventory = character:GetInventory()

	for _, item in pairs(inventory:GetItems()) do
		if (item:GetData("lockerRot")) then
			item:SetData("lockerRot", nil)
		end
	end

	-- Remove any remaining infected item in their original locker
    local removedItemCount = self:RemoveAllInfectedItems(character)

	ix.chat.Send(nil,
        "nemesis_ai_locker_rot_hint",
		"The hunt is over as "
		.. character:GetName()
        .. " has successfully removed the 'Locker Rot Virus' from their items.",
        false,
		Schema.util.AllPlayersExcept(client)
    )

	if (removedItemCount > 0) then
		ix.chat.Send(nil,
			"nemesis_ai_locker_rot_warning",
			"The 'Locker Rot Virus' has consumed "
			.. tostring(removedItemCount)
			.. " items from your locker and/or inventory. "
            .. "You have successfully saved the rest.",
            false,
			{ client }
		)
	end

	local randomTaunt = self.lockerRotCompleteAntiVirusTaunt[math.random(#self.lockerRotCompleteAntiVirusTaunt)]
	self:PlayNemesisSentences(randomTaunt, nil, client:GetName())

	self.lockerRotEvent = nil
end

-- If the character dies, destroy a part of their items, the rest is lost.
-- Removes items from the inventory right away, so they can't be transferred to the corpse in a moment.
function PLUGIN:DoPlayerDeath(client, attacker, damageinfo)
	if (not self.lockerRotEvent) then
		return
	end

	local character = client:GetCharacter()

	if (not character or self.lockerRotEvent.targetCharacter ~= character) then
		return
	end

	local inventory = character:GetInventory()
	local candidateItems = {}

	for _, item in pairs(inventory:GetItems()) do
		if (item:GetData("lockerRot")) then
			table.insert(candidateItems, item)
		end
	end

	local itemCountToDrop = math.Round(#candidateItems * self.rankToPercentItemsDropped)
	local itemCountToRemove = #candidateItems - itemCountToDrop

	-- Lose these items forever (the rest will drop into the corpse)
	for i = 1, itemCountToRemove do
		candidateItems[i]:Remove()
	end

	self:ClearLockerRotNetVar(client)
	self:SetTarget(nil)

    if (IsValid(attacker) and attacker:IsPlayer()) then
        local randomTaunt = self.lockerRotCompleteTaunts[math.random(#self.lockerRotCompleteTaunts)]
        self:PlayNemesisSentences(randomTaunt, nil, attacker:GetName())
    else
        local randomTaunt = self.lockerRotCompleteNoAttackerTaunts[math.random(#self.lockerRotCompleteNoAttackerTaunts)]
        self:PlayNemesisSentences(randomTaunt, nil, character:GetName())
    end

	self.lockerRotEvent = nil
end

-- Always drop the remaining items that are infected with the locker rot on death (the rest will already have been removed)
function PLUGIN:ShouldPlayerDeathDropItem(client, item, dropModeIsRandom)
	if (not self.lockerRotEvent) then
		return
	end

    if (not item:GetData("lockerRot")) then
        return
    end

	-- When dropping the item stops rotting
	item:SetData("lockerRot", nil)

	return true
end
