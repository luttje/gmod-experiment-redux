local PANEL = {}
AccessorFunc(PANEL, "ShortName", "ShortName", FORCE_STRING)
AccessorFunc(PANEL, "Weapon", "Weapon")
AccessorFunc(PANEL, "Slot", "Slot")

AccessorFunc(PANEL, "IsMenu", "IsMenu")
AccessorFunc(PANEL, "SlotLayout", "SlotLayout")

local flash_end = 0
local lock = Material("tacrp/hud/mark_lock.png", "mips smooth")

function PANEL:GetInstalled()
    if self:GetIsMenu() and IsValid(self:GetWeapon()) and self:GetWeapon().Attachments then
        local installed = self:GetWeapon().Attachments[self:GetSlot()].Installed
        if installed == "" then return nil end
        return installed
    else
        return self:GetShortName()
    end
end

function PANEL:Init()

    self:SetText("")

    self.Icon = vgui.Create("DImage", self)
    self.Title = vgui.Create("DLabel", self)

    self.Title.Paint = function(self2, w, h)
        if self2:GetTextColor() == Color(0, 0, 0) then
            surface.SetDrawColor(255, 255, 255, 50)
            surface.DrawRect(0, 0, w, h)
        end
    end

    self:SetMouseInputEnabled(true)
end

function PANEL:PerformLayout(w, h)

    local atttbl = TacRP.GetAttTable(self:GetInstalled())
    local empty = self:GetInstalled() == nil

    self.Icon:Dock(FILL)

    if empty then
        self.Icon:SetVisible(false)
        self.Title:SetText("N/A")
    else
        self.Icon:SetVisible(true)
        self.Icon:SetMaterial(atttbl.Icon)
        self.Title:SetText(TacRP:GetAttName(self:GetInstalled()))
    end

    self.Title:SetSize(w, ScreenScale(6))
    self.Title:SetFont("TacRP_Myriad_Pro_6")
    self.Title:SizeToContentsX(8)
    if self.Title:GetWide() >= w then
        self.Title:SetWide(w)
    end
    self.Title:SetContentAlignment(2)
    self.Title:SetPos(w / 2 - self.Title:GetWide() / 2, h - ScreenScale(6))

end

function PANEL:GetColors()

    local wep = self:GetWeapon()
    local att = self:GetShortName()
    local atttbl = TacRP.GetAttTable(att)
    local empty = self:GetInstalled() == nil
    local hover = self:IsHovered()
    local attached = IsValid(wep) and self:GetSlot()
            and wep.Attachments[self:GetSlot()].Installed == att
    self:SetDrawOnTop(hover)
    local has = empty and 0 or TacRP:PlayerGetAtts(wep:GetOwner(), att)

    local col_bg = Color(0, 0, 0, 150)
    local col_corner = Color(255, 255, 255)
    local col_text = Color(255, 255, 255)
    local col_image = Color(255, 255, 255)

    if (attached and !self:GetIsMenu()) or (self:GetIsMenu() and self:GetSlotLayout():GetActiveSlot() == self:GetSlot()) then
        col_bg = Color(150, 150, 150, 150)
        col_corner = Color(50, 50, 255)
        col_text = Color(0, 0, 0)
        col_image = Color(200, 200, 200)
        if hover then
            col_bg = Color(255, 255, 255)
            col_corner = Color(150, 150, 255)
            col_text = Color(0, 0, 0)
            col_image = Color(255, 255, 255)
        end
    else
        if self:GetIsMenu() or TacRP.ConVars["free_atts"]:GetBool() or has > 0 then
            if hover then
                col_bg = Color(255, 255, 255)
                col_corner = Color(0, 0, 0)
                col_text = Color(0, 0, 0)
                col_image = Color(255, 255, 255)
            end
        else
            if hover then
                col_bg = Color(150, 150, 150)
                col_corner = Color(25, 0, 0)
                col_text = Color(0, 0, 0)
                col_image = Color(255, 255, 255)
            else
                col_bg = Color(25, 20, 20, 150)
                col_corner = Color(255, 0, 0)
                col_text = Color(255, 0, 0)
                col_image = Color(200, 200, 200)
            end
        end
    end

    return col_bg, col_corner, col_text, col_image
end

function PANEL:Paint(w, h)

    local wep = self:GetWeapon()
    local att = self:GetShortName()
    local atttbl = TacRP.GetAttTable(att)
    local empty = self:GetInstalled() == nil

    if !IsValid(wep) then return end

    local hover = self:IsHovered()
    self:SetDrawOnTop(hover)
    local has = empty and 0 or TacRP:PlayerGetAtts(wep:GetOwner(), att)

    local col_bg, col_corner, col_text, col_image = self:GetColors()


    surface.SetDrawColor(col_bg)
    surface.DrawRect(0, 0, w, h)
    TacRP.DrawCorneredBox(0, 0, w, h, col_corner)

    self.Title:SetTextColor(col_text)
    self.Icon:SetImageColor(col_image)

    if !self:GetIsMenu() and !TacRP.ConVars["lock_atts"]:GetBool() and !TacRP.ConVars["free_atts"]:GetBool() and !atttbl.Free then
        local numtxt = has
        if !TacRP.ConVars["free_atts"]:GetBool() and engine.ActiveGamemode() == "terrortown" and TacRP.ConVars["ttt_bench_freeatts"]:GetBool() and TacRP.NearBench(wep:GetOwner()) then
            numtxt = "*"
        end

        surface.SetFont("TacRP_Myriad_Pro_6")
        surface.SetTextColor(col_text)
        local nt_w = surface.GetTextSize(numtxt)
        surface.SetTextPos(w - nt_w - TacRP.SS(2), TacRP.SS(1))
        surface.DrawText(numtxt)
    end
end

function PANEL:PaintOver(w, h)
    -- thank u fesiug
    if self:IsHovered() and self:GetShortName() != nil then

        local wep = self:GetWeapon()
        local att = self:GetShortName()
        local atttbl = TacRP.GetAttTable(att)
        local attslot = wep.Attachments[self:GetSlot()]

        local todo = DisableClipping(true)
        local col_bg = Color(0, 0, 0, 230)
        local col_corner = Color(255, 255, 255)
        local col_text = Color(255, 255, 255)
        local col_text_pro = Color(0, 130, 0, 230)
        local col_text_con = Color(130, 0, 0, 230)
        local rx, ry = self:CursorPos()
        rx = rx + TacRP.SS(12)
        --ry = ry + TacRP.SS(16)
        local gap = TacRP.SS(18)
        local firstoff = TacRP.SS(20)
        local statjump = TacRP.SS(12)
        local statted = false

        local vertsize = firstoff + gap + TacRP.SS(4)
        if atttbl.Pros then vertsize = vertsize + statjump * #atttbl.Pros end
        if atttbl.Cons then vertsize = vertsize + statjump * #atttbl.Cons end

        if self:GetY() + ry >= ScrH() - vertsize then
            ry = ry + (ScrH() - vertsize - (self:GetY() + ry))
        end

        local bw, bh = TacRP.SS(160), TacRP.SS(18)
        surface.SetDrawColor(col_bg)
        TacRP.DrawCorneredBox(rx, ry, bw, bh, col_corner)

        txt = TacRP:GetAttName(att, true)
        surface.SetTextColor(col_text)
        surface.SetFont("TacRP_Myriad_Pro_10")
        surface.SetTextPos(rx + TacRP.SS(2), ry + TacRP.SS(1))
        surface.DrawText(txt)

        txt = TacRP:GetAttDesc(att)
        surface.SetFont("TacRP_Myriad_Pro_6")
        surface.SetTextPos(rx + TacRP.SS(2), ry + TacRP.SS(1 + 8 + 2))
        surface.DrawText(txt)

        local bump = firstoff
        local txjy = TacRP.SS(1)
        local rump = TacRP.SS(9)
        if atttbl.Pros then for aa, ab in ipairs(atttbl.Pros) do
            surface.SetDrawColor(col_text_pro)
            TacRP.DrawCorneredBox( rx, ry + bump, bw, TacRP.SS(10) )
            surface.SetFont("TacRP_Myriad_Pro_8")
            surface.SetTextColor(col_text)
            surface.SetTextPos(rx + rump, ry + bump + txjy)
            surface.DrawText(TacRP:TryTranslate(ab))

            surface.SetFont("TacRP_Myriad_Pro_8")
            surface.SetTextPos(rx + TacRP.SS(3), ry + bump + txjy)
            surface.DrawText("+")

            bump = bump + statjump
            statted = true
        end end
        if atttbl.Cons then for aa, ab in ipairs(atttbl.Cons) do
            surface.SetDrawColor(col_text_con)
            TacRP.DrawCorneredBox( rx, ry + bump, bw, TacRP.SS(10) )
            surface.SetFont("TacRP_Myriad_Pro_8")
            surface.SetTextColor(col_text)
            surface.SetTextPos(rx + rump, ry + bump + txjy)
            surface.DrawText(TacRP:TryTranslate(ab))

            surface.SetFont("TacRP_Myriad_Pro_8")
            surface.SetTextPos(rx + TacRP.SS(3.8), ry + bump + txjy)
            surface.DrawText("-")

            bump = bump + statjump
            statted = true
        end end

        if statted then
            surface.SetDrawColor(col_bg)
            surface.DrawLine(rx, ry + gap, rx + bw, ry + gap)
        end

        local can, reason = TacRP.CanCustomize(wep:GetOwner(), self, att, attslot)
        if !can then
            reason = reason or "Restricted"
            local reasonx, reasonw = rx + TacRP.SS(14), bw - TacRP.SS(14)
            surface.SetDrawColor(25, 0, 0, 240)
            TacRP.DrawCorneredBox(reasonx, ry + bump, reasonw, TacRP.SS(12), col_text_con)
            surface.SetFont("TacRP_Myriad_Pro_12")
            if flash_end > CurTime() then
                local c = 255 - (flash_end - CurTime()) * 255
                surface.SetTextColor(255, c, c)
                surface.SetDrawColor(255, c, c)
            else
                surface.SetTextColor(255, 255, 255)
                surface.SetDrawColor(255, 255, 255)
            end

            surface.SetMaterial(lock)
            surface.DrawTexturedRect(rx, ry + bump, TacRP.SS(12), TacRP.SS(12))

            local tw = surface.GetTextSize(reason)
            surface.SetTextPos(reasonx + reasonw / 2 - tw / 2, ry + bump)
            surface.DrawText(reason)
        elseif engine.ActiveGamemode() == "terrortown" and TacRP.NearBench(wep:GetOwner()) then
            local reasonx, reasonw = rx, bw
            reason = "Free Customization At Bench"
            surface.SetDrawColor(0, 0, 0, 200)
            TacRP.DrawCorneredBox(reasonx, ry + bump, reasonw, TacRP.SS(10), col_text_con)
            surface.SetFont("TacRP_Myriad_Pro_10")
            surface.SetTextColor(255, 255, 255)
            surface.SetDrawColor(255, 255, 255)
            local tw = surface.GetTextSize(reason)
            surface.SetTextPos(reasonx + reasonw / 2 - tw / 2, ry + bump)
            surface.DrawText(reason)
        end

        DisableClipping(todo)

    end
end

function PANEL:Think()
    if self:GetIsMenu() then
        if self.LastInstalled and self.LastInstalled != self:GetInstalled() then
            self:InvalidateLayout(true)
        end
        self.LastInstalled = self:GetInstalled()
    end
end

function PANEL:DoClick()
    local wep = self:GetWeapon()
    if !IsValid(wep) or wep:GetOwner() != LocalPlayer() then return end
    local att = self:GetShortName()
    local slot = self:GetSlot()
    local attslot = wep.Attachments[slot]

    if self:GetIsMenu() then
        if self:GetSlotLayout():GetActiveSlot() == slot then
            self:GetSlotLayout():SetSlot(0)
        else
            self:GetSlotLayout():SetSlot(slot)
        end
    elseif attslot.Installed then
        if attslot.Installed == att then
            wep:Detach(slot)
        else
            wep:Detach(slot, true, true)
            wep:Attach(slot, att)
        end
    else
        wep:Attach(slot, att)
    end
end
function PANEL:DoRightClick()
    local wep = self:GetWeapon()
    if !IsValid(wep) or wep:GetOwner() != LocalPlayer() then return end
    local att = self:GetShortName()
    local slot = self:GetSlot()
    local attslot = wep.Attachments[slot]

    if attslot.Installed and attslot.Installed == att then
        wep:Detach(slot)
    end
end

vgui.Register("TacRPAttSlot", PANEL, "DLabel")