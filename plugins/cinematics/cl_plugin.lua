local PLUGIN = PLUGIN

PLUGIN.cinematicData = PLUGIN.cinematicData or {}
PLUGIN.currentScene = nil

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

function PLUGIN:ClearFadeEffects()
	self.cinematicData.fadeIn = nil
	self.cinematicData.fadeOut = nil
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

	-- Handle sound fade completion callbacks
	if self.cinematicData.currentSound and self.cinematicData.currentSound.fadeCallback then
		local soundData = self.cinematicData.currentSound

		if CurTime() >= soundData.fadeEndTime then
			local callback = soundData.fadeCallback
			soundData.fadeCallback = nil
			soundData.fadeEndTime = nil

			-- If faded to 0, mark as not playing
			if soundData.fadeTargetVolume <= 0 then
				soundData.isPlaying = false
			end

			-- Execute callback
			if callback then
				callback()
			end
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

	-- Call current scene's OnDraw
	if (self.currentScene and self.currentScene.OnDraw) then
		self.currentScene:OnDraw()
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

function PLUGIN:SetBlackAndWhite(enabled)
	self.cinematicData.blackAndWhite = enabled
end

function PLUGIN:ShowCinematicText(text, duration)
	duration = duration or ix.config.Get("cinematicTextDuration")

	self.cinematicData.textDisplay = {
		text = text,
		startTime = CurTime(),
		duration = duration,
		alpha = 255
	}
end

function PLUGIN:PlayCinematicSound(soundPath, volume, fadeInTime)
	volume = volume or 1.0
	fadeInTime = fadeInTime or 0

	-- Stop any existing sound
	self:StopCinematicSound()

	-- Create new sound
	local filter = nil -- Client-side doesn't need filter
	self.cinematicSound = CreateSound(game.GetWorld(), soundPath, filter)

	if not self.cinematicSound then
		ErrorNoHalt("Failed to create cinematic sound: " .. soundPath)
		return false
	end

	-- Set sound properties
	self.cinematicSound:SetSoundLevel(0) -- Play everywhere (no attenuation)

	-- Handle fade in
	if fadeInTime > 0 then
		self.cinematicSound:PlayEx(0, 100)             -- Start at 0 volume
		self.cinematicSound:ChangeVolume(volume, fadeInTime) -- Fade to target volume
	else
		self.cinematicSound:PlayEx(volume, 100)
	end

	-- Store sound data for management
	self.cinematicData.currentSound = {
		sound = self.cinematicSound,
		volume = volume,
		isPlaying = true
	}

	return true
end

function PLUGIN:FadeCinematicSound(fadeTime, targetVolume, callback)
	if not self.cinematicSound or not self.cinematicData.currentSound then
		if callback then callback() end
		return false
	end

	fadeTime = fadeTime or 2.0
	targetVolume = targetVolume or 0

	-- Start the fade
	self.cinematicSound:ChangeVolume(targetVolume, fadeTime)

	-- Store fade data for callback handling
	self.cinematicData.currentSound.fadeCallback = callback
	self.cinematicData.currentSound.fadeEndTime = CurTime() + fadeTime
	self.cinematicData.currentSound.fadeTargetVolume = targetVolume

	return true
end

function PLUGIN:StopCinematicSound(fadeTime)
	if not self.cinematicSound then
		return
	end

	if fadeTime and fadeTime > 0 then
		-- Fade out then stop
		self:FadeCinematicSound(fadeTime, 0, function()
			if self.cinematicSound then
				self.cinematicSound:Stop()
				self.cinematicSound = nil
				self.cinematicData.currentSound = nil
			end
		end)
	else
		-- Stop immediately
		self.cinematicSound:Stop()
		self.cinematicSound = nil
		self.cinematicData.currentSound = nil
	end
end

function PLUGIN:SetCinematicSoundVolume(volume)
	if not self.cinematicSound or not self.cinematicData.currentSound then
		return false
	end

	self.cinematicSound:ChangeVolume(volume, 0)
	self.cinematicData.currentSound.volume = volume
	return true
end

function PLUGIN:IsCinematicSoundPlaying()
	return self.cinematicSound and self.cinematicData.currentSound and self.cinematicData.currentSound.isPlaying
end

-- Network message receivers
net.Receive("ixCinematicFadeIn", function()
	local fadeTime = net.ReadFloat()
	PLUGIN:FadeIn(fadeTime)
end)

net.Receive("ixCinematicFadeOut", function()
	local fadeTime = net.ReadFloat()
	local hasCallback = net.ReadBool()
	local blackPeriod = net.ReadFloat()
	local callbackData = nil

	if (hasCallback) then
		callbackData = {
			client = LocalPlayer(),
			sceneID = net.ReadString(),
			blackPeriod = blackPeriod
		}
	end

	PLUGIN:FadeOut(fadeTime, function()
		if (callbackData) then
			-- Keep screen black for the specified duration
			timer.Simple(callbackData.blackPeriod, function()
				-- After black period, send completion message to server
				net.Start("ixCinematicFadeComplete")
				net.WriteString(callbackData.sceneID)
				net.SendToServer()
			end)
		end
	end)
end)

net.Receive("ixCinematicSetBlackWhite", function()
	local enabled = net.ReadBool()

	PLUGIN:SetBlackAndWhite(enabled)
end)

net.Receive("ixCinematicShowText", function()
	local text = net.ReadString()
	local duration = net.ReadFloat()

	PLUGIN:ShowCinematicText(text, duration)
end)

net.Receive("ixCinematicEnterScene", function()
	local sceneID = net.ReadString()
	local scene = PLUGIN:GetScene(sceneID)

	if (scene) then
		PLUGIN.currentScene = scene

		if (scene.OnEnterLocalPlayer) then
			scene:OnEnterLocalPlayer()
		end
	end
end)

net.Receive("ixCinematicLeaveScene", function()
	local scene = PLUGIN.currentScene

	if (scene) then
		if (scene.OnLeaveLocalPlayer) then
			scene:OnLeaveLocalPlayer()
		end

		PLUGIN.currentScene = nil
	end

	-- Clear all cinematic effects when leaving a scene
	PLUGIN:ClearFadeEffects()
	PLUGIN:SetBlackAndWhite(false)
	PLUGIN.cinematicData.textDisplay = nil
end)
