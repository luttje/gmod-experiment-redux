local PANEL = {}

function PANEL:Init()
    self:SetTall(20)
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)

    self.health = 0
    self.maxHealth = 0
end

function PANEL:SetHealth(health)
    self.health = health
end

function PANEL:SetMaxHealth(maxHealth)
    self.maxHealth = maxHealth
end

function PANEL:Paint(w, h)
    local health = self.health
    local maxHealth = self.maxHealth

    local healthFraction = health / maxHealth
    local healthColor = derma.GetColor("Error", self)

    surface.SetDrawColor(ColorAlpha(healthColor, 50))
    surface.DrawRect(0, 0, w * healthFraction, h)

    if (healthFraction == 0) then
		local pulse = math.abs(math.sin(RealTime() * 2) * 50)
		surface.SetDrawColor(healthColor.r, healthColor.g, healthColor.b, pulse)
		surface.DrawRect(0, 0, w, h)
	end

	draw.SimpleTextOutlined("Health: " .. health .. " / " .. maxHealth, "ixSmallFont", 4, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black)
end

vgui.Register("expMonsterHealth", PANEL, "EditablePanel")
