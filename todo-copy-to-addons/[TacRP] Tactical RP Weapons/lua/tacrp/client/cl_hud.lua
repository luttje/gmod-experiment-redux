local mat_corner_ul = Material("TacRP/hud/800corner_nobg1.png", "mips smooth")
local mat_corner_ur = Material("TacRP/hud/800corner_nobg2.png", "mips smooth")
local mat_corner_br = Material("TacRP/hud/800corner_nobg3.png", "mips smooth")
local mat_corner_bl = Material("TacRP/hud/800corner_nobg4.png", "mips smooth")

function TacRP.DrawCorneredBox(x, y, w, h, col)
    col = col or Color(255, 255, 255)

    surface.DrawRect(x, y, w, h)

    surface.SetDrawColor(col)

    local s = 8

    surface.SetMaterial(mat_corner_ul)
    surface.DrawTexturedRect(x, y, s, s)

    surface.SetMaterial(mat_corner_ur)
    surface.DrawTexturedRect(x + w - s, y, s, s)

    surface.SetMaterial(mat_corner_bl)
    surface.DrawTexturedRect(x, y + h - s, s, s)

    surface.SetMaterial(mat_corner_br)
    surface.DrawTexturedRect(x + w - s, y + h - s, s, s)
end

local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
}

hook.Add("HUDShouldDraw", "TacRP_HideHUD", function(name)
    if !IsValid(LocalPlayer()) then return end
    local wpn = LocalPlayer():GetActiveWeapon()

    if IsValid(wpn) and wpn.ArcticTacRP and
            ((TacRP.ConVars["drawhud"]:GetBool() and TacRP.ConVars["hud"]:GetBool()) or wpn:GetCustomize()) and hide[name]  then
        return false
    end
end)

local names = {
    ["357"] = "Magnum Ammo",
    ["smg1"] = "Carbine Ammo",
    ["ar2"] = "Rifle Ammo",
    ["sniperpenetratedround"] = "Sniper Ammo",
}

hook.Add("PreGamemodeLoaded", "TacRP_AmmoName", function()
    if TacRP.ConVars["ammonames"]:GetBool() then
        for k, v in pairs(names) do
            language.Add(k .. "_ammo", v)
        end
    end
end)

local gaA = 0
function TacRP.GetFOVAcc(spread)
    local raw = isnumber(spread)
    if !raw and spread:IsWeapon() then spread = spread:GetSpread() end
    cam.Start3D()
        local lool = ( EyePos() + ( EyeAngles():Forward() ) + ( spread * EyeAngles():Up() ) ):ToScreen()
    cam.End3D()

    local gau = ( (ScrH() / 2) - lool.y )
    if raw then return gau end

    gaA = math.Approach(gaA, gau, (ScrH() / 2) * FrameTime() * 2)

    return gaA
end

TacRP.PanelColors = {
    ["bg"] = {
        Color(0, 0, 0, 150), -- normal
        Color(255, 255, 255, 255), -- hover
        Color(150, 150, 150, 150), -- sel
        Color(255, 255, 255, 255), -- sel, hover
    },
    ["bg2"] = {
        Color(0, 0, 0, 200), -- normal
        Color(255, 255, 255, 255), -- hover
        Color(150, 150, 150, 200), -- sel
        Color(255, 255, 255, 255), -- sel, hover
    },
    ["corner"] = {
        Color(255, 255, 255),
        Color(0, 0, 0),
        Color(50, 50, 255),
        Color(150, 150, 255),
    },
    ["text"] = {
        Color(255, 255, 255),
        Color(0, 0, 0),
        Color(255, 255, 255),
        Color(0, 0, 0),
    },
    ["text_glow"] = {
        Color(255, 255, 255, 100),
        Color(0, 0, 0, 100),
        Color(255, 255, 255, 100),
        Color(0, 0, 0, 100),
    },
}

function TacRP.GetPanelColor(str, hvr, sel)
    local i = 1
    if isnumber(hvr) or hvr == nil then
        i = hvr or 1
    elseif sel then
        i = hvr and 4 or 3
    elseif hvr then
        i = 2
    end

    return TacRP.PanelColors[str][i]
end

function TacRP.GetPanelColors(hvr, sel)
    local i = 1
    if sel then
        i = hvr and 4 or 3
    elseif hvr then
        i = 2
    end
    return TacRP.PanelColors["bg2"][i], TacRP.PanelColors["corner"][i], TacRP.PanelColors["text"][i]
end

hook.Add("RenderScreenspaceEffects", "TacRP_Gas", function()
    if LocalPlayer():GetNWFloat("TacRPGasEnd", 0) > CurTime() then
        local delta = math.Clamp((LocalPlayer():GetNWFloat("TacRPGasEnd", 0) - CurTime()) / 2, 0, 1) ^ 1.5

        DrawMaterialOverlay("effects/water_warp01", delta * 0.1)
        DrawMotionBlur(0.5 * delta, 0.75 * delta, 0.01)
        DrawColorModify({
            [ "$pp_colour_addr" ] = 0.125 * delta,
            [ "$pp_colour_addg" ] = 0.2 * delta,
            [ "$pp_colour_addb" ] = 0.05 * delta,
            [ "$pp_colour_brightness" ] = -0.2 * delta,
            [ "$pp_colour_contrast" ] = 1 - delta * 0.1,
            [ "$pp_colour_colour" ] = 1 - delta * 0.75,
            [ "$pp_colour_mulr" ] = 0,
            [ "$pp_colour_mulg" ] = 0,
            [ "$pp_colour_mulb" ] = 0,
        })
    end
end )