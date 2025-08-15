local PLUGIN = PLUGIN

PLUGIN.name = "Cinematics"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Cinematic sequences and transitions for immersive storytelling."

ix.util.Include("sh_commands.lua")

PLUGIN.activeSequences = PLUGIN.activeSequences or {}
PLUGIN.playerSequences = PLUGIN.playerSequences or {}

if (SERVER) then
	util.AddNetworkString("ixCinematicFadeIn")
	util.AddNetworkString("ixCinematicFadeOut")
	util.AddNetworkString("ixCinematicFadeComplete")
	util.AddNetworkString("ixCinematicSetBlackWhite")
	util.AddNetworkString("ixCinematicShowText")
end

ix.config.Add("cinematicFadeTime", 2, "Duration of fade in/out effects during cinematics.", nil, {
	data = { min = 0.5, max = 10, decimals = 1 },
	category = "cinematics"
})

ix.config.Add("cinematicTextDuration", 5, "Default duration for cinematic text display.", nil, {
	data = { min = 1, max = 30, decimals = 0 },
	category = "cinematics"
})

ix.config.Add("cinematicBlackPeriod", 0.5, "Duration of black screen during cinematic transitions.", nil, {
	data = { min = 0.1, max = 2, decimals = 1 },
	category = "cinematics"
})

if (CLIENT) then
	PLUGIN.cinematicData = PLUGIN.cinematicData or {}

	function PLUGIN:FadeIn(fadeTime)
		fadeTime = fadeTime or ix.config.Get("cinematicFadeTime", 2)

		self.cinematicData.fadeIn = {
			startTime = CurTime(),
			duration = fadeTime,
			active = true
		}

		-- Clear any existing fade out
		self.cinematicData.fadeOut = nil
	end

	function PLUGIN:FadeOut(fadeTime, callback)
		fadeTime = fadeTime or ix.config.Get("cinematicFadeTime", 2)

		self.cinematicData.fadeOut = {
			startTime = CurTime(),
			duration = fadeTime,
			active = true,
			callback = callback
		}

		-- Clear any existing fade in
		self.cinematicData.fadeIn = nil
	end

	function PLUGIN:RenderScreenspaceEffects()
		-- Handle black and white effect
		if (self.cinematicData.blackAndWhite and IsValid(LocalPlayer())) then
			local tab = {}
			tab["$pp_colour_addr"] = 0
			tab["$pp_colour_addg"] = 0
			tab["$pp_colour_addb"] = 0
			tab["$pp_colour_brightness"] = 0
			tab["$pp_colour_contrast"] = 1.2
			tab["$pp_colour_colour"] = 0
			tab["$pp_colour_mulr"] = 0
			tab["$pp_colour_mulg"] = 0
			tab["$pp_colour_mulb"] = 0

			DrawColorModify(tab)
		end
	end

	function PLUGIN:Think()
		-- Handle fade out completion and callback
		if (self.cinematicData.fadeOut and self.cinematicData.fadeOut.active) then
			local fadeData = self.cinematicData.fadeOut
			local elapsed = CurTime() - fadeData.startTime

			if (elapsed >= fadeData.duration) then
				fadeData.active = false

				-- Execute callback if provided
				if (fadeData.callback and type(fadeData.callback) == "function") then
					fadeData.callback()
				end
			end
		end

		-- Handle fade in completion
		if (self.cinematicData.fadeIn and self.cinematicData.fadeIn.active) then
			local fadeData = self.cinematicData.fadeIn
			local elapsed = CurTime() - fadeData.startTime

			if (elapsed >= fadeData.duration) then
				fadeData.active = false
				self.cinematicData.fadeIn = nil
			end
		end
	end

	function PLUGIN:HUDPaint()
		-- Handle cinematic text display
		if (self.cinematicData.textDisplay) then
			local text = self.cinematicData.textDisplay.text
			local alpha = self.cinematicData.textDisplay.alpha or 255
			local startTime = self.cinematicData.textDisplay.startTime
			local duration = self.cinematicData.textDisplay.duration

			if (CurTime() - startTime > duration) then
				self.cinematicData.textDisplay = nil
				return
			end

			local fadeInTime = 0.5
			local fadeOutTime = 1
			local elapsed = CurTime() - startTime

			if (elapsed < fadeInTime) then
				alpha = alpha * (elapsed / fadeInTime)
			elseif (elapsed > duration - fadeOutTime) then
				alpha = alpha * ((duration - elapsed) / fadeOutTime)
			end

			local scrW, scrH = ScrW(), ScrH()
			local font = "ixMediumFont"

			surface.SetFont(font)
			local textW, textH = surface.GetTextSize(text)

			local x = scrW / 2 - textW / 2
			local y = scrH - 100

			draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, alpha * 0.8), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			draw.SimpleText(text, font, x, y, Color(255, 255, 255, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end

		-- Handle fade effects - draw last so they appear on top
		local scrW, scrH = ScrW(), ScrH()
		local shouldDrawBlack = false
		local fadeAlpha = 0

		-- Fade In effect (black to transparent)
		if (self.cinematicData.fadeIn and self.cinematicData.fadeIn.active) then
			local fadeData = self.cinematicData.fadeIn
			local elapsed = CurTime() - fadeData.startTime
			local progress = math.Clamp(elapsed / fadeData.duration, 0, 1)

			-- Alpha goes from 255 (opaque black) to 0 (transparent)
			fadeAlpha = math.max(fadeAlpha, 255 * (1 - progress))
			shouldDrawBlack = true
		end

		-- Fade Out effect (transparent to black)
		if (self.cinematicData.fadeOut and self.cinematicData.fadeOut.active) then
			local fadeData = self.cinematicData.fadeOut
			local elapsed = CurTime() - fadeData.startTime
			local progress = math.Clamp(elapsed / fadeData.duration, 0, 1)

			-- Alpha goes from 0 (transparent) to 255 (opaque black)
			fadeAlpha = math.max(fadeAlpha, 255 * progress)
			shouldDrawBlack = true
		end

		-- Also keep screen black if fade out is complete but we're still in transition
		if (self.cinematicData.fadeOut and not self.cinematicData.fadeOut.active and
				self.cinematicData.fadeOut.callback) then
			fadeAlpha = 255
			shouldDrawBlack = true
		end

		if (shouldDrawBlack) then
			surface.SetDrawColor(0, 0, 0, fadeAlpha)
			surface.DrawRect(0, 0, scrW, scrH)
		end
	end

	-- Network message receivers
	net.Receive("ixCinematicFadeIn", function()
		local fadeTime = net.ReadFloat()

		PLUGIN:FadeIn(fadeTime)
	end)

	net.Receive("ixCinematicFadeOut", function()
		local fadeTime = net.ReadFloat()
		local hasCallback = net.ReadBool()
		local blackPeriod = net.ReadFloat() -- Read the black period duration
		local callbackData = nil

		if (hasCallback) then
			callbackData = {
				client = LocalPlayer(),
				sequenceID = net.ReadString(),
				blackPeriod = blackPeriod
			}
		end

		PLUGIN:FadeOut(fadeTime, function()
			if (callbackData) then
				-- Keep screen black for the specified duration
				timer.Simple(callbackData.blackPeriod, function()
					-- After black period, send completion message to server
					net.Start("ixCinematicFadeComplete")
					net.WriteString(callbackData.sequenceID)
					net.SendToServer()
				end)
			end
		end)
	end)

	net.Receive("ixCinematicSetBlackWhite", function()
		local enabled = net.ReadBool()
		PLUGIN.cinematicData.blackAndWhite = enabled
	end)

	net.Receive("ixCinematicShowText", function()
		local text = net.ReadString()
		local duration = net.ReadFloat()

		PLUGIN.cinematicData.textDisplay = {
			text = text,
			startTime = CurTime(),
			duration = duration,
			alpha = 255
		}
	end)

	return
end

function PLUGIN:GetCinematicSpawns(sequenceID)
	local spawns = {}

	for _, entity in ipairs(ents.FindByClass("exp_cinematic_spawn")) do
		if (entity:GetSequenceID() == sequenceID) then
			spawns[#spawns + 1] = entity
		end
	end

	return spawns
end

function PLUGIN:GetCinematicItemSpawns(sequenceID, itemSpawnID)
	local spawns = {}

	for _, entity in ipairs(ents.FindByClass("exp_cinematic_item_spawn")) do
		if (entity:GetSequenceID() == sequenceID) then
			if (not itemSpawnID or entity:GetItemSpawnID() == itemSpawnID) then
				spawns[#spawns + 1] = entity
			end
		end
	end

	return spawns
end

function PLUGIN:GetCinematicEnemySpawns(sequenceID, enemySpawnID)
	local spawns = {}

	for _, entity in ipairs(ents.FindByClass("exp_cinematic_enemy_spawn")) do
		if (entity:GetSequenceID() == sequenceID) then
			if (not enemySpawnID or entity:GetEnemySpawnID() == enemySpawnID) then
				spawns[#spawns + 1] = entity
			end
		end
	end

	return spawns
end

function PLUGIN:StartCinematicSequence(client, sequenceID)
	if (self.playerSequences[client]) then
		self:EndCinematicSequence(client)
	end

	self.playerSequences[client] = {
		sequenceID = sequenceID,
		startTime = CurTime()
	}

	if (not self.activeSequences[sequenceID]) then
		self.activeSequences[sequenceID] = {}
	end

	self.activeSequences[sequenceID][client] = true

	hook.Run("CinematicSequenceStarted", client, sequenceID)
end

function PLUGIN:EndCinematicSequence(client)
	local sequence = self.playerSequences[client]

	if (not sequence) then
		return
	end

	local sequenceID = sequence.sequenceID

	self.playerSequences[client] = nil

	if (self.activeSequences[sequenceID]) then
		self.activeSequences[sequenceID][client] = nil

		if (table.IsEmpty(self.activeSequences[sequenceID])) then
			self.activeSequences[sequenceID] = nil
		end
	end

	net.Start("ixCinematicSetBlackWhite")
	net.WriteBool(false)
	net.Send(client)

	hook.Run("CinematicSequenceEnded", client, sequenceID)
end

function PLUGIN:SpawnPlayerAtCinematic(client, sequenceID, fadeIn)
	local spawns = self:GetCinematicSpawns(sequenceID)

	if (#spawns == 0) then
		ix.util.SchemaErrorNoHalt("No cinematic spawns found for sequence: " .. sequenceID)
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

function PLUGIN:TransitionPlayerToCinematic(client, newSequenceID, fadeTime, blackPeriod)
	fadeTime = fadeTime or ix.config.Get("cinematicFadeTime")
	blackPeriod = blackPeriod or ix.config.Get("cinematicBlackPeriod")

	net.Start("ixCinematicFadeOut")
	net.WriteFloat(fadeTime)
	net.WriteBool(true)      -- has callback
	net.WriteFloat(blackPeriod) -- Send black period duration
	net.WriteString(newSequenceID)
	net.Send(client)
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

function PLUGIN:SpawnCinematicEnemy(sequenceID, enemyClass, enemySpawnID)
	local spawns = self:GetCinematicEnemySpawns(sequenceID, enemySpawnID)
	local spawnedEnemies = {}

	for _, spawn in ipairs(spawns) do
		local enemy = ents.Create(enemyClass or "npc_manhack")
		enemy:SetPos(spawn:GetPos())
		enemy:SetAngles(spawn:GetAngles())
		enemy:Spawn()
		enemy:Activate()

		spawnedEnemies[#spawnedEnemies + 1] = enemy
	end

	return spawnedEnemies
end

-- Server-side network message receiver
net.Receive("ixCinematicFadeComplete", function(len, client)
	local sequenceID = net.ReadString()
	PLUGIN:SpawnPlayerAtCinematic(client, sequenceID, true)
end)

function PLUGIN:PlayerDisconnected(client)
	self:EndCinematicSequence(client)
end
