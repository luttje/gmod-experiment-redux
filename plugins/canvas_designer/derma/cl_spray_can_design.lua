local PLUGIN = PLUGIN
local PANEL = {}

AccessorFunc(PANEL, "targetItem", "TargetItem")

function PANEL:Init()
	self:SetTitle("Load Design into Spray Can")
	self:SetSize(800, 600)
	self:Center()
	self:MakePopup()
	self:SetDeleteOnClose(true)

	self.selectedCanvasItem = nil
	self.previewCanvas = nil

	self:CreateMainContainer()
end

function PANEL:SetTargetItem(item)
	self.targetItem = item
	self:SetTitle("Load Design into Spray Can - " .. item:GetName())
	self:RefreshCanvasList()
end

function PANEL:CreateMainContainer()
	-- Main container
	self.mainContainer = vgui.Create("EditablePanel", self)
	self.mainContainer:Dock(FILL)
	self.mainContainer:DockMargin(8, 8, 8, 8)

	self:CreateTopPanel()
	self:CreateContentPanel()
	self:CreateBottomPanel()
end

function PANEL:CreateTopPanel()
	-- Top panel for dropdown selection
	self.topPanel = vgui.Create("EditablePanel", self.mainContainer)
	self.topPanel:SetTall(60)
	self.topPanel:Dock(TOP)
	self.topPanel:DockMargin(0, 0, 0, 8)
	self.topPanel.Paint = function(panel, width, height)
		draw.RoundedBox(4, 0, 0, width, height, PLUGIN.THEME.panel)
	end

	self:CreateDropdownLabel()
	self:CreateCanvasDropdown()
end

function PANEL:CreateDropdownLabel()
	-- Dropdown label
	self.dropdownLabel = vgui.Create("DLabel", self.topPanel)
	self.dropdownLabel:SetText("Select Canvas Design to Load:")
	self.dropdownLabel:SetTextColor(PLUGIN.THEME.text)
	self.dropdownLabel:SetFont("ixMediumFont")
	self.dropdownLabel:Dock(LEFT)
	self.dropdownLabel:DockMargin(15, 15, 15, 5)
	self.dropdownLabel:SizeToContents()
end

function PANEL:CreateCanvasDropdown()
	-- Dropdown for canvas selection
	self.canvasDropdown = vgui.Create("DComboBox", self.topPanel)
	self.canvasDropdown:SetTall(28)
	self.canvasDropdown:Dock(FILL)
	self.canvasDropdown:DockMargin(15, 10, 15, 0)
	self.canvasDropdown:SetValue("Select a canvas design...")

	self.canvasDropdown.OnSelect = function(dropdown, index, value, data)
		self:OnCanvasSelected(data)
	end
end

function PANEL:CreateContentPanel()
	self.contentPanel = vgui.Create("EditablePanel", self.mainContainer)
	self.contentPanel:Dock(FILL)

	self:CreateColumnHeader(self.contentPanel, "Design to Load")
	self:CreateSelectedDesignPreview()
end

function PANEL:CreateColumnHeader(parentPanel, headerText)
	local headerPanel = vgui.Create("EditablePanel", parentPanel)
	headerPanel:SetTall(40)
	headerPanel:Dock(TOP)
	headerPanel:DockMargin(0, 0, 0, 8)
	headerPanel.Paint = function(panel, width, height)
		draw.RoundedBox(4, 0, 0, width, height, PLUGIN.THEME.panel)

		surface.SetTextColor(PLUGIN.THEME.text)
		surface.SetFont("ixMediumFont")

		local textWidth, textHeight = surface.GetTextSize(headerText)
		surface.SetTextPos(15, height * 0.5 - textHeight * 0.5)
		surface.DrawText(headerText)
	end

	return headerPanel
end

function PANEL:CreateSelectedDesignPreview()
	-- Right canvas preview container
	self.contentPreviewParent = vgui.Create("expDualScrollPanel", self.contentPanel)
	self.contentPreviewParent:Dock(FILL)

	-- Right canvas preview panel
	self.contentPreviewPanel = vgui.Create("EditablePanel")
	self.contentPreviewParent:AddItem(self.contentPreviewPanel)
	self.contentPreviewPanel:Dock(TOP)
	self.contentPreviewPanel.Paint = function(panel, width, height)
		self:PaintSelectedDesignPreview(panel, width, height)
	end
end

function PANEL:PaintSelectedDesignPreview(panel, width, height)
	if (self.previewCanvas) then
		local canvasWidth, canvasHeight = self.previewCanvas:GetSize()
		local offsetX = (width - canvasWidth) * 0.5
		local offsetY = (height - canvasHeight) * 0.5

		self.previewCanvas:DrawCanvas(offsetX, offsetY, canvasWidth, canvasHeight)

		panel:SetSize(canvasWidth, canvasHeight)
		self.contentPreviewParent:InvalidateLayout()
	else
		-- Show message when no canvas is selected
		surface.SetTextColor(PLUGIN.THEME.textSecondary)
		surface.SetFont("ixMediumFont")

		local messageText = "Select a design to load"
		local textWidth, textHeight = surface.GetTextSize(messageText)

		surface.SetTextPos(width * 0.5 - textWidth * 0.5, height * 0.5 - textHeight * 0.5)
		surface.DrawText(messageText)

		panel:SetSize(width, 100)
	end
end

function PANEL:CreateBottomPanel()
	-- Bottom button panel
	self.bottomPanel = vgui.Create("EditablePanel", self.mainContainer)
	self.bottomPanel:SetTall(50)
	self.bottomPanel:Dock(BOTTOM)

	self:CreateLoadButton()
	self:CreateClearButton()
	self:CreateCancelButton()
end

function PANEL:CreateLoadButton()
	-- Load button
	self.loadButton = PLUGIN:CreateStyledButton(self.bottomPanel, "Load Design", PLUGIN.THEME.success)
	self.loadButton:SetSize(120, 30)
	self.loadButton:Dock(RIGHT)
	self.loadButton:DockMargin(0, 10, 15, 10)
	self.loadButton.DoClick = function()
		self:OnLoadButtonClicked()
	end
end

function PANEL:CreateClearButton()
	-- Clear button
	self.clearButton = PLUGIN:CreateStyledButton(self.bottomPanel, "Clear Design", PLUGIN.THEME.warning)
	self.clearButton:SetSize(120, 30)
	self.clearButton:Dock(RIGHT)
	self.clearButton:DockMargin(0, 10, 8, 10)
	self.clearButton.DoClick = function()
		self:OnClearButtonClicked()
	end
end

function PANEL:CreateCancelButton()
	-- Cancel button
	self.cancelButton = PLUGIN:CreateStyledButton(self.bottomPanel, "Cancel", PLUGIN.THEME.textSecondary)
	self.cancelButton:SetSize(100, 30)
	self.cancelButton:Dock(RIGHT)
	self.cancelButton:DockMargin(0, 10, 8, 10)
	self.cancelButton.DoClick = function()
		self:Close()
	end
end

function PANEL:RefreshCanvasList()
	if (not self.targetItem) then return end

	-- Get all canvas items from inventory that have designs
	local character = LocalPlayer():GetCharacter()
	local inventory = character:GetInventory()
	local canvasItems = {}

	for _, inventoryItem in pairs(inventory:GetItems()) do
		-- Look for canvas items with designs
		if (inventoryItem.uniqueID == PLUGIN.CANVAS_ITEM_ID) then
			local designData = inventoryItem:GetData("design")
			if (designData) then
				table.insert(canvasItems, inventoryItem)
			end
		end
	end

	self.canvasItems = canvasItems

	-- Clear and populate dropdown with canvas items
	self.canvasDropdown:Clear()
	for i, canvasItem in ipairs(canvasItems) do
		local designData = canvasItem:GetData("design", {})
		local displayName = designData.name or ("Canvas #" .. canvasItem:GetID())
		self.canvasDropdown:AddChoice(displayName, canvasItem)
	end

	-- Handle empty canvas list
	if (#canvasItems == 0) then
		self.canvasDropdown:SetEnabled(false)
		self.canvasDropdown:SetValue("No designed canvases found in inventory")
		self.loadButton:SetEnabled(false)
	end
end

function PANEL:OnCanvasSelected(selectedCanvasItem)
	self.selectedCanvasItem = selectedCanvasItem
	if (selectedCanvasItem) then
		self.previewCanvas = PLUGIN.CanvasDesigner:New(selectedCanvasItem)
	else
		self.previewCanvas = nil
	end
end

function PANEL:OnLoadButtonClicked()
	if (not self.selectedCanvasItem) then
		LocalPlayer():Notify("Please select a canvas design to load first!")
		return
	end

	local selectedDesign = self.selectedCanvasItem:GetData("design")
	if (not selectedDesign) then
		LocalPlayer():Notify("Selected canvas has no design!")
		return
	end

	self:ShowLoadConfirmation(selectedDesign)
end

function PANEL:OnClearButtonClicked()
	-- Clear the current design from the spray can
	local confirmationFrame = vgui.Create("expFrame")
	confirmationFrame:SetTitle("Confirm Clear")
	confirmationFrame:SetSize(400, 130)
	confirmationFrame:Center()
	confirmationFrame:MakePopup()
	confirmationFrame:SetDeleteOnClose(true)

	local confirmationContainer = vgui.Create("EditablePanel", confirmationFrame)
	confirmationContainer:Dock(FILL)
	confirmationContainer:DockMargin(15, 15, 15, 15)

	local confirmationLabel = vgui.Create("DLabel", confirmationContainer)
	confirmationLabel:SetText("This will remove the current design from your spray can.")
	confirmationLabel:SetTextColor(PLUGIN.THEME.text)
	confirmationLabel:SetFont("ixMediumFont")
	confirmationLabel:Dock(TOP)
	confirmationLabel:DockMargin(0, 0, 0, 15)

	local confirmationButtons = vgui.Create("EditablePanel", confirmationContainer)
	confirmationButtons:SetTall(30)
	confirmationButtons:Dock(BOTTOM)

	local confirmYesButton = PLUGIN:CreateStyledButton(confirmationButtons, "Yes, Clear", PLUGIN.THEME.warning)
	confirmYesButton:SetSize(100, 30)
	confirmYesButton:Dock(RIGHT)
	confirmYesButton:DockMargin(0, 0, 8, 0)
	confirmYesButton.DoClick = function()
		self:ExecuteClear()
		confirmationFrame:Close()
	end

	local confirmNoButton = PLUGIN:CreateStyledButton(confirmationButtons, "Cancel", PLUGIN.THEME.textSecondary)
	confirmNoButton:SetSize(100, 30)
	confirmNoButton:Dock(RIGHT)
	confirmNoButton:DockMargin(0, 0, 8, 0)
	confirmNoButton.DoClick = function()
		confirmationFrame:Close()
	end
end

function PANEL:ShowLoadConfirmation(selectedDesign)
	-- Confirmation dialog before overwriting
	local confirmationFrame = vgui.Create("expFrame")
	confirmationFrame:SetTitle("Confirm Load")
	confirmationFrame:SetSize(400, 150)
	confirmationFrame:Center()
	confirmationFrame:MakePopup()
	confirmationFrame:SetDeleteOnClose(true)

	local confirmationContainer = vgui.Create("EditablePanel", confirmationFrame)
	confirmationContainer:Dock(FILL)
	confirmationContainer:DockMargin(15, 15, 15, 15)

	local confirmationLabel = vgui.Create("DLabel", confirmationContainer)
	confirmationLabel:SetText("This will load the following design into your spray can:")
	confirmationLabel:SetTextColor(PLUGIN.THEME.text)
	confirmationLabel:SetFont("ixMediumFont")
	confirmationLabel:Dock(TOP)
	confirmationLabel:DockMargin(0, 0, 0, 5)

	local designNameLabel = vgui.Create("DLabel", confirmationContainer)
	designNameLabel:SetText('"' .. (selectedDesign.name or "Unnamed Design") .. '"')
	designNameLabel:SetTextColor(PLUGIN.THEME.textHighlight)
	designNameLabel:SetFont("ixMediumFont")
	designNameLabel:Dock(TOP)
	designNameLabel:DockMargin(0, 0, 0, 15)

	local confirmationButtons = vgui.Create("EditablePanel", confirmationContainer)
	confirmationButtons:SetTall(30)
	confirmationButtons:Dock(BOTTOM)

	local confirmYesButton = PLUGIN:CreateStyledButton(confirmationButtons, "Yes, Load", PLUGIN.THEME.success)
	confirmYesButton:SetSize(100, 30)
	confirmYesButton:Dock(RIGHT)
	confirmYesButton:DockMargin(0, 0, 8, 0)
	confirmYesButton.DoClick = function()
		self:ExecuteLoad(selectedDesign)
		confirmationFrame:Close()
	end

	local confirmNoButton = PLUGIN:CreateStyledButton(confirmationButtons, "Cancel", PLUGIN.THEME.textSecondary)
	confirmNoButton:SetSize(100, 30)
	confirmNoButton:Dock(RIGHT)
	confirmNoButton:DockMargin(0, 0, 8, 0)
	confirmNoButton.DoClick = function()
		confirmationFrame:Close()
	end
end

function PANEL:ExecuteLoad(selectedDesign)
	-- Send load request to server
	net.Start("expSprayCanLoadDesign")
	net.WriteUInt(self.targetItem:GetID(), 32)
	net.WriteUInt(selectedDesign.width, PLUGIN.CANVAS_WIDTH_BITS)
	net.WriteUInt(selectedDesign.height, PLUGIN.CANVAS_HEIGHT_BITS)
	net.WriteString(selectedDesign.name)
	net.WriteString(selectedDesign.data)
	net.SendToServer()

	self:Close()
end

function PANEL:ExecuteClear()
	-- Send clear request to server
	net.Start("expSprayCanClearDesign")
	net.WriteUInt(self.targetItem:GetID(), 32)
	net.SendToServer()

	self:Close()
end

vgui.Register("expSprayCanDesignSelector", PANEL, "expFrame")
