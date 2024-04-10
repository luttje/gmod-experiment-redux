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

        self:SetupMonitorDrawing(monitor)
	end
end

function PLUGIN:SetupMonitorDrawing(monitor)
	local correctedAngle, scale = self:PrepareMonitorForDrawing(monitor)
	local customRenderTarget, renderTargetMaterial = self:GetMonitorRenderTarget(monitor)
	local wave = 25 * math.sin(CurTime()) * monitor.random
	monitor.drawAlphaBackground = 90 + wave
	monitor.drawAlphaForeground = 225 + wave
	monitor.drawStutterX = math.random() > 0.01 and 0 or math.sin(CurTime() * 40) * 2
	monitor.drawStutterY = math.random() > 0.01 and 0 or math.sin(CurTime() * 20) * 4

	-- Draw the monitor contents to the render target so we can easily mirror the whole thing
	render.PushRenderTarget(customRenderTarget)
	self:DrawMonitorContents(monitor)
	render.PopRenderTarget()

	self:RenderMonitorToPlayerView(monitor, renderTargetMaterial, correctedAngle, scale)
	self:RenderMonitorToPlayerView(monitor, renderTargetMaterial, correctedAngle, scale, true)
end

function PLUGIN:PrepareMonitorForDrawing(monitor)
    local correctedAngle = monitor:GetAngles()
    correctedAngle:RotateAroundAxis(monitor:GetForward(), 90)
    correctedAngle:RotateAroundAxis(monitor:GetUp(), 90)

    local scale = monitor:GetMonitorScale() or 1
    local entityParent = monitor:GetParent()
    if IsValid(entityParent) then
        scale = scale * entityParent:GetModelScale()
    end

    return correctedAngle, scale
end

function PLUGIN:GetMonitorRenderTarget(monitor)
	local width, height = monitor:GetMonitorWidth(), monitor:GetMonitorHeight()
	local renderTarget = GetRenderTarget("monitor_rendertarget_" .. monitor:EntIndex(), width, height)

	monitor.expRenderTargetMaterial = monitor.expRenderTargetMaterial or
		CreateMaterial("monitor_material_" .. monitor:EntIndex(), "UnlitGeneric", {
			["$basetexture"] = renderTarget:GetName(),
			["$translucent"] = 1,
			["$vertexalpha"] = 1
		})

	return renderTarget, monitor.expRenderTargetMaterial
end

function PLUGIN:DrawMonitorContents(monitor)
    cam.Start2D()
    render.Clear(0, 0, 0, 0, true, true)
    self:DrawDirectionArrowIfApplicable(monitor)
    self:DrawMonitorOverlay(monitor)
    cam.End2D()
end

function PLUGIN:DrawDirectionArrowIfApplicable(monitor)
	local direction, distance = self:GetDirectionToTarget(monitor)

    if (direction) then
        self:DrawDistanceText(monitor, distance)
        self:DrawDirectionArrow(monitor, direction)
    end
end

function PLUGIN:GetDirectionToTarget(monitor)
	if not IsValid(TEST_BOUNTY) then return end

	local centerOfMonitorPos = monitor:GetPos()
		- monitor:GetAngles():Right() * (monitor:GetMonitorWidth() * .5 * monitor:GetMonitorScale())
		- monitor:GetAngles():Up() * (monitor:GetMonitorHeight() * .5 * monitor:GetMonitorScale())

	local heading = (TEST_BOUNTY:GetPos() + Vector(0, 0, 70)) - centerOfMonitorPos
	local distance = heading:Length()
	local direction = heading / distance

	return direction, distance
end

function PLUGIN:DrawDistanceText(monitor, distance)
	local font = "ixMediumFont"
	local distanceCentimeters = distance / 2
	local distanceRounded = math.Round(distanceCentimeters / 100)
	local text = distanceRounded == 0 and "They're right here!" or
		(distanceRounded .. (distanceRounded == 1 and " meter" or " meters"))
	local textWidth, textHeight = self:GetCachedTextSize(font, text)

	surface.SetTextColor(255, 255, 255, monitor.drawAlphaForeground)
	surface.SetFont(font)
	surface.SetTextPos((monitor:GetMonitorWidth() * .5) - (textWidth * .5), (monitor:GetMonitorHeight() * .5) + 128)
	surface.DrawText(text)
end

function PLUGIN:DrawDirectionArrow(monitor, direction)
	local rotation
	local correctedDirection = direction
	local monitorAngles = monitor:GetAngles()

	correctedDirection:Rotate(Angle(0, monitorAngles.y * -1, 0))
	local x, y, z = math.Round(correctedDirection.x), math.Round(correctedDirection.y), math.Round(correctedDirection.z)

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

	surface.SetDrawColor(255, 255, 255, monitor.drawAlphaForeground)
	if (rotation) then
		surface.SetMaterial(arrowMaterial)
		surface.DrawTexturedRectRotated(monitor:GetMonitorWidth() * .5, monitor:GetMonitorHeight() * .5, 256, 256, rotation)
	else
		if (x == 1) then
			surface.SetMaterial(arrowBackwardMaterial)
		elseif (x == -1) then
			surface.SetMaterial(arrowForwardMaterial)
		else
			drawCircle(monitor:GetMonitorWidth() * .5, monitor:GetMonitorHeight() * .5, 256, 18)
		end

		surface.DrawTexturedRect(monitor:GetMonitorWidth() * .5 - 128, monitor:GetMonitorHeight() * .5 - 128, 256, 256)
	end
end

function PLUGIN:DrawMonitorOverlay(monitor)
	local width, height = monitor:GetMonitorWidth(), monitor:GetMonitorHeight()

    local texW, texH = 512, 512
    surface.SetDrawColor(200, 200, 200, 200)
    surface.SetMaterial(scanLinesMaterial)
    surface.DrawTexturedRectUV(0, 0, width, height, 0, 0, width / texW, height / texH)
end

function PLUGIN:RenderMonitorToPlayerView(monitor, renderTargetMaterial, correctedAngle, scale, mirrored)
	local width, height = monitor:GetMonitorWidth(), monitor:GetMonitorHeight()

	if (mirrored) then
		correctedAngle = Angle(
			correctedAngle.p,
			correctedAngle.y,
			correctedAngle.r
		)
		correctedAngle:RotateAroundAxis(monitor:GetUp(), 180)
	end

	cam.Start3D2D(
        monitor:GetPos(),
        correctedAngle,
        scale
    )
    surface.SetDrawColor(255, 255, 255, monitor.drawAlphaBackground)
	surface.SetMaterial(renderTargetMaterial)
	if (mirrored) then
		surface.DrawTexturedRectUV(-width, 0, width, height, 1, 0, 0, 1)
	else
    	surface.DrawTexturedRect(monitor.drawStutterX, monitor.drawStutterY, width - monitor.drawStutterX, height - monitor.drawStutterY)
	end
    cam.End3D2D()
end
