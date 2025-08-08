local PLUGIN = PLUGIN
local PANEL = {}

AccessorFunc(PANEL, "canvasItem", "CanvasItem")
AccessorFunc(PANEL, "canvasDesigner", "CanvasDesigner")

function PANEL:Init()
	self:SetTitle("Canvas Viewer")
	self:SetSize(500, 400)
	self:Center()
	self:MakePopup()
	self:SetDeleteOnClose(true)

	self:CreateCanvasViewerPanel()
end

function PANEL:SetCanvasItem(canvasItem)
	self.canvasItem = canvasItem

	self:SetTitle("Viewing Canvas - " .. canvasItem:GetName())
	self.canvasDesigner = PLUGIN.CanvasDesigner:New(canvasItem)

	self:UpdateCanvasDisplay()
end

function PANEL:CreateCanvasViewerPanel()
	self.canvasScrollPanel = vgui.Create("expDualScrollPanel", self)
	self.canvasScrollPanel:Dock(FILL)

	self.canvasViewerPanel = vgui.Create("EditablePanel")
	self.canvasScrollPanel:AddItem(self.canvasViewerPanel)
	self.canvasViewerPanel:Dock(TOP)
	self.canvasViewerPanel:DockMargin(8, 8, 8, 8)

	self.canvasViewerPanel.Paint = function(viewerPanel, panelWidth, panelHeight)
		self:PaintCanvasViewer(viewerPanel, panelWidth, panelHeight)
	end
end

function PANEL:PaintCanvasViewer(viewerPanel, panelWidth, panelHeight)
	local canvasWidth, canvasHeight = self.canvasDesigner:GetSize()
	local canvasOffsetX = (panelWidth - canvasWidth) * 0.5
	local canvasOffsetY = (panelHeight - canvasHeight) * 0.5

	self.canvasDesigner:DrawCanvas(canvasOffsetX, canvasOffsetY, canvasWidth, canvasHeight, true)

	viewerPanel:SetSize(canvasWidth, canvasHeight)
	self.canvasScrollPanel:InvalidateLayout()
end

function PANEL:UpdateCanvasDisplay()
	if (IsValid(self.canvasViewerPanel)) then
		self.canvasViewerPanel:InvalidateLayout(true)
	end
end

function PANEL:ValidateCanvasData()
	if (not self.canvasItem) then
		return false
	end

	local designData = self.canvasItem:GetData("design")

	if (not designData) then
		LocalPlayer():Notify("This canvas is blank!")
		return false
	end

	return true
end

vgui.Register("expCanvasViewer", PANEL, "expFrame")
