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
    BaseClass.PerformLayout(self)

    self.btnClose:SetSize(32, 32)
    self.btnClose:SetPos(self:GetWide() - 28, -4)
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
