local PLUGIN = PLUGIN
local PANEL = {}

function PANEL:Init()
    Schema.businessPurchasePanel = self

	self:DockPadding(16, 16, 16, 16)

    self.itemIcon = self:Add("expBusinessItem")

    self.purchaseButton = self:Add("DButton")
    self.purchaseButton:SetText(L"completePurchase")
    self.purchaseButton:SetFont("ixBigFont")
	self.purchaseButton:SizeToContents()
    self.purchaseButton:SetTall(128)
	self.purchaseButton:Dock(BOTTOM)

    self.purchaseLabel = self:Add("DLabel")
    self.purchaseLabel:SetFont("ixMediumFont")
    self.purchaseLabel:SetText("")
    self.purchaseLabel:SetTextColor(color_white)
    self.purchaseLabel:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    self.purchaseLabel:SizeToContents()
    self.purchaseLabel:SetContentAlignment(5)

	self:SetItemVisible(false)
end

function PANEL:SetItemVisible(isVisible)
	self.itemIcon:SetVisible(isVisible)
	self.purchaseButton:SetVisible(isVisible)
	self.purchaseLabel:SetVisible(isVisible)
end

function PANEL:BuyItem(uniqueID)
    local itemTable = ix.item.Get(uniqueID)

    self.itemIcon:Clear()
    self.itemIcon:SetItem(itemTable)
    self.itemIcon.icon.OnMousePressed = function() end
    self.itemIcon.icon.OnMouseReleased = function() end

    self.purchaseButton.DoClick = function()
        local entity = ix.menu.panel:GetEntity()

        PLUGIN.lastPurchase = {
			entity = entity,
            itemTable = itemTable,
			purchasedAt = CurTime()
		}

        net.Start("expBusinessPurchase")
		net.WriteEntity(entity)
        net.WriteString(uniqueID)
		net.SendToServer()
    end

	self:SetItemVisible(true)

    self.purchaseLabel:SetText(L("confirmPurchase", ix.currency.Get(itemTable.price)))
    self.purchaseLabel:SizeToContents()
	self.purchaseLabel:SetWide(math.min(self.purchaseLabel:GetWide(), self:GetWide() - 32))

    self.itemIcon:Center()
	self.purchaseLabel:SetPos(self:GetWide() * 0.5 - self.purchaseLabel:GetWide() * 0.5,
		self.itemIcon.y - self.purchaseLabel:GetTall() - 16)
end

function PANEL:OnMouseReleased(key)
	if (key == MOUSE_LEFT) then
		ix.menu.panel:Remove()
	end
end

vgui.Register("expBusinessPurchase", PANEL, "EditablePanel")
