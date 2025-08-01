local ammotypes = {
    "ti_flashbang",
    "ti_thermite",
    "ti_smoke",
    "ti_c4",
    "ti_gas",
    "ti_nuke",
    "ti_charge",
    -- "ti_sniper",
}

local materials = {
    ["ti_flashbang"] = "tacrp/grenades/flashbang",
    ["ti_thermite"] = "tacrp/grenades/thermite",
    ["ti_smoke"] = "tacrp/grenades/smoke",
    ["ti_c4"] = "tacrp/grenades/c4",
    ["ti_gas"] = "tacrp/grenades/gas",
    ["ti_nuke"] = "tacrp/grenades/nuke",
    ["ti_charge"] = "tacrp/grenades/breach",
    ["SniperPenetratedRound"] = "tacrp/grenades/sniper",
}

for _, i in pairs(ammotypes) do
    game.AddAmmoType({
        name = i,
        max = "tacrp_max_grenades",
    })

    if CLIENT then
        language.Add(i .. "_ammo", TacRP:GetPhrase("ammo." .. i) or i)
    end
end


if CLIENT then
    hook.Add("InitPostEntity", "tacrp_hl2hud", function()
        if !HL2HUD then return end
        local tbl = HL2HUD.scheme.GetDefault().HudTextures.AmmoInv
        local tbl2 = HL2HUD.scheme.GetDefault().HudTextures.Ammo

        for k, v in pairs(materials) do
            local info = {
                type = 2,
                w = 64,
                h = 64,
                x = 0,
                y = 0,
                u1 = 0,
                u2 = 64,
                v1 = 0,
                v2 = 64,
                scalable = false,
                texture = surface.GetTextureID(v)
            }
            if !tbl[k] then
                tbl[k] = info
            end
            if !tbl2[k] then
                tbl2[k] = info
            end
        end
    end)
end