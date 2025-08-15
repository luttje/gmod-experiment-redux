local PLUGIN = PLUGIN

--[[
	Commands only for testing cinematic sequences.
--]]

do
	local COMMAND = {}

	COMMAND.description = "Start a cinematic sequence for a player."
	COMMAND.arguments = {
		ix.type.player,
		ix.type.string
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target, sequenceID)
		PLUGIN:StartCinematicSequence(target, sequenceID)
		PLUGIN:SpawnPlayerAtCinematic(target, sequenceID)

		client:Notify("Started cinematic sequence '" .. sequenceID .. "' for " .. target:Name())
	end

	ix.command.Add("CinematicStart", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "End the cinematic sequence for a player."
	COMMAND.arguments = {
		ix.type.player
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target)
		PLUGIN:EndCinematicSequence(target)

		client:Notify("Ended cinematic sequence for " .. target:Name())
	end

	ix.command.Add("CinematicEnd", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Transition a player to a different cinematic sequence."
	COMMAND.arguments = {
		ix.type.player,
		ix.type.string,
		bit.bor(ix.type.number, ix.type.optional)
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target, newSequenceID, fadeTime)
		PLUGIN:TransitionPlayerToCinematic(target, newSequenceID, fadeTime)

		if (PLUGIN.playerSequences[target]) then
			PLUGIN.playerSequences[target].sequenceID = newSequenceID
		end

		client:Notify("Transitioning " .. target:Name() .. " to sequence '" .. newSequenceID .. "'")
	end

	ix.command.Add("CinematicTransition", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Toggle black and white effect for a player."
	COMMAND.arguments = {
		ix.type.player,
		bit.bor(ix.type.bool, ix.type.optional)
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target, enabled)
		if (enabled == nil) then
			enabled = true
		end

		PLUGIN:SetPlayerBlackAndWhite(target, enabled)

		client:Notify("Set black and white effect for " .. target:Name() .. " to " .. tostring(enabled))
	end

	ix.command.Add("CinematicBlackWhite", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Spawn enemies at cinematic enemy spawn points."
	COMMAND.arguments = {
		ix.type.string,
		bit.bor(ix.type.string, ix.type.optional),
		bit.bor(ix.type.string, ix.type.optional)
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, sequenceID, enemyClass, enemySpawnID)
		local enemies = PLUGIN:SpawnCinematicEnemy(sequenceID, enemyClass, enemySpawnID)

		client:Notify("Spawned " .. #enemies .. " enemies for sequence '" .. sequenceID .. "'")
	end

	ix.command.Add("CinematicSpawnEnemy", COMMAND)
end
