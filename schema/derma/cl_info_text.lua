do
	--- @class expInfoText : DPanel
	local PANEL = {}

	local PADDING = 6

	-- Called when the panel is initialized.
	function PANEL:Init()
		self:SetPos(4, 4)
		self:SetSize(self:GetWide() - 8, 24)
		self:SetBackgroundColor(Color(139, 174, 179, 255))

		local panel = vgui.Create("EditablePanel", self)
		panel:Dock(LEFT)
		panel:DockMargin(PADDING, PADDING, 0, PADDING)
		panel:SetSize(16, 16)

		self.icon = vgui.Create("DImage", panel)
		self.icon:SetImage("icon16/comment.png")
		self.icon:SetSize(16, 16)

		self.label = vgui.Create("DLabel", self)
		self.label:SetText("")
		self.label:SetWrap(true)
		self.label:SetAutoStretchVertical(true)
		self.label:Dock(TOP)
		self.label:DockMargin(PADDING, PADDING, PADDING, PADDING)
		self.label:SetFont("DermaDefaultBold")
		self.label:SetExpensiveShadow(1, Color(0, 0, 0, 150))
	end

	-- Called when the layout should be performed.
	function PANEL:PerformLayout(width, height)
		-- Ensure the label is up-to-date in height
		self.label:InvalidateLayout(true)

		local labelHeight = self.label:GetTall()
		local desiredHeight = labelHeight + (PADDING * 2)

		if (height ~= desiredHeight) then
			self:SetTall(desiredHeight)
		end

		derma.SkinHook("Layout", "Panel", self)
	end

	-- Called when the panel is painted.
	function PANEL:Paint(w, h)
		if (self:GetPaintBackground()) then
			local width, height = self:GetSize()
			local x, y = 0, 0

			if (self:IsDepressed()) then
				height = height - 4
				width = width - 4
				x = x + 2
				y = y + 2
			end

			draw.RoundedBox(4, x, y, width, height, self:GetBackgroundColor())

			if (self:IsButton() and self:IsHovered()) then
				draw.RoundedBox(4, x, y, width, height, Color(255, 255, 255, 50))
			end
		end

		return true
	end

	--- Sets the text of the panel.
	function PANEL:SetText(text)
		self.label:SetText(text)
		self.label:SizeToContents()
	end

	--- Sets whether the panel is a button.
	function PANEL:SetButton(isButton)
		self.isButton = isButton
	end

	--- Gets whether the panel is a button.
	function PANEL:IsButton()
		return self.isButton
	end

	--- Sets whether the panel is depressed.
	function PANEL:SetDepressed(isDepressed)
		self.isDepressed = isDepressed
	end

	--- Gets whether the panel is depressed.
	function PANEL:IsDepressed()
		return self.isDepressed
	end

	--- Sets whether the panel is hovered.
	function PANEL:SetHovered(isHovered)
		self.isHovered = isHovered
	end

	--- Gets whether the panel is hovered.
	function PANEL:IsHovered()
		return self.isHovered
	end

	--- Sets the text color of the panel.
	function PANEL:SetTextColor(color)
		self.label:SetTextColor(color)
	end

	-- Called when the mouse is pressed on the panel.
	function PANEL:OnMousePressed(mouseCode)
		if (self:IsButton()) then
			self:SetDepressed(true)
			self:MouseCapture(true)
		end
	end

	-- Called when the mouse is released on the panel.
	function PANEL:OnMouseReleased(mouseCode)
		if (self:IsButton() and self:IsDepressed()
				and self:IsHovered()) then
			if (self.DoClick) then
				surface.PlaySound("ui/buttonclick.wav")
				self:DoClick()
			end
		end

		self:SetDepressed(false)
		self:MouseCapture(false)
	end

	-- Called when the mouse has entered the panel.
	function PANEL:OnCursorEntered()
		self:SetHovered(true)
	end

	-- Called when the mouse has entered the panel.
	function PANEL:OnCursorExited()
		self:SetHovered(false)
	end

	--- Sets whether the icon is shown.
	function PANEL:SetShowIcon(showIcon)
		self.icon:SetVisible(showIcon)
	end

	--- Sets the icon.
	function PANEL:SetIcon(icon)
		self.icon:SetImage(icon)
		self.icon:SizeToContents()
		self.icon:SetVisible(true)
	end

	--- Sets the panel's info color.
	function PANEL:SetInfoColor(color)
		if (color == "red") then
			--self:SetBackgroundColor( Color(179, 46, 49, 255) )
			self:SetBackgroundColor(Color(238, 44, 44, 255))
			self:SetIcon("icon16/exclamation.png")
		elseif (color == "orange") then
			--self:SetBackgroundColor( Color(223, 154, 72, 255) )
			self:SetBackgroundColor(Color(255, 97, 3, 255))
			self:SetIcon("icon16/error.png")
		elseif (color == "green") then
			--self:SetBackgroundColor( Color(139, 215, 113, 255) )
			self:SetBackgroundColor(Color(0, 238, 118, 255))
			self:SetIcon("icon16/tick.png")
		elseif (color == "silver") then
			self:SetBackgroundColor(Color(192, 192, 192, 255))
			self:SetIcon("icon16/tick.png")
		elseif (color == "blue") then
			--self:SetBackgroundColor( Color(139, 174, 179, 255) )
			self:SetBackgroundColor(Color(0, 178, 238, 255))
			self:SetIcon("icon16/information.png")
		else
			self:SetShowIcon(false)
			self:SetBackgroundColor(color)
		end
	end

	vgui.Register("expInfoText", PANEL, "DPanel")
end
