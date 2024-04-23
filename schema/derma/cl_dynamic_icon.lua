local PANEL = {}

PANEL.padding = 32

function PANEL:Init()
	self:SetSize(64, 64)
end

function PANEL:PerformLayout(width, height)
	self.paddingHalf = self.padding * 0.5
end

function PANEL:SetSymbol(pathOrSpritesheetData, opacity)
	self.opacity = opacity or 255
    self.symbolID = isstring(pathOrSpritesheetData) and surface.GetTextureID(pathOrSpritesheetData) or nil
	self.symbolSprite = istable(pathOrSpritesheetData) and pathOrSpritesheetData or nil
end

function PANEL:SetBack(path, color, opacity)
	self.opacity = opacity or 255
	self.backID = surface.GetTextureID(path)
	self.backColor = color
end

function PANEL:SetBadge(pathOrSpritesheetData, color)
	self.badgeColor = color or color_white
    self.badgeID = isstring(pathOrSpritesheetData) and surface.GetTextureID(pathOrSpritesheetData) or nil
	self.badgeSprite = istable(pathOrSpritesheetData) and pathOrSpritesheetData or nil
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

function PANEL:DrawSymbol(symbol, x, y, width, height)
	if (isnumber(symbol)) then
		surface.SetDrawColor(255, 255, 255, self.opacity)
		surface.SetTexture(symbol)
		surface.DrawTexturedRect(x, y, width, height)
	end

	if (istable(symbol)) then
		local spritesheetData = symbol
		surface.SetDrawColor(255, 255, 255, self.opacity)

		Schema.util.DrawSpritesheetMaterial(
			spritesheetData.spritesheet,
            x,
			y,
			width,
			height,
			spritesheetData.x,
			spritesheetData.y,
			spritesheetData.w or spritesheetData.size,
			spritesheetData.h or spritesheetData.size,
			spritesheetData.mirror or false
		)
	end
end

function PANEL:PaintOver(width, height)
    self:DrawSymbol(self.symbolID or self.symbolSprite, self.paddingHalf, self.paddingHalf, width - self.padding, height - self.padding)

	if (self.badgeID or self.badgeSprite) then
		local badgeSize = 16
		local padding = 8
		local paddingHalf = padding * 0.5

		surface.SetDrawColor(self.badgeColor)
		surface.DrawRect(width - badgeSize, 0, badgeSize, badgeSize)

		surface.SetDrawColor(255, 255, 255, self.opacity)
		self:DrawSymbol(self.badgeID or self.badgeSprite, width - badgeSize + paddingHalf, paddingHalf, badgeSize - padding, badgeSize - padding)
    end
end

vgui.Register("expDynamicIcon", PANEL, "EditablePanel")
