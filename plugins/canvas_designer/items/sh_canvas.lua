local PLUGIN = PLUGIN
local ITEM = ITEM

ITEM.name = "Design Canvas"
ITEM.price = 25
ITEM.shipmentSize = 10
ITEM.noBusiness = true -- Disabled for now
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Art"
ITEM.description =
"A blank canvas for creating custom logos and drawings. Use it to design artwork that can be shared with other players."

-- Canvas constants
local CANVAS_DEFAULT_WIDTH = 400
local CANVAS_DEFAULT_HEIGHT = 400
local CANVAS_MINIMUM_WIDTH = 100
local CANVAS_MINIMUM_HEIGHT = 100
local CANVAS_MAX_WIDTH = 800
local CANVAS_MAX_HEIGHT = 800

local CANVAS_WIDTH_BITS = 10  -- Max 1023
local CANVAS_HEIGHT_BITS = 10 -- Max 1023

local MAX_ELEMENTS = 10
local GRID_SIZE = 20

-- Spritesheet constants
local SPRITE_SIZE = 128

-- Available sprite types with their spritesheet positions and categories
local SPRITE_TYPES = {
	{ name = "Rectangle",   icon = { 0, 0 }, category = "shapes",  keywords = "square box rect" },
	{ name = "Circle",      icon = { 1, 0 }, category = "shapes",  keywords = "round ball" },
	{ name = "Triangle",    icon = { 2, 0 }, category = "shapes",  keywords = "tri point" },
	{ name = "Diamond",     icon = { 3, 0 }, category = "shapes",  keywords = "rhombus gem" },
	{ name = "Star",        icon = { 4, 0 }, category = "shapes",  keywords = "asterisk rating" },
	{ name = "Heart",       icon = { 5, 0 }, category = "shapes",  keywords = "love like" },
	{ name = "Arrow",       icon = { 0, 1 }, category = "arrows",  keywords = "direction right east" },
	{ name = "Chevron",     icon = { 1, 1 }, category = "arrows",  keywords = "direction right east" },
	{ name = "Cross",       icon = { 2, 1 }, category = "symbols", keywords = "x delete remove" },
	{ name = "Check",       icon = { 3, 1 }, category = "symbols", keywords = "tick yes confirm ok" },
	{ name = "Lightning",   icon = { 4, 1 }, category = "symbols", keywords = "zap electric shock" },
	{ name = "Question",    icon = { 5, 1 }, category = "symbols", keywords = "help unknown ask" },
	{ name = "Exclamation", icon = { 6, 1 }, category = "symbols", keywords = "alert warning caution" },

	-- Premium
	{ name = "Skull",       icon = { 0, 7 }, category = "colored", keywords = "death danger",         defaultColor = color_white, premiumKey = "sprites_colored" },
	{ name = "Nanobot",     icon = { 1, 7 }, category = "colored", keywords = "robot technology",     defaultColor = color_white, premiumKey = "sprites_colored" },
}

local SHAPE_CATEGORIES = { "all" }

for _, sprite in ipairs(SPRITE_TYPES) do
	if (not table.HasValue(SHAPE_CATEGORIES, sprite.category)) then
		table.insert(SHAPE_CATEGORIES, sprite.category)
	end
end

local SPRITES_BY_NAME = {}
for _, sprite in ipairs(SPRITE_TYPES) do
	SPRITES_BY_NAME[sprite.name] = sprite
end

-- Theme colors
local THEME = {
	background = Color(45, 45, 48),
	surface = Color(60, 60, 65),
	panel = Color(55, 55, 60),
	primary = Color(0, 122, 255),
	secondary = Color(88, 166, 255),
	success = Color(40, 167, 69),
	warning = Color(255, 193, 7),
	danger = Color(220, 53, 69),
	text = Color(240, 240, 240),
	textSecondary = Color(180, 180, 180),
	border = Color(80, 80, 85),
	hover = Color(70, 70, 75),
	underline = Color(255, 255, 255),
}

function ITEM:GetName()
	return self:GetData("design", {}).name or (CLIENT and L(self.name) or self.name)
end

if (SERVER) then
	util.AddNetworkString("expCanvasDesigner")
	util.AddNetworkString("expCanvasSave")
	util.AddNetworkString("expCanvasView")

	resource.AddFile("materials/experiment-redux/canvas_designer_spritesheet.png")

	net.Receive("expCanvasSave", function(length, client)
		local itemID = net.ReadUInt(32)
		local canvasWidth = net.ReadUInt(CANVAS_WIDTH_BITS)
		local canvasHeight = net.ReadUInt(CANVAS_HEIGHT_BITS)
		local name = net.ReadString()
		local jsonData = net.ReadString()
		local item = ix.item.instances[itemID]

		if (not item or item:GetOwner() ~= client) then
			client:Notify("You do not own this Canvas!")
			return
		end

		-- Validate JSON data
		local success, data = pcall(util.JSONToTable, jsonData)
		if (not success or not data) then
			client:Notify("Invalid canvas data!")
			return
		end

		-- Validate element count and structure
		if (#data > MAX_ELEMENTS) then
			client:Notify("Too many elements on canvas!")
			return
		end

		-- Validate canvas dimensions
		if (canvasWidth < CANVAS_MINIMUM_WIDTH or canvasWidth > CANVAS_MAX_WIDTH or
				canvasHeight < CANVAS_MINIMUM_HEIGHT or canvasHeight > CANVAS_MAX_HEIGHT) then
			client:Notify("Invalid canvas dimensions!")
			return
		end

		local premiumPackages = client:GetCharacterNetVar("premiumPackages", {})

		-- Basic validation of each element
		for _, element in ipairs(data) do
			if (type(element) ~= "table") or
				not element.type or
				not element.spriteX or
				not element.spriteY or
				not element.x or
				not element.y or
				not element.scaleX or
				not element.scaleY or
				not element.color then
				client:Notify("Invalid canvas element data!")
				return
			end

			-- Check if the sprite is premium and if the player has access
			local spriteType = SPRITES_BY_NAME[element.type]
			local isUnlocked = not spriteType.premiumKey or premiumPackages[spriteType.premiumKey]

			if (not isUnlocked) then
				client:Notify("You do not have access to the sprite: " .. element.type)
				return
			end
		end

		item:SetData("design", {
			width = canvasWidth,
			height = canvasHeight,
			data = jsonData,
			name = name,
		})
		client:Notify("Canvas design saved!")
	end)
elseif (CLIENT) then
	-- Cache the spritesheet material
	local spritesheetMat = Material("experiment-redux/canvas_designer_spritesheet.png")

	function ITEM:PopulateTooltip(tooltip)
		local designData = self:GetData("design")

		if (designData) then
			local panel = tooltip:AddRowAfter("name", "design_status")
			panel:SetBackgroundColor(THEME.success)
			panel:SetText("Contains Custom Design")
			panel:SizeToContents()
		else
			local panel = tooltip:AddRowAfter("name", "design_status")
			panel:SetBackgroundColor(THEME.warning)
			panel:SetText("Blank Canvas")
			panel:SizeToContents()
		end
	end

	-- Canvas designer class
	local CanvasDesigner = {}
	CanvasDesigner.__index = CanvasDesigner

	function CanvasDesigner:New(item)
		local obj = setmetatable({}, self)
		obj.item = item
		obj.elements = {}
		obj.selectedElement = nil
		obj.isDragging = false
		obj.dragStartX = 0
		obj.dragStartY = 0
		obj.elementStartX = 0
		obj.elementStartY = 0
		obj.canvasOffsetX = 0
		obj.canvasOffsetY = 0

		-- Load existing design
		local designData = item:GetData("design", {})

		obj.canvasWidth = designData.width or CANVAS_DEFAULT_WIDTH
		obj.canvasHeight = designData.height or CANVAS_DEFAULT_HEIGHT
		obj.name = designData.name or "Unnamed Canvas"

		if (designData) then
			obj:LoadDesign(designData.data)
		end

		return obj
	end

	function CanvasDesigner:GetSize()
		return self.canvasWidth, self.canvasHeight
	end

	function CanvasDesigner:LoadDesign(jsonData)
		local success, data = pcall(util.JSONToTable, jsonData)
		if success and data then
			self.elements = data
		else
			self.elements = {}
		end
	end

	function CanvasDesigner:SaveDesign()
		return util.TableToJSON(self.elements)
	end

	function CanvasDesigner:OnElementsChanged()
		-- This can be overridden to handle element changes
	end

	function CanvasDesigner:AddElement(spriteType, x, y)
		if (#self.elements >= MAX_ELEMENTS) then
			return false
		end

		local element = {
			id = os.time() .. math.random(1000, 9999),
			type = spriteType.name,
			spriteX = spriteType.icon[1],
			spriteY = spriteType.icon[2],
			x = x or 100,
			y = y or 100,
			scaleX = 1.0,
			scaleY = 1.0,
			rotation = 0,
			color = spriteType.defaultColor or { r = 0, g = 0, b = 0, a = 255 }
		}

		table.insert(self.elements, element)
		self:SelectElement(#self.elements)

		self:OnElementsChanged()

		return true
	end

	function CanvasDesigner:SelectElement(index)
		if (not index or index < 1 or index > #self.elements) then
			self.selectedElement = nil
		else
			self.selectedElement = index
		end

		self:OnElementsChanged()
	end

	function CanvasDesigner:GetSelectedElementIndex()
		return self.selectedElement
	end

	function CanvasDesigner:DeleteSelected()
		if (self.selectedElement and self.elements[self.selectedElement]) then
			table.remove(self.elements, self.selectedElement)
			self:SelectElement(nil)
		end
	end

	function CanvasDesigner:GetElementAt(x, y)
		for i = #self.elements, 1, -1 do
			local element = self.elements[i]
			local sizeX = SPRITE_SIZE * element.scaleX
			local sizeY = SPRITE_SIZE * element.scaleY
			local halfSizeX = sizeX * .5
			local halfSizeY = sizeY * .5

			if (x >= element.x - halfSizeX and x <= element.x + halfSizeX and
					y >= element.y - halfSizeY and y <= element.y + halfSizeY) then
				return i
			end
		end

		return nil
	end

	function CanvasDesigner:DrawGrid(x, y, w, h)
		surface.SetDrawColor(THEME.border.r, THEME.border.g, THEME.border.b, 50)

		for i = 0, w, GRID_SIZE do
			surface.DrawLine(x + i, y, x + i, y + h)
		end

		for i = 0, h, GRID_SIZE do
			surface.DrawLine(x, y + i, x + w, y + i)
		end
	end

	function CanvasDesigner:DrawCanvas(x, y, w, h, withoutGrid)
		-- Draw background
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(x, y, w, h)

		if (not withoutGrid) then
			-- Draw grid
			self:DrawGrid(x, y, w, h)
		end

		-- Draw elements
		for i, element in ipairs(self.elements) do
			local drawX = x + element.x - (SPRITE_SIZE * element.scaleX) * .5
			local drawY = y + element.y - (SPRITE_SIZE * element.scaleY) * .5
			local sizeX = SPRITE_SIZE * element.scaleX
			local sizeY = SPRITE_SIZE * element.scaleY

			surface.SetDrawColor(element.color.r, element.color.g, element.color.b, element.color.a)
			surface.SetMaterial(spritesheetMat)

			Schema.draw.DrawSpritesheetMaterial(
				spritesheetMat,
				drawX, drawY,
				sizeX, sizeY,
				element.spriteX, element.spriteY,
				SPRITE_SIZE, SPRITE_SIZE,
				false,
				element.rotation
			)

			-- Draw selection outline
			if (self:GetSelectedElementIndex() == i) then
				surface.SetDrawColor(THEME.primary.r, THEME.primary.g, THEME.primary.b, 255)
				surface.DrawOutlinedRect(drawX - 3, drawY - 3, sizeX + 6, sizeY + 6, 2)
			end
		end
	end

	local function CreateStyledButton(parent, text, color)
		local btn = vgui.Create("DButton", parent)
		btn:SetText("")
		btn.Paint = function(self, w, h)
			local bgColor = color or THEME.primary
			if self:IsHovered() then
				bgColor = Color(math.min(bgColor.r + 20, 255), math.min(bgColor.g + 20, 255),
					math.min(bgColor.b + 20, 255))
			end
			if self:IsDown() then
				bgColor = Color(math.max(bgColor.r - 20, 0), math.max(bgColor.g - 20, 0), math.max(bgColor.b - 20, 0))
			end

			draw.RoundedBox(4, 0, 0, w, h, bgColor)

			surface.SetTextColor(255, 255, 255, 255)
			surface.SetFont("ixSmallBoldFont")
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w * .5 - tw * .5, h * .5 - th * .5)
			surface.DrawText(text)
		end
		return btn
	end

	local function openCanvasDesigner(item)
		local frame = vgui.Create("expFrame")
		frame:SetTitle("Canvas Designer - " .. item:GetName())
		frame:SetSize(1000, 800)
		frame:Center()
		frame:MakePopup()
		frame:SetDeleteOnClose(true)

		local canvas = CanvasDesigner:New(item)

		-- Main container
		local container = vgui.Create("EditablePanel", frame)
		container:Dock(FILL)
		container:DockMargin(8, 8, 8, 8)

		-- Top toolbar
		local topbar = vgui.Create("EditablePanel", container)
		topbar:SetTall(50)
		topbar:Dock(TOP)
		topbar:DockMargin(0, 0, 0, 8)

		-- Element count
		local countLabel = vgui.Create("DLabel", topbar)
		countLabel:SetText("Elements: 0/" .. MAX_ELEMENTS)
		countLabel:SetTextColor(THEME.text)
		countLabel:SetFont("ixSmallBoldFont")
		countLabel:Dock(LEFT)
		countLabel:DockMargin(15, 0, 0, 0)
		countLabel:SizeToContents()

		local function updateElementCount()
			local count = #canvas.elements
			countLabel:SetText("Elements: " .. count .. "/" .. MAX_ELEMENTS)
			countLabel:SetTextColor(count >= MAX_ELEMENTS and THEME.danger or THEME.success)
			countLabel:SizeToContents()
		end

		-- Delete button
		local deleteBtn = CreateStyledButton(topbar, "Delete Selected", THEME.danger)
		deleteBtn:SetSize(120, 30)
		deleteBtn:Dock(RIGHT)
		deleteBtn:DockMargin(0, 10, 15, 10)
		deleteBtn.DoClick = function()
			if (canvas:GetSelectedElementIndex()) then
				canvas:DeleteSelected()
				updateElementCount()
			end
		end

		-- Clear all button
		local clearBtn = CreateStyledButton(topbar, "Clear All", THEME.warning)
		clearBtn:SetSize(100, 30)
		clearBtn:Dock(RIGHT)
		clearBtn:DockMargin(0, 10, 8, 10)
		clearBtn.DoClick = function()
			if #canvas.elements > 0 then
				Derma_Query("Are you sure you want to clear the entire canvas?", "Clear Canvas", "Yes", function()
					canvas.elements = {}
					canvas:SelectElement(nil)
				end, "No")
			end
		end

		-- When DELETE is pressed, clear the selected element
		function frame:OnKeyCodePressed(keyCode)
			if (keyCode == KEY_DELETE and canvas:GetSelectedElementIndex()) then
				canvas:DeleteSelected()
				updateElementCount()
			end
		end

		-- Side panel for elements list and properties
		local sidePanel = vgui.Create("EditablePanel", container)
		sidePanel:SetWide(350)
		sidePanel:Dock(RIGHT)
		sidePanel:DockMargin(8, 0, 0, 0)

		sidePanel.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, THEME.panel)
		end

		-- Elements list
		local elementsList = vgui.Create("DTree", sidePanel)
		elementsList:Dock(TOP)
		elementsList:SetTall(100)
		elementsList:DockMargin(10, 10, 10, 0)
		elementsList.OnMouseReleased = function(node)
			-- Deselect if we click outside any ndoe
			canvas:SelectElement(nil)
		end

		CanvasDesigner.OnElementsChanged = function()
			elementsList:Clear()

			for i, element in ipairs(canvas.elements) do
				local node = elementsList:AddNode(element.type .. " #" .. i)
				node:SetIcon("icon16/application_view_list.png")
				node:SetExpanded(false)

				if (canvas:GetSelectedElementIndex() == i) then
					node:SetSelected(true)
				end

				node.DoClick = function()
					canvas:SelectElement(i)
				end
			end

			updateElementCount()
		end
		CanvasDesigner:OnElementsChanged()

		-- Properties panel
		local propPanel = vgui.Create("DScrollPanel", sidePanel)
		propPanel:Dock(FILL)

		local propTitle = propPanel:Add("DLabel")
		propTitle:SetText("Properties")
		propTitle:SetTextColor(THEME.text)
		propTitle:SetFont("ixBigFont")
		propTitle:Dock(TOP)
		propTitle:DockMargin(15, 15, 15, 10)
		propTitle:SizeToContents()

		local canvasPropTitle = propPanel:Add("DLabel")
		canvasPropTitle:SetText("Canvas Properties")
		canvasPropTitle:SetTextColor(THEME.text)
		canvasPropTitle:SetFont("ixMediumFont")
		canvasPropTitle:Dock(TOP)
		canvasPropTitle:DockMargin(15, 15, 15, 10)
		canvasPropTitle:SizeToContents()

		-- Name control
		local nameContainer = propPanel:Add("EditablePanel")
		nameContainer:Dock(TOP)
		nameContainer:SetTall(28)

		local nameLabel = vgui.Create("DLabel", nameContainer)
		nameLabel:SetText("Canvas Name")
		nameLabel:SetTextColor(THEME.text)
		nameLabel:SetFont("ixSmallBoldFont")
		nameLabel:Dock(LEFT)
		nameLabel:DockMargin(10, 10, 10, 5)
		nameLabel:SizeToContents()

		local nameEntry = vgui.Create("DTextEntry", nameContainer)
		nameEntry:Dock(FILL)
		nameEntry:DockMargin(10, 10, 10, 0)
		nameEntry:SetValue(canvas.name)
		nameEntry.OnChange = function(self)
			local newName = self:GetValue()

			if (newName and newName ~= "") then
				canvas.name = newName
			else
				self:SetValue(canvas.name)
			end
		end

		-- Canvas size control
		local canvasWidthContainer = propPanel:Add("EditablePanel")
		canvasWidthContainer:Dock(TOP)
		canvasWidthContainer:SetTall(28)

		local canvasWidthLabel = vgui.Create("DLabel", canvasWidthContainer)
		canvasWidthLabel:SetText("Canvas Width")
		canvasWidthLabel:SetTextColor(THEME.text)
		canvasWidthLabel:SetFont("ixSmallBoldFont")
		canvasWidthLabel:Dock(LEFT)
		canvasWidthLabel:DockMargin(10, 10, 10, 5)
		canvasWidthLabel:SizeToContents()

		local canvasWidthEntry = vgui.Create("DTextEntry", canvasWidthContainer)
		canvasWidthEntry:Dock(FILL)
		canvasWidthEntry:DockMargin(10, 10, 10, 0)
		canvasWidthEntry:SetNumeric(true)
		canvasWidthEntry:SetValue(tostring(canvas.canvasWidth))
		canvasWidthEntry.OnChange = function(self)
			local newWidth = tonumber(self:GetValue())

			if (newWidth and newWidth > CANVAS_MINIMUM_WIDTH and newWidth <= CANVAS_MAX_WIDTH) then
				canvas.canvasWidth = newWidth
				canvasWidthEntry:SetValue(tostring(newWidth))
			else
				self:SetValue(tostring(canvas.canvasWidth))
			end
		end

		canvasWidthContainer:InvalidateLayout(true)

		local canvasHeightContainer = propPanel:Add("EditablePanel")
		canvasHeightContainer:Dock(TOP)
		canvasHeightContainer:SetTall(28)

		local canvasHeightLabel = vgui.Create("DLabel", canvasHeightContainer)
		canvasHeightLabel:SetText("Canvas Height")
		canvasHeightLabel:SetTextColor(THEME.text)
		canvasHeightLabel:SetFont("ixSmallBoldFont")
		canvasHeightLabel:Dock(LEFT)
		canvasHeightLabel:DockMargin(10, 10, 10, 5)
		canvasHeightLabel:SizeToContents()

		local canvasHeightEntry = vgui.Create("DTextEntry", canvasHeightContainer)
		canvasHeightEntry:Dock(FILL)
		canvasHeightEntry:DockMargin(10, 10, 10, 0)
		canvasHeightEntry:SetNumeric(true)
		canvasHeightEntry:SetValue(tostring(canvas.canvasHeight))
		canvasHeightEntry.OnChange = function(self)
			local newHeight = tonumber(self:GetValue())

			if (newHeight and newHeight > CANVAS_MINIMUM_HEIGHT and newHeight <= CANVAS_MAX_HEIGHT) then
				canvas.canvasHeight = newHeight
				canvasHeightEntry:SetValue(tostring(newHeight))
			else
				self:SetValue(tostring(canvas.canvasHeight))
			end
		end

		canvasHeightContainer:InvalidateLayout(true)

		local selectedPropTitle = propPanel:Add("DLabel")
		selectedPropTitle:SetText("Selected Element Properties")
		selectedPropTitle:SetTextColor(THEME.text)
		selectedPropTitle:SetFont("ixMediumFont")
		selectedPropTitle:Dock(TOP)
		selectedPropTitle:DockMargin(15, 15, 15, 10)
		selectedPropTitle:SizeToContents()

		-- Scale control
		local scaleContainer = propPanel:Add("EditablePanel")
		scaleContainer:SetTall(160)
		scaleContainer:Dock(TOP)
		scaleContainer:DockMargin(10, 5, 10, 8)

		local scaleXLabel = vgui.Create("DLabel", scaleContainer)
		scaleXLabel:SetText("Scale X")
		scaleXLabel:SetTextColor(THEME.text)
		scaleXLabel:SetFont("ixSmallBoldFont")
		scaleXLabel:Dock(TOP)
		scaleXLabel:DockMargin(10, 10, 10, 5)
		scaleXLabel:SizeToContents()

		local scaleXSlider = vgui.Create("DNumSlider", scaleContainer)
		scaleXSlider:Dock(TOP)
		scaleXSlider:DockMargin(10, 0, 10, 10)
		scaleXSlider:SetSize(180, 20)
		scaleXSlider:SetMin(0.1)
		scaleXSlider:SetMax(15.0)
		scaleXSlider:SetDecimals(1)
		scaleXSlider:SetValue(1.0)
		scaleXSlider.OnValueChanged = function(self, value)
			if (canvas:GetSelectedElementIndex() and canvas.elements[canvas:GetSelectedElementIndex()]) then
				canvas.elements[canvas:GetSelectedElementIndex()].scaleX = value
			end
		end
		scaleXSlider.Label:SetVisible(false)

		local scaleYLabel = vgui.Create("DLabel", scaleContainer)
		scaleYLabel:SetText("Scale Y")
		scaleYLabel:SetTextColor(THEME.text)
		scaleYLabel:SetFont("ixSmallBoldFont")
		scaleYLabel:Dock(TOP)
		scaleYLabel:DockMargin(10, 10, 10, 5)
		scaleYLabel:SizeToContents()

		local scaleYSlider = vgui.Create("DNumSlider", scaleContainer)
		scaleYSlider:Dock(TOP)
		scaleYSlider:DockMargin(10, 0, 10, 10)
		scaleYSlider:SetSize(180, 20)
		scaleYSlider:SetMin(0.1)
		scaleYSlider:SetMax(15.0)
		scaleYSlider:SetDecimals(1)
		scaleYSlider:SetValue(1.0)
		scaleYSlider.OnValueChanged = function(self, value)
			if (canvas:GetSelectedElementIndex() and canvas.elements[canvas:GetSelectedElementIndex()]) then
				canvas.elements[canvas:GetSelectedElementIndex()].scaleY = value
			end
		end
		scaleYSlider.Label:SetVisible(false)

		-- Rotation control
		local rotationContainer = propPanel:Add("EditablePanel")
		rotationContainer:SetTall(100)
		rotationContainer:Dock(TOP)
		rotationContainer:DockMargin(10, 0, 10, 8)

		local rotationLabel = vgui.Create("DLabel", rotationContainer)
		rotationLabel:SetText("Rotation")
		rotationLabel:SetTextColor(THEME.text)
		rotationLabel:SetFont("ixSmallBoldFont")
		rotationLabel:Dock(TOP)
		rotationLabel:DockMargin(10, 10, 10, 5)
		rotationLabel:SizeToContents()

		local rotationSlider = vgui.Create("DNumSlider", rotationContainer)
		rotationSlider:Dock(TOP)
		rotationSlider:DockMargin(10, 0, 10, 10)
		rotationSlider:SetSize(180, 20)
		rotationSlider:SetMin(0)
		rotationSlider:SetMax(360)
		rotationSlider:SetDecimals(0)
		rotationSlider:SetValue(0)
		rotationSlider.OnValueChanged = function(self, value)
			if (canvas:GetSelectedElementIndex() and canvas.elements[canvas:GetSelectedElementIndex()]) then
				canvas.elements[canvas:GetSelectedElementIndex()].rotation = value
			end
		end
		rotationSlider.Label:SetVisible(false)

		-- Color control
		local colorContainer = propPanel:Add("EditablePanel")
		colorContainer:SetTall(200)
		colorContainer:Dock(TOP)
		colorContainer:DockMargin(10, 0, 10, 8)

		local colorLabel = vgui.Create("DLabel", colorContainer)
		colorLabel:SetText("Color")
		colorLabel:SetTextColor(THEME.text)
		colorLabel:SetFont("ixSmallBoldFont")
		colorLabel:Dock(TOP)
		colorLabel:DockMargin(10, 10, 10, 5)
		colorLabel:SizeToContents()

		local colorMixer = vgui.Create("DColorMixer", colorContainer)
		colorMixer:Dock(TOP)
		colorMixer:DockMargin(10, 0, 10, 10)
		colorMixer:SetPalette(false)
		colorMixer:SetAlphaBar(true)
		colorMixer:SetWangs(true)
		colorMixer:SetColor(Color(255, 255, 255, 255))
		colorMixer.ValueChanged = function(self, color)
			if (canvas:GetSelectedElementIndex() and canvas.elements[canvas:GetSelectedElementIndex()]) then
				local element = canvas.elements[canvas:GetSelectedElementIndex()]
				element.color = { r = color.r, g = color.g, b = color.b, a = color.a }
			end
		end

		-- Canvas panel and parent
		local canvasPanelParent = vgui.Create("expDualScrollPanel", container)
		canvasPanelParent:Dock(FILL)

		local canvasPanel = vgui.Create("EditablePanel")
		canvasPanelParent:AddItem(canvasPanel)
		canvasPanel:Dock(TOP)
		canvasPanel:DockMargin(0, 0, 0, 8)
		canvasPanel.Paint = function(self, w, h)
			local canvasWidth, canvasHeight = canvas:GetSize()

			canvas.canvasOffsetX = (w - canvasWidth) * .5
			canvas.canvasOffsetY = (h - canvasHeight) * .5

			canvas:DrawCanvas(canvas.canvasOffsetX, canvas.canvasOffsetY, canvasWidth, canvasHeight)

			self:SetSize(canvasWidth, canvasHeight)
		end

		-- Asset Browser
		local assetBrowser = vgui.Create("EditablePanel", container)
		assetBrowser:SetTall(200)
		assetBrowser:Dock(BOTTOM)

		-- Search header
		local searchHeader = vgui.Create("EditablePanel", assetBrowser)
		searchHeader:SetTall(40)
		searchHeader:Dock(TOP)

		local searchLabel = vgui.Create("DLabel", searchHeader)
		searchLabel:SetText("Asset Browser")
		searchLabel:SetTextColor(THEME.text)
		searchLabel:SetFont("ixSmallBoldFont")
		searchLabel:Dock(LEFT)
		searchLabel:DockMargin(15, 0, 15, 0)
		searchLabel:SizeToContents()

		local searchBox = vgui.Create("DTextEntry", searchHeader)
		searchBox:SetPlaceholderText("Search assets...")
		searchBox:Dock(FILL)
		searchBox:DockMargin(0, 8, 15, 8)

		-- Category tabs
		local categoryTabs = vgui.Create("DPropertySheet", assetBrowser)
		categoryTabs:Dock(FILL)
		categoryTabs:DockMargin(8, 0, 8, 8)

		categoryTabs.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
		end

		-- Create asset grid function
		local function createAssetGrid(parent, filterCategory, searchTerm)
			local scrollPanel = vgui.Create("DScrollPanel", parent)
			scrollPanel:Dock(FILL)

			local iconLayout = vgui.Create("DIconLayout", scrollPanel)
			iconLayout:Dock(TOP)
			iconLayout:SetSpaceY(8)
			iconLayout:SetSpaceX(8)
			iconLayout:DockMargin(8, 8, 8, 8)

			local premiumPackages = LocalPlayer():GetCharacterNetVar("premiumPackages", {})

			for _, spriteType in ipairs(SPRITE_TYPES) do
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
				assetBtn.Paint = function(self, w, h)
					local bgColor = THEME.panel

					if (self:IsHovered()) then
						bgColor = THEME.hover
					end

					draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(bgColor, isUnlocked and 255 or 100))

					-- Draw sprite
					surface.SetDrawColor(255, 255, 255, isUnlocked and 255 or 100)
					surface.SetMaterial(spritesheetMat)

					local iconSize = 40
					local iconX = w * .5 - iconSize * .5
					local iconY = 8

					Schema.draw.DrawSpritesheetMaterial(
						spritesheetMat,
						iconX, iconY,
						iconSize, iconSize,
						spriteType.icon[1], spriteType.icon[2],
						SPRITE_SIZE, SPRITE_SIZE,
						false
					)

					-- Draw name
					surface.SetTextColor(THEME.text.r, THEME.text.g, THEME.text.b, 255)
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

					surface.SetTextPos(w * .5 - tw * .5, h - th - 4)
					surface.DrawText(text)

					-- If the sprite is premium and we don't have that key in premiumPackages, draw a lock icon
					if (not isUnlocked) then
						surface.SetDrawColor(255, 255, 255, 200)
						surface.SetMaterial(Material("icon16/lock.png"))
						surface.DrawTexturedRect(w - 20, h - 20, 16, 16)
					end
				end

				assetBtn.OnMousePressed = function(self, keyCode)
					if (not isUnlocked) then
						Derma_Query(
							"You do not have access to this premium asset.\nSupport us by purchasing it from our store!",
							"Premium Asset",
							"OK",
							function() end
						)
						return
					end

					if (keyCode == MOUSE_LEFT) then
						local canvasWidth, canvasHeight = canvas:GetSize()

						if (canvas:AddElement(spriteType, canvasWidth * .5, canvasHeight * .5)) then
							updateElementCount()
						else
							LocalPlayer():Notify("Maximum elements reached!")
						end
					end
				end
			end

			return iconLayout
		end

		local categoryPanels = {}

		-- Create tabs for each category
		for _, category in ipairs(SHAPE_CATEGORIES) do
			local panel = vgui.Create("EditablePanel")

			local grid = createAssetGrid(panel, category, "")
			categoryPanels[category] = { panel = panel, grid = grid }

			local sheet = categoryTabs:AddSheet(string.upper(category), panel, "icon16/folder.png")
			sheet.Tab.Paint = function(self, w, h)
				local bgColor = THEME.panel

				if (self:IsHovered() or self:IsActive()) then
					bgColor = THEME.primary
				end

				draw.RoundedBox(4, 0, 0, w, h, bgColor)

				if (self:IsActive()) then
					draw.RoundedBox(4, 4, h - 6, w - 8, 2, THEME.underline)
				end
			end
		end

		-- Search functionality
		searchBox.OnChange = function(self)
			local searchTerm = self:GetValue()
			for category, data in pairs(categoryPanels) do
				-- Clear the entire panel and recreate everything
				data.panel:Clear()
				data.grid = createAssetGrid(data.panel, category, searchTerm)
				categoryPanels[category].grid = data.grid
			end
		end

		-- Mouse handling for canvas
		canvasPanel.OnMousePressed = function(self, keyCode)
			if (keyCode == MOUSE_LEFT) then
				local mx, my = self:CursorPos()
				local canvasX = mx - canvas.canvasOffsetX
				local canvasY = my - canvas.canvasOffsetY
				local canvasWidth, canvasHeight = canvas:GetSize()

				if (canvasX >= 0 and canvasX <= canvasWidth and canvasY >= 0 and canvasY <= canvasHeight) then
					local elementIndex = canvas:GetElementAt(canvasX, canvasY)

					if (elementIndex) then
						canvas:SelectElement(elementIndex)
						canvas.isDragging = true
						canvas.dragStartX = mx
						canvas.dragStartY = my
						canvas.elementStartX = canvas.elements[elementIndex].x
						canvas.elementStartY = canvas.elements[elementIndex].y

						-- Update property controls
						local element = canvas.elements[elementIndex]
						scaleXSlider:SetValue(element.scaleX)
						scaleYSlider:SetValue(element.scaleY)
						rotationSlider:SetValue(element.rotation)
						colorMixer:SetColor(Color(element.color.r, element.color.g, element.color.b, element.color.a))
					else
						canvas:SelectElement(nil)
					end
				end
			end
		end

		canvasPanel.OnMouseReleased = function(self, keyCode)
			if (keyCode == MOUSE_LEFT) then
				canvas.isDragging = false
			end
		end

		local lastThink = 0
		canvasPanel.Think = function(self)
			if (CurTime() - lastThink < 0.01) then
				return
			end

			lastThink = CurTime()

			if (canvas.isDragging and canvas:GetSelectedElementIndex()) then
				local mx, my = self:CursorPos()
				local deltaX = mx - canvas.dragStartX
				local deltaY = my - canvas.dragStartY

				local element = canvas.elements[canvas:GetSelectedElementIndex()]
				local canvasWidth, canvasHeight = canvas:GetSize()

				element.x = math.Clamp(canvas.elementStartX + deltaX, 0, canvasWidth)
				element.y = math.Clamp(canvas.elementStartY + deltaY, 0, canvasHeight)
			end
		end

		-- Bottom action buttons
		local bottomPanel = vgui.Create("EditablePanel", frame)
		bottomPanel:SetTall(50)
		bottomPanel:Dock(BOTTOM)
		bottomPanel:DockMargin(8, 0, 8, 8)

		local saveButton = CreateStyledButton(bottomPanel, "Save Design", THEME.success)
		saveButton:SetSize(120, 30)
		saveButton:Dock(RIGHT)
		saveButton:DockMargin(0, 10, 15, 10)
		saveButton.DoClick = function()
			local canvasWidth, canvasHeight = canvas:GetSize()
			local jsonData = canvas:SaveDesign()
			net.Start("expCanvasSave")
			net.WriteUInt(item:GetID(), 32)
			net.WriteUInt(canvasWidth, CANVAS_WIDTH_BITS)
			net.WriteUInt(canvasHeight, CANVAS_HEIGHT_BITS)
			net.WriteString(canvas.name)
			net.WriteString(jsonData)
			net.SendToServer()
		end

		local cancelButton = CreateStyledButton(bottomPanel, "Cancel", THEME.textSecondary)
		cancelButton:SetSize(100, 30)
		cancelButton:Dock(RIGHT)
		cancelButton:DockMargin(0, 10, 8, 10)
		cancelButton.DoClick = function()
			frame:Close()
		end

		updateElementCount()
	end

	local function ViewCanvasDesign(item)
		local designData = item:GetData("design")

		if (not designData) then
			LocalPlayer():Notify("This canvas is blank!")
			return
		end

		local frame = vgui.Create("expFrame")
		frame:SetTitle("Viewing Canvas - " .. item:GetName())
		frame:SetSize(500, 400)
		frame:Center()
		frame:MakePopup()
		frame:SetDeleteOnClose(true)

		local canvas = CanvasDesigner:New(item)

		local viewerPanelParent = vgui.Create("expDualScrollPanel", frame)
		viewerPanelParent:Dock(FILL)

		local viewerPanel = vgui.Create("EditablePanel")
		viewerPanelParent:AddItem(viewerPanel)
		viewerPanel:Dock(TOP)
		viewerPanel:DockMargin(8, 8, 8, 8)
		viewerPanel.Paint = function(self, w, h)
			local canvasWidth, canvasHeight = canvas:GetSize()
			local offsetX = (w - canvasWidth) * .5
			local offsetY = (h - canvasHeight) * .5

			canvas:DrawCanvas(offsetX, offsetY, canvasWidth, canvasHeight, true)

			self:SetSize(canvasWidth, canvasHeight)
		end
	end

	net.Receive("expCanvasDesigner", function()
		local itemID = net.ReadUInt(32)
		local item = ix.item.instances[itemID]

		if (item) then
			if (IsValid(ix.gui.menu)) then
				ix.gui.menu:Remove()
			end

			openCanvasDesigner(item)
		end
	end)

	net.Receive("expCanvasView", function()
		local itemID = net.ReadUInt(32)
		local item = ix.item.instances[itemID]

		if (item) then
			if (IsValid(ix.gui.menu)) then
				ix.gui.menu:Remove()
			end

			ViewCanvasDesign(item)
		end
	end)
end

ITEM.functions.Design = {
	name = "Design Canvas",
	tip = "Open the canvas designer to create artwork.",
	icon = "icon16/palette.png",
	OnRun = function(item)
		if (SERVER) then
			net.Start("expCanvasDesigner")
			net.WriteUInt(item:GetID(), 32)
			net.Send(item.player)
		end

		-- Don't lose item
		return false
	end,
	OnCanRun = function(item)
		return item.player:GetCharacter() and item.invID == item.player:GetCharacter():GetInventory():GetID()
	end
}

ITEM.functions.View = {
	name = "View Design",
	tip = "View the artwork on this canvas.",
	icon = "icon16/zoom.png",
	OnRun = function(item)
		if (SERVER) then
			net.Start("expCanvasView")
			net.WriteUInt(item:GetID(), 32)
			net.Send(item.player)
		end

		-- Don't lose item
		return false
	end,
	OnCanRun = function(item)
		local designData = item:GetData("design")
		return designData
	end
}
