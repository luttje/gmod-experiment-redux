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

function Schema.cinematics.SetFogData(fogStart, fogEnd, color, density)
	Schema.cinematics.cinematicData.fogData = {
		fogStart = fogStart,
		fogEnd = fogEnd,
		color = color or Color(255, 255, 255),
		density = density or 0.5
	}
end

function Schema.cinematics.ClearFogData()
	Schema.cinematics.cinematicData.fogData = nil
end

function Schema.cinematics.SetBlackAndWhite(enabled)
	Schema.cinematics.cinematicData.blackAndWhite = enabled
end

--- @param textData string|table<{text:string, delay:number?, duration:number?, horizontalAlignment:TEXT_ALIGN?, verticalAlignment:TEXT_ALIGN?}>
--- @param duration? number
--- @param horizontalAlignment? TEXT_ALIGN
--- @param verticalAlignment? TEXT_ALIGN
function Schema.cinematics.ShowCinematicText(textData, duration, horizontalAlignment, verticalAlignment)
	if (type(textData) == "string") then
		duration = duration or Schema.cinematics.CINEMATIC_TEXT_DURATION
		horizontalAlignment = horizontalAlignment or TEXT_ALIGN_LEFT
		verticalAlignment = verticalAlignment or TEXT_ALIGN_BOTTOM

		Schema.cinematics.cinematicData.textDisplay = {
			text = textData,
			startTime = CurTime(),
			duration = duration,
			alpha = 255,
			horizontalAlignment = horizontalAlignment,
			verticalAlignment = verticalAlignment
		}
		return
	end

	-- Handle array of text entries
	if (type(textData) == "table") then
		local processedEntries = {}
		local currentTime = 0

		for i, entry in ipairs(textData) do
			local delay, text, displayDuration, horizontalAlignment, verticalAlignment

			if (type(entry[1]) == "string") then
				text = entry.text
				displayDuration = entry.duration or Schema.cinematics.CINEMATIC_TEXT_DURATION
				horizontalAlignment = entry.horizontalAlignment or TEXT_ALIGN_LEFT
				verticalAlignment = entry.verticalAlignment or TEXT_ALIGN_BOTTOM
				delay = entry.delay or 0
			else
				delay = entry.delay or 0
				text = entry.text
				displayDuration = entry.duration or Schema.cinematics.CINEMATIC_TEXT_DURATION
				horizontalAlignment = entry.horizontalAlignment or TEXT_ALIGN_LEFT
				verticalAlignment = entry.verticalAlignment or TEXT_ALIGN_BOTTOM
			end

			currentTime = currentTime + delay

			table.insert(processedEntries, {
				text = text,
				startTime = CurTime() + currentTime,
				duration = displayDuration,
				horizontalAlignment = horizontalAlignment,
				verticalAlignment = verticalAlignment,
				alpha = 255,
				index = i
			})

			-- Don't add display duration to currentTime for next entry
			-- Each entry's timing is independent after its delay
		end

		Schema.cinematics.cinematicData.textDisplayArray = processedEntries
		Schema.cinematics.cinematicData.textDisplay = nil -- Clear single text display
		return
	end
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

function Schema.cinematics.CalculateTextAlpha(startTime, duration, baseAlpha)
	local fadeInTime = 0.5
	local fadeOutTime = 1
	local elapsed = CurTime() - startTime
	local alpha = baseAlpha

	if (elapsed < fadeInTime) then
		alpha = alpha * (elapsed / fadeInTime)
	elseif (elapsed > duration - fadeOutTime) then
		alpha = alpha * ((duration - elapsed) / fadeOutTime)
	end

	return alpha
end

function Schema.cinematics.CalculateVerticalStartPosition(activeEntries, scrH, verticalAlignment)
	local lineHeight = 40 -- Same as yOffset increment
	local totalHeight = (#activeEntries) * lineHeight
	local padding = 50 -- Distance from screen edges

	local startY

	if verticalAlignment == TEXT_ALIGN_TOP then
		startY = padding
	elseif verticalAlignment == TEXT_ALIGN_CENTER then
		startY = (scrH - totalHeight) / 2
	else -- TEXT_ALIGN_BOTTOM (default)
		startY = scrH - totalHeight - padding
	end

	-- Ensure we don't go off-screen
	startY = math.max(padding, startY)                   -- Don't go above top edge
	startY = math.min(scrH - totalHeight - padding, startY) -- Don't go below bottom edge

	return startY
end

function Schema.cinematics.DrawCinematicText(text, horizontalAlignment, verticalAlignment, alpha, scrW, scrH, index,
											 baseY)
	local font = "ixBigFontOutlined"
	local lineHeight = 40
	local yOffset = (index - 1) * lineHeight

	surface.SetFont(font)

	local x, y
	local textAlign = TEXT_ALIGN_LEFT

	-- Calculate horizontal position based on alignment
	if horizontalAlignment == TEXT_ALIGN_CENTER then
		x = scrW * .5
		textAlign = TEXT_ALIGN_CENTER
	elseif horizontalAlignment == TEXT_ALIGN_RIGHT then
		x = scrW - 50 -- 50 pixels from right edge
		textAlign = TEXT_ALIGN_RIGHT
	else        -- TEXT_ALIGN_LEFT
		x = 50  -- 50 pixels from left edge
		textAlign = TEXT_ALIGN_LEFT
	end

	-- Use the calculated base Y position plus offset for this line
	y = baseY + yOffset

	-- Draw shadow
	draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, alpha * 0.8), textAlign, TEXT_ALIGN_TOP)
	-- Draw main text
	draw.SimpleText(text, font, x, y, Color(255, 255, 255, alpha), textAlign, TEXT_ALIGN_TOP)
end

-- Calculate bloom intensity based on fade progress
function Schema.cinematics.CalculateBloomIntensity(fadeType, progress)
	local maxBloom = 2.5 -- Maximum bloom intensity
	local minBloom = 0.0 -- Minimum bloom intensity

	if fadeType == "fadeIn" then
		local easedProgress = 1 - math.pow(1 - progress, 3)
		return maxBloom * (1 - easedProgress) + minBloom * easedProgress
	elseif fadeType == "fadeOut" then
		local bloomProgress
		if progress <= 0.5 then
			bloomProgress = progress * 2            -- Scale 0-0.5 to 0-1
			local easedProgress = math.pow(bloomProgress, 2) -- Quadratic easing in
			return minBloom * (1 - easedProgress) + maxBloom * easedProgress
		else
			bloomProgress = (progress - 0.5) * 2            -- Scale 0.5-1 to 0-1
			local easedProgress = 1 - math.pow(1 - bloomProgress, 2) -- Quadratic easing out
			return maxBloom * (1 - easedProgress) + minBloom * easedProgress
		end
	end

	return minBloom
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

	-- Handle bloom effects during fade transitions
	local bloomIntensity = 0
	local shouldApplyBloom = false

	-- Calculate bloom for fade in
	if (Schema.cinematics.cinematicData.fadeIn and Schema.cinematics.cinematicData.fadeIn.active) then
		local fadeData = Schema.cinematics.cinematicData.fadeIn
		local elapsed = CurTime() - fadeData.startTime
		local progress = math.Clamp(elapsed / fadeData.duration, 0, 1)

		bloomIntensity = Schema.cinematics.CalculateBloomIntensity("fadeIn", progress)
		shouldApplyBloom = true
	end

	-- Calculate bloom for fade out (this takes priority if both are somehow active)
	if (Schema.cinematics.cinematicData.fadeOut and Schema.cinematics.cinematicData.fadeOut.active) then
		local fadeData = Schema.cinematics.cinematicData.fadeOut
		local elapsed = CurTime() - fadeData.startTime
		local progress = math.Clamp(elapsed / fadeData.duration, 0, 1)

		bloomIntensity = Schema.cinematics.CalculateBloomIntensity("fadeOut", progress)
		shouldApplyBloom = true
	end

	-- Apply bloom effect if needed
	if (shouldApplyBloom and bloomIntensity > 0) then
		local darken = math.max(0.2, 1 - (bloomIntensity * 0.4))
		local multiply = bloomIntensity
		local sizeX = math.min(8, bloomIntensity * 3)
		local sizeY = math.min(8, bloomIntensity * 3)
		local passes = math.min(3, math.ceil(bloomIntensity))
		local colorMultiply = 1

		DrawBloom(darken, multiply, sizeX, sizeY, passes, colorMultiply, 1, 1, 1)
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
	local scrW, scrH = ScrW(), ScrH()

	if (Schema.cinematics.cinematicData.textDisplay) then
		local textData = Schema.cinematics.cinematicData.textDisplay
		local text = textData.text
		local alpha = textData.alpha or 255
		local startTime = textData.startTime
		local duration = textData.duration
		local horizontalAlignment = textData.horizontalAlignment or textData.alignment or
			TEXT_ALIGN_LEFT -- Backward compatibility
		local verticalAlignment = textData.verticalAlignment or TEXT_ALIGN_BOTTOM

		if (CurTime() - startTime > duration) then
			Schema.cinematics.cinematicData.textDisplay = nil
			return
		end

		alpha = Schema.cinematics.CalculateTextAlpha(startTime, duration, alpha)

		-- For single text, calculate position as if it's the only entry
		local singleEntryArray = { { index = 1 } }
		local baseY = Schema.cinematics.CalculateVerticalStartPosition(singleEntryArray, scrH, verticalAlignment)

		Schema.cinematics.DrawCinematicText(text, horizontalAlignment, verticalAlignment, alpha, scrW, scrH, 1, baseY)
	end

	-- Handle array text display
	if (Schema.cinematics.cinematicData.textDisplayArray) then
		local activeEntries = {}
		local allEntries = Schema.cinematics.cinematicData.textDisplayArray

		-- First pass: collect all active entries
		for i, entry in ipairs(allEntries) do
			local currentTime = CurTime()
			local startTime = entry.startTime
			local duration = entry.duration

			-- Check if this entry should be active
			if currentTime >= startTime and currentTime <= startTime + duration then
				table.insert(activeEntries, entry)
			end
		end

		-- If we have active entries, calculate the base Y position using ALL entries and draw them
		if #activeEntries > 0 then
			-- Use the vertical alignment from the first active entry (assuming all entries use same vertical alignment)
			local verticalAlignment = activeEntries[1].verticalAlignment or TEXT_ALIGN_BOTTOM

			-- Calculate base Y position based on TOTAL entries, not just active ones
			local baseY = Schema.cinematics.CalculateVerticalStartPosition(allEntries, scrH, verticalAlignment)

			-- Second pass: draw all active entries using their original index for positioning
			for i, entry in ipairs(activeEntries) do
				local startTime = entry.startTime
				local duration = entry.duration
				local alpha = Schema.cinematics.CalculateTextAlpha(startTime, duration, entry.alpha)
				local horizontalAlignment = entry.horizontalAlignment or TEXT_ALIGN_LEFT

				-- Use the entry's original index for consistent positioning
				Schema.cinematics.DrawCinematicText(entry.text, horizontalAlignment, verticalAlignment, alpha, scrW, scrH,
					entry.index, baseY)
			end
		else
			-- If no entries are active, clear the array
			Schema.cinematics.cinematicData.textDisplayArray = nil
		end
	end

	-- Call current scene's OnDraw
	if (Schema.cinematics.currentScene and Schema.cinematics.currentScene.OnDraw) then
		Schema.cinematics.currentScene:OnDraw()
	end

	-- Handle fade effects - draw last so they appear on top
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

hook.Add("SetupWorldFog", "FlashbackFogHook", function()
	if (not Schema.cinematics.cinematicData.fogData) then
		return
	end

	render.FogMode(MATERIAL_FOG_LINEAR)

	local fogData = Schema.cinematics.cinematicData.fogData

	-- Set fog parameters
	render.FogStart(fogData.fogStart)
	render.FogEnd(fogData.fogEnd)
	render.FogColor(fogData.color.r, fogData.color.g, fogData.color.b)
	render.FogMaxDensity(fogData.density)

	return true -- This tells the engine we've set up custom fog
end)

hook.Add("SetupSkyboxFog", "FlashbackSkyboxFogHook", function(skyboxScale)
	if (not Schema.cinematics.cinematicData.fogData) then
		return
	end

	local fogData = Schema.cinematics.cinematicData.fogData

	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogStart(fogData.fogStart * skyboxScale)
	render.FogEnd(fogData.fogEnd * skyboxScale)
	render.FogColor(fogData.color.r, fogData.color.g, fogData.color.b)
	render.FogMaxDensity(fogData.density)

	return true
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
	Schema.cinematics.ClearFogData()
	Schema.cinematics.SetBlackAndWhite(false)
	Schema.cinematics.cinematicData.textDisplay = nil
	Schema.cinematics.cinematicData.textDisplayArray = nil
end)
