local PLUGIN = PLUGIN

function PLUGIN:GetCinematicSpawns(cinematicSpawnID)
	local spawns = {}

	for _, entity in ipairs(ents.FindByClass("exp_cinematic_spawn")) do
		if (entity:GetSequenceID() == cinematicSpawnID) then
			spawns[#spawns + 1] = entity
		end
	end

	return spawns
end

function PLUGIN:PutPlayerInScene(client, sceneID)
	local scene = self:GetScene(sceneID)
	if (not scene) then
		ix.util.SchemaErrorNoHalt("Scene not found: " .. sceneID)
		return false
	end

	-- End any existing scene
	if (self.playerScenes[client]) then
		self:RemovePlayerFromScene(client)
	end

	-- Set up new scene
	self.playerScenes[client] = {
		scene = scene,
		startTime = CurTime()
	}

	-- Spawn player at cinematic spawn if specified
	if (scene.cinematicSpawnID) then
		self:SpawnPlayerAtCinematic(client, scene.cinematicSpawnID, true)
	end

	-- Call server-side scene enter
	if (scene.OnEnterServer) then
		scene:OnEnterServer(client)
	end

	-- Notify client to enter scene
	net.Start("ixCinematicEnterScene")
	net.WriteString(sceneID)
	net.Send(client)

	hook.Run("PlayerEnteredScene", client, sceneID)
	return true
end

function PLUGIN:IsPlayerInScene(client, sceneID)
	local sceneData = self.playerScenes[client]
	if (not sceneData) then
		return false
	end

	return sceneData.scene.sceneID == sceneID
end

function PLUGIN:RemovePlayerFromScene(client)
	local sceneData = self.playerScenes[client]
	if (not sceneData) then
		return
	end

	local scene = sceneData.scene

	if (scene.OnLeaveServer) then
		scene:OnLeaveServer(client)
	end

	self.playerScenes[client] = nil

	-- Reset visual effects
	net.Start("ixCinematicSetBlackWhite")
	net.WriteBool(false)
	net.Send(client)

	-- Notify client to leave scene
	net.Start("ixCinematicLeaveScene")
	net.Send(client)

	hook.Run("PlayerLeftScene", client, scene.sceneID)
end

function PLUGIN:RemovePlayerFromSceneFadeOut(client, fadeTime, blackPeriod, callback)
	local sceneData = self.playerScenes[client]
	if (not sceneData) then
		if (callback) then
			callback()
		end
		return false
	end

	fadeTime = fadeTime or ix.config.Get("cinematicFadeTime")
	blackPeriod = blackPeriod or ix.config.Get("cinematicBlackPeriod")

	-- Store removal data for when fade completes
	self.pendingRemovals = self.pendingRemovals or {}
	self.pendingRemovals[client] = {
		callback = callback,
		sceneID = sceneData.scene.sceneID
	}

	-- Start fade out with callback
	net.Start("ixCinematicFadeOut")
	net.WriteFloat(fadeTime)
	net.WriteBool(true)                       -- has callback
	net.WriteFloat(blackPeriod)
	net.WriteString(PLUGIN.REMOVE_FROM_SCENE_ID) -- Special identifier for removal
	net.Send(client)

	return true
end

function PLUGIN:TransitionPlayerToScene(client, newSceneID, fadeTime, blackPeriod)
	local newScene = self:GetScene(newSceneID)
	if (not newScene) then
		ix.util.SchemaErrorNoHalt("Scene not found for transition: " .. newSceneID)
		return false
	end

	fadeTime = fadeTime or ix.config.Get("cinematicFadeTime")
	blackPeriod = blackPeriod or ix.config.Get("cinematicBlackPeriod")

	-- Store transition data
	self.pendingTransitions = self.pendingTransitions or {}
	self.pendingTransitions[client] = newSceneID

	net.Start("ixCinematicFadeOut")
	net.WriteFloat(fadeTime)
	net.WriteBool(true) -- has callback
	net.WriteFloat(blackPeriod)
	net.WriteString(newSceneID)
	net.Send(client)

	return true
end

function PLUGIN:SpawnPlayerAtCinematic(client, cinematicSpawnID, fadeIn)
	local spawns = self:GetCinematicSpawns(cinematicSpawnID)

	if (#spawns == 0) then
		ix.util.SchemaErrorNoHalt("No cinematic spawns found for: " .. cinematicSpawnID)
		return false
	end

	local spawn = spawns[math.random(1, #spawns)]
	local position = spawn:GetPos()
	local angles = spawn:GetAngles()

	client:SetPos(position)
	client:SetEyeAngles(angles)
	client:SetLocalVelocity(Vector(0, 0, 0))

	if (fadeIn ~= false) then
		local fadeTime = ix.config.Get("cinematicFadeTime")

		net.Start("ixCinematicFadeIn")
		net.WriteFloat(fadeTime)
		net.Send(client)
	end

	return true
end

function PLUGIN:SetPlayerBlackAndWhite(client, enabled)
	net.Start("ixCinematicSetBlackWhite")
	net.WriteBool(enabled)
	net.Send(client)
end

function PLUGIN:ShowCinematicText(client, text, duration)
	duration = duration or ix.config.Get("cinematicTextDuration")

	net.Start("ixCinematicShowText")
	net.WriteString(text)
	net.WriteFloat(duration)
	net.Send(client)
end

function PLUGIN:GetPlayerScene(client)
	local sceneData = self.playerScenes[client]
	if (sceneData) then
		return sceneData.scene.sceneID
	end
	return nil
end

-- Server-side network message receiver for transition/removal completion
net.Receive("ixCinematicFadeComplete", function(len, client)
	local sceneID = net.ReadString()

	-- Handle scene removal
	if (sceneID == PLUGIN.REMOVE_FROM_SCENE_ID) then
		if (PLUGIN.pendingRemovals and PLUGIN.pendingRemovals[client]) then
			local removalData = PLUGIN.pendingRemovals[client]
			PLUGIN.pendingRemovals[client] = nil

			-- Remove player from scene
			PLUGIN:RemovePlayerFromScene(client)

			-- Execute callback if provided
			if (removalData.callback) then
				removalData.callback()
			end
		end

		return
	end

	-- Handle scene transition
	if (PLUGIN.pendingTransitions and PLUGIN.pendingTransitions[client]) then
		PLUGIN.pendingTransitions[client] = nil
		PLUGIN:PutPlayerInScene(client, sceneID)
	end
end)

function PLUGIN:Think()
	-- Call OnServerThink for all players in scenes
	for client, sceneData in pairs(self.playerScenes) do
		if (IsValid(client) and sceneData.scene.OnServerThink) then
			sceneData.scene:OnServerThink(client)
		end
	end
end

function PLUGIN:PlayerDisconnected(client)
	self:RemovePlayerFromScene(client)

	if (self.pendingTransitions) then
		self.pendingTransitions[client] = nil
	end

	if (self.pendingRemovals) then
		self.pendingRemovals[client] = nil
	end
end
