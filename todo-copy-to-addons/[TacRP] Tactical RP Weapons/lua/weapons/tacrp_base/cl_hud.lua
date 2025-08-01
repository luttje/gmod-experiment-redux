function SWEP:ShouldDrawCrosshair()
    if !TacRP.ConVars["crosshair"]:GetBool() then
        return self:DoLowerIrons() and self:GetSightAmount() > 0 and !self:GetPeeking() and !self:GetReloading()
    end
    return !self:GetReloading() and !self:GetCustomize() and !self:GetSafe() and self:GetBlindFireMode() == TacRP.BLINDFIRE_NONE
        and !(self:SprintLock() and !self.DrawCrosshairInSprint)
        and (self:GetSightAmount() <= 0.5 or self:GetPeeking() or self:DoLowerIrons())
        and !(self:GetValue("CanQuickNade") and tobool(self:GetOwner():GetInfo("tacrp_nademenu")) and self:GetOwner():KeyDown(IN_GRENADE2))
        and !(self:GetValue("CanBlindFire") and tobool(self:GetOwner():GetInfo("tacrp_blindfiremenu")) and (self:GetOwner():KeyDown(IN_ZOOM) or self:GetOwner().TacRPBlindFireDown))
end

function SWEP:DoDrawCrosshair(x, y)
    local ft = FrameTime()
    local ply = self:GetOwner()

    self.CrosshairAlpha = self.CrosshairAlpha or 0
    if !self:ShouldDrawCrosshair() then
        self.CrosshairAlpha = math.Approach(self.CrosshairAlpha, 0, -10 * ft)
    else
        self.CrosshairAlpha = math.Approach(self.CrosshairAlpha, 1, 5 * ft)
    end

    local dev = GetConVar("developer"):GetInt() > 0 and LocalPlayer():IsAdmin()
    local tacfunc
    if self:GetValue("TacticalCrosshair") and self:GetTactical() then
        tacfunc = self:GetValue("TacticalCrosshair")
    elseif !dev and self.CrosshairAlpha <= 0 then return true end

    local loweriron = self:DoLowerIrons() and self:GetSightAmount() > 0 and !self:GetPeeking() and !self:GetReloading()

    local dir = self:GetShootDir(true)

    local tr = util.TraceLine({
        start = self:GetMuzzleOrigin(),
        endpos = self:GetMuzzleOrigin() + (dir:Forward() * 50000),
        mask = MASK_SHOT,
        filter = self:GetOwner()
    })
    cam.Start3D()
        local w2s = tr.HitPos:ToScreen()
        x = math.Round(w2s.x)
        y = math.Round(w2s.y)
    cam.End3D()
    local x2, y2 = x, y

    local spread = TacRP.GetFOVAcc(self)
    local sway = self:IsSwayEnabled() and self:GetSwayAmount() or self:GetForcedSwayAmount()

    local truepos = self:GetValue("TacticalCrosshairTruePos")
    if dev or truepos then
        local tr2 = util.TraceLine({
            start = self:GetMuzzleOrigin(),
            endpos = self:GetMuzzleOrigin() + (self:GetShootDir():Forward() * 50000),
            mask = MASK_SHOT,
            filter = self:GetOwner()
        })
        cam.Start3D()
            local tw2s = tr2.HitPos:ToScreen()
            x2 = math.Round(tw2s.x)
            y2 = math.Round(tw2s.y)
        cam.End3D()
    end

    if tacfunc then
        tacfunc(self, truepos and x2 or x, truepos and y2 or y, spread, sway)
    end

    spread = math.Round( math.max(spread, 2) + TacRP.SS(sway * math.pi))

    if !dev and self.CrosshairAlpha <= 0 then return true end

    local clr
    if TacRP.ConVars["ttt_rolecrosshair"] and TacRP.ConVars["ttt_rolecrosshair"]:GetBool() then
        if GetRoundState() == ROUND_PREP or GetRoundState() == ROUND_POST then
            clr = Color(255, 255, 255)
        elseif ply.GetRoleColor and ply:GetRoleColor() then
            clr = ply:GetRoleColor() -- TTT2 feature
        elseif ply:IsActiveTraitor() then
            clr = Color(255, 50, 50)
        elseif ply:IsActiveDetective() then
            clr = Color(50, 50, 255)
        else
            clr = Color(50, 255, 50)
        end
    end

    if loweriron then
        clr = clr or color_white
        surface.SetDrawColor(clr.r, clr.g, clr.b, clr.a * self.CrosshairAlpha * 0.75 * self:GetSightAmount())
        surface.DrawRect(x - 1, y - 1, 3, 3)

        surface.SetDrawColor(0, 0, 0, clr.a * self.CrosshairAlpha * self:GetSightAmount() * 0.5)
        surface.DrawOutlinedRect(x - 2, y - 2, 5, 5, 1)
    elseif TacRP.ConVars["crosshair"]:GetBool() then
        clr = clr or Color(50, 255, 50)
        surface.SetDrawColor(clr.r, clr.g, clr.b, clr.a * self.CrosshairAlpha)

        surface.DrawRect(x, y, 1, 1)
        if self.CrosshairStatic then spread = 16 end
        local w = 16
        surface.DrawLine(x, y - spread - w, x, y - spread)
        surface.DrawLine(x, y + spread, x, y + spread + w)
        surface.DrawLine(x - spread - w, y, x - spread, y)
        surface.DrawLine(x + spread, y, x + spread + w, y)
    end

    -- Developer Crosshair
    if dev then

        if self:StillWaiting() then
            surface.SetDrawColor(150, 150, 150, 255)
        else
            surface.SetDrawColor(255, 50, 50, 255)
        end
        surface.DrawLine(x2, y2 - 256, x2, y2 + 256)
        surface.DrawLine(x2 - 256, y2, x2 + 256, y2)
        spread = TacRP.GetFOVAcc(self)
        local recoil_txt = "Recoil: " .. tostring(math.Round(self:GetRecoilAmount() or 0, 3))
        surface.DrawCircle(x2, y2, spread, 255, 255, 255, 150)
        surface.DrawCircle(x2, y2, spread + 1, 255, 255, 255, 150)
        surface.SetFont("TacRP_Myriad_Pro_32_Unscaled")
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(x2 - 256, y2)
        surface.DrawText(recoil_txt)
        local spread_txt = tostring("Cone: " .. math.Round(math.deg(self:GetSpread()), 3)) .. " deg"
        surface.SetTextPos(x2 - 256, y2 - 34)
        surface.DrawText(spread_txt)
        local spread_txt = tostring(math.Round( math.deg(self:GetSpread()) * 60, 3)) .. "MOA"
        surface.SetTextPos(x2 - 256, y2 - 66)
        surface.DrawText(spread_txt)
        -- local tw = surface.GetTextSize(spread_txt)
        -- surface.SetTextPos(x2 + 256 - tw, y2)
        -- surface.DrawText(spread_txt)

        local dist = (tr.HitPos - tr.StartPos):Length()
        local dist_txt = math.Round(dist) .. " HU"
        local tw = surface.GetTextSize(dist_txt)
        surface.SetTextPos(x2 + 256 - tw, y2)
        surface.DrawText(dist_txt)

        local damage_txt = math.Round(self:GetDamageAtRange(dist)) .. " DMG"
        local tw2 = surface.GetTextSize(damage_txt)
        surface.SetTextPos(x2 + 256 - tw2, y2 - 34)
        surface.DrawText(damage_txt)

        local sprint_txt = math.Round(self:GetSprintAmount() * 100) .. "%"
        local tw3 = surface.GetTextSize(sprint_txt)
        surface.SetTextPos(x2 - tw3 * 0.5, y2 + 256)
        surface.DrawText(sprint_txt)

        local sight_txt = math.Round(self:GetSightAmount() * 100) .. "%"
        local tw4 = surface.GetTextSize(sight_txt)
        surface.SetTextPos(x2 - tw4 * 0.5, y2 + 256 + 32)
        surface.DrawText(sight_txt)
    end

    return true
end

function SWEP:GetBinding(bind)
    local t_bind = input.LookupBinding(bind)

    if !t_bind then
        t_bind = "BIND " .. bind .. "!"
    end

    return string.upper(t_bind)
end

local mat_vignette = Material("tacrp/hud/vignette.png", "mips smooth")
local mat_radial = Material("tacrp/grenades/radial.png", "mips smooth")

local rackrisetime = 0
local lastrow = 0

local lasthp = 0
local lasthealtime = 0
local lastdmgtime = 0
local lastarmor = 0

local faceindex = 0

local shockedtime = 0
local lastblindfiremode = 0

local col = Color(255, 255, 255)
local col_hi = Color(255, 150, 0)
local col_hi2 = Color(255, 230, 200)
local col_dark = Color(255, 255, 255, 20)

function SWEP:ShouldDrawBottomBar()
    return self:GetFiremodeAmount() > 0 or self:GetValue("CanQuickNade")
end

function SWEP:DrawBottomBar(x, y, w, h)
    if self:GetFiremodeAmount() > 0 then
        if self:GetSafe() then
            surface.SetMaterial(self:GetFiremodeMat(0))
        else
            surface.SetMaterial(self:GetFiremodeMat(self:GetCurrentFiremode()))
        end
        surface.SetDrawColor(col)
        local sfm = TacRP.SS(14)
        surface.DrawTexturedRect(x + w - sfm - TacRP.SS(1 + 10), y + h - sfm - TacRP.SS(1), sfm, sfm)
    end

    if self:GetFiremodeAmount() > 1 and !self:GetSafe() then
        local nextfm = TacRP.GetBind("use") .. "+" .. TacRP.GetBind("reload")

        surface.SetTextColor(col)
        surface.SetFont("TacRP_HD44780A00_5x8_4")
        local tw = surface.GetTextSize(nextfm)
        surface.SetTextPos(x + w - tw - TacRP.SS(2), y + h - TacRP.SS(14))
        surface.DrawText(nextfm)

        surface.SetMaterial(self:GetFiremodeMat(self:GetNextFiremode()))
        surface.SetDrawColor(col)
        local nfm = TacRP.SS(8)
        surface.DrawTexturedRect(x + w - nfm - TacRP.SS(4), y + h - nfm - TacRP.SS(1), nfm, nfm)
    elseif self:GetSafe() then
        surface.SetMaterial(self:GetFiremodeMat(self:GetCurrentFiremode()))
        surface.SetDrawColor(col)
        local nfm = TacRP.SS(8)
        surface.DrawTexturedRect(x + w - nfm - TacRP.SS(4), y + h - nfm - TacRP.SS(1), nfm, nfm)
    end

    if self:GetValue("CanQuickNade") then
        local nade = self:GetGrenade()

        local qty = nil --"INF"

        if nade.Singleton then
            qty = self:GetOwner():HasWeapon(nade.GrenadeWep) and 1 or 0
        elseif !TacRP.IsGrenadeInfiniteAmmo(nade.Index) then
            qty = self:GetOwner():GetAmmoCount(nade.Ammo)
        end

        local sg = TacRP.SS(14)

        if nade.Icon then
            surface.SetMaterial(nade.Icon)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawTexturedRect(x + TacRP.SS(2), y + h - sg - TacRP.SS(1), sg, sg)
        end

        local nadetext = nade.PrintName .. (qty and ("x" .. qty) or "")
        surface.SetTextPos(x + TacRP.SS(4) + sg, y + h - sg + TacRP.SS(1))
        surface.SetFont("TacRP_HD44780A00_5x8_8")
        surface.SetTextColor(col)
        surface.DrawText(nadetext)

        local mat = nil
        if !TacRP.ConVars["nademenu"]:GetBool() then
            mat = self:GetNextGrenade().Icon
        else
            mat = mat_radial
        end

        local nsg = TacRP.SS(10)

        if mat then
            surface.SetMaterial(mat)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawTexturedRect(x + w - TacRP.SS(41), y + h - nsg - TacRP.SS(1), nsg, nsg)
        end

        local nextnadetxt = TacRP.GetBind("grenade2")

        surface.SetTextColor(col)
        surface.SetFont("TacRP_HD44780A00_5x8_4")
        local tw = surface.GetTextSize(nextnadetxt)
        surface.SetTextPos(x + w - TacRP.SS(36) - (tw / 2), y + h - nsg - TacRP.SS(4))
        surface.DrawText(nextnadetxt)
    end
end

local breath_a = 0
local last = 1
local lastt = 0
function SWEP:DrawBreathBar(x, y, w, h)
    if CurTime() > lastt + 1 then
        breath_a = math.Approach(breath_a, 0, FrameTime() * 2)
    elseif breath_a < 1 then
        breath_a = math.Approach(breath_a, 1, FrameTime())
    end
    local breath = self:GetBreath()
    if last != self:GetBreath() then
        lastt = CurTime()
        last = breath
    end
    if breath_a == 0 then return end

    x = x - w / 2
    y = y - h / 2

    surface.SetDrawColor(90, 90, 90, 200 * breath_a)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2, 1)
    surface.SetDrawColor(0, 0, 0, 75 * breath_a)
    surface.DrawRect(x, y, w, h)

    if self:GetOutOfBreath() then
        surface.SetDrawColor(255, 255 * breath ^ 0.5, 255 * breath, 150 * breath_a)
    else
        surface.SetDrawColor(255, 255, 255, 150 * breath_a)
    end

    surface.DrawRect(x, y, w * self:GetBreath(), h)
end

function SWEP:DrawHUDBackground()
    self:DoScope()

    if !GetConVar("cl_drawhud"):GetBool() then return end

    -- draw a vignette effect around the screen based on recoil
    local recoil = self:GetRecoilAmount()
    if recoil > 0 and TacRP.ConVars["vignette"]:GetBool() then
        local recoil_pct = math.Clamp(recoil / self:GetValue("RecoilMaximum"), 0, 1) ^ 1.25
        local delta = self:Curve(recoil_pct)
        surface.SetDrawColor(0, 0, 0, 200 * delta)
        surface.SetMaterial(mat_vignette)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    end

    if self:GetValue("BlindFireCamera") then
        self:DoCornershot()
    end

    if self:GetValue("TacticalDraw") and self:GetTactical() then
        self:GetValue("TacticalDraw")(self)
    end

    self:DrawCustomizeHUD()

    if !self:GetCustomize() and TacRP.ConVars["hints"]:GetBool() then
        self:DrawHints()
    end

    if !self:GetCustomize() and TacRP.ConVars["hud"]:GetBool() then

        if TacRP.ConVars["drawhud"]:GetBool() and engine.ActiveGamemode() != "terrortown" then

            local w = TacRP.SS(110)
            local h = TacRP.SS(40)
            local x = ScrW() - w - TacRP.SS(8)
            local y = ScrH() - h - TacRP.SS(8)

            surface.SetDrawColor(0, 0, 0, 150)
            TacRP.DrawCorneredBox(x, y, w, h, col)

            surface.SetFont("TacRP_HD44780A00_5x8_8")
            local tw = surface.GetTextSize(self.PrintName)
            surface.SetTextPos(x + TacRP.SS(3), y + TacRP.SS(1))
            if tw > w then
                surface.SetFont("TacRP_HD44780A00_5x8_6")
                tw = surface.GetTextSize(self.PrintName)
            elseif tw > w - TacRP.SS(3) then
                surface.SetTextPos(x + TacRP.SS(1.5), y + TacRP.SS(1))
            end
            surface.SetTextColor(col)
            surface.DrawText(self.PrintName)

            local ammotype = self:GetValue("PrimaryGrenade") and (TacRP.QuickNades[self:GetValue("PrimaryGrenade")].Ammo) or self:GetValue("Ammo")
            local clips = math.min(math.ceil(self:GetOwner():GetAmmoCount(ammotype)), 999)

            if self.Primary.ClipSize > 0 then

                if TacRP.ConVars["hud_ammo_number"]:GetBool() then
                    surface.SetFont("TacRP_HD44780A00_5x8_10")
                    local t = math.max(0, self:Clip1()) .. " /" .. self.Primary.ClipSize
                    local tw = surface.GetTextSize(t)
                    surface.SetTextColor(col)
                    surface.SetTextPos(x + w - tw - TacRP.SS(40), y + TacRP.SS(12))
                    surface.DrawText(t)
                else
                    local sb = TacRP.SS(4)
                    local xoffset = TacRP.SS(77)
                    -- local pw = TacRP.SS(1)

                    local row1_bullets = 0
                    local row2_bullets = 0
                    local rackrise = 0
                    local cs = self:GetCapacity()
                    local c1 = self:Clip1()
                    local aps = self:GetValue("AmmoPerShot")

                    local row_size = 15
                    if cs == 20 then
                        row_size = 10
                    end

                    local row = math.ceil(c1 / row_size)
                    local maxrow = math.ceil(cs / row_size)

                    local row2_size = math.min(row_size, self:GetCapacity())
                    local row1_size = math.Clamp(self:GetCapacity() - row2_size, 0, row_size)

                    if c1 > row_size * 2 then
                        if row == maxrow then
                            row1_size = cs - row_size * (maxrow - 1)
                            row1_bullets = c1 - row_size * (maxrow - 1)
                        elseif c1 % row_size == 0 then
                            row1_bullets = row_size
                        else
                            row1_bullets = c1 % row_size
                        end
                        row2_bullets = row2_size
                    else
                        row2_bullets = math.min(row2_size, c1)
                        row1_bullets = math.min(row1_size, c1 - row2_bullets)
                    end

                    if row > 1 and row < lastrow then
                        rackrisetime = CurTime()
                    end
                    lastrow = row

                    if rackrisetime + 0.2 > CurTime() then
                        local rackrisedelta = ((rackrisetime + 0.2) - CurTime()) / 0.2
                        rackrise = rackrisedelta * (sb + TacRP.SS(1))
                    end

                    render.SetScissorRect(x, y, x + w, y + TacRP.SS(12) + sb + sb + 3, true)

                    for i = 1, row1_size do
                        if i >= row1_bullets - aps + 1 and i <= row1_bullets then
                            surface.SetDrawColor(col_hi)
                        elseif i > row1_bullets then
                            surface.SetDrawColor(col_dark)
                        elseif i % 5 == 0 then
                            surface.SetDrawColor(col_hi2)
                        else
                            surface.SetDrawColor(col)
                        end
                        surface.DrawRect(x + xoffset - (i * (sb + TacRP.SS(1))), y + TacRP.SS(12) + rackrise, sb, sb)
                    end

                    local hi_left = math.max(0, aps - row1_bullets)
                    for i = 1, row2_size do
                        if (i >= row2_bullets - aps + 1 and i <= row2_bullets and row1_bullets <= 0) or (row1_bullets > 0 and hi_left > 0 and i >= row2_bullets - hi_left + 1 and i <= row2_bullets) then
                            surface.SetDrawColor(col_hi)
                        elseif i > row2_bullets then
                            surface.SetDrawColor(col_dark)
                        elseif i % 5 == 0 then
                            surface.SetDrawColor(col_hi2)
                        else
                            surface.SetDrawColor(col)
                        end

                        if row1_size == 0 and row2_size <= 10 then
                            local m = 1.5
                            if row2_size <= 5 then
                                m = 2
                            end

                            surface.DrawRect(x + xoffset - (i * (sb * m + TacRP.SS(1))), y + TacRP.SS(12 + 1) + sb * (2 - m) / 2, sb * m, sb * m)
                        -- elseif row > 2 and i <= row - 2 then
                        --     surface.DrawRect(x + xoffset - (i * (sb + TacRP.SS(1))), y + TacRP.SS(12 + 1) + sb + rackrise, sb, sb)
                        --     surface.SetDrawColor(col_hi)
                        --     surface.DrawRect(x + xoffset - (i * (sb + TacRP.SS(1))) + sb / 2 - pw / 2, y + TacRP.SS(12 + 1) + sb + rackrise, pw, sb)
                        --     surface.DrawRect(x + xoffset - (i * (sb + TacRP.SS(1))), y + TacRP.SS(12 + 1) + sb + rackrise + sb / 2 - pw / 2, sb, pw)
                        else
                            surface.DrawRect(x + xoffset - (i * (sb + TacRP.SS(1))), y + TacRP.SS(12 + 1) + sb + rackrise, sb, sb)
                        end
                    end
                end

                render.SetScissorRect(0, 0, 0, 0, false)

                if self.Primary.ClipSize <= 0 and ammotype == "" then
                    clips = ""
                elseif ammotype == "" then
                    clips = "---"
                elseif self.Primary.ClipSize > 0 then
                    surface.SetTextColor(col)
                    surface.SetTextPos(x + w - TacRP.SS(31), y + TacRP.SS(16))
                    surface.SetFont("TacRP_HD44780A00_5x8_6")
                    surface.DrawText("+")
                    if (self:GetValue("PrimaryGrenade") and TacRP.IsGrenadeInfiniteAmmo(self:GetValue("PrimaryGrenade"))) or (!self:GetValue("PrimaryGrenade") and self:GetInfiniteAmmo()) then
                        clips = "INF"
                    end
                end

                surface.SetTextColor(col)
                surface.SetTextPos(x + w - TacRP.SS(25), y + TacRP.SS(12))
                surface.SetFont("TacRP_HD44780A00_5x8_10")
                surface.DrawText(clips)
            else
                if ammotype == "" then
                    clips = ""
                elseif (self:GetValue("PrimaryGrenade") and TacRP.IsGrenadeInfiniteAmmo(self:GetValue("PrimaryGrenade"))) or (!self:GetValue("PrimaryGrenade") and self:GetInfiniteAmmo()) then
                    clips = "INF"
                end


                if self:GetValue("PrimaryGrenade") then
                    local nade = TacRP.QuickNades[self:GetValue("PrimaryGrenade")]
                    if nade.Icon then
                        local sg = TacRP.SS(32)
                        surface.SetMaterial(nade.Icon)
                        surface.SetDrawColor(255, 255, 255)
                        surface.DrawTexturedRect(x + TacRP.SS(4), y + h - sg + TacRP.SS(1), sg, sg)
                    end

                    surface.SetTextColor(col)
                    surface.SetTextPos(x + TacRP.SS(36), y + h - TacRP.SS(20))
                    surface.SetFont("TacRP_HD44780A00_5x8_14")
                    surface.DrawText("x" .. clips)
                else
                    surface.SetTextColor(col)
                    surface.SetTextPos(x + TacRP.SS(36), y + TacRP.SS(12))
                    surface.SetFont("TacRP_HD44780A00_5x8_10")
                    surface.DrawText(clips)
                end
            end

            if self:ShouldDrawBottomBar() then
                surface.SetDrawColor(col)
                surface.DrawLine(x + TacRP.SS(2), y + TacRP.SS(24), x + w - TacRP.SS(2), y + TacRP.SS(24))
                self:DrawBottomBar(x, y, w, h)
            end

            if self:GetValue("Bipod") then
                self:DrawBipodHint(x - h / 2 - TacRP.SS(4), y + h - TacRP.SS(10), h / 2)
            end


            local l_w = TacRP.SS(80)
            local l_h = TacRP.SS(40)
            local l_x = TacRP.SS(8)
            local l_y = ScrH() - l_h - TacRP.SS(8)

            local perc = LocalPlayer():Health() / LocalPlayer():GetMaxHealth()

            surface.SetDrawColor(0, 0, 0, 150)
            TacRP.DrawCorneredBox(l_x, l_y, l_w, l_h, col)

            surface.SetTextPos(l_x + TacRP.SS(4), l_y + TacRP.SS(1))
            surface.SetFont("TacRP_HD44780A00_5x8_10")

            if perc <= 0.2 then
                surface.SetTextColor(col_hi)

                if math.sin(CurTime() * 7) > 0.5 then
                    surface.SetTextColor(col)
                end
            elseif perc <= 0.4 then
                surface.SetTextColor(col_hi)
            else
                surface.SetTextColor(col)
            end

            surface.DrawText("♥")

            local hpb_x = l_x + TacRP.SS(14)
            local hpb_y = l_y + TacRP.SS(4)
            local hpb_w = TacRP.SS(2)
            local hpb_h = TacRP.SS(8)

            local hpb_can = math.ceil(20 * perc)

            hpb_can = math.min(hpb_can, 20)

            for i = 1, 20 do
                if hpb_can <= 2 then
                    surface.SetDrawColor(col_hi)
                else
                    surface.SetDrawColor(col)
                end
                if hpb_can >= i then
                    surface.DrawRect(hpb_x + (i * (hpb_w + TacRP.SS(1))), hpb_y, hpb_w, hpb_h)
                else
                    surface.DrawOutlinedRect(hpb_x + (i * (hpb_w + TacRP.SS(1))), hpb_y, hpb_w, hpb_h)
                end
            end

            surface.SetDrawColor(col)

            surface.DrawLine(l_x + TacRP.SS(2), l_y + TacRP.SS(15), l_x + l_w - TacRP.SS(2), l_y + TacRP.SS(15))

            local face = "-_-"

            local blindfiremode = self:GetBlindFireMode()

            if blindfiremode == TacRP.BLINDFIRE_KYS then
                if lastblindfiremode != blindfiremode then
                    shockedtime = CurTime() + 1
                    faceindex = math.random(1, 2)
                end
            end

            lastblindfiremode = blindfiremode

            if lastdmgtime + 1 > CurTime() then
                face = ({
                    "#> <",
                    "(>Д<)",
                    "(@_@)",
                    "(ー;ー)",
                    "(・ロ・)",
                    "゛> <",
                    "(>_メ)",
                    "(*_*)",
                    "゜・+_+"
                })[faceindex]
            elseif shockedtime > CurTime() then
                face = ({
                    ";O-O;",
                    ";>-<;",
                })[faceindex]
            elseif blindfiremode == TacRP.BLINDFIRE_KYS then
                if math.sin(CurTime() * 1) > 0.995 then
                    face = ";>_<;"
                else
                    face = ";o_o;"
                end
            elseif lasthealtime + 1 > CurTime() then
                if perc >= 1 then
                    face = ({
                        "(^ω~)",
                        "(>ω^)",
                        "(>3^)",
                        "(^.~)",
                        "(･ω<)",
                        "(^.~)",
                        "♥(ツ)♥"
                    })[faceindex]

                    if lasthp < LocalPlayer():Health() then
                        lasthealtime = CurTime()

                        faceindex = math.random(1, 7)
                    end
                else
                    face = ({
                        "(^w^)",
                        "('3')",
                        "(♡3♡)",
                        "(ПωП)",
                        "(>3<)",
                        "('w')",
                        "TYSM!"
                    })[faceindex]
                end
            else
                if math.sin(CurTime() * 3) > 0.98 then
                    if perc < 0.1 then
                        face = "(>_<)"
                    elseif perc < 0.25 then
                        face = "(>_<)"
                    elseif perc < 0.5 then
                        face = "(>_<)"
                    elseif perc < 0.95 then
                        face = "(-_-)"
                    else
                        face = "(-_-)"
                    end
                else
                    if perc < 0.1 then
                        face = "(×_×)"
                    elseif perc < 0.25 then
                        face = "(;_;)"
                    elseif perc < 0.5 then
                        face = "(゜_゜)"
                    elseif perc < 0.95 then
                        face = "('_')"
                    else
                        face = "(^_^)"
                    end
                end

                if lasthp > LocalPlayer():Health() then
                    lastdmgtime = CurTime()

                    faceindex = math.random(1, 8)
                elseif lasthp < LocalPlayer():Health() or lastarmor < LocalPlayer():Armor() then
                    lasthealtime = CurTime()

                    faceindex = math.random(1, 7)
                end
            end

            if LocalPlayer():GetNWBool("HasGodMode") or perc > 2.5 then
                if math.sin(CurTime() * 3) > 0.96 then
                    face = "(UwU)"
                else
                    face = "(OwO)"
                end
            end

            surface.SetTextPos(l_x + TacRP.SS(4), l_y + TacRP.SS(22))
            surface.SetFont("TacRP_HD44780A00_5x8_10")
            surface.SetTextColor(col)
            surface.DrawText(face)

            lasthp = LocalPlayer():Health()

            local armor = self:GetOwner():Armor()

            local asq = TacRP.SS(8)
            local ss = TacRP.SS(4)

            local function drawarmorsquare(level, x, y)
                if level == 1 then
                    surface.SetDrawColor(col)
                    surface.DrawOutlinedRect(x, y, asq, asq)
                    surface.DrawOutlinedRect(x + 1, y + 1, asq - 2, asq - 2)
                elseif level == 2 then
                    surface.SetDrawColor(col)
                    surface.DrawRect(x + ((asq - ss) / 2), y + ((asq - ss) / 2), ss, ss)
                    surface.DrawOutlinedRect(x, y, asq, asq)
                    surface.DrawOutlinedRect(x + 1, y + 1, asq - 2, asq - 2)
                else
                    surface.SetDrawColor(col)
                    surface.DrawRect(x, y, asq, asq)
                end
            end

            local cx1 = l_x + l_w - TacRP.SS(20)
            local cy1 = l_y + TacRP.SS(19)
            local cx2 = cx1 + asq + 2
            local cy2 = cy1 + asq + 2

            surface.SetTextPos(cx1 - TacRP.SS(10), cy1 + TacRP.SS(3))
            surface.SetFont("TacRP_HD44780A00_5x8_10")
            surface.SetTextColor(col)
            surface.DrawText("⌂")

            if armor >= 100 then
                drawarmorsquare(3, cx1, cy1)
            elseif armor > 75 then
                drawarmorsquare(2, cx1, cy1)
            else
                drawarmorsquare(1, cx1, cy1)
            end

            if armor >= 75 then
                drawarmorsquare(3, cx2, cy1)
            elseif armor > 50 then
                drawarmorsquare(2, cx2, cy1)
            else
                drawarmorsquare(1, cx2, cy1)
            end

            if armor >= 50 then
                drawarmorsquare(3, cx2, cy2)
            elseif armor > 25 then
                drawarmorsquare(2, cx2, cy2)
            else
                drawarmorsquare(1, cx2, cy2)
            end

            if armor >= 25 then
                drawarmorsquare(3, cx1, cy2)
            elseif armor > 0 then
                drawarmorsquare(2, cx1, cy2)
            else
                drawarmorsquare(1, cx1, cy2)
            end
        elseif TacRP.ConVars["minhud"]:GetBool() and self:ShouldDrawBottomBar() then
            local bipod = self:GetValue("Bipod")
            local w = TacRP.SS(110)
            local h = TacRP.SS(16)
            local x = ScrW() / 2 - w / 2
            local y = ScrH() - h - TacRP.SS(8)

            if bipod then x = x - h / 2 - TacRP.SS(2) end

            surface.SetDrawColor(0, 0, 0, 150)
            TacRP.DrawCorneredBox(x, y, w, h, col)

            self:DrawBottomBar(x, y, w, h)

            if bipod then
                self:DrawBipodHint(x + w + TacRP.SS(4), y + h / 2, h)
            end
        end
    end

    if self:GetValue("Scope") or self:GetValue("PrimaryMelee") then
        self:DrawBreathBar(ScrW() * 0.5, ScrH() * 0.65, TacRP.SS(64), TacRP.SS(4))
    end

    self:DrawGrenadeHUD()

    self:DrawBlindFireHUD()

    lastammo = self:Clip1()
    lastarmor = LocalPlayer():Armor()
end

SWEP.Mat_Select = nil

function SWEP:DrawWeaponSelection(x, y, w, h, a)
    if !self.Mat_Select then
        self.Mat_Select = Material(self.IconOverride or  "entities/" .. self:GetClass() .. ".png", "smooth mips")

    end

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(self.Mat_Select)
    if self.IconOverride then
        w = w - 128
        x = x + 64
    end
    if w > h then
        y = y - ((w - h) / 2)
    end

    surface.DrawTexturedRect(x, y, w, w)
end

function SWEP:RangeUnitize(range)
    if TacRP.ConVars["metricunit"]:GetBool() then
        return tostring(math.Round(range * TacRP.HUToM)) .. TacRP:GetPhrase("unit.meter")
    else
        return tostring(math.Round(range)) .. TacRP:GetPhrase("unit.hu")
    end
end

function SWEP:CustomAmmoDisplay()
    self.AmmoDisplay = self.AmmoDisplay or {}
    self.AmmoDisplay.Draw = true

    if TacRP.IsGrenadeInfiniteAmmo(self:GetGrenadeIndex()) then
        self.AmmoDisplay.SecondaryAmmo = 99
    end

    if self.Primary.ClipSize <= 0 and self.Primary.Ammo != "" then
        if self:GetValue("PrimaryGrenade") and TacRP.IsGrenadeInfiniteAmmo(self:GetValue("PrimaryGrenade")) then
            self.AmmoDisplay.SecondaryAmmo = -1
            self.AmmoDisplay.PrimaryClip = -1
            self.AmmoDisplay.PrimaryAmmo = -1
        else
            self.AmmoDisplay.PrimaryClip = self:Ammo1()
            self.AmmoDisplay.PrimaryAmmo = -1
        end
    elseif self.Primary.ClipSize <= 0 then
        self.AmmoDisplay.PrimaryClip = -1
    else
        self.AmmoDisplay.PrimaryClip = self:Clip1()
        self.AmmoDisplay.PrimaryAmmo = self:GetInfiniteAmmo() and 9999 or self:Ammo1()
    end
    return self.AmmoDisplay
end