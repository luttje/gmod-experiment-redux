local PANEL = {}

BUTTON_SCALE_SMALL = "small"
BUTTON_SCALE_BIG = "big"

DEFINE_BASECLASS("DButton")

local gradient = surface.GetTextureID("vgui/gradient-r")
local BUTTON_FONT = "ixMenuButtonFont"
local BUTTON_FONT_SMALL = "ixGenericFont"
local BUTTON_FONT_BIG = "ixBigFont"
local BUTTON_HEIGHT = 36
local BUTTON_HEIGHT_SMALL = 25
local BUTTON_HEIGHT_BIG = 128

function PANEL:Init()
    self:SetTextColor(color_white)
    self:SetFont(BUTTON_FONT)
    self:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    self:SetTall(BUTTON_HEIGHT)

    self.color = ColorAlpha(ix.config.Get("color"), 100)
end

function PANEL:SetScale(scale)
    local isSmall = scale == BUTTON_SCALE_SMALL
    local isBig = scale == BUTTON_SCALE_BIG

    self:SetFont(isSmall and BUTTON_FONT_SMALL or (isBig and BUTTON_FONT_BIG or BUTTON_FONT))
    self:SetTall(isSmall and BUTTON_HEIGHT_SMALL or (isBig and BUTTON_HEIGHT_BIG or BUTTON_HEIGHT))

    self.isSmall = isSmall
	self.isBig = isBig

    self:SetText(self:GetText())
end

function PANEL:SetText(text)
    BaseClass.SetText(self, L(text))
    self:SizeToContentsX((self.isSmall and BUTTON_HEIGHT_SMALL or (self.isBig and BUTTON_HEIGHT_BIG or BUTTON_HEIGHT)) *
    3)
end

function PANEL:PaintBackground(width, height)
    surface.SetDrawColor(self:IsHovered() and ColorAlpha(self.color, 255) or self.color)
    surface.DrawRect(0, 0, width, height)

	if (not self:IsHovered()) then
		surface.SetDrawColor(0, 0, 0, self.isSmall and 100 or 152)
		surface.SetTexture(gradient)
		surface.DrawTexturedRect(0, 0, width, height)
	end
end

function PANEL:Paint(width, height)
	self:PaintBackground(width, height)
end

vgui.Register("expButton", PANEL, "DButton")
