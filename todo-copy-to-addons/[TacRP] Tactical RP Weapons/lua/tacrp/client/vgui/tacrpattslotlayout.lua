local PANEL = {}
AccessorFunc(PANEL, "ActiveSlot", "ActiveSlot")
AccessorFunc(PANEL, "Weapon", "Weapon")
AccessorFunc(PANEL, "Scroll", "Scroll")

function PANEL:LoadAttachments()
    self:Clear()

    if (self:GetActiveSlot() or 0) <= 0 then
        if self:GetScroll() then self:GetScroll():SetVisible(false) end
        return
    end

    local attslot = self:GetWeapon().Attachments[self:GetActiveSlot()]
    local atts = TacRP.GetAttsForCats(attslot.Category or "")

    table.sort(atts, function(a, b)
        a = a or ""
        b = b or ""

        if a == "" or b == "" then return true end

        local atttbl_a = TacRP.GetAttTable(a)
        local atttbl_b = TacRP.GetAttTable(b)

        local order_a = 0
        local order_b = 0

        order_a = atttbl_a.SortOrder or order_a
        order_b = atttbl_b.SortOrder or order_b

        if order_a == order_b then
            return (atttbl_a.PrintName or "") < (atttbl_b.PrintName or "")
        end

        return order_a < order_b
    end)

    for i, att in pairs(atts) do
        local slot_panel = self:Add("TacRPAttSlot") --vgui.Create("TacRPAttSlot", self)
        slot_panel:SetShortName(att)
        slot_panel:SetSlot(self:GetActiveSlot())
        slot_panel:SetWeapon(self:GetWeapon())
        slot_panel:SetSize(TacRP.SS(32), TacRP.SS(32))
    end

    -- self:InvalidateLayout(true)

    if self:GetScroll() then
        self:GetScroll():SetVisible(true)
        self:GetScroll():SetTall(math.min(ScrH() * 0.9, #atts * (TacRP.SS(32) + self:GetSpaceY())))
        self:GetScroll():CenterVertical()
        self:GetScroll():GetVBar():SetScroll(0)
    end

end

function PANEL:SetSlot(i)
    self:SetActiveSlot(i)
    self:LoadAttachments()

    self:GetWeapon().LastCustomizeSlot = i
end

-- function PANEL:Paint(w, h)
--     surface.SetDrawColor(255, 0, 0)
--     surface.DrawRect(0, 0, w, h)
-- end

vgui.Register("TacRPAttSlotLayout", PANEL, "DIconLayout")