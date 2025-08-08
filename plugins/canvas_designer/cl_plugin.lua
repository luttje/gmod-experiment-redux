local PLUGIN = PLUGIN

function PLUGIN:CreateStyledButton(parent, text, color)
	local button = vgui.Create("DButton", parent)
	button:SetText("")
	button.Paint = function(button, width, height)
		local backgroundColor = color or PLUGIN.THEME.primary

		if (button:IsHovered()) then
			backgroundColor = Color(
				math.min(backgroundColor.r + 20, 255),
				math.min(backgroundColor.g + 20, 255),
				math.min(backgroundColor.b + 20, 255)
			)
		end

		if (button:IsDown()) then
			backgroundColor = Color(
				math.max(backgroundColor.r - 20, 0),
				math.max(backgroundColor.g - 20, 0),
				math.max(backgroundColor.b - 20, 0)
			)
		end

		draw.RoundedBox(4, 0, 0, width, height, backgroundColor)

		surface.SetTextColor(255, 255, 255, 255)
		surface.SetFont("ixSmallBoldFont")

		local textWidth, textHeight = surface.GetTextSize(text)

		surface.SetTextPos(width * .5 - textWidth * .5, height * .5 - textHeight * .5)
		surface.DrawText(text)
	end

	return button
end

net.Receive("expCanvasDesigner", function()
	local itemID = net.ReadUInt(32)
	local item = ix.item.instances[itemID]

	if (item) then
		if (IsValid(ix.gui.menu)) then
			ix.gui.menu:Remove()
		end

		local frame = vgui.Create("expCanvasDesigner")
		frame:Setup(item)
	end
end)

net.Receive("expCanvasCopySelector", function()
	local itemID = net.ReadUInt(32)
	local item = ix.item.instances[itemID]

	if (item) then
		if (IsValid(ix.gui.menu)) then
			ix.gui.menu:Remove()
		end

		local copySelector = vgui.Create("expCanvasCopySelector")
		copySelector:SetTargetItem(item)
	end
end)

net.Receive("expCanvasView", function()
	local itemID = net.ReadUInt(32)
	local item = ix.item.instances[itemID]

	if (item) then
		if (IsValid(ix.gui.menu)) then
			ix.gui.menu:Remove()
		end

		local viewerFrame = vgui.Create("expCanvasViewer")
		viewerFrame:SetCanvasItem(item)
	end
end)

net.Receive("expSprayCanDesignSelector", function()
	local itemID = net.ReadUInt(32)

	local character = LocalPlayer():GetCharacter()
	if (not character) then return end

	local inventory = character:GetInventory()
	if (not inventory) then return end

	local item = ix.item.instances[itemID]
	if (not item) then return end

	if (IsValid(ix.gui.menu)) then
		ix.gui.menu:Remove()
	end

	local designSelector = vgui.Create("expSprayCanDesignSelector")
	designSelector:SetTargetItem(item)
end)
