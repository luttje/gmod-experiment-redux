TacRP.DefaultConfigs = {
    -- General purpose configs
    ["tactical"] = { -- This is the default config with all convars on default value!
        ["balance"] = 0,
    },
    ["arcade"] = {
        ["balance"] = 1,
        ["penalty_reload"] = false,
        ["penalty_melee"] = false,
    },
    ["hardcore"] = {
        ["balance"] = 0,
        ["mult_damage"] = 2.5,
        ["mult_damage_magnum"] = 2,
        ["mult_damage_sniper"] = 1.4,
        ["mult_damage_shotgun"] = 1.5,
        ["mult_damage_explosive"] = 2,
        ["mult_recoil_kick"] = 1.25,
        ["sprint_reload"] = false,
    },
    ["boomer"] = {
        ["balance"] = 1,
        ["oldschool"] = true,
        ["crosshair"] = true,
        ["sway"] = false,
        ["freeaim"] = false,
        ["recoilpattern"] = false,
        ["altrecoil"] = false,
    },
    ["csgo"] = {
        ["balance"] = 0,
        ["oldschool"] = true,
        ["crosshair"] = true,
        ["sway"] = false,
        ["freeaim"] = false,
        ["physbullet"] = false,
    },

    -- pve configs
    ["pve_hl2"] = {
        ["balance"] = 1,
        ["oldschool"] = true,
        ["crosshair"] = true,
        ["sway"] = false,
        ["freeaim"] = false,
        ["physbullet"] = false,
        ["recoilpattern"] = false,
        ["altrecoil"] = false,

        ["mult_damage"] = 0.5,
        ["mult_damage_magnum"] = 0.8,
        ["mult_damage_sniper"] = 0.8,
        ["mult_damage_shotgun"] = 0.8,
        ["mult_damage_explosive"] = 0.5,
        ["mult_recoil_kick"] = 0.75,

        ["penalty_reload"] = false,
        ["penalty_melee"] = false,
        ["npc_equality"] = true,
    },
    ["pve_tac"] = {
        ["balance"] = 0,

        ["mult_damage"] = 0.5,
        ["mult_damage_magnum"] = 0.8,
        ["mult_damage_sniper"] = 0.8,
        ["mult_damage_shotgun"] = 0.8,
        ["mult_damage_explosive"] = 0.5,
        ["mult_recoil_kick"] = 0.75,

        ["sprint_reload"] = false,
        ["npc_equality"] = true,
    },

    -- TTT configs
    ["ttt_modern"] = {
        ["balance"] = 2,
        ["sprint_reload"] = false,
    },
    ["ttt_purist"] = {
        ["balance"] = 2,
        ["crosshair"] = true,
        ["sway"] = false,
        ["freeaim"] = false,
        ["physbullet"] = false,

        ["penalty_reload"] = false,
        ["penalty_melee"] = false,
        ["sprint_reload"] = false,
    }
}

if SERVER then
    function TacRP.ApplyConfig(tbl)
        if isstring(tbl) then
            tbl = TacRP.DefaultConfigs[tbl] or {}
        end
        for name, cvar in pairs(TacRP.ConVars) do
            local val = tbl[name]
            if val == nil then
                cvar:Revert()
            elseif isstring(val) then
                cvar:SetString(val)
            elseif isbool(val) then
                cvar:SetBool(val)
            elseif math.Round(val) == val then
                cvar:SetInt(val)
            else
                cvar:SetFloat(val)
            end
        end
    end

    net.Receive("tacrp_applyconfig", function(len, ply)
        if !ply:IsAdmin() then return end

        local config = net.ReadString()
        TacRP.ApplyConfig(config)
    end)
end

concommand.Add("tacrp_applyconfig", function(ply, cmd, args, argStr)
    if #args < 1 or (IsValid(ply) and !ply:IsAdmin()) then return end
    if SERVER then
        TacRP.ApplyConfig(args[1])
    else
        net.Start("tacrp_applyconfig")
            net.WriteString(args[1])
        net.SendToServer()
    end
end, function(cmd, argStr)
    local arg = string.Trim(argStr:lower())
    local tbl = {}
    for cfg, vals in SortedPairs(TacRP.DefaultConfigs) do
        if string.Left(cfg, string.len(arg)) == arg then
            table.insert(tbl, cmd .. " " .. cfg)
        end
    end
    return tbl
end)