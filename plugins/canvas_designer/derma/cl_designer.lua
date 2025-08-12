local PLUGIN = PLUGIN
local PANEL = {}

AccessorFunc(PANEL, "canvas", "Canvas")
AccessorFunc(PANEL, "item", "Item")

function PANEL:Init()
	self:SetDeleteOnClose(true)
	self:MakePopup()
end

function PANEL:Setup(item)
	self:SetItem(item)
	self:SetTitle("Canvas Designer - " .. item:GetName())
	self:SetSize(ScrW(), ScrH())
	self:Center()

	local canvas = PLUGIN.CanvasDesigner:New(item)
	self:SetCanvas(canvas)

	self:CreateLayout()
	self:SetupEventHandlers()
	self:UpdateElementCount()
end

function PANEL:CreateLayout()
	self:CreateMainContainer()
	self:CreateTopToolbar()
	self:CreateSidePanel()
	self:CreateCanvasPanel()
	self:CreateAssetBrowser()
	self:CreateBottomPanel()
end

function PANEL:CreateMainContainer()
	self.container = vgui.Create("EditablePanel", self)
	self.container:Dock(FILL)
	self.container:DockMargin(8, 8, 8, 8)
end

function PANEL:CreateTopToolbar()
	self.topbar = vgui.Create("EditablePanel", self.container)
	self.topbar:SetTall(50)
	self.topbar:Dock(TOP)
	self.topbar:DockMargin(0, 0, 0, 8)

	self:CreateElementCounter()
	self:CreateToolbarButtons()
end

function PANEL:CreateElementCounter()
	self.countLabel = vgui.Create("DLabel", self.topbar)
	self.countLabel:SetText("Elements: 0/" .. PLUGIN:GetMaximumElements(LocalPlayer()))
	self.countLabel:SetTextColor(PLUGIN.THEME.text)
	self.countLabel:SetFont("ixSmallBoldFont")
	self.countLabel:Dock(LEFT)
	self.countLabel:DockMargin(15, 0, 0, 0)
	self.countLabel:SizeToContents()
end

function PANEL:CreateToolbarButtons()
	-- Delete button
	self.deleteBtn = PLUGIN:CreateStyledButton(self.topbar, "Delete Selected", PLUGIN.THEME.danger)
	self.deleteBtn:SetSize(120, 30)
	self.deleteBtn:Dock(RIGHT)
	self.deleteBtn:DockMargin(0, 10, 15, 10)
	self.deleteBtn.DoClick = function()
		local canvas = self:GetCanvas()
		if (canvas:GetSelectedElementIndex()) then
			canvas:DeleteSelected()
			self:UpdateElementCount()
		end
	end

	-- Clear all button
	self.clearBtn = PLUGIN:CreateStyledButton(self.topbar, "Clear All", PLUGIN.THEME.warning)
	self.clearBtn:SetSize(100, 30)
	self.clearBtn:Dock(RIGHT)
	self.clearBtn:DockMargin(0, 10, 8, 10)
	self.clearBtn.DoClick = function()
		local canvas = self:GetCanvas()
		if (#canvas.elements > 0) then
			Derma_Query("Are you sure you want to clear the entire canvas?", "Clear Canvas", "Yes", function()
				canvas.elements = {}
				canvas:SelectElement(nil)
			end, "No")
		end
	end
end

function PANEL:CreateSidePanel()
	self.sidePanel = vgui.Create("EditablePanel", self.container)
	self.sidePanel:SetWide(350)
	self.sidePanel:Dock(RIGHT)
	self.sidePanel:DockMargin(8, 0, 0, 0)

	self.sidePanel.Paint = function(self, w, h)
		draw.RoundedBox(4, 0, 0, w, h, PLUGIN.THEME.panel)
	end

	self:CreateElementsList()
	self:CreatePropertiesPanel()
end

function PANEL:CreateElementsList()
	self.elementsList = vgui.Create("DTree", self.sidePanel)
	self.elementsList:Dock(TOP)
	self.elementsList:SetTall(100)
	self.elementsList:DockMargin(10, 10, 10, 0)
	self.elementsList.OnMouseReleased = function(node)
		-- Deselect if we click outside any node
		self:GetCanvas():SelectElement(nil)
	end
end

function PANEL:CreatePropertiesPanel()
	self.propPanel = vgui.Create("DScrollPanel", self.sidePanel)
	self.propPanel:Dock(FILL)

	self:CreatePropertiesTitle()
	self:CreateCanvasProperties()
	self:CreateSelectedElementProperties()
end

function PANEL:CreatePropertiesTitle()
	local propTitle = self.propPanel:Add("DLabel")
	propTitle:SetText("Properties")
	propTitle:SetTextColor(PLUGIN.THEME.text)
	propTitle:SetFont("ixBigFont")
	propTitle:Dock(TOP)
	propTitle:DockMargin(15, 15, 15, 10)
	propTitle:SizeToContents()
end

function PANEL:CreateCanvasProperties()
	local canvasPropTitle = self.propPanel:Add("DLabel")
	canvasPropTitle:SetText("Canvas Properties")
	canvasPropTitle:SetTextColor(PLUGIN.THEME.text)
	canvasPropTitle:SetFont("ixMediumFont")
	canvasPropTitle:Dock(TOP)
	canvasPropTitle:DockMargin(15, 15, 15, 10)
	canvasPropTitle:SizeToContents()

	self:CreateNameControl()
	self:CreateCanvasSizeControls()
end

function PANEL:CreateNameControl()
	local canvas = self:GetCanvas()
	local nameContainer = self.propPanel:Add("EditablePanel")
	nameContainer:Dock(TOP)
	nameContainer:SetTall(28)

	local nameLabel = vgui.Create("DLabel", nameContainer)
	nameLabel:SetText("Canvas Name")
	nameLabel:SetTextColor(PLUGIN.THEME.text)
	nameLabel:SetFont("ixSmallBoldFont")
	nameLabel:Dock(LEFT)
	nameLabel:DockMargin(10, 10, 10, 5)
	nameLabel:SizeToContents()

	self.nameEntry = vgui.Create("DTextEntry", nameContainer)
	self.nameEntry:Dock(FILL)
	self.nameEntry:DockMargin(10, 10, 10, 0)
	self.nameEntry:SetValue(canvas.name)
	self.nameEntry.OnChange = function(self_entry)
		local newName = self_entry:GetValue()

		if (newName and newName ~= "") then
			canvas.name = newName
		else
			self_entry:SetValue(canvas.name)
		end
	end
end

function PANEL:CreateCanvasSizeControls()
	self:CreateCanvasWidthControl()
	self:CreateCanvasHeightControl()
end

function PANEL:CreateCanvasWidthControl()
	local canvas = self:GetCanvas()
	local canvasWidthContainer = self.propPanel:Add("EditablePanel")
	canvasWidthContainer:Dock(TOP)
	canvasWidthContainer:SetTall(28)

	local canvasWidthLabel = vgui.Create("DLabel", canvasWidthContainer)
	canvasWidthLabel:SetText("Canvas Width")
	canvasWidthLabel:SetTextColor(PLUGIN.THEME.text)
	canvasWidthLabel:SetFont("ixSmallBoldFont")
	canvasWidthLabel:Dock(LEFT)
	canvasWidthLabel:DockMargin(10, 10, 10, 5)
	canvasWidthLabel:SizeToContents()

	self.canvasWidthEntry = vgui.Create("DTextEntry", canvasWidthContainer)
	self.canvasWidthEntry:Dock(FILL)
	self.canvasWidthEntry:DockMargin(10, 10, 10, 0)
	self.canvasWidthEntry:SetNumeric(true)
	self.canvasWidthEntry:SetValue(tostring(canvas.canvasWidth))
	self.canvasWidthEntry.OnChange = function(self_entry)
		local newWidth = tonumber(self_entry:GetValue())

		if (newWidth and newWidth > PLUGIN.CANVAS_MINIMUM_WIDTH and newWidth <= PLUGIN.CANVAS_MAX_WIDTH) then
			canvas.canvasWidth = newWidth
			self.canvasWidthEntry:SetValue(tostring(newWidth))
		else
			self_entry:SetValue(tostring(canvas.canvasWidth))
		end
	end

	canvasWidthContainer:InvalidateLayout(true)
end

function PANEL:CreateCanvasHeightControl()
	local canvas = self:GetCanvas()
	local canvasHeightContainer = self.propPanel:Add("EditablePanel")
	canvasHeightContainer:Dock(TOP)
	canvasHeightContainer:SetTall(28)

	local canvasHeightLabel = vgui.Create("DLabel", canvasHeightContainer)
	canvasHeightLabel:SetText("Canvas Height")
	canvasHeightLabel:SetTextColor(PLUGIN.THEME.text)
	canvasHeightLabel:SetFont("ixSmallBoldFont")
	canvasHeightLabel:Dock(LEFT)
	canvasHeightLabel:DockMargin(10, 10, 10, 5)
	canvasHeightLabel:SizeToContents()

	self.canvasHeightEntry = vgui.Create("DTextEntry", canvasHeightContainer)
	self.canvasHeightEntry:Dock(FILL)
	self.canvasHeightEntry:DockMargin(10, 10, 10, 0)
	self.canvasHeightEntry:SetNumeric(true)
	self.canvasHeightEntry:SetValue(tostring(canvas.canvasHeight))
	self.canvasHeightEntry.OnChange = function(self_entry)
		local newHeight = tonumber(self_entry:GetValue())

		if (newHeight and newHeight > PLUGIN.CANVAS_MINIMUM_HEIGHT and newHeight <= PLUGIN.CANVAS_MAX_HEIGHT) then
			canvas.canvasHeight = newHeight
			self.canvasHeightEntry:SetValue(tostring(newHeight))
		else
			self_entry:SetValue(tostring(canvas.canvasHeight))
		end
	end

	canvasHeightContainer:InvalidateLayout(true)
end

function PANEL:CreateSelectedElementProperties()
	local selectedPropTitle = self.propPanel:Add("DLabel")
	selectedPropTitle:SetText("Selected Element Properties")
	selectedPropTitle:SetTextColor(PLUGIN.THEME.text)
	selectedPropTitle:SetFont("ixMediumFont")
	selectedPropTitle:Dock(TOP)
	selectedPropTitle:DockMargin(15, 15, 15, 10)
	selectedPropTitle:SizeToContents()

	self:CreateScaleControls()
	self:CreateRotationControl()
	self:CreateColorControl()
end

function PANEL:CreateScaleControls()
	local scaleContainer = self.propPanel:Add("EditablePanel")
	scaleContainer:SetTall(160)
	scaleContainer:Dock(TOP)
	scaleContainer:DockMargin(10, 5, 10, 8)

	-- Scale X
	local scaleXLabel = vgui.Create("DLabel", scaleContainer)
	scaleXLabel:SetText("Scale X")
	scaleXLabel:SetTextColor(PLUGIN.THEME.text)
	scaleXLabel:SetFont("ixSmallBoldFont")
	scaleXLabel:Dock(TOP)
	scaleXLabel:DockMargin(10, 10, 10, 5)
	scaleXLabel:SizeToContents()

	self.scaleXSlider = vgui.Create("DNumSlider", scaleContainer)
	self.scaleXSlider:Dock(TOP)
	self.scaleXSlider:DockMargin(10, 0, 10, 10)
	self.scaleXSlider:SetSize(180, 20)
	self.scaleXSlider:SetMin(0.1)
	self.scaleXSlider:SetMax(15.0)
	self.scaleXSlider:SetDecimals(1)
	self.scaleXSlider:SetValue(1.0)
	self.scaleXSlider.OnValueChanged = function(self_slider, value)
		local canvas = self:GetCanvas()
		if (canvas:GetSelectedElementIndex() and canvas.elements[canvas:GetSelectedElementIndex()]) then
			canvas.elements[canvas:GetSelectedElementIndex()].scaleX = value
		end
	end
	self.scaleXSlider.Label:SetVisible(false)

	-- Scale Y
	local scaleYLabel = vgui.Create("DLabel", scaleContainer)
	scaleYLabel:SetText("Scale Y")
	scaleYLabel:SetTextColor(PLUGIN.THEME.text)
	scaleYLabel:SetFont("ixSmallBoldFont")
	scaleYLabel:Dock(TOP)
	scaleYLabel:DockMargin(10, 10, 10, 5)
	scaleYLabel:SizeToContents()

	self.scaleYSlider = vgui.Create("DNumSlider", scaleContainer)
	self.scaleYSlider:Dock(TOP)
	self.scaleYSlider:DockMargin(10, 0, 10, 10)
	self.scaleYSlider:SetSize(180, 20)
	self.scaleYSlider:SetMin(0.1)
	self.scaleYSlider:SetMax(15.0)
	self.scaleYSlider:SetDecimals(1)
	self.scaleYSlider:SetValue(1.0)
	self.scaleYSlider.OnValueChanged = function(self_slider, value)
		local canvas = self:GetCanvas()
		if (canvas:GetSelectedElementIndex() and canvas.elements[canvas:GetSelectedElementIndex()]) then
			canvas.elements[canvas:GetSelectedElementIndex()].scaleY = value
		end
	end
	self.scaleYSlider.Label:SetVisible(false)
end

function PANEL:CreateRotationControl()
	local rotationContainer = self.propPanel:Add("EditablePanel")
	rotationContainer:SetTall(100)
	rotationContainer:Dock(TOP)
	rotationContainer:DockMargin(10, 0, 10, 8)

	local rotationLabel = vgui.Create("DLabel", rotationContainer)
	rotationLabel:SetText("Rotation")
	rotationLabel:SetTextColor(PLUGIN.THEME.text)
	rotationLabel:SetFont("ixSmallBoldFont")
	rotationLabel:Dock(TOP)
	rotationLabel:DockMargin(10, 10, 10, 5)
	rotationLabel:SizeToContents()

	self.rotationSlider = vgui.Create("DNumSlider", rotationContainer)
	self.rotationSlider:Dock(TOP)
	self.rotationSlider:DockMargin(10, 0, 10, 10)
	self.rotationSlider:SetSize(180, 20)
	self.rotationSlider:SetMin(0)
	self.rotationSlider:SetMax(360)
	self.rotationSlider:SetDecimals(0)
	self.rotationSlider:SetValue(0)
	self.rotationSlider.OnValueChanged = function(self_slider, value)
		local canvas = self:GetCanvas()
		if (canvas:GetSelectedElementIndex() and canvas.elements[canvas:GetSelectedElementIndex()]) then
			canvas.elements[canvas:GetSelectedElementIndex()].rotation = value
		end
	end
	self.rotationSlider.Label:SetVisible(false)
end

function PANEL:CreateColorControl()
	local colorContainer = self.propPanel:Add("EditablePanel")
	colorContainer:SetTall(200)
	colorContainer:Dock(TOP)
	colorContainer:DockMargin(10, 0, 10, 8)

	local colorLabel = vgui.Create("DLabel", colorContainer)
	colorLabel:SetText("Color")
	colorLabel:SetTextColor(PLUGIN.THEME.text)
	colorLabel:SetFont("ixSmallBoldFont")
	colorLabel:Dock(TOP)
	colorLabel:DockMargin(10, 10, 10, 5)
	colorLabel:SizeToContents()

	self.colorMixer = vgui.Create("DColorMixer", colorContainer)
	self.colorMixer:Dock(TOP)
	self.colorMixer:DockMargin(10, 0, 10, 10)
	self.colorMixer:SetPalette(false)
	self.colorMixer:SetAlphaBar(true)
	self.colorMixer:SetWangs(true)
	self.colorMixer:SetColor(Color(255, 255, 255, 255))
	self.colorMixer.ValueChanged = function(self_mixer, color)
		local canvas = self:GetCanvas()
		if (canvas:GetSelectedElementIndex() and canvas.elements[canvas:GetSelectedElementIndex()]) then
			local element = canvas.elements[canvas:GetSelectedElementIndex()]
			element.color = { r = color.r, g = color.g, b = color.b, a = color.a }
		end
	end
end

function PANEL:CreateCanvasPanel()
	self.canvasPanelParent = vgui.Create("expDualScrollPanel", self.container)
	self.canvasPanelParent:Dock(FILL)

	self.canvasPanel = vgui.Create("EditablePanel")
	self.canvasPanelParent:AddItem(self.canvasPanel)
	self.canvasPanel:Dock(TOP)
	self.canvasPanel:DockMargin(0, 0, 0, 8)

	-- Set initial size to ensure proper layout
	local canvas = self:GetCanvas()
	local canvasWidth, canvasHeight = canvas:GetSize()
	self.canvasPanel:SetSize(canvasWidth + 100, canvasHeight + 100) -- Add padding for centering

	self.canvasPanel.Paint = function(panel, w, h)
		local canvas = self:GetCanvas()
		local canvasWidth, canvasHeight = canvas:GetSize()
		local offsetX = (w - canvasWidth) * 0.5
		local offsetY = (h - canvasHeight) * 0.5

		-- Store the offset for mouse handling
		canvas:SetDrawOffset(offsetX, offsetY)

		canvas:DrawCanvas(offsetX, offsetY, canvasWidth, canvasHeight)
	end

	self:SetupCanvasMouseHandling()
end

function PANEL:CreateAssetBrowser()
	self.assetBrowser = vgui.Create("EditablePanel", self.container)
	self.assetBrowser:SetTall(280)
	self.assetBrowser:Dock(BOTTOM)

	self:CreateAssetSearchHeader()
	self:CreateAssetCategoryTabs()
end

function PANEL:CreateAssetSearchHeader()
	local searchHeader = vgui.Create("EditablePanel", self.assetBrowser)
	searchHeader:SetTall(40)
	searchHeader:Dock(TOP)

	local searchLabel = vgui.Create("DLabel", searchHeader)
	searchLabel:SetText("Asset Browser")
	searchLabel:SetTextColor(PLUGIN.THEME.text)
	searchLabel:SetFont("ixSmallBoldFont")
	searchLabel:Dock(LEFT)
	searchLabel:DockMargin(15, 0, 15, 0)
	searchLabel:SizeToContents()

	self.searchBox = vgui.Create("DTextEntry", searchHeader)
	self.searchBox:SetPlaceholderText("Search assets...")
	self.searchBox:Dock(FILL)
	self.searchBox:DockMargin(0, 8, 15, 8)
end

function PANEL:CreateAssetCategoryTabs()
	self.categoryTabs = vgui.Create("DPropertySheet", self.assetBrowser)
	self.categoryTabs:Dock(FILL)
	self.categoryTabs:DockMargin(8, 0, 8, 8)

	self.categoryTabs.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
	end

	self.categoryPanels = {}

	-- Create tabs for each category
	for _, category in ipairs(PLUGIN.SHAPE_CATEGORIES) do
		local panel = vgui.Create("EditablePanel")

		local grid = self:CreateAssetGrid(panel, category, "")
		self.categoryPanels[category] = { panel = panel, grid = grid }

		local sheet = self.categoryTabs:AddSheet(string.upper(category), panel, "icon16/folder.png")
		sheet.Tab.Paint = function(tab, w, h)
			local bgColor = PLUGIN.THEME.panel

			if (tab:IsHovered() or tab:IsActive()) then
				bgColor = PLUGIN.THEME.primary
			end

			draw.RoundedBox(4, 0, 0, w, h, bgColor)

			if (tab:IsActive()) then
				draw.RoundedBox(4, 4, h - 6, w - 8, 2, PLUGIN.THEME.underline)
			end
		end
	end

	self:SetupAssetSearch()
end

function PANEL:CreateAssetGrid(parent, filterCategory, searchTerm)
	local canvas = self:GetCanvas()
	local scrollPanel = vgui.Create("DScrollPanel", parent)
	scrollPanel:Dock(FILL)

	local iconLayout = vgui.Create("DIconLayout", scrollPanel)
	iconLayout:Dock(TOP)
	iconLayout:SetSpaceY(8)
	iconLayout:SetSpaceX(8)
	iconLayout:DockMargin(8, 8, 8, 8)

	-- lua_run P1:GivePremiumPackage("colored-sprites-pack")
	local premiumPackages = LocalPlayer():GetPremiumPackages()

	for _, spriteType in ipairs(PLUGIN.SPRITE_TYPES) do
		local shouldShow = (filterCategory == "all" or spriteType.category == filterCategory)
		local isUnlocked = not spriteType.premiumKey or premiumPackages[spriteType.premiumKey]

		if (searchTerm and searchTerm ~= "") then
			local searchLower = string.lower(searchTerm)
			local nameMatch = string.find(string.lower(spriteType.name), searchLower)
			local keywordMatch = string.find(string.lower(spriteType.keywords or ""), searchLower)
			local categoryMatch = string.find(string.lower(spriteType.category), searchLower)

			shouldShow = shouldShow and (nameMatch or keywordMatch or categoryMatch)
		end

		if (not shouldShow) then
			continue
		end

		local assetBtn = vgui.Create("EditablePanel", iconLayout)
		assetBtn:SetSize(80, 80)
		assetBtn.Paint = function(panel, w, h)
			local bgColor = PLUGIN.THEME.panel

			if (panel:IsHovered()) then
				bgColor = PLUGIN.THEME.hover
			end

			draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(bgColor, isUnlocked and 255 or 100))

			-- Draw sprite
			surface.SetDrawColor(255, 255, 255, isUnlocked and 255 or 100)

			local iconSize = 40
			local iconX = w * 0.5 - iconSize * 0.5
			local iconY = 8

			Schema.draw.DrawSpritesheetMaterial(
				spriteType.icon.material,
				iconX, iconY,
				iconSize, iconSize,
				spriteType.icon.x, spriteType.icon.y,
				spriteType.icon.size, spriteType.icon.size,
				false
			)

			-- Draw name
			surface.SetTextColor(PLUGIN.THEME.text.r, PLUGIN.THEME.text.g, PLUGIN.THEME.text.b, 255)
			surface.SetFont("DermaDefault")

			local text = spriteType.name
			local tw, th = surface.GetTextSize(text)

			if (tw > w - 4) then
				while (tw > w - 10 and #text > 0) do
					text = string.sub(text, 1, #text - 1)
					tw, th = surface.GetTextSize(text .. "...")
				end

				text = text .. "..."
			end

			surface.SetTextPos(w * 0.5 - tw * 0.5, h - th - 4)
			surface.DrawText(text)

			-- If the sprite is premium and we don't have that key in premiumPackages, draw a lock icon
			if (not isUnlocked) then
				surface.SetDrawColor(255, 255, 255, 200)
				surface.SetMaterial(Material("icon16/lock.png"))
				surface.DrawTexturedRect(w - 20, h - 20, 16, 16)
			end
		end

		assetBtn.OnMousePressed = function(panel, keyCode)
			if (not isUnlocked) then
				Derma_Query(
					"You do not have access to this premium asset.\nSupport us by purchasing it from the Premium Shop!",
					"Premium Asset",
					"OK",
					function() end,
					"Open Premium Shop",
					function()
						if (not IsValid(ix.gui.menu)) then
							vgui.Create("ixMenu")
						end

						local premiumShopId

						for _, subPanel in pairs(ix.gui.menu.subpanels) do
							if (subPanel.subpanelName == "premiumShop") then
								premiumShopId = subPanel.subpanelID
							end
						end

						if (premiumShopId) then
							ix.gui.menu:TransitionSubpanel(premiumShopId)
						end
					end
				)
				return
			end

			if (keyCode == MOUSE_LEFT) then
				local canvasWidth, canvasHeight = canvas:GetSize()

				if (canvas:AddElement(spriteType, canvasWidth * 0.5, canvasHeight * 0.5)) then
					self:UpdateElementCount()
				else
					LocalPlayer():Notify("Maximum elements reached!")
				end
			end
		end
	end

	return iconLayout
end

function PANEL:CreateBottomPanel()
	self.bottomPanel = vgui.Create("EditablePanel", self)
	self.bottomPanel:SetTall(50)
	self.bottomPanel:Dock(BOTTOM)
	self.bottomPanel:DockMargin(8, 0, 8, 8)

	self:CreateBottomButtons()
end

function PANEL:CreateBottomButtons()
	local canvas = self:GetCanvas()
	self.saveButton = PLUGIN:CreateStyledButton(self.bottomPanel, "Save Design", PLUGIN.THEME.success)
	self.saveButton:SetSize(120, 30)
	self.saveButton:Dock(RIGHT)
	self.saveButton:DockMargin(0, 10, 15, 10)
	self.saveButton.DoClick = function()
		local canvasWidth, canvasHeight = canvas:GetSize()
		local jsonData = canvas:SaveDesign()
		net.Start("expCanvasSave")
		net.WriteUInt(self:GetItem():GetID(), 32)
		net.WriteUInt(canvasWidth, PLUGIN.CANVAS_WIDTH_BITS)
		net.WriteUInt(canvasHeight, PLUGIN.CANVAS_HEIGHT_BITS)
		net.WriteString(canvas.name)
		net.WriteString(jsonData)
		net.SendToServer()
	end

	self.cancelButton = PLUGIN:CreateStyledButton(self.bottomPanel, "Cancel", PLUGIN.THEME.textSecondary)
	self.cancelButton:SetSize(100, 30)
	self.cancelButton:Dock(RIGHT)
	self.cancelButton:DockMargin(0, 10, 8, 10)
	self.cancelButton.DoClick = function()
		self:Close()
	end
end

function PANEL:SetupEventHandlers()
	self:SetupElementsChangedCallback()
	self:SetupKeyboardHandling()
end

function PANEL:SetupElementsChangedCallback()
	local canvas = self:GetCanvas()
	PLUGIN.CanvasDesigner.OnElementsChanged = function()
		self.elementsList:Clear()

		for i = #canvas.elements, 1, -1 do
			local element = canvas.elements[i]
			local node = self.elementsList:AddNode(element.type .. " #" .. i)
			node:SetIcon("icon16/application_view_list.png")
			node:SetExpanded(false)

			if (canvas:GetSelectedElementIndex() == i) then
				node:SetSelected(true)
			end

			node.DoClick = function()
				canvas:SelectElement(i)
			end

			-- Add right-click context menu
			node.DoRightClick = function()
				local menu = DermaMenu()

				-- Move Up option
				local moveUpOption = menu:AddOption("Move Up", function()
					self:MoveElement(i, i + 1)
				end)
				moveUpOption:SetIcon("icon16/arrow_up.png")
				if (i == #canvas.elements) then
					moveUpOption:SetEnabled(false)
				end

				-- Move Down option
				local moveDownOption = menu:AddOption("Move Down", function()
					self:MoveElement(i, i - 1)
				end)
				moveDownOption:SetIcon("icon16/arrow_down.png")
				if (i == 1) then
					moveDownOption:SetEnabled(false)
				end

				menu:AddSpacer()

				-- Move to Top option
				local moveTopOption = menu:AddOption("Move to Top", function()
					self:MoveElement(i, #canvas.elements)
				end)
				moveTopOption:SetIcon("icon16/arrow_up.png")
				if (i == #canvas.elements) then
					moveTopOption:SetEnabled(false)
				end

				-- Move to Bottom option
				local moveBottomOption = menu:AddOption("Move to Bottom", function()
					self:MoveElement(i, 1)
				end)
				moveBottomOption:SetIcon("icon16/arrow_down.png")
				if (i == 1) then
					moveBottomOption:SetEnabled(false)
				end

				menu:AddSpacer()

				-- Delete option
				local deleteOption = menu:AddOption("Delete Element", function()
					canvas:SelectElement(i)
					canvas:DeleteSelected()
					self:UpdateElementCount()
				end)
				deleteOption:SetIcon("icon16/delete.png")

				menu:Open()
			end
		end

		self:UpdateElementCount()
	end
	PLUGIN.CanvasDesigner:OnElementsChanged()
end

function PANEL:MoveElement(fromIndex, toIndex)
	local canvas = self:GetCanvas()
	local elements = canvas.elements
	local elementCount = #elements

	-- Validate indices
	if (fromIndex < 1 or fromIndex > elementCount or toIndex < 1 or toIndex > elementCount) then
		return
	end

	-- Don't move if already at target position
	if (fromIndex == toIndex) then
		return
	end

	-- Store the currently selected element index
	local selectedIndex = canvas:GetSelectedElementIndex()
	local newSelectedIndex = selectedIndex

	-- Remove the element from its current position
	local element = table.remove(elements, fromIndex)

	-- Insert it at the new position
	table.insert(elements, toIndex, element)

	-- Update the selected element index if necessary
	if (selectedIndex) then
		if (selectedIndex == fromIndex) then
			-- The selected element was moved
			newSelectedIndex = toIndex
		elseif (fromIndex < selectedIndex and toIndex >= selectedIndex) then
			-- Element moved from before to after/at selected position
			newSelectedIndex = selectedIndex - 1
		elseif (fromIndex > selectedIndex and toIndex <= selectedIndex) then
			-- Element moved from after to before/at selected position
			newSelectedIndex = selectedIndex + 1
		end
	end

	-- Update the canvas selection
	if (newSelectedIndex ~= selectedIndex) then
		canvas:SelectElement(newSelectedIndex)
	end

	-- Trigger the elements changed callback to refresh the tree
	if (PLUGIN.CanvasDesigner.OnElementsChanged) then
		PLUGIN.CanvasDesigner:OnElementsChanged()
	end
end

function PANEL:SetupKeyboardHandling()
	function self:OnKeyCodePressed(keyCode)
		local canvas = self:GetCanvas()
		if (keyCode == KEY_DELETE and canvas:GetSelectedElementIndex()) then
			canvas:DeleteSelected()
			self:UpdateElementCount()
		end
	end
end

function PANEL:SetupCanvasMouseHandling()
	self.canvasPanel.OnMousePressed = function(panel, keyCode)
		if (keyCode == MOUSE_LEFT) then
			local canvas = self:GetCanvas()
			local mx, my = panel:CursorPos()
			local panelW, panelH = panel:GetSize()
			local canvasWidth, canvasHeight = canvas:GetSize()

			-- Calculate and set the offset for GetElementAt to use
			local offsetX = (panelW - canvasWidth) * 0.5
			local offsetY = (panelH - canvasHeight) * 0.5
			canvas:SetDrawOffset(offsetX, offsetY)

			-- Let GetElementAt handle the coordinate conversion
			local elementIndex = canvas:GetElementAt(mx, my)

			-- Also check if we're within canvas bounds manually for debugging
			local canvasX = mx - offsetX
			local canvasY = my - offsetY

			if (canvasX >= 0 and canvasX <= canvasWidth and canvasY >= 0 and canvasY <= canvasHeight) then
				if (elementIndex) then
					canvas:SelectElement(elementIndex)
					canvas.isDragging = true
					canvas.dragStartX = mx
					canvas.dragStartY = my
					canvas.elementStartX = canvas.elements[elementIndex].x
					canvas.elementStartY = canvas.elements[elementIndex].y

					-- Update property controls
					local element = canvas.elements[elementIndex]
					self.scaleXSlider:SetValue(element.scaleX)
					self.scaleYSlider:SetValue(element.scaleY)
					self.rotationSlider:SetValue(element.rotation)
					self.colorMixer:SetColor(Color(element.color.r, element.color.g, element.color.b, element.color.a))
				else
					canvas:SelectElement(nil)
				end
			end
		end
	end

	self.canvasPanel.OnMouseReleased = function(panel, keyCode)
		if (keyCode == MOUSE_LEFT) then
			self:GetCanvas().isDragging = false
		end
	end

	self.lastThink = 0
	self.canvasPanel.Think = function(panel)
		if (CurTime() - self.lastThink < 0.01) then
			return
		end

		self.lastThink = CurTime()
		local canvas = self:GetCanvas()

		if (canvas.isDragging and canvas:GetSelectedElementIndex()) then
			local mx, my = panel:CursorPos()
			local deltaX = mx - canvas.dragStartX
			local deltaY = my - canvas.dragStartY

			local element = canvas.elements[canvas:GetSelectedElementIndex()]

			element.x = canvas.elementStartX + deltaX
			element.y = canvas.elementStartY + deltaY
		end
	end
end

function PANEL:SetupAssetSearch()
	self.searchBox.OnChange = function(searchBox)
		local searchTerm = searchBox:GetValue()
		for category, data in pairs(self.categoryPanels) do
			-- Clear the entire panel and recreate everything
			data.panel:Clear()
			data.grid = self:CreateAssetGrid(data.panel, category, searchTerm)
			self.categoryPanels[category].grid = data.grid
		end
	end
end

function PANEL:UpdateElementCount()
	local maxElements = PLUGIN:GetMaximumElements(LocalPlayer())
	local count = #self:GetCanvas().elements

	self.countLabel:SetText("Elements: " .. count .. "/" .. maxElements)
	self.countLabel:SetTextColor(count >= maxElements and PLUGIN.THEME.danger or PLUGIN.THEME.success)
	self.countLabel:SizeToContents()
end

vgui.Register("expCanvasDesigner", PANEL, "expFrame")
