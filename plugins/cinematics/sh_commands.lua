local PLUGIN = PLUGIN

--[[
	Commands for testing the scene-based cinematic system.
--]]

do
	local COMMAND = {}

	COMMAND.description = "Put a player in a cinematic scene."
	COMMAND.arguments = {
		ix.type.player,
		ix.type.string
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target, sceneID)
		local success = PLUGIN:PutPlayerInScene(target, sceneID)

		if (success) then
			client:Notify("Put " .. target:Name() .. " in scene '" .. sceneID .. "'")
		else
			client:Notify("Failed to put " .. target:Name() .. " in scene '" .. sceneID .. "'")
		end
	end

	ix.command.Add("ScenePut", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Remove a player from their current scene."
	COMMAND.arguments = {
		ix.type.player
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target)
		local currentScene = PLUGIN:GetPlayerScene(target)

		if (currentScene) then
			PLUGIN:RemovePlayerFromScene(target)
			client:Notify("Removed " .. target:Name() .. " from scene '" .. currentScene .. "'")
		else
			client:Notify(target:Name() .. " is not in any scene")
		end
	end

	ix.command.Add("SceneRemove", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Transition a player to a different scene."
	COMMAND.arguments = {
		ix.type.player,
		ix.type.string,
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional)
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target, newSceneID, fadeTime, blackPeriod)
		local success = PLUGIN:TransitionPlayerToScene(target, newSceneID, fadeTime, blackPeriod)

		if (success) then
			client:Notify("Transitioning " .. target:Name() .. " to scene '" .. newSceneID .. "'")
		else
			client:Notify("Failed to transition " .. target:Name() .. " to scene '" .. newSceneID .. "'")
		end
	end

	ix.command.Add("SceneTransition", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Show cinematic text to a player."
	COMMAND.arguments = {
		ix.type.player,
		ix.type.string,
		bit.bor(ix.type.number, ix.type.optional)
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target, text, duration)
		PLUGIN:ShowCinematicText(target, text, duration)

		client:Notify("Showing text to " .. target:Name() .. ": '" .. text .. "'")
	end

	ix.command.Add("SceneText", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Check which scene a player is currently in."
	COMMAND.arguments = {
		ix.type.player
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target)
		local currentScene = PLUGIN:GetPlayerScene(target)

		if (currentScene) then
			client:Notify(target:Name() .. " is in scene '" .. currentScene .. "'")
		else
			client:Notify(target:Name() .. " is not in any scene")
		end
	end

	ix.command.Add("SceneCheck", COMMAND)
end
