Schema.cinematics = ix.util.GetOrCreateCommonLibrary("cinematics", nil, {
	cinematicData = {},
	currentScene = nil
})

function Schema.cinematics.FadeIn(fadeTime)
	fadeTime = fadeTime or Schema.cinematics.CINEMATIC_FADE_TIME

	Schema.cinematics.cinematicData.fadeIn = {
		startTime = CurTime(),
		duration = fadeTime,
		active = true
	}

	-- Clear any existing fade out
	Schema.cinematics.cinematicData.fadeOut = nil
end

function Schema.cinematics.FadeOut(fadeTime, callback)
	fadeTime = fadeTime or Schema.cinematics.CINEMATIC_FADE_TIME

	Schema.cinematics.cinematicData.fadeOut = {
		startTime = CurTime(),
		duration = fadeTime,
		active = true,
		callback = callback
	}

	-- Clear any existing fade in
	Schema.cinematics.cinematicData.fadeIn = nil
end

function Schema.cinematics.ClearFadeEffects()
	Schema.cinematics.cinematicData.fadeIn = nil
	Schema.cinematics.cinematicData.fadeOut = nil
end

function Schema.cinematics.SetBlackAndWhite(enabled)
	Schema.cinematics.cinematicData.blackAndWhite = enabled
end

function Schema.cinematics.ShowCinematicText(text, duration)
	duration = duration or Schema.cinematics.CINEMATIC_TEXT_DURATION

	Schema.cinematics.cinematicData.textDisplay = {
		text = text,
		startTime = CurTime(),
		duration = duration,
		alpha = 255
	}
end

function Schema.cinematics.PlayCinematicSound(soundPath, volume, fadeInTime)
	volume = volume or 1.0
	fadeInTime = fadeInTime or 0

	-- Stop any existing sound
	Schema.cinematics.StopCinematicSound()

	-- Create new sound
	local filter = nil -- Client-side doesn't need filter
	Schema.cinematics.cinematicSound = CreateSound(game.GetWorld(), soundPath, filter)

	if not Schema.cinematics.cinematicSound then
		ErrorNoHalt("Failed to create cinematic sound: " .. soundPath)
		return false
	end

	-- Set sound properties
	Schema.cinematics.cinematicSound:SetSoundLevel(0) -- Play everywhere (no attenuation)

	-- Handle fade in
	if fadeInTime > 0 then
		Schema.cinematics.cinematicSound:PlayEx(0, 100)             -- Start at 0 volume
		Schema.cinematics.cinematicSound:ChangeVolume(volume, fadeInTime) -- Fade to target volume
	else
		Schema.cinematics.cinematicSound:PlayEx(volume, 100)
	end

	-- Store sound data for management
	Schema.cinematics.cinematicData.currentSound = {
		sound = Schema.cinematics.cinematicSound,
		volume = volume,
		isPlaying = true
	}

	return true
end

function Schema.cinematics.FadeCinematicSound(fadeTime, targetVolume, callback)
	if not Schema.cinematics.cinematicSound or not Schema.cinematics.cinematicData.currentSound then
		if callback then callback() end
		return false
	end

	fadeTime = fadeTime or 2.0
	targetVolume = targetVolume or 0

	-- Start the fade
	Schema.cinematics.cinematicSound:ChangeVolume(targetVolume, fadeTime)

	-- Store fade data for callback handling
	Schema.cinematics.cinematicData.currentSound.fadeCallback = callback
	Schema.cinematics.cinematicData.currentSound.fadeEndTime = CurTime() + fadeTime
	Schema.cinematics.cinematicData.currentSound.fadeTargetVolume = targetVolume

	return true
end

function Schema.cinematics.StopCinematicSound(fadeTime)
	if not Schema.cinematics.cinematicSound then
		return
	end

	if fadeTime and fadeTime > 0 then
		-- Fade out then stop
		Schema.cinematics.FadeCinematicSound(fadeTime, 0, function()
			if Schema.cinematics.cinematicSound then
				Schema.cinematics.cinematicSound:Stop()
				Schema.cinematics.cinematicSound = nil
				Schema.cinematics.cinematicData.currentSound = nil
			end
		end)
	else
		-- Stop immediately
		Schema.cinematics.cinematicSound:Stop()
		Schema.cinematics.cinematicSound = nil
		Schema.cinematics.cinematicData.currentSound = nil
	end
end

function Schema.cinematics.SetCinematicSoundVolume(volume)
	if not Schema.cinematics.cinematicSound or not Schema.cinematics.cinematicData.currentSound then
		return false
	end

	Schema.cinematics.cinematicSound:ChangeVolume(volume, 0)
	Schema.cinematics.cinematicData.currentSound.volume = volume
	return true
end

function Schema.cinematics.IsCinematicSoundPlaying()
	return Schema.cinematics.cinematicSound and Schema.cinematics.cinematicData.currentSound and
		Schema.cinematics.cinematicData.currentSound.isPlaying
end

hook.Add("RenderScreenspaceEffects", "expCinematicsRenderScreenspaceEffects", function()
	-- Handle black and white effect
	if (Schema.cinematics.cinematicData.blackAndWhite and IsValid(LocalPlayer())) then
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
end)

hook.Add("Think", "expCinematicsThink", function()
	-- Handle fade out completion and callback
	if (Schema.cinematics.cinematicData.fadeOut and Schema.cinematics.cinematicData.fadeOut.active) then
		local fadeData = Schema.cinematics.cinematicData.fadeOut
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
	if (Schema.cinematics.cinematicData.fadeIn and Schema.cinematics.cinematicData.fadeIn.active) then
		local fadeData = Schema.cinematics.cinematicData.fadeIn
		local elapsed = CurTime() - fadeData.startTime

		if (elapsed >= fadeData.duration) then
			fadeData.active = false
			Schema.cinematics.cinematicData.fadeIn = nil
		end
	end

	-- Handle sound fade completion callbacks
	if Schema.cinematics.cinematicData.currentSound and Schema.cinematics.cinematicData.currentSound.fadeCallback then
		local soundData = Schema.cinematics.cinematicData.currentSound

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
end)

hook.Add("HUDPaint", "expCinematicsHUDPaint", function()
	-- Handle cinematic text display
	if (Schema.cinematics.cinematicData.textDisplay) then
		local text = Schema.cinematics.cinematicData.textDisplay.text
		local alpha = Schema.cinematics.cinematicData.textDisplay.alpha or 255
		local startTime = Schema.cinematics.cinematicData.textDisplay.startTime
		local duration = Schema.cinematics.cinematicData.textDisplay.duration

		if (CurTime() - startTime > duration) then
			Schema.cinematics.cinematicData.textDisplay = nil
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
	if (Schema.cinematics.currentScene and Schema.cinematics.currentScene.OnDraw) then
		Schema.cinematics.currentScene:OnDraw()
	end

	-- Handle fade effects - draw last so they appear on top
	local scrW, scrH = ScrW(), ScrH()
	local shouldDrawBlack = false
	local fadeAlpha = 0

	-- Fade In effect (black to transparent)
	if (Schema.cinematics.cinematicData.fadeIn and Schema.cinematics.cinematicData.fadeIn.active) then
		local fadeData = Schema.cinematics.cinematicData.fadeIn
		local elapsed = CurTime() - fadeData.startTime
		local progress = math.Clamp(elapsed / fadeData.duration, 0, 1)

		-- Alpha goes from 255 (opaque black) to 0 (transparent)
		fadeAlpha = math.max(fadeAlpha, 255 * (1 - progress))
		shouldDrawBlack = true
	end

	-- Fade Out effect (transparent to black)
	if (Schema.cinematics.cinematicData.fadeOut and Schema.cinematics.cinematicData.fadeOut.active) then
		local fadeData = Schema.cinematics.cinematicData.fadeOut
		local elapsed = CurTime() - fadeData.startTime
		local progress = math.Clamp(elapsed / fadeData.duration, 0, 1)

		-- Alpha goes from 0 (transparent) to 255 (opaque black)
		fadeAlpha = math.max(fadeAlpha, 255 * progress)
		shouldDrawBlack = true
	end

	-- Also keep screen black if fade out is complete but we're still in transition
	if (Schema.cinematics.cinematicData.fadeOut and not Schema.cinematics.cinematicData.fadeOut.active and
			Schema.cinematics.cinematicData.fadeOut.callback) then
		fadeAlpha = 255
		shouldDrawBlack = true
	end

	if (shouldDrawBlack) then
		surface.SetDrawColor(0, 0, 0, fadeAlpha)
		surface.DrawRect(0, 0, scrW, scrH)
	end
end)

-- Network message receivers
net.Receive("ixCinematicFadeIn", function()
	local fadeTime = net.ReadFloat()
	Schema.cinematics.FadeIn(fadeTime)
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

	Schema.cinematics.FadeOut(fadeTime, function()
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

	Schema.cinematics.SetBlackAndWhite(enabled)
end)

net.Receive("ixCinematicShowText", function()
	local text = net.ReadString()
	local duration = net.ReadFloat()

	Schema.cinematics.ShowCinematicText(text, duration)
end)

net.Receive("ixCinematicEnterScene", function()
	local sceneID = net.ReadString()
	local scene = Schema.cinematics.Get(sceneID)

	if (scene) then
		Schema.cinematics.currentScene = scene

		if (scene.OnEnterLocalPlayer) then
			scene:OnEnterLocalPlayer()
		end
	end
end)

net.Receive("ixCinematicLeaveScene", function()
	local scene = Schema.cinematics.currentScene

	if (scene) then
		if (scene.OnLeaveLocalPlayer) then
			scene:OnLeaveLocalPlayer()
		end

		Schema.cinematics.currentScene = nil
	end

	-- Clear all cinematic effects when leaving a scene
	Schema.cinematics.ClearFadeEffects()
	Schema.cinematics.SetBlackAndWhite(false)
	Schema.cinematics.cinematicData.textDisplay = nil
end)
