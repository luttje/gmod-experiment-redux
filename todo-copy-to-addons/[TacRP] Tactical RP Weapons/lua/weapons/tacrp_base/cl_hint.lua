local glyphs = {
    ["MOUSE1"] = Material("tacrp/glyphs/shared_mouse_l_click_lg.png", "mips smooth"),
    ["MOUSE2"] = Material("tacrp/glyphs/shared_mouse_r_click_lg.png", "mips smooth"),
    ["MOUSE3"] = Material("tacrp/glyphs/shared_mouse_mid_click_lg.png", "mips smooth"),
    ["MOUSE4"] = Material("tacrp/glyphs/shared_mouse_4_lg.png", "mips smooth"),
    ["MOUSE5"] = Material("tacrp/glyphs/shared_mouse_5_lg.png", "mips smooth"),

    ["MWHEELUP"] = Material("tacrp/glyphs/shared_mouse_scroll_up_lg.png", "mips smooth"),
    ["MWHEELDOWN"] = Material("tacrp/glyphs/shared_mouse_scroll_down_lg.png", "mips smooth"),
}

local rename = {
    KP_INS        = "KP 0",
    KP_END        = "KP 1",
    KP_DOWNARROW  = "KP 2",
    KP_PGDN       = "KP 3",
    KP_LEFTARROW  = "KP 4",
    KP_5          = "KP 5",
    KP_RIGHTARROW = "KP 6",
    KP_HOME       = "KP 7",
    KP_UPARROW    = "KP 8",
    KP_PGUP       = "KP 9",
    KP_SLASH      = "KP /",
    KP_MULTIPLY   = "KP *",
    KP_MINUS      = "KP -",
    KP_PLUS       = "KP +",
    KP_ENTER      = "KP ENTER",
    KP_DEL        = "KP .",
}

local mat_bipod = Material("tacrp/hud/bipod.png", "mips smooth")

SWEP.CachedCapabilities = {}
function SWEP:GetHintCapabilities()
    self.CachedCapabilities = {}

    if self:GetValue("PrimaryMelee") then
        self.CachedCapabilities["+attack"] = {so = 0, str = "Melee Attack"}
    elseif self:GetValue("PrimaryGrenade") then
        self.CachedCapabilities["+attack"] = {so = 0, str = "Throw Overhand"}
        self.CachedCapabilities["+attack2"] = {so = 0.1, str = "Throw Underhand"}
    end
    -- hopefully you don't need me to tell you how to shoot a gun

    if self:GetScopeLevel() != 0 then
        if TacRP.ConVars["togglepeek"]:GetBool() then
            self.CachedCapabilities["+menu_context"] = {so = 2, str = "Toggle Peek"}
        else
            self.CachedCapabilities["+menu_context"] = {so = 2, str = "Peek"}
        end

        if self:CanHoldBreath() then
            self.CachedCapabilities["+speed"] = {so = 2.1, str = "Hold Breath"}
        end
    elseif #self.Attachments > 0 then
        self.CachedCapabilities["+menu_context"] = {so = 1, str = "Customize"}
    else
        self.CachedCapabilities["+menu_context"] = {so = 1, str = "Inspect"}
    end

    if self:GetFiremodeAmount() > 1 and !self:GetSafe() then
        self.CachedCapabilities["+use/+reload"] = {so = 11, str = "Firemode"}
    end
    if self:GetFiremodeAmount() > 0 and !self:DoForceSightsBehavior() then
        if self:GetSafe() then
            self.CachedCapabilities["+use/+attack2"] = {so = 12, str = "Disable Safety"}
        else
            self.CachedCapabilities["+use/+attack2"] = {so = 12, str = "Enable Safety"}
        end
    end

    if self:GetValue("CanMeleeAttack") and !self:GetValue("PrimaryMelee") then
        local bind = "+use/+attack"
        if TacRP.GetKeyIsBound("+tacrp_melee") then
            bind = TacRP.GetBindKey("+tacrp_melee")
        elseif self:DoOldSchoolScopeBehavior() then
            bind = "+attack2"
        end
        self.CachedCapabilities[bind] = {so = 30, str = "Quick Melee"}
    end

    if self:GetValue("CanToggle") and TacRP.ConVars["toggletactical"]:GetBool() then
        if TacRP.ConVars["flashlight_alt"]:GetBool() then
            self.CachedCapabilities["+walk/impulse 100"] = {so = 31, str = "Toggle " .. (self:GetValue("TacticalName") or "Tactical")}
            self.CachedCapabilities["impulse 100"] = {so = 32, str = "Suit Flashlight"}
        else
            self.CachedCapabilities["impulse 100"] = {so = 31, str = "Toggle " .. (self:GetValue("TacticalName") or "Tactical")}
            self.CachedCapabilities["+walk/impulse 100"] = {so = 32, str = "Suit Flashlight"}
        end
    end

    -- blindfire / quickthrow
    if self:GetValue("CanBlindFire") and self:GetScopeLevel() == 0 and !self:GetSafe() then
        if TacRP.ConVars["blindfiremenu"]:GetBool() then
            self.CachedCapabilities["+zoom"] = {so = 39, str = "Blindfire Menu"}
        else
            if self:GetOwner():KeyDown(IN_ZOOM) then
                self.CachedCapabilities = {}
                self.CachedCapabilities["+zoom/+forward"] = {so = 39, str = "Blindfire Up"}
                self.CachedCapabilities["+zoom/+moveleft"] = {so = 39.1, str = "Blindfire Left"}
                self.CachedCapabilities["+zoom/+moveright"] = {so = 39.2, str = "Blindfire Right"}
                self.CachedCapabilities["+zoom/+back"] = {so = 39.3, str = "Blindfire Cancel"}
                if !TacRP.ConVars["idunwannadie"]:GetBool() then
                    self.CachedCapabilities["+zoom/+speed/+walk"] = {so = 39.4, str = "Suicide"}
                end
                return self.CachedCapabilities
            else
                self.CachedCapabilities["+zoom"] = {so = 39, str = "Blindfire"}
            end
        end
    end

    if self:GetValue("CanQuickNade") then
        local bound1, bound2 = TacRP.GetKeyIsBound("+grenade1"), TacRP.GetKeyIsBound("+grenade2")
        if bound1 then
            self.CachedCapabilities["+grenade1"] = {so = 35, str = "Quickthrow"}
        end
        if bound2 then
            if TacRP.ConVars["nademenu"]:GetBool() then
                if TacRP.ConVars["nademenu_click"]:GetBool() and self.GrenadeMenuAlpha == 1 then
                    self.CachedCapabilities = {}
                    self.CachedCapabilities["+grenade2"] = {so = 36, str = "Prepare Grenade"}
                    self.CachedCapabilities["+grenade2/+attack"] = {so = 36.1, str = "Throw Overhand"}
                    self.CachedCapabilities["+grenade2/+attack2"] = {so = 36.2, str = "Throw Underhand"}
                    if TacRP.AreTheGrenadeAnimsReadyYet then
                        self.CachedCapabilities["+grenade2/MOUSE3"] = {so = 36.3, str = "Pull Out Grenade"}
                    end
                    -- if TacRP.GetKeyIsBound("+grenade1") then
                    --     self.CachedCapabilities["+grenade1"] = {so = 36.4, str = "Quickthrow"}
                    -- end

                    return self.CachedCapabilities
                else
                    self.CachedCapabilities["+grenade2"] = {so = 36, str = "Quickthrow Menu"}
                end
            else
                self.CachedCapabilities["+grenade2"] = {so = 36, str = "Quickthrow Next"}
                self.CachedCapabilities["+walk/+grenade2"] = {so = 37, str = "Quickthrow Prev"}

            end
        end
        if !bound2 and !bound1 then
            self.CachedCapabilities["+grenade1"] = {so = 36, str = "Quickthrow"}
        end
    end

    if engine.ActiveGamemode() == "terrortown" then
        self.CachedCapabilities["+use/+zoom"] = {so = 1001, str = "TTT Radio"}
        self.CachedCapabilities["+use/+menu_context"] = {so = 1002, str = "TTT Shop"}
    end

    self:RunHook("Hook_GetHintCapabilities", self.CachedCapabilities)

    return self.CachedCapabilities
end

SWEP.LastHintLife = 0
function SWEP:DrawHints()
    if LocalPlayer() != self:GetOwner() then return end
    local a = TacRP.ConVars["hints_always"]:GetBool() and 1 or math.Clamp(((self.LastHintLife + 4) - CurTime()) / 1, 0, 1)
    if a <= 0 then return end

    local font = TacRP.ConVars["hints_altfont"]:GetBool() and "TacRP_Myriad_Pro_8" or "TacRP_HD44780A00_5x8_5"

    local caps = self:GetHintCapabilities()

    local clr_w = Color(255, 255, 255, a * 255)

    local x, y = TacRP.SS(4), ScrH() / 2
    local row = TacRP.SS(12)
    local glyphsize = TacRP.SS(8)
    local w, h = TacRP.SS(100), table.Count(caps) * row
    surface.SetDrawColor(0, 0, 0, 150 * a)
    TacRP.DrawCorneredBox(x, y - h / 2, w, h, clr_w)
    local x2, x3 = TacRP.SS(6), TacRP.SS(30)
    local y2 = y - h / 2
    for k, v in SortedPairsByMemberValue(self.CachedCapabilities, "so") do
        local keys = string.Explode("/", k, false)
        surface.SetDrawColor(clr_w)
        local x_glyph = x2
        local y_glyph = y2 + row / 2
        for i = 1, #keys do
            local key = TacRP.GetBindKey(keys[i])
            if glyphs[key] then
                surface.SetMaterial(glyphs[key])
                surface.DrawTexturedRect(x + x_glyph, y_glyph - glyphsize / 2, TacRP.SS(8), glyphsize)
                -- surface.DrawOutlinedRect(x + x_glyph, y_glyph - glyphsize / 2, glyphsize, glyphsize, 2)
                x_glyph = x_glyph + glyphsize
            else
                key = rename[key] or key
                local addw = string.len(key) * TacRP.SS(3.5) + TacRP.SS(5)
                surface.DrawOutlinedRect(x + x_glyph, y_glyph - glyphsize / 2, addw, glyphsize, 1)
                draw.SimpleText(key, "TacRP_HD44780A00_5x8_5", x + x_glyph + addw / 2, y_glyph, clr_w, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                x_glyph = x_glyph + addw
            end

            if i < #keys then
                x_glyph = x_glyph + TacRP.SS(2)
            else
                x_glyph = x_glyph + TacRP.SS(4)
            end
        end

        draw.SimpleText(v.str, font, x + math.max(x3, x_glyph), y2 + row / 2, clr_w, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        y2 = y2 + row
    end
end

function SWEP:DrawBipodHint(x, y, s)
    surface.SetDrawColor(0, 0, 0, 150)
    TacRP.DrawCorneredBox(x, y - s / 2, s, s, color_white)
    if self:CanBipod() then
        if self:GetInBipod() then
            surface.SetDrawColor(255, 255, 255, 255)
        else
            local c = math.sin(CurTime() * 8) * 25 + 175
            surface.SetDrawColor(c, c, c, 255)
        end
        surface.SetMaterial(mat_bipod)
        surface.DrawTexturedRect(x, y - s / 2, s, s)

        if !self:GetInBipod() then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(glyphs["MOUSE2"])
            surface.DrawTexturedRect(x + s * 0.3333, y + s * 0.15, s / 3, s / 3)
        end
    else
        surface.SetDrawColor(100, 100, 100, 255)
        surface.SetMaterial(mat_bipod)
        surface.DrawTexturedRect(x, y - s / 2, s, s)
    end
end