-- local customizedelta = 0
local range = 0

local enable_armor = false
local armor = Material("tacrp/hud/armor.png", "mip smooth")

local body = Material("tacrp/hud/body.png", "mips smooth")
local news = Material("tacrp/hud/news.png", "mips smooth")

local body_head = Material("tacrp/hud/body_head.png", "mips smooth")
local body_chest = Material("tacrp/hud/body_chest.png", "mips smooth")
local body_stomach = Material("tacrp/hud/body_stomach.png", "mips smooth")
local body_arms = Material("tacrp/hud/body_arms.png", "mips smooth")
local body_legs = Material("tacrp/hud/body_legs.png", "mips smooth")

local stk_clr = {
    [1] = Color(255, 75, 75),
    [2] = Color(120, 20, 20),
    [3] = Color(130, 90, 90),
    [4] = Color(60, 35, 35),
    [5] = Color(80, 80, 80),
    [6] = Color(160, 160, 160),
    [7] = Color(180, 180, 180),
    [8] = Color(200, 200, 200),
    [9] = Color(220, 220, 220),
    [10] = Color(240, 240, 240),
    [11] = Color(255, 255, 255),
}
local function bodydamagetext(name, dmg, num, mult, x, y, hover)

    local stk = math.ceil(100 / (dmg * mult))

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetTextColor(255, 255, 255, 255)
    surface.DrawLine(TacRP.SS(2), y, x, y)

    surface.SetFont("TacRP_Myriad_Pro_6")
    surface.SetTextPos(TacRP.SS(2), y)
    -- surface.DrawText(name)
    -- surface.SetTextPos(TacRP.SS(1), y + TacRP.SS(6))
    if hover then
        surface.DrawText(stk .. TacRP:GetPhrase(num > 1 and "unit.ptk" or "unit.stk"))
    else
        surface.DrawText(math.floor(dmg * mult)) --  .. (num > 1 and ("×" .. num) or "")
    end

    local c = stk_clr[math.Clamp(num > 1 and math.ceil(stk / num) or stk, 1, 11)]
    if enable_armor then
        surface.SetDrawColor(c.b, c.g, c.r - (c.r - c.g) * 0.25, 255)
    else
        surface.SetDrawColor(c.r, c.g, c.b, 255)
    end
end

local lastcustomize = false

SWEP.CustomizeHUD = nil

function SWEP:CreateCustomizeHUD()
    self:RemoveCustomizeHUD()

    gui.EnableScreenClicker(true)
    TacRP.CursorEnabled = true

    local bg = vgui.Create("DPanel")

    self.CustomizeHUD = bg
    self.StaticStats = true

    local scrw = ScrW()
    local scrh = ScrH()

    local airgap = TacRP.SS(8)
    local smallgap = TacRP.SS(4)

    bg:SetPos(0, 0)
    bg:SetSize(ScrW(), ScrH())
    bg.OnRemove = function(self2)
        if !IsValid(self) then return end
        if TacRP.ConVars["autosave"]:GetBool() and TacRP.ConVars["free_atts"]:GetBool() then
            self:SavePreset()
        end
    end
    bg.Paint = function(self2, w, h)
        if !IsValid(self) or !IsValid(self:GetOwner()) or self:GetOwner():GetActiveWeapon() != self then
            self2:Remove()
            if (self.GrenadeMenuAlpha or 0) != 1 then
                gui.EnableScreenClicker(false)
                TacRP.CursorEnabled = false
            end
            return
        end

        local name_txt = TacRP:GetPhrase("wep." .. self:GetClass() .. "name.full") or TacRP:GetPhrase("wep." .. self:GetClass() .. "name") or self:GetValue("FullName") or self:GetValue("PrintName")

        surface.SetFont("TacRP_Myriad_Pro_32")
        local name_w = surface.GetTextSize(name_txt)

        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(w - name_w - TacRP.SS(20), airgap, name_w + TacRP.SS(12), TacRP.SS(34))
        TacRP.DrawCorneredBox(w - name_w - TacRP.SS(20), airgap, name_w + TacRP.SS(12), TacRP.SS(34))

        surface.SetTextPos(w - name_w - TacRP.SS(14), airgap)
        surface.SetTextColor(255, 255, 255)
        surface.DrawText(name_txt)

        surface.SetFont("TacRP_Myriad_Pro_12")

        if self:GetValue("Ammo") != "" then
            local ammo_txt = language.GetPhrase(string.lower(self:GetValue("Ammo")) .. "_ammo")
            local ammo_w = surface.GetTextSize(ammo_txt)

            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(w - name_w - ammo_w - TacRP.SS(32) - smallgap, airgap + TacRP.SS(20), ammo_w + TacRP.SS(12), TacRP.SS(14))
            TacRP.DrawCorneredBox(w - name_w - ammo_w - TacRP.SS(32) - smallgap, airgap + TacRP.SS(20), ammo_w + TacRP.SS(12), TacRP.SS(14))

            surface.SetTextPos(w - name_w - ammo_w - TacRP.SS(30), airgap + TacRP.SS(21))
            surface.SetTextColor(255, 255, 255)
            surface.DrawText(ammo_txt)
        end

        if self.SubCatTier and self.SubCatType then
            local type_txt = self:GetSubClassName(TacRP.UseTiers())
            surface.SetFont("TacRP_Myriad_Pro_12")
            local type_w = surface.GetTextSize(type_txt)

            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(w - name_w - type_w - TacRP.SS(32) - smallgap, airgap, type_w + TacRP.SS(12), TacRP.SS(18))
            TacRP.DrawCorneredBox(w - name_w - type_w - TacRP.SS(32) - smallgap, airgap, type_w + TacRP.SS(12), TacRP.SS(18))

            surface.SetTextPos(w - name_w - type_w - TacRP.SS(30), airgap + TacRP.SS(3))
            surface.SetTextColor(255, 255, 255)
            surface.DrawText(type_txt)
        end

    end

    local stack = airgap + TacRP.SS(34)

    if !self:GetValue("NoRanger") then
        local ranger = vgui.Create("DPanel", bg)
        ranger:SetPos(scrw - TacRP.SS(128) - airgap, stack + smallgap)
        ranger:SetSize(TacRP.SS(128), TacRP.SS(64))
        ranger.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, w, h)
            TacRP.DrawCorneredBox(0, 0, w, h)

            local exp = self:GetValue("ExplosiveDamage")

            local dmg_max = (self:GetValue("Damage_Max") + exp) * self:GetConfigDamageMultiplier()
            local dmg_min = (self:GetValue("Damage_Min") + exp) * self:GetConfigDamageMultiplier()

            local range_min, range_max = self:GetMinMaxRange()

            surface.SetDrawColor(255, 255, 255, 50)

            local range_1_y = 2 * (h / 5)
            local range_2_y = 4 * (h / 5)

            local range_1_x = 0
            local range_2_x = (w / 3)
            local range_3_x = 2 * (w / 3)

            if dmg_max < dmg_min then
                range_1_y = 4 * (h / 5)
                range_2_y = 2 * (h / 5)
            elseif dmg_max == dmg_min then
                range_1_y = 3 * (h / 5)
                range_2_y = 3 * (h / 5)
            end

            if range_min == 0 then
                range_2_x = 0
                range_3_x = w / 2
            end

            surface.DrawLine(range_2_x, 0, range_2_x, h)
            surface.DrawLine(range_3_x, 0, range_3_x, h)

            surface.SetDrawColor(255, 255, 255)

            for i = 0, 1 do
                surface.DrawLine(range_1_x, range_1_y + i, range_2_x, range_1_y + i)
                surface.DrawLine(range_2_x, range_1_y + i, range_3_x, range_2_y + i)
                surface.DrawLine(range_3_x, range_2_y + i, w, range_2_y + i)
            end

            local mouse_x, mouse_y = input.GetCursorPos()
            mouse_x, mouse_y = self2:ScreenToLocal(mouse_x, mouse_y)

            local draw_rangetext = true

            if mouse_x > 0 and mouse_x < w and mouse_y > 0 and mouse_y < h then

                local range_m_x = 0

                if mouse_x < range_2_x then
                    range = range_min
                    range_m_x = range_2_x
                elseif mouse_x > range_3_x then
                    range = range_max
                    range_m_x = range_3_x
                else
                    local d = (mouse_x - range_2_x) / (range_3_x - range_2_x)
                    range = Lerp(d, range_min, range_max)
                    range_m_x = mouse_x
                end

                local dmg = self:GetDamageAtRange(range) + exp * self:GetConfigDamageMultiplier()

                local txt_dmg1 = tostring(math.Round(dmg)) .. TacRP:GetPhrase("unit.damage")

                if self:GetValue("Num") > 1 then
                    txt_dmg1 = math.Round(dmg * self:GetValue("Num")) .. "-" .. txt_dmg1
                end

                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawLine(range_m_x, 0, range_m_x, h)

                surface.SetFont("TacRP_Myriad_Pro_8")
                surface.SetTextColor(255, 255, 255)
                local txt_dmg1_w = surface.GetTextSize(txt_dmg1)
                surface.SetTextPos((w / 3) - txt_dmg1_w - (TacRP.SS(2)), TacRP.SS(1))
                surface.DrawText(txt_dmg1)

                local txt_range1 = self:RangeUnitize(range)

                surface.SetFont("TacRP_Myriad_Pro_8")
                surface.SetTextColor(255, 255, 255)
                local txt_range1_w = surface.GetTextSize(txt_range1)
                surface.SetTextPos((w / 3) - txt_range1_w - (TacRP.SS(2)), TacRP.SS(1 + 8))
                surface.DrawText(txt_range1)

                draw_rangetext = false
            end


            if draw_rangetext then
                local txt_dmg1 = tostring(math.Round(dmg_max)) .. TacRP:GetPhrase("unit.damage")

                if self:GetValue("Num") > 1 then
                    txt_dmg1 = math.Round(dmg_max * self:GetValue("Num")) .. "-" .. txt_dmg1
                end

                surface.SetFont("TacRP_Myriad_Pro_8")
                surface.SetTextColor(255, 255, 255)
                local txt_dmg1_w = surface.GetTextSize(txt_dmg1)
                surface.SetTextPos((w / 3) - txt_dmg1_w - (TacRP.SS(2)), TacRP.SS(1))
                surface.DrawText(txt_dmg1)

                local txt_range1 = self:RangeUnitize(range_min)

                surface.SetFont("TacRP_Myriad_Pro_8")
                surface.SetTextColor(255, 255, 255)
                local txt_range1_w = surface.GetTextSize(txt_range1)
                surface.SetTextPos((w / 3) - txt_range1_w - (TacRP.SS(2)), TacRP.SS(1 + 8))
                surface.DrawText(txt_range1)

                local txt_dmg2 = tostring(math.Round(dmg_min)) .. TacRP:GetPhrase("unit.damage")

                if self:GetValue("Num") > 1 then
                    txt_dmg2 = math.Round(dmg_min * self:GetValue("Num")) .. "-" .. txt_dmg2
                end

                surface.SetFont("TacRP_Myriad_Pro_8")
                surface.SetTextColor(255, 255, 255)
                surface.SetTextPos(2 * (w / 3) + (TacRP.SS(2)), TacRP.SS(1))
                surface.DrawText(txt_dmg2)

                local txt_range2 = self:RangeUnitize(range_max)

                surface.SetFont("TacRP_Myriad_Pro_8")
                surface.SetTextColor(255, 255, 255)
                surface.SetTextPos(2 * (w / 3) + (TacRP.SS(2)), TacRP.SS(1 + 8))
                surface.DrawText(txt_range2)
            end
        end

        local bodychart = vgui.Create("DPanel", bg)
        bodychart:SetPos(scrw - TacRP.SS(128 + 44) - airgap, stack + smallgap)
        bodychart:SetSize(TacRP.SS(40), TacRP.SS(64))
        bodychart:SetZPos(100)
        bodychart.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, w, h)
            TacRP.DrawCorneredBox(0, 0, w, h)

            local za = TacRP.SS(1)
            for i=1, 7 do
                local c = stk_clr[i]
                if enable_armor then
                    surface.SetDrawColor( c.b, c.g, c.r - (c.r - c.g) * 0.25, 255 )
                else
                    surface.SetDrawColor( c.r, c.g, c.b, 255 )
                end
                surface.DrawRect( math.Round(w - (za*5) - za*2), math.Round(h - (za*5*i) - za*2), math.Round(za*5), math.Round(za*5) )

                surface.SetTextColor( 255, 255, 255, 127 )
                surface.SetFont("TacRP_Myriad_Pro_5")
                surface.SetTextPos( math.Round(w - za*5 - za*0.7), math.Round(h - (za*5*i) - za*2))
                surface.DrawText(i)
            end

            local h2 = h - TacRP.SS(4)
            local w2 = math.ceil(h2 * (136 / 370))
            local x2, y2 = w - w2 - TacRP.SS(2), TacRP.SS(2)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(body)
            surface.DrawTexturedRect(x2, y2, w2, h2)

            local dmg = self:GetDamageAtRange(range, true) + self:GetValue("ExplosiveDamage")

            if enable_armor then
                dmg = dmg * math.Clamp(self:GetValue("ArmorPenetration"), 0, 1)
            end

            local num =  self:GetValue("Num")
            local mult = self:GetBodyDamageMultipliers() --self:GetValue("BodyDamageMultipliers")
            local hover = self2:IsHovered()

            local upperbody = mult[HITGROUP_STOMACH] == mult[HITGROUP_CHEST]

            bodydamagetext("Head", dmg, num, mult[HITGROUP_HEAD], w - TacRP.SS(16), upperbody and TacRP.SS(6) or TacRP.SS(4), hover)
            surface.SetMaterial(body_head)
            surface.DrawTexturedRect(x2, y2, w2, h2)

            bodydamagetext("Chest", dmg, num, mult[HITGROUP_CHEST], w - TacRP.SS(16), upperbody and TacRP.SS(18) or TacRP.SS(14), hover)
            surface.SetMaterial(body_chest)
            surface.DrawTexturedRect(x2, y2, w2, h2)

            if !upperbody then
                bodydamagetext("Stomach", dmg, num, mult[HITGROUP_STOMACH], w - TacRP.SS(16), TacRP.SS(24), hover)
            end
            surface.SetMaterial(body_stomach)
            surface.DrawTexturedRect(x2, y2, w2, h2)

            bodydamagetext("Arms", dmg, num, mult[HITGROUP_LEFTARM], w - TacRP.SS(22), upperbody and TacRP.SS(30) or TacRP.SS(34), hover)
            surface.SetMaterial(body_arms)
            surface.DrawTexturedRect(x2, y2, w2, h2)

            bodydamagetext("Legs", dmg, num, mult[HITGROUP_LEFTLEG], w - TacRP.SS(18), upperbody and TacRP.SS(42) or TacRP.SS(44), hover)
            surface.SetMaterial(body_legs)
            surface.DrawTexturedRect(x2, y2, w2, h2)

            surface.SetDrawColor(0, 0, 0, 50)

            surface.SetFont("TacRP_Myriad_Pro_8")
            local txt = self:RangeUnitize(range)
            --local tw, th = surface.GetTextSize(txt)
            --surface.DrawRect(TacRP.SS(1), h - TacRP.SS(10), tw + TacRP.SS(1), th)
            surface.SetTextPos(TacRP.SS(2) + 2, h - TacRP.SS(10) + 2)
            surface.SetTextColor(0, 0, 0, 150)
            surface.DrawText(txt)
            surface.SetTextColor(255, 255, 255, 255)
            surface.SetTextPos(TacRP.SS(2), h - TacRP.SS(10))
            surface.DrawText(txt)
            if num > 1 then
                local txt2 = "×" .. math.floor(num)
                local tw2 = surface.GetTextSize(txt2)
                --surface.DrawRect(w - tw2 - TacRP.SS(2), h - TacRP.SS(10), tw2 + TacRP.SS(1), th2)

                surface.SetTextPos(w - tw2 - TacRP.SS(2) + 2, h - TacRP.SS(10) + 2)
                surface.SetTextColor(0, 0, 0, 150)
                surface.DrawText(txt2)
                surface.SetTextColor(255, 255, 255, 255)
                surface.SetTextPos(w - tw2 - TacRP.SS(2), h - TacRP.SS(10))
                surface.DrawText(txt2)
            end
        end

        local armorbtn = vgui.Create("DLabel", bg)
        armorbtn:SetText("")
        armorbtn:SetPos(scrw - TacRP.SS(128 + 44 - 32) - airgap, stack + smallgap + TacRP.SS(2))
        armorbtn:SetSize(TacRP.SS(6), TacRP.SS(6))
        armorbtn:SetZPos(110)
        armorbtn:SetMouseInputEnabled(true)
        armorbtn:MoveToFront()
        armorbtn.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            if enable_armor and self2:IsHovered() then
                surface.SetDrawColor(Color(255, 255, 255, 255))
            elseif self2:IsHovered() then
                surface.SetDrawColor(Color(255, 220, 220, 255))
            elseif enable_armor then
                surface.SetDrawColor(Color(255, 255, 255, 175))
            else
                surface.SetDrawColor(Color(255, 200, 200, 125))
            end
            surface.SetMaterial(armor)
            -- surface.DrawTexturedRect(w * 0.2, h * 0.2, w * 0.6, h * 0.6)
            surface.DrawTexturedRect(0, 0, w, h)
        end
        armorbtn.DoClick = function(self2)
            enable_armor = !enable_armor
        end

        stack = stack + TacRP.SS(64) + smallgap
    end

    if self:GetValue("PrimaryGrenade") then
        local desc_box = vgui.Create("DPanel", bg)
        desc_box:SetSize(TacRP.SS(172), TacRP.SS(108))
        desc_box:SetPos(scrw - TacRP.SS(172) - airgap, stack + smallgap)
        stack = stack + TacRP.SS(48) + smallgap
        desc_box.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, w, h)
            TacRP.DrawCorneredBox(0, 0, w, h)

            local nade = TacRP.QuickNades[self:GetValue("PrimaryGrenade")]

            surface.SetFont("TacRP_Myriad_Pro_8")
            surface.SetTextPos(TacRP.SS(6), TacRP.SS(4))
            surface.DrawText("FUSE:")

            surface.SetFont("TacRP_Myriad_Pro_8")
            surface.SetTextPos(TacRP.SS(4), TacRP.SS(12))
            surface.DrawText(nade.DetType or "")

            surface.SetFont("TacRP_Myriad_Pro_8")
            surface.SetTextColor(255, 255, 255)
            surface.SetTextPos(TacRP.SS(6), TacRP.SS(24))
            surface.DrawText(TacRP:GetPhrase("cust.description"))

            if !self.MiscCache["cust_desc"] then
                self.MiscCache["cust_desc"] = TacRP.MultiLineText(nade.Description, w - TacRP.SS(8), "TacRP_Myriad_Pro_8")
            end

            for i, k in ipairs(self.MiscCache["cust_desc"]) do
                surface.SetFont("TacRP_Myriad_Pro_8")
                surface.SetTextColor(255, 255, 255)
                surface.SetTextPos(TacRP.SS(4), TacRP.SS(32) + (TacRP.SS(8 * (i - 1))))
                surface.DrawText(k)
            end
        end
    else
        local tabs_h = TacRP.SS(8)

        local desc_box = vgui.Create("DPanel", bg)
        desc_box.PrintName = TacRP:GetPhrase("cust.description2")
        desc_box:SetSize(TacRP.SS(172), TacRP.SS(36))
        desc_box:SetPos(scrw - TacRP.SS(172) - airgap, stack + smallgap + tabs_h + TacRP.SS(2))
        desc_box.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, w, h)
            TacRP.DrawCorneredBox(0, 0, w, h)

            -- surface.SetFont("TacRP_Myriad_Pro_8")
            -- surface.SetTextColor(255, 255, 255)
            -- surface.SetTextPos(TacRP.SS(6), TacRP.SS(4))
            -- surface.DrawText(TacRP:GetPhrase("cust.description"))

            if !self.MiscCache["cust_desc"] then
                self.MiscCache["cust_desc"] = TacRP.MultiLineText(self:GetValue("Description"), w - TacRP.SS(8), "TacRP_Myriad_Pro_8")
            end

            surface.SetFont("TacRP_Myriad_Pro_8")
            surface.SetTextColor(255, 255, 255)
            for i, k in pairs(self.MiscCache["cust_desc"]) do
                surface.SetTextPos(TacRP.SS(4), TacRP.SS(2) + (TacRP.SS(8 * (i - 1))))
                surface.DrawText(k)
            end

            if self.Description_Quote then
                surface.SetFont("TacRP_Myriad_Pro_8_Italic")
                surface.SetTextColor(255, 255, 255)
                surface.SetTextPos(TacRP.SS(4), TacRP.SS(26))
                surface.DrawText(self.Description_Quote)
            end
        end

        local trivia_box = vgui.Create("DPanel", bg)
        trivia_box.PrintName = TacRP:GetPhrase("cust.trivia")
        trivia_box:SetSize(TacRP.SS(172), TacRP.SS(36))
        trivia_box:SetPos(scrw - TacRP.SS(172) - airgap, stack + smallgap + tabs_h + TacRP.SS(2))
        trivia_box.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, w, h)
            TacRP.DrawCorneredBox(0, 0, w, h)

            surface.SetFont("TacRP_Myriad_Pro_10")
            surface.SetTextColor(255, 255, 255)

            surface.SetTextPos(TacRP.SS(4), TacRP.SS(6))
            local manu_str = TacRP:TryTranslate(self:GetValue("Trivia_Manufacturer")) or TacRP:GetPhrase("trivia.unknown")
            local manu_w = surface.GetTextSize(manu_str)
            if manu_w + TacRP.SS(6) >= w / 2 then
                surface.SetFont("TacRP_Myriad_Pro_8")
                if !self.MiscCache["cust_manufacturer"] then
                    self.MiscCache["cust_manufacturer"] = TacRP.MultiLineText(manu_str, w / 2 - TacRP.SS(2), "TacRP_Myriad_Pro_8")
                end
                for i, k in pairs(self.MiscCache["cust_manufacturer"]) do
                    surface.SetTextPos(TacRP.SS(4), TacRP.SS(7) + (TacRP.SS(6 * (i - 1))))
                    surface.DrawText(k)
                end
            else
                surface.DrawText(manu_str)
            end

            surface.SetFont("TacRP_Myriad_Pro_10")

            surface.SetTextPos(TacRP.SS(4), TacRP.SS(24))
            surface.DrawText(TacRP:TryTranslate(self:GetValue("Trivia_Year")) or TacRP:GetPhrase("trivia.unknown"))

            surface.SetTextPos(w / 2, TacRP.SS(6))
            surface.DrawText(TacRP:TryTranslate(self:GetValue("Trivia_Caliber")) or TacRP:GetPhrase("trivia.unknown"))

            surface.SetTextPos(w / 2, TacRP.SS(24))
            surface.DrawText(TacRP:GetPhrase(TacRP.FactionToPhrase[self:GetValue("Faction")]))

            surface.SetFont("TacRP_Myriad_Pro_6")
            surface.SetTextColor(255, 255, 255)

            surface.SetTextPos(TacRP.SS(4), TacRP.SS(2))
            surface.DrawText(TacRP:GetPhrase("trivia.manufacturer"))

            surface.SetTextPos(TacRP.SS(4), TacRP.SS(20))
            surface.DrawText(TacRP:GetPhrase("trivia.year"))

            surface.SetTextPos(w / 2, TacRP.SS(2))
            surface.DrawText(TacRP:GetPhrase("trivia.caliber"))

            surface.SetTextPos(w / 2, TacRP.SS(20))
            surface.DrawText(TacRP:GetPhrase("trivia.faction"))
        end

        local credits_box = vgui.Create("DPanel", bg)
        credits_box.PrintName = TacRP:GetPhrase("cust.credits")
        credits_box:SetSize(TacRP.SS(172), TacRP.SS(36))
        credits_box:SetPos(scrw - TacRP.SS(172) - airgap, stack + smallgap + tabs_h + TacRP.SS(2))
        credits_box.Paint = function(self2, w, h)
            if !IsValid(self) or !self.Credits then return end

            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, w, h)
            TacRP.DrawCorneredBox(0, 0, w, h)

            if !self.MiscCache["cust_credits"] then
                self.MiscCache["cust_credits"] = TacRP.MultiLineText(self.Credits, w - TacRP.SS(8), "TacRP_Myriad_Pro_8")
            end

            for i, k in ipairs(self.MiscCache["cust_credits"]) do
                surface.SetFont("TacRP_Myriad_Pro_8")
                surface.SetTextColor(255, 255, 255)
                surface.SetTextPos(TacRP.SS(4), TacRP.SS(2) + TacRP.SS(8 * (i - 1)))
                surface.DrawText(k)
            end
        end

        local tabs = {desc_box}
        if self.Trivia_Caliber or self.Trivia_Manufacturer or self.Trivia_Year then
            table.insert(tabs, trivia_box)
        else
            trivia_box:Hide()
        end
        if self.Credits then
            table.insert(tabs, credits_box)
        else
            trivia_box:Hide()
        end
        self.ActiveDescTab = self.ActiveDescTab or 1

        local tabs_w = TacRP.SS(172) / #tabs - #tabs * TacRP.SS(0.5)
        for i = 1, #tabs do
            if i != self.ActiveDescTab then
                tabs[i]:Hide()
            end

            local tab_button = vgui.Create("DLabel", bg)
            tab_button.TabIndex = i
            tab_button:SetSize(tabs_w, tabs_h)
            tab_button:SetPos(scrw - TacRP.SS(172) - airgap + (TacRP.SS(2) + tabs_w) * (i - 1), stack + smallgap)
            tab_button:SetText("")
            tab_button:SetMouseInputEnabled(true)
            tab_button:MoveToFront()
            tab_button.Paint = function(self2, w2, h2)
                if !IsValid(self) then return end

                local hover = #tabs > 1 and self2:IsHovered()
                local selected = #tabs > 1 and self.ActiveDescTab == i

                local col_bg = Color(0, 0, 0, 150)
                local col_corner = Color(255, 255, 255)
                local col_text = Color(255, 255, 255)

                if selected then
                    col_bg = Color(150, 150, 150, 150)
                    col_corner = Color(50, 50, 255)
                    col_text = Color(0, 0, 0)
                    if hover then
                        col_bg = Color(255, 255, 255)
                        col_corner = Color(150, 150, 255)
                        col_text = Color(0, 0, 0)
                    end
                elseif hover then
                    col_bg = Color(255, 255, 255)
                    col_corner = Color(0, 0, 0)
                    col_text = Color(0, 0, 0)
                end

                surface.SetDrawColor(col_bg)
                surface.DrawRect(0, 0, w2, h2)
                TacRP.DrawCorneredBox(0, 0, w2, h2, col_corner)

                draw.SimpleText(tabs[i].PrintName, "TacRP_Myriad_Pro_8", w2 / 2, h2 / 2, col_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            tab_button.DoClick = function(self2)
                if self2.TabIndex == self.ActiveDescTab then return end
                self.ActiveDescTab = self2.TabIndex
                for j = 1, #tabs do
                    if j != self.ActiveDescTab then
                        tabs[j]:Hide()
                    else
                        tabs[j]:Show()
                    end
                end
            end
        end

        stack = stack + TacRP.SS(48) + smallgap
    end

    if !self:GetValue("NoStatBox") then

        local statgroup = self:GetValue("PrimaryMelee") and self.StatGroupsMelee or self.StatGroups
        local statdisplay = self:GetValue("PrimaryMelee") and self.StatDisplayMelee or self.StatDisplay

        local tabs_h = TacRP.SS(10)

        local group_box = vgui.Create("DPanel", bg)
        group_box.PrintName = TacRP:GetPhrase("cust.rating")
        group_box:SetSize(TacRP.SS(164), TacRP.SS(172))
        group_box:SetPos(scrw - TacRP.SS(164) - airgap - smallgap, stack + smallgap * 2 + tabs_h)
        group_box.Paint = function(self2)
            if !IsValid(self) then return end

            local w, h = TacRP.SS(172), TacRP.SS(16)
            local x, y = 0, 0

            local hovered = false
            local hoverindex = 0
            local hoverscore = 0

            for i, v in ipairs(statgroup) do

                if !self.StatScoreCache[i] then
                    self.StaticStats = true
                    local sb = v.RatingFunction(self, true)
                    local sc = v.RatingFunction(self, false)

                    local ib, ic = 0, 0
                    for j = 1, #self.StatGroupGrades do
                        if ib == 0 and sb > self.StatGroupGrades[j][1] then
                            ib = j
                        end
                        if ic == 0 and sc > self.StatGroupGrades[j][1] then
                            ic = j
                        end
                    end

                    self.StatScoreCache[i] = {{math.min(sc or 0, 100), ic}, {math.min(sb or 0, 100), ib}}
                    self.StaticStats = false
                end
                local scorecache = self.StatScoreCache[i]
                local f = scorecache[1][1] / 100
                local f_base = scorecache[2][1] / 100

                local w2, h2 = TacRP.SS(95), TacRP.SS(8)
                surface.SetDrawColor(0, 0, 0, 150)
                surface.DrawRect(x, y, w, h)
                TacRP.DrawCorneredBox(x, y, w, h)

                draw.SimpleText(TacRP:GetPhrase(v.Name) or v.Name, "TacRP_Myriad_Pro_10", x + TacRP.SS(4), y + TacRP.SS(8), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                surface.SetDrawColor(75, 75, 75, 100)
                surface.DrawRect(x + TacRP.SS(64), y + TacRP.SS(4), w2, h2)

                surface.SetDrawColor(Lerp(f, 200, 0), Lerp(f, 0, 200), 0, 150)
                surface.DrawRect(x + TacRP.SS(64), y + TacRP.SS(4), w2 * f, h2)

                surface.SetDrawColor(0, 0, 0, 0)
                TacRP.DrawCorneredBox(x + TacRP.SS(64), y + TacRP.SS(4), w2, h2)

                for j = 1, 4 do
                    surface.SetDrawColor(255, 255, 255, 125)
                    surface.DrawRect(x + TacRP.SS(64) + w2 * (j / 5) - 0.5, y + h2 - TacRP.SS(1.5), 1, TacRP.SS(3))
                end

                surface.SetDrawColor(255, 255, 255, 20)
                surface.DrawRect(x + TacRP.SS(64), y + TacRP.SS(2.5) + h2 / 2, w2 * f_base, TacRP.SS(3))

                local grade = self.StatGroupGrades[scorecache[1][2]]
                if grade then
                    draw.SimpleText(grade[2], "TacRP_HD44780A00_5x8_8", x + TacRP.SS(61), y + TacRP.SS(7.5), grade[3], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end

                local mx, my = self2:CursorPos()
                if mx > 0 and mx <= w and my > y and my <= y + h then
                    hovered = true
                    hoverindex = i
                    hoverscore = scorecache[1][1]
                end

                y = y + TacRP.SS(18)
            end

            if hovered then
                local v = statgroup[hoverindex]
                local todo = DisableClipping(true)
                local col_bg = Color(0, 0, 0, 254)
                local col_corner = Color(255, 255, 255)
                local col_text = Color(255, 255, 255)
                local rx, ry = self2:CursorPos()
                rx = rx + TacRP.SS(16)
                ry = ry + TacRP.SS(16)

                local desc = TacRP:GetPhrase(v.Description) or v.Description or ""
                desc = string.Explode("\n", desc)

                if self2:GetY() + ry >= TacRP.SS(280) then
                    ry = ry - TacRP.SS(60)
                end

                if self2:GetX() + rx + TacRP.SS(160) >= ScrW() then
                    rx = rx - TacRP.SS(160)
                end

                local bw, bh = TacRP.SS(160), TacRP.SS(12 + (6 * #desc))
                surface.SetDrawColor(col_bg)
                TacRP.DrawCorneredBox(rx, ry, bw, bh, col_corner)

                local txt = TacRP:GetPhrase(v.Name) or v.Name
                surface.SetTextColor(col_text)
                surface.SetFont("TacRP_Myriad_Pro_10")
                surface.SetTextPos(rx + TacRP.SS(2), ry + TacRP.SS(1))
                surface.DrawText(txt)

                local scoretxt = TacRP:GetPhrase("rating.score", {score = math.Round(hoverscore, 1), max = 100})
                draw.SimpleText(scoretxt, "TacRP_Myriad_Pro_8", rx + bw - TacRP.SS(2), ry + TacRP.SS(2), col_text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

                surface.SetFont("TacRP_Myriad_Pro_6")
                for j, k in pairs(desc) do
                    surface.SetTextPos(rx + TacRP.SS(2), ry + TacRP.SS(1 + 8 + 2) + (TacRP.SS(6 * (j - 1))))
                    surface.DrawText(k)
                end

                DisableClipping(todo)
            end
        end

        local w_statbox = TacRP.SS(164)
        local x_3 = w_statbox - TacRP.SS(32)
        local x_2 = x_3 - TacRP.SS(32)
        local x_1 = x_2 - TacRP.SS(32)

        local function updatestat(i, k)
            if k.ConVarCheck then
                if !k.ConVar then k.ConVar = GetConVar(k.ConVarCheck) end
                if k.ConVar:GetBool() == tobool(k.ConVarInvert) then return end
            end

            if k.Spacer then
                self.MiscCache["statbox"][i] = {}
                return
            end
            local value = self:GetValue(k.Value)
            local orig = self:GetBaseValue(k.Value)
            local diff = nil

            if k.HideIfSame and orig == value then return end
            if k.DefaultValue != nil and value == k.DefaultValue and orig == k.DefaultValue then return end

            if k.ValueCheck and self:GetValue(k.ValueCheck) != !k.ValueInvert then
                return
            end

            local stat_base = 0
            local stat_curr = 0

            if k.AggregateFunction then
                stat_base = k.AggregateFunction(self, true, orig)
                stat_curr = k.AggregateFunction(self, false, value)
            else
                stat_base = math.Round(orig, 4)
                stat_curr = math.Round(value, 4)
            end

            if stat_base == nil and stat_cur == nil then return end

            if k.DifferenceFunction then
                diff = k.DifferenceFunction(self, orig, value)
            elseif isnumber(stat_base) and isnumber(stat_curr) then
                if stat_curr == stat_base then
                    diff = ""
                else
                    diff = math.Round((stat_curr / stat_base - 1) * 100)
                    if diff > 0 then
                        diff = "+" .. tostring(diff) .. "%"
                    else
                        diff = tostring(diff) .. "%"
                    end
                end
            end

            local txt_base = tostring(stat_base)
            local txt_curr = tostring(stat_curr)

            if isbool(stat_base) then
                if stat_base then
                    txt_base = "YES"
                else
                    txt_base = "NO"
                end

                if stat_curr then
                    txt_curr = "YES"
                else
                    txt_curr = "NO"
                end
            end

            if k.DisplayFunction then
                txt_base = k.DisplayFunction(self, true, orig)
                txt_curr = k.DisplayFunction(self, false, value)
            end

            if k.Unit then
                local unit = TacRP:TryTranslate(k.Unit)
                txt_base = txt_base .. unit
                txt_curr = txt_curr .. unit
            end

            local good = false
            local goodorbad = false

            if k.BetterFunction then
                goodorbad, good = k.BetterFunction(self, orig, value)
            elseif stat_base != stat_curr then
                if isnumber(stat_curr) then
                    good = stat_curr > stat_base
                    goodorbad = true
                elseif isbool(stat_curr) then
                    good = !stat_base and stat_curr
                    goodorbad = true
                end
            end

            if k.LowerIsBetter then
                good = !good
            end

            if goodorbad then
                if good then
                    surface.SetTextColor(175, 255, 175)
                else
                    surface.SetTextColor(255, 175, 175)
                end
            else
                surface.SetTextColor(255, 255, 255)
            end

            self.MiscCache["statbox"][i] = {txt_base, txt_curr, goodorbad, good, diff}
        end

        local function populate_stats(layout)
            if !IsValid(self) then return end
            self.StaticStats = true
            layout:Clear()
            self.MiscCache["statbox"] = {}
            self.StatRows = {}
            for i, k in ipairs(statdisplay) do
                updatestat(i, k)
                if !self.MiscCache["statbox"][i] then continue end
                local spacer = k.Spacer

                local row = layout:Add("DPanel")
                row:SetSize(w_statbox, TacRP.SS(spacer and 12 or 9))
                row.StatIndex = i
                row.Paint = function(self2, w, h)
                    if !IsValid(self) then return end
                    if !self.MiscCache["statbox"] then
                        populate_stats(layout)
                    end
                    local sicache = self.MiscCache["statbox"][self2.StatIndex]
                    if !sicache then
                        self2:Remove()
                        return
                    end
                    surface.SetFont(spacer and "TacRP_Myriad_Pro_11" or "TacRP_Myriad_Pro_8")
                    surface.SetTextColor(255, 255, 255)
                    surface.SetTextPos(TacRP.SS(3), 0)
                    local name = TacRP:GetPhrase(k.Name) or k.Name
                    surface.DrawText(name .. (spacer and "" or ":"))

                    if !spacer then
                        surface.SetDrawColor(255, 255, 255)
                        surface.SetTextPos(x_1 + TacRP.SS(4), 0)
                        surface.DrawText(sicache[1])

                        if sicache[3] then
                            if sicache[4] then
                                surface.SetTextColor(175, 255, 175)
                            else
                                surface.SetTextColor(255, 175, 175)
                            end
                        end

                        if sicache[2] != sicache[1] then
                            surface.SetTextPos(x_2 + TacRP.SS(4), 0)
                            surface.DrawText(sicache[2])
                        end

                        if sicache[5] then
                            surface.SetTextPos(x_3 + TacRP.SS(4), 0)
                            surface.DrawText(sicache[5])
                        end
                    end

                    surface.SetDrawColor(255, 255, 255, k.Spacer and 125 or 5)
                    local um, umm = k.Spacer and 3 or 1, k.Spacer and 2 or 1
                    surface.DrawRect( 0, h-um, w, umm )
                end
                self.StatRows[row] = i
            end
            self.StaticStats = false
        end

        local stat_box = vgui.Create("DPanel", bg)
        stat_box.PrintName = TacRP:GetPhrase("cust.stats")
        stat_box:SetSize(w_statbox, TacRP.SS(172))
        stat_box:SetPos(scrw - w_statbox - airgap - smallgap, stack + smallgap * 2 + tabs_h)
        stat_box.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, w, h)
            TacRP.DrawCorneredBox(0, 0, w, h)

            surface.SetDrawColor(255, 255, 255, 100)
            --surface.DrawLine(x_1, 0, x_1, h)
            --surface.DrawLine(x_2, 0, x_2, h)
            --surface.DrawLine(x_3, 0, x_3, h)
            surface.DrawLine(0, TacRP.SS(2 + 8 + 1), w, TacRP.SS(2 + 8 + 1))

            surface.SetFont("TacRP_Myriad_Pro_8")
            surface.SetTextColor(255, 255, 255)
            surface.SetTextPos(TacRP.SS(4), TacRP.SS(2))
            surface.DrawText(TacRP:GetPhrase("stat.table.stat"))

            surface.SetFont("TacRP_Myriad_Pro_8")
            surface.SetTextColor(255, 255, 255)
            surface.SetTextPos(x_1 + TacRP.SS(4), TacRP.SS(2))
            surface.DrawText(TacRP:GetPhrase("stat.table.base"))

            surface.SetFont("TacRP_Myriad_Pro_8")
            surface.SetTextColor(255, 255, 255)
            surface.SetTextPos(x_2 + TacRP.SS(4), TacRP.SS(2))
            surface.DrawText(TacRP:GetPhrase("stat.table.curr"))

            surface.SetFont("TacRP_Myriad_Pro_8")
            surface.SetTextColor(255, 255, 255)
            surface.SetTextPos(x_3 + TacRP.SS(4), TacRP.SS(2))
            surface.DrawText(TacRP:GetPhrase("stat.table.diff"))
        end
        local stat_scroll = vgui.Create("DScrollPanel", stat_box)
        stat_scroll:Dock(FILL)
        stat_scroll:DockMargin(0, TacRP.SS(12), 0, 0)
        local sbar = stat_scroll:GetVBar()
        function sbar:Paint(w, h)
        end
        function sbar.btnUp:Paint(w, h)
            local c_bg, c_txt = TacRP.GetPanelColor("bg2", self:IsHovered()), TacRP.GetPanelColor("text", self:IsHovered())
            surface.SetDrawColor(c_bg)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText("↑", "TacRP_HD44780A00_5x8_4", w / 2, h / 2, c_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        function sbar.btnDown:Paint(w, h)
            local c_bg, c_txt = TacRP.GetPanelColor("bg2", self:IsHovered()), TacRP.GetPanelColor("text", self:IsHovered())        surface.SetDrawColor(c_bg)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText("↓", "TacRP_HD44780A00_5x8_4", w / 2, h / 2, c_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        function sbar.btnGrip:Paint(w, h)
            local c_bg, c_cnr = TacRP.GetPanelColor("bg2", self:IsHovered()), TacRP.GetPanelColor("corner", self:IsHovered())        surface.SetDrawColor(c_bg)
            TacRP.DrawCorneredBox(0, 0, w, h, c_cnr)
        end
        local stat_layout = vgui.Create("DIconLayout", stat_scroll)
        stat_layout:Dock(FILL)
        stat_layout:SetLayoutDir(TOP)
        -- stat_layout:SetSpaceY(TacRP.SS(2))
        populate_stats(stat_layout)

        stat_box.PaintOver = function(self2, w, h)
            if !IsValid(self) then return end
            local panel = vgui.GetHoveredPanel()
            if self.StatRows[panel] then
                local stat = statdisplay[self.StatRows[panel]]

                local todo = DisableClipping(true)
                local col_bg = Color(0, 0, 0, 254)
                local col_corner = Color(255, 255, 255)
                local col_text = Color(255, 255, 255)
                local rx, ry = self2:CursorPos()
                rx = rx + TacRP.SS(16)
                ry = ry + TacRP.SS(16)

                local desc = istable(stat.Description) and stat.Description or TacRP:GetPhrase(stat.Description) or stat.Description or ""
                if isstring(desc) then
                    desc = string.Explode("\n", desc)
                end

                if self2:GetY() + ry >= TacRP.SS(280) then
                    ry = ry - TacRP.SS(60)
                end

                if self2:GetX() + rx + TacRP.SS(160) >= ScrW() then
                    rx = rx - TacRP.SS(160)
                end

                local bw, bh = TacRP.SS(160), TacRP.SS(12 + (6 * #desc))
                surface.SetDrawColor(col_bg)
                TacRP.DrawCorneredBox(rx, ry, bw, bh, col_corner)

                local txt = TacRP:GetPhrase(stat.Name) or stat.Name
                surface.SetTextColor(col_text)
                surface.SetFont("TacRP_Myriad_Pro_10")
                surface.SetTextPos(rx + TacRP.SS(2), ry + TacRP.SS(1))
                surface.DrawText(txt)

                surface.SetFont("TacRP_Myriad_Pro_6")
                for i, k in pairs(desc) do
                    surface.SetTextPos(rx + TacRP.SS(2), ry + TacRP.SS(1 + 8 + 2) + (TacRP.SS(6 * (i - 1))))
                    surface.DrawText(k)
                end

                DisableClipping(todo)
            end
        end

        local tabs = {group_box, stat_box}
        self.ActiveTab = self.ActiveTab or 1

        -- local tab_list = vgui.Create("DPanel", bg)
        -- tab_list:SetSize(TacRP.SS(172), tabs_h)
        -- tab_list:SetPos(scrw - TacRP.SS(172) - airgap, stack + smallgap)
        -- tab_list:SetMouseInputEnabled(false)
        -- tab_list.Paint = function() return end

        local tabs_w = TacRP.SS(172) / #tabs - #tabs * TacRP.SS(0.5)
        for i = 1, #tabs do
            if i != self.ActiveTab then
                tabs[i]:Hide()
            end

            local tab_button = vgui.Create("DLabel", bg)
            tab_button.TabIndex = i
            tab_button:SetSize(tabs_w, tabs_h)
            tab_button:SetPos(scrw - TacRP.SS(172) - airgap + (TacRP.SS(2) + tabs_w) * (i - 1), stack + smallgap)
            tab_button:SetText("")
            tab_button:SetMouseInputEnabled(true)
            tab_button:MoveToFront()
            tab_button.Paint = function(self2, w2, h2)
                if !IsValid(self) then return end

                local hover = self2:IsHovered()
                local selected = self.ActiveTab == i

                local col_bg = Color(0, 0, 0, 150)
                local col_corner = Color(255, 255, 255)
                local col_text = Color(255, 255, 255)

                if selected then
                    col_bg = Color(150, 150, 150, 150)
                    col_corner = Color(50, 50, 255)
                    col_text = Color(0, 0, 0)
                    if hover then
                        col_bg = Color(255, 255, 255)
                        col_corner = Color(150, 150, 255)
                        col_text = Color(0, 0, 0)
                    end
                elseif hover then
                    col_bg = Color(255, 255, 255)
                    col_corner = Color(0, 0, 0)
                    col_text = Color(0, 0, 0)
                end

                surface.SetDrawColor(col_bg)
                surface.DrawRect(0, 0, w2, h2)
                TacRP.DrawCorneredBox(0, 0, w2, h2, col_corner)

                draw.SimpleText(tabs[i].PrintName, "TacRP_Myriad_Pro_8", w2 / 2, h2 / 2, col_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            tab_button.DoClick = function(self2)
                if self2.TabIndex == self.ActiveTab then return end
                self.ActiveTab = self2.TabIndex
                for j = 1, #tabs do
                    if j != self.ActiveTab then
                        tabs[j]:Hide()
                    else
                        tabs[j]:Show()
                    end
                end
            end
        end
    end

    local attachment_slots = {}

    local offset = (scrh - (TacRP.SS(34 + 8) * table.Count(self.Attachments))) / 2

    self.Attachments["BaseClass"] = nil

    if TacRP.ConVars["cust_legacy"]:GetBool() then

        for slot, attslot in pairs(self.Attachments) do
            local atts = TacRP.GetAttsForCats(attslot.Category or "")

            attachment_slots[slot] = {}

            local slot_name = vgui.Create("DPanel", bg)
            slot_name:SetPos(airgap, offset + airgap - TacRP.SS(8) + ((slot - 1) * TacRP.SS(34 + 8)))
            slot_name:SetSize(TacRP.SS(128), TacRP.SS(8))
            slot_name.Paint = function(self2, w, h)
                if !IsValid(self) then return end

                local txt = TacRP:TryTranslate(attslot.PrintName or "Slot")
                if txt then
                    surface.SetFont("TacRP_Myriad_Pro_8")
                    surface.SetTextColor(Color(255, 255, 255))
                    surface.SetTextPos(0, 0)
                    surface.DrawText(txt)
                end
            end

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

            local prosconspanel = vgui.Create("DPanel", bg)
            prosconspanel:SetPos(airgap + ((table.Count(atts)) * TacRP.SS(34)), offset + airgap + ((slot - 1) * TacRP.SS(34 + 8)))
            prosconspanel:SetSize(TacRP.SS(128), TacRP.SS(34))
            prosconspanel.Paint = function(self2, w, h)
                if !IsValid(self) then return end

                local installed = attslot.Installed

                if !installed then return end

                local atttbl = TacRP.GetAttTable(installed)

                local pros = atttbl.Pros or {}
                local cons = atttbl.Cons or {}

                local c = 0

                for i, pro in pairs(pros) do
                    surface.SetFont("TacRP_Myriad_Pro_8")
                    surface.SetTextColor(Color(50, 255, 50))
                    surface.SetTextPos(0, TacRP.SS(c * 8))
                    surface.DrawText("+" .. TacRP:TryTranslate(pro))

                    c = c + 1
                end

                for i, con in pairs(cons) do
                    surface.SetFont("TacRP_Myriad_Pro_8")
                    surface.SetTextColor(Color(255, 50, 50))
                    surface.SetTextPos(0, TacRP.SS(c * 8))
                    surface.DrawText("-" .. TacRP:TryTranslate(con))

                    c = c + 1
                end
            end

            for i, att in pairs(atts) do
                local slot_panel = vgui.Create("TacRPAttSlot", bg)
                table.insert(attachment_slots[slot], slot_panel)
                slot_panel:SetSlot(slot)
                slot_panel:SetShortName(att)
                slot_panel:SetWeapon(self)
                slot_panel:SetPos(airgap + ((i - 1) * TacRP.SS(34)), offset + airgap + ((slot - 1) * TacRP.SS(34 + 8)))
                slot_panel:SetSize(TacRP.SS(32), TacRP.SS(32))
            end
        end

    else

        local rows = 1
        local cnt = table.Count(self.Attachments)
        if cnt > 5 then cnt = math.ceil(cnt / 2) rows = 2 end
        local ph = math.min(scrh, TacRP.SS((42 + 6) * cnt))

        local layout = vgui.Create("DIconLayout", bg)
        layout:SetSize(TacRP.SS(32 * rows + 6 * (rows - 1)), ph)
        layout:SetPos(airgap, scrh / 2 - ph / 2)
        layout:SetSpaceX(math.floor(TacRP.SS(6)))
        layout:SetSpaceY(math.floor(TacRP.SS(6)))
        layout:SetLayoutDir(LEFT)

        local scroll = vgui.Create("DScrollPanel", bg)
        scroll:SetSize(TacRP.SS(36), scrh * 0.9)
        scroll:SetPos(airgap * 2 + layout:GetWide(), scrh * 0.05)
        scroll:SetVisible(false)

        local slotlayout = vgui.Create("TacRPAttSlotLayout", scroll)
        slotlayout:SetSize(TacRP.SS(36), scrh)
        slotlayout:SetWeapon(self)
        slotlayout:SetScroll(scroll)
        slotlayout:SetSpaceY(TacRP.SS(4))
        slotlayout:SetLayoutDir(TOP)
        if self.LastCustomizeSlot then
            slotlayout:SetSlot(self.LastCustomizeSlot)
        end
        -- slotlayout:Dock(FILL)

        for slot, attslot in pairs(self.Attachments) do
            attachment_slots[slot] = {}

            local slot_bg = vgui.Create("DPanel", layout)
            slot_bg:SetSize(TacRP.SS(32), TacRP.SS(42))
            slot_bg.Paint = function() end

            local slot_icon = vgui.Create("TacRPAttSlot", slot_bg)
            slot_icon:SetSlot(slot)
            if (attslot.Installed or "") != "" then
                slot_icon:SetShortName(attslot.Installed)
            end
            slot_icon:SetWeapon(self)
            slot_icon:SetIsMenu(true)
            slot_icon:SetSlotLayout(slotlayout)
            slot_icon:SetPos(0, TacRP.SS(10))
            slot_icon:SetSize(TacRP.SS(32), TacRP.SS(32))

            local slot_name = vgui.Create("DPanel", slot_bg)
            slot_name:SetSize(TacRP.SS(32), TacRP.SS(8))
            slot_name.Paint = function(self2, w, h)
                if !IsValid(self) then return end
                local col_bg, col_corner, col_text = slot_icon:GetColors()

                surface.SetDrawColor(col_bg)
                surface.DrawRect(0, 0, w, h)
                TacRP.DrawCorneredBox(0, 0, w, h, col_corner)

                local txt = TacRP:TryTranslate(attslot.PrintName or "Slot")
                if txt then
                    draw.SimpleText(txt, "TacRP_Myriad_Pro_8", w / 2, h / 2, col_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end
    end

    local cvarbox = vgui.Create("DCheckBox", bg)
    cvarbox:SetSize(TacRP.SS(8), TacRP.SS(8))
    cvarbox:SetPos(airgap, scrh - TacRP.SS(10))
    cvarbox:SetText("")
    cvarbox:SetConVar("tacrp_cust_legacy")
    function cvarbox.Paint(self2, w, h)
        local c_bg, c_cnr, c_txt = TacRP.GetPanelColors(self2:IsHovered(), self2:GetChecked())
        surface.SetDrawColor(c_bg)
        surface.DrawRect(0, 0, w, h)
        TacRP.DrawCorneredBox(0, 0, w, h, c_cnr)
        if self2:GetChecked() then
            draw.SimpleText("O", "TacRP_HD44780A00_5x8_4", w / 2, h / 2, c_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        local todo = DisableClipping(true)

        draw.SimpleText("Legacy Menu", "TacRP_Myriad_Pro_8", w + TacRP.SS(2), h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)


        DisableClipping(todo)
    end
    function cvarbox.DoClick(self2)
        self2:Toggle()
        timer.Simple(0, function()
            self:CreateCustomizeHUD()
        end)
    end

    -- tacrp_drop
    local primarygrenade = self:GetValue("PrimaryGrenade")
    if (engine.ActiveGamemode() == "terrortown" or TacRP.ConVars["allowdrop"]:GetBool()) and TacRP.ConVars["cust_drop"]:GetBool() and (!primarygrenade or !TacRP.IsGrenadeInfiniteAmmo(primarygrenade)) then
        local phrase = primarygrenade and "cust.drop_nade" or "cust.drop_wep"
        local dropbox = vgui.Create("DButton", bg)
        local bw, bh = TacRP.SS(52), TacRP.SS(10)
        dropbox:SetSize(bw, bh)
        dropbox:SetPos(ScrW() / 2 - bw / 2, scrh - bh - smallgap / 2)
        dropbox:SetText("")
        function dropbox.Paint(self2, w, h)
            local c_bg, c_cnr, c_txt = TacRP.GetPanelColors(self2:IsHovered(), self2:IsDown())
            surface.SetDrawColor(c_bg)
            -- surface.DrawRect(0, 0, w, h)
            TacRP.DrawCorneredBox(0, 0, w, h, c_cnr)
            draw.SimpleText(TacRP:GetPhrase(phrase), "TacRP_Myriad_Pro_8", w / 2, h / 2, c_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        end
        function dropbox.DoClick(self2)
            if engine.ActiveGamemode() == "terrortown" then
                LocalPlayer():ConCommand("ttt_dropweapon")
            else
                LocalPlayer():ConCommand("tacrp_drop")
            end
        end
    end

    local news_s = TacRP.SS(12)
    local news_i = TacRP.SS(8)
    local newsbutton = vgui.Create("DButton", bg)
    newsbutton:SetSize(news_s, news_s)
    newsbutton:SetPos(smallgap, smallgap / 2)
    newsbutton:SetText("")
    function newsbutton.Paint(self2, w, h)
        local c_bg, c_cnr, c_txt = TacRP.GetPanelColors(self2:IsHovered(), self2:IsDown())
        surface.SetDrawColor(c_bg)
        TacRP.DrawCorneredBox(0, 0, w, h, c_cnr)

        if self2.flash then
            local todo = DisableClipping(true)
            draw.NoTexture()
            surface.SetDrawColor(c_bg)
            draw.SimpleTextOutlined(string.upper(self2.flash), "TacRP_HD44780A00_5x8_6", w + smallgap, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 150))
            DisableClipping(todo)
            local c = (math.sin(SysTime() * 10)) * 30 + (self2:IsHovered() and 50 or 225)
            surface.SetDrawColor(c, c, c, 255)
        else
            surface.SetDrawColor(c_txt)
        end

        surface.SetMaterial(news)
        surface.DrawTexturedRect((news_s - news_i) / 2, (news_s - news_i) / 2, news_i,news_i)
    end
    function newsbutton.DoClick(self2)
        LocalPlayer():ConCommand("tacrp_news")
    end
    TacRP.FetchNews(function()
        for i, v in ipairs(TacRP.NewsLoaded) do
            if !TacRP.NewsRead[v.Key] then
                newsbutton.flash = v.Type or "article"
                break
            end
        end
    end)

    self.StaticStats = false
end

function SWEP:RemoveCustomizeHUD()
    if self.CustomizeHUD then
        self.CustomizeHUD:Remove()

        if (self.GrenadeMenuAlpha or 0) != 1 and (self.BlindFireMenuAlpha or 0) != 1 then
            gui.EnableScreenClicker(false)
            TacRP.CursorEnabled = false
        end

        self.LastHintLife = CurTime()
    end
end

function SWEP:DrawCustomizeHUD()

    local customize = self:GetCustomize()

    if customize and !lastcustomize then
        self:CreateCustomizeHUD()
    elseif !customize and lastcustomize then
        self:RemoveCustomizeHUD()
    end

    lastcustomize = self:GetCustomize()

    -- if self:GetCustomize() then
    --     customizedelta = math.Approach(customizedelta, 1, FrameTime() * 1 / 0.25)
    -- else
    --     customizedelta = math.Approach(customizedelta, 0, FrameTime() * 1 / 0.25)
    -- end

    -- local curvedcustomizedelta = self:Curve(customizedelta)

    -- if curvedcustomizedelta > 0 then
    --     RunConsoleCommand("pp_bokeh", "1")
    -- else
    --     RunConsoleCommand("pp_bokeh", "0")
    -- end

    -- RunConsoleCommand("pp_bokeh_blur", tostring(curvedcustomizedelta * 5))
    -- RunConsoleCommand("pp_bokeh_distance", 0)
    -- RunConsoleCommand("pp_bokeh_focus", tostring(((1 - curvedcustomizedelta) * 11) + 1))
end