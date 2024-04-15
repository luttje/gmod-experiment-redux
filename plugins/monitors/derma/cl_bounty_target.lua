local PLUGIN = PLUGIN

local arrowMaterial = Material("experiment-redux/arrow.png")
local arrowForwardMaterial = Material("experiment-redux/arrow_forward.png") -- From the perspective of the player
local arrowBackwardMaterial = Material("experiment-redux/arrow_backward.png")

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)
    self:SetPos(0, 0)
end

function PANEL:SetMonitor(monitor)
    self.monitor = monitor
end

function PANEL:DrawDistanceText(distance)
	local font = "ixMediumFont"
	local distanceCentimeters = Schema.util.UnitToCentimeters(distance)
	local distanceRounded = math.Round(distanceCentimeters / 100)
	local text = distanceRounded == 0 and "They're right here!" or
		(distanceRounded .. (distanceRounded == 1 and " meter" or " meters"))
	local textWidth, textHeight = Schema.GetCachedTextSize(font, text)

	surface.SetTextColor(255, 255, 255, 90)
	surface.SetFont(font)
	surface.SetTextPos((self:GetWide() * .5) - (textWidth * .5), (self:GetTall() * .5) + 128)
	surface.DrawText(text)
end

function PANEL:DrawDirectionArrow(direction)
	local rotation
    local correctedDirection = direction
	local monitorAngles = self.monitor:GetAngles()

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

	surface.SetDrawColor(255, 255, 255, 90)
	if (rotation) then
		surface.SetMaterial(arrowMaterial)
		surface.DrawTexturedRectRotated(self:GetWide() * .5, self:GetTall() * .5, 256, 256, rotation)
	else
		if (x == 1) then
			surface.SetMaterial(arrowBackwardMaterial)
		elseif (x == -1) then
			surface.SetMaterial(arrowForwardMaterial)
		else
			drawCircle(self:GetWide() * .5, self:GetTall() * .5, 256, 18)
		end

		surface.DrawTexturedRect(self:GetWide() * .5 - 128, self:GetTall() * .5 - 128, 256, 256)
	end
end

function PANEL:Paint(width, height)
	local monitor = self.monitor
	if (not monitor) then return end

    local direction, distance = PLUGIN:GetDirectionToTarget(monitor)
	if (not direction) then return end

	self:DrawDirectionArrow(direction)
	self:DrawDistanceText(distance)
end

vgui.Register("expMonitorTarget", PANEL, "Panel")
