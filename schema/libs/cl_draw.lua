Schema.draw = Schema.draw or {}

--- Draws a circle on the screen.
-- Source: https://wiki.facepunch.com/gmod/surface.DrawPoly
--- @param x number
--- @param y number
--- @param radius number
--- @param seg number
function Schema.draw.DrawCircle(x, y, radius, seg)
	local cir = {}

	table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })
	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		table.insert(cir,
			{ x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) /
			2 + 0.5 })
	end

	local a = math.rad(0) -- This is needed for non absolute segment counts
	table.insert(cir,
		{ x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 +
		0.5 })

	surface.DrawPoly(cir)
end

--- Draws part of a spritesheet
--- @param spritesheet IMaterial
--- @param x number Where to draw the spritesheet part on the X axis.
--- @param y number Where to draw the spritesheet part on the Y axis.
--- @param w number How wide the drawn spritesheet part should be.
--- @param h number How tall the drawn spritesheet part should be.
--- @param partX number The X position (starting at 0) of the part (not in pixels, but in parts).
--- @param partY number The Y position (starting at 0) of the part.
--- @param partW number The width of each part in the spritesheet.
--- @param partH number The height of each part in the spritesheet.
--- @param mirror? boolean Whether to mirror the spritesheet part.
function Schema.draw.DrawSpritesheetMaterial(spritesheet, x, y, w, h, partX, partY, partW, partH, mirror)
    local spritesheetWidth, spritesheetHeight = spritesheet:Width(), spritesheet:Height()
    local spriteX, spriteY = spritesheetWidth / partW, spritesheetHeight / partH
    local u = partX / spriteX
    local v = partY / spriteY
    local u2 = (partX + 1) / spriteX
    local v2 = (partY + 1) / spriteY

    if (mirror) then
        u, u2 = u2, u
    end

    surface.SetMaterial(spritesheet)
    surface.DrawTexturedRectUV(x, y, w, h, u, v, u2, v2)
end

--- Draws a label and value on screen
function Schema.draw.DrawLabeledValue(label, value, x, y)
	x = x or ScrW() * 0.5
    y = y or ScrH() * 0.1

	local font = "ixSmallTitleFont"

	local labelWidth, labelHeight = draw.SimpleTextOutlined(
		label,
		font,
		x,
		y,
		Color(255, 255, 255, 50),
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1,
		color_black
	)

	draw.SimpleTextOutlined(
		value,
		font,
		x,
		y + labelHeight,
		color_white,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1,
		color_black
	)
end

--- Shows a spritesheet picker to get the x and y position of a spritesheet part.
concommand.Add("debug_spritesheet_picker", function(client, command, arguments)
	if (not client:IsSuperAdmin()) then
		return
	end

	if (#arguments < 1) then
		arguments[1] = "experiment-redux/flatmsicons32.png"
	end

	local spritesheetPath = arguments[1]
	local spritesheet = Material(spritesheetPath)

	if (spritesheet:IsError()) then
		ix.util.SchemaErrorNoHalt("Invalid spritesheet path.\n")
		return
	end

	if (IsValid(ix.gui.debugSpritesheetPicker)) then
		ix.gui.debugSpritesheetPicker:Remove()
	end

	local frame = vgui.Create("DFrame")
	ix.gui.debugSpritesheetPicker = frame
	frame:SetSize(math.min(ScrW(), spritesheet:Width() + 8), math.min(ScrH(), spritesheet:Height() + 8))
	frame:Center()
	frame:SetTitle("Spritesheet Picker")
	frame:MakePopup()

	local spriteWidthLabel = frame:Add("DLabel")
	spriteWidthLabel:Dock(TOP)
	spriteWidthLabel:SetText("Sprite Width:")
	spriteWidthLabel:SizeToContents()

	local spriteWidthInput = frame:Add("DTextEntry")
	spriteWidthInput:Dock(TOP)
	spriteWidthInput:SetValue("32")

	local spriteHeightLabel = frame:Add("DLabel")
	spriteHeightLabel:Dock(TOP)
	spriteHeightLabel:SetText("Sprite Height:")
	spriteHeightLabel:SizeToContents()

	local spriteHeightInput = frame:Add("DTextEntry")
	spriteHeightInput:Dock(TOP)
	spriteHeightInput:SetValue("32")

	local spriteSizeButton = frame:Add("DButton")
	spriteSizeButton:Dock(TOP)
	spriteSizeButton:SetText("Set Sprite Size")

	local scroll = frame:Add("DScrollPanel")
	scroll:Dock(FILL)

	local output = frame:Add("DTextEntry")
	output:SetTall(100)
	output:SetMultiline(true)
	output:Dock(BOTTOM)

	local spriteWidth, spriteHeight = tonumber(spriteWidthInput:GetValue()), tonumber(spriteHeightInput:GetValue())
	local selectedSpriteX, selectedSpriteY = 0, 0

	function output:DoRefresh()
		local spriteDimensions

		if (spriteWidth == spriteHeight) then
			spriteDimensions = "size = " .. spriteWidth
		else
			spriteDimensions = "w = " .. spriteWidth .. ", h = " .. spriteHeight
		end

		local outputText = [[{
			spritesheet = "]] ..spritesheetPath .. [[",
			x = ]] .. selectedSpriteX .. [[,
			y = ]] .. selectedSpriteY .. [[,
			]] .. spriteDimensions .. [[,
		}]]

		self:SetText(outputText)
	end

	local spritesheetImage = scroll:Add("DImage")
	spritesheetImage:SetMaterial(spritesheet)
	spritesheetImage:Dock(TOP)

	local aspectRatio = spritesheet:Height() / spritesheet:Width()
	local scaleX, scaleY = 1, 1
	output:DoRefresh()

	spritesheetImage.Think = function(self)
		local scaledHeight = spritesheetImage:GetWide() * aspectRatio

		scaleX = spritesheetImage:GetWide() / spritesheet:Width()
		scaleY = scaledHeight / spritesheet:Height()

		if (scaledHeight ~= spritesheetImage:GetTall()) then
			spritesheetImage:SetTall(scaledHeight)
		end
	end

	spriteSizeButton.DoClick = function()
		spriteWidth = tonumber(spriteWidthInput:GetValue())
		spriteHeight = tonumber(spriteHeightInput:GetValue())
	end

	local spritePicker = scroll:Add("EditablePanel")
	spritePicker:SetSize(spritesheet:Width(), spritesheet:Height())
	spritePicker.Paint = function(self, w, h)
		local partX = selectedSpriteX
		local partY = selectedSpriteY

		surface.SetDrawColor(255, 0, 0, 255)
		surface.DrawOutlinedRect(partX * spriteWidth * scaleX, partY * spriteHeight * scaleY, spriteWidth * scaleX, spriteHeight * scaleY)
	end

	spritePicker.OnMousePressed = function(self, code)
		local x, y = self:CursorPos()
		local partX = math.floor(x / (spriteWidth * scaleX))
		local partY = math.floor(y / (spriteHeight * scaleY))

		selectedSpriteX = partX
		selectedSpriteY = partY

		output:DoRefresh()
	end
end)
