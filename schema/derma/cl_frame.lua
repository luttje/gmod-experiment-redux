local PANEL = {}

DEFINE_BASECLASS("DFrame")

function PANEL:Init()
	self.lblTitle:SetFont("expSmallerFont")
	self.lblTitle:SetTextColor(color_white)

	if (IsValid(self.btnClose)) then
		self.btnClose:Remove()
	end

	self.btnClose = self:Add("expCloseButton")
	self.btnClose:SetPaintedManually(true)
	self.btnClose.DoClick = function(button)
		self:Close()
	end
end

function PANEL:PerformLayout()
	local titlePush = 0

	if (IsValid(self.imgIcon)) then
		self.imgIcon:SetPos(5, 5)
		self.imgIcon:SetSize(16, 16)
		titlePush = 16
	end

	self.btnClose:SetSize(32, 32)
	self.btnClose:SetPos(self:GetWide() - 28, -4)

	self.btnMaxim:SetPos(self:GetWide() - 31 * 2 - 4, 0)
	self.btnMaxim:SetSize(31, 24)

	self.btnMinim:SetPos(self:GetWide() - 31 * 3 - 4, 0)
	self.btnMinim:SetSize(31, 24)

	self.lblTitle:SetPos(8 + titlePush, 2)
	self.lblTitle:SetSize(self:GetWide() - 25 - titlePush, 20)
end

function PANEL:Paint(width, height)
	BaseClass.Paint(self, width, height)

	DisableClipping(true)
	self.btnClose:PaintManual()
	DisableClipping(false)
end

vgui.Register("expFrame", PANEL, "DFrame")

PANEL = {}

function PANEL:Init()
	self:SetSize(48, 48)
	self:SetIcon("experiment-redux/close.png")
end

vgui.Register("expCloseButton", PANEL, "DImageButton")
