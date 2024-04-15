local PANEL = {}

PANEL.padding = 24

function PANEL:Init()
	self.OnCursorEntered = function() end
	self.OnMouseReleased = function() end
	self.OnCursorExited = function() end
	self.OnMousePressed = function() end
	self:SetCursor("none")
end

function PANEL:PerformLayout(width, height)
	self.paddingHalf = self.padding * 0.5
end

function PANEL:SetSymbol(path, opacity)
	self.opacity = opacity or 255
	self.symbolID = surface.GetTextureID(path)
end

function PANEL:SetBack(path, color, opacity)
	self.opacity = opacity or 255
	self.backID = surface.GetTextureID(path)
	self.backColor = color
end

function PANEL:SetBadge(path, color)
	self.badgeID = surface.GetTextureID(path)
	self.badgeColor = color or color_white
end

function PANEL:Paint(width, height)
    if (not self.backID) then
        return
    end

	local color = self.backColor or {}

	surface.SetDrawColor(color.r or 255, color.g or 255, color.b or 255, self.opacity)
	surface.SetTexture(self.backID)
	surface.DrawTexturedRect(0, 0, width, height)
end

function PANEL:PaintOver(width, height)
    if (self.symbolID) then
		surface.SetDrawColor(255, 255, 255, self.opacity)
		surface.SetTexture(self.symbolID)
		surface.DrawTexturedRect(self.paddingHalf, self.paddingHalf, width - self.padding, height - self.padding)
    end

	if (self.badgeID) then
		local badgeSize = 16
		local padding = 8
		local paddingHalf = padding * 0.5

		surface.SetDrawColor(self.badgeColor)
		surface.DrawRect(width - badgeSize, 0, badgeSize, badgeSize)

		surface.SetDrawColor(255, 255, 255, self.opacity)
		surface.SetTexture(self.badgeID)
		surface.DrawTexturedRect(width - badgeSize + paddingHalf, paddingHalf, badgeSize - padding, badgeSize - padding)
	end
end

vgui.Register("expDynamicIcon", PANEL, "DImageButton")
