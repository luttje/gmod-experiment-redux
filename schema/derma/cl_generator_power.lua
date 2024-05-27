local PANEL = {}

function PANEL:Init()
    self:SetTall(20)
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)

    self.power = 0
    self.maxPower = 0
end

function PANEL:SetPower(power)
    self.power = power
end

function PANEL:SetMaxPower(maxPower)
    self.maxPower = maxPower
end

function PANEL:Paint(w, h)
    local power = self.power
    local maxPower = self.maxPower

    local powerFraction = power / maxPower
    local powerColor = derma.GetColor("Info", self)

    if (powerFraction <= 0.25) then
        powerColor = derma.GetColor("Error", self)
    elseif (powerFraction <= 0.5) then
        powerColor = derma.GetColor("Warning", self)
    end

    surface.SetDrawColor(ColorAlpha(powerColor, 50))
    surface.DrawRect(0, 0, w * powerFraction, h)

    if (powerFraction == 0) then
		local pulse = math.abs(math.sin(RealTime() * 2) * 50)
		surface.SetDrawColor(powerColor.r, powerColor.g, powerColor.b, pulse)
		surface.DrawRect(0, 0, w, h)
	end

	draw.SimpleTextOutlined("Power: " .. power .. " / " .. maxPower, "ixSmallFont", 4, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
end

vgui.Register("expGeneratorPower", PANEL, "EditablePanel")
