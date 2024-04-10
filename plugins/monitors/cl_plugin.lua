local PLUGIN = PLUGIN

local scanLinesMaterial = Material("experiment-redux/combinescanline")
local arrowMaterial = Material("experiment-redux/arrow.png")
local arrowForwardMaterial = Material("experiment-redux/arrow_forward.png") -- From the perspective of the player
local arrowBackwardMaterial = Material("experiment-redux/arrow_backward.png")

net.Receive("expSetMonitorTarget", function(length)
	local entity = net.ReadEntity()

	TEST_BOUNTY = IsValid(entity) and entity or nil
end)

net.Receive("expMonitorsPrintPresets", function(length)
	local presets = PLUGIN.presets

	print("Presets:")
	for key, preset in pairs(presets) do
		print("\t" .. key .. ": " .. preset.description)
	end
end)

function PLUGIN:GetCachedTextSize(font, text)
	if (! self.CachedTextSizes) then
		self.CachedTextSizes = {}
	end

	if (! self.CachedTextSizes[font]) then
		self.CachedTextSizes[font] = {}
	end

	if (! self.CachedTextSizes[font][text]) then
		surface.SetFont(font)

		self.CachedTextSizes[font][text] = { surface.GetTextSize(text) }
	end

	return unpack(self.CachedTextSizes[font][text])
end

function PLUGIN:PostDrawTranslucentRenderables(isDrawingDepth, isDrawingSkybox)
	if (isDrawingSkybox or isDrawingDepth) then return end

	local monitorEntities = ents.FindByClass("exp_monitor")

	for _, monitor in pairs(monitorEntities) do
		if (not monitor:GetPoweredOn() or monitor:IsDormant()) then
			continue
		end

		local entityParent = monitor:GetParent()
		local correctedAngle = monitor:GetAngles()
		correctedAngle:RotateAroundAxis(monitor:GetForward(), 90)
		correctedAngle:RotateAroundAxis(monitor:GetUp(), 90)

		local scale = monitor:GetMonitorScale()
		local alpha = 50 + (25 * math.sin(CurTime()) * monitor.random)

		-- TODO: Make sure not all monitors are blinking at the same time.
		-- if(monitor.justSparked)then
		-- 	if(not monitor.justSparkedTimer)then
		-- 		monitor.justSparkedTimer = true
		-- 		timer.Simple(0, function()
		-- 			if(IsValid(monitor))then
		-- 				monitor.justSparkedTimer = nil
		-- 				monitor.justSparked = nil
		-- 			end
		-- 		end)
		-- 	end

		-- 	return
		-- end

		local width, height, scale = monitor:GetMonitorWidth(), monitor:GetMonitorHeight(), monitor:GetMonitorScale()
		local scaledSize = 256 -- TODO: Scale

		local direction, distance = nil, 0

		if (IsValid(TEST_BOUNTY)) then
			local centerOfMonitorPos =
				monitor:GetPos()
				- (
					monitor:GetAngles():Right() * (width * .5 * scale)
				)
				- (
					monitor:GetAngles():Up() * (height * .5 * scale)
				)

			-- At 70 on z to point at their face
			local heading = (TEST_BOUNTY:GetPos() + Vector(0, 0, 70)) - centerOfMonitorPos

			distance = heading:Length()
			direction = heading / distance
		end

		-- TODO: Draw back-side (mirrored) as well
		cam.Start3D2D(
			monitor:GetPos(),
			correctedAngle,
			scale and (scale * (IsValid(entityParent) and entityParent:GetModelScale() or 1)) or 1)
		surface.SetDrawColor(77, 148, 255, alpha)
		surface.DrawRect(0, 0, width, height)

		if (direction) then
			local rotation
			local correctedDirection = direction
			local monitorAngles = monitor:GetAngles()

			-- Why -1? I dunno, maybe because we're facing the opposite way of the player. This math is beyond me but through 2 hours of trial and error it's now working
			correctedDirection:Rotate(Angle(0, monitorAngles.y * -1, 0))
			local x, y, z = math.Round(correctedDirection.x), math.Round(correctedDirection.y),
				math.Round(correctedDirection.z)

			-- We ignore the x as we're only drawing an arrow in 2D, without perspective
			if (y == 0 and z == 1) then
				rotation = 90
			elseif (y == 1 and z == 1) then
				rotation = 45
			elseif (y == 1 and z == 0) then
				rotation = 0
			elseif (y == 1 and z == -1) then
				rotation = -45
			elseif (y == 0 and z == -1) then
				rotation = -90
			elseif (y == -1 and z == -1) then
				rotation = -135
			elseif (y == -1 and z == 0) then
				rotation = 180
			elseif (y == -1 and z == 1) then
				rotation = 135
			end

			local font = "ixMediumFont"
			-- TODO: Use this (https://gist.github.com/CaptainPRICE/132fd12cf45a24b39176) to calculate in feet and inches as well if that's what the player prefers
			local distanceCentimeters = distance / 2
			local distanceRounded = math.Round(distanceCentimeters / 100)
			local text = distanceRounded == 0 and "They're right here!" or
				(distanceRounded .. (distanceRounded == 1 and " meter" or " meters"))
			local textWidth, textHeight = self:GetCachedTextSize(font, text)

			surface.SetTextColor(255, 255, 255, alpha)
			surface.SetFont(font)
			surface.SetTextPos((width * .5) - (textWidth * .5), (height * .5) + (scaledSize * .5) + 10)
			surface.DrawText(text)

			surface.SetDrawColor(255, 255, 255, alpha)
			if (rotation) then
				surface.SetMaterial(arrowMaterial)
				surface.DrawTexturedRectRotated(width * .5, height * .5, scaledSize, scaledSize, rotation)
			else
				if (x == 1) then
					surface.SetMaterial(arrowBackwardMaterial)
				elseif (x == -1) then
					surface.SetMaterial(arrowForwardMaterial)
				else
					-- Draw a dot to indicate the target is directly in front of the screen
					drawCircle(width * .5, height * .5, scaledSize, 18)
				end

				surface.DrawTexturedRect((width * .5) - (scaledSize * .5), (height * .5) - (scaledSize * .5), scaledSize,
					scaledSize)
			end
		end

		local texW, texH = 512, 512
		surface.SetDrawColor(200, 200, 200, 100)
		surface.SetMaterial(scanLinesMaterial)
		surface.DrawTexturedRectUV(0, 0, width, height, 0, 0, width / texW, height / texH)
		cam.End3D2D()
	end
end
