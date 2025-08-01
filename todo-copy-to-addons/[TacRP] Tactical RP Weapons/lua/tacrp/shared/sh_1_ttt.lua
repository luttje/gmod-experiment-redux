TacRP.TTTAmmoToEntity = {
    ["pistol"] = "item_ammo_pistol_ttt",
    ["smg1"] = "item_ammo_smg1_ttt",
    ["AlyxGun"] = "item_ammo_revolver_ttt",
    ["357"] = "item_ammo_357_ttt",
    ["buckshot"] = "item_box_buckshot_ttt"
}
--[[
WEAPON_TYPE_RANDOM = 1
WEAPON_TYPE_MELEE = 2
WEAPON_TYPE_NADE = 3
WEAPON_TYPE_SHOTGUN = 4
WEAPON_TYPE_HEAVY = 5
WEAPON_TYPE_SNIPER = 6
WEAPON_TYPE_PISTOL = 7
WEAPON_TYPE_SPECIAL = 8
]]

TacRP.AmmoToTTT = {
    ["357"] = "AlyxGun",
    ["SniperPenetratedRound"] = "357",
    ["ar2"] = "smg1",
}

TacRP.TTTAmmoToClipMax = {
    ["357"] = 20,
    ["smg1"] = 60,
    ["pistol"] = 60,
    ["alyxgun"] = 36,
    ["buckshot"] = 24
}

TacRP.TTTReplaceLookup = {
    ["weapon_ttt_glock"] = true,
    ["weapon_ttt_m16"] = true,
    ["weapon_zm_mac10"] = true,
    ["weapon_zm_pistol"] = true,
    ["weapon_zm_revolver"] = true,
    ["weapon_zm_rifle"] = true,
    ["weapon_zm_shotgun"] = true,
    ["weapon_zm_sledge"] = true,

    ["weapon_zm_molotov"] = true,
    ["weapon_ttt_confgrenade"] = true,
    ["weapon_ttt_smokegrenade"] = true,
}

TacRP.TTTReplacePreset = {
    ["Pistol"] = {["weapon_zm_pistol"] = 1},
    ["Magnum"] = {["weapon_zm_revolver"] = 1},
    ["MachinePistol"] = {["weapon_ttt_glock"] = 1},
    ["SMG"] = {["weapon_ttt_m16"] = 1, ["weapon_zm_mac10"] = 0.5},
    ["AssaultRifle"] = {["weapon_ttt_m16"] = 0.5, ["weapon_zm_mac10"] = 1},
    ["BattleRifle"] = {["weapon_ttt_m16"] = 1, ["weapon_zm_mac10"] = 1},
    ["MarksmanRifle"] = {["weapon_zm_mac10"] = 0.5, ["weapon_zm_rifle"] = 1},
    ["Shotgun"] = {["weapon_zm_shotgun"] = 1},
    ["AutoShotgun"] = {["weapon_zm_shotgun"] = 0.5},
    ["MachineGun"] = {["weapon_zm_sledge"] = 1},
    ["SniperRifle"] = {["weapon_zm_rifle"] = 1},
}

TacRP.TTTReplaceCache = {}
function TacRP.GetRandomTTTWeapon(key)
    if !TacRP.TTTReplaceLookup[key] then return end
    if !TacRP.TTTReplaceCache[key] then
        TacRP.TTTReplaceCache[key] = {0, {}}
        for i, wep in pairs(weapons.GetList()) do
            local weap = weapons.Get(wep.ClassName)
            if !weap or !weap.ArcticTacRP or wep.ClassName == "tacrp_base" or wep.ClassName == "tacrp_base_nade" or !wep.AutoSpawnable then
                continue
            end

            if (istable(wep.TTTReplace) and wep.TTTReplace[key]) then
                TacRP.TTTReplaceCache[key][1] = TacRP.TTTReplaceCache[key][1] + wep.TTTReplace[key]
                TacRP.TTTReplaceCache[key][2][wep.ClassName] = wep.TTTReplace[key]
            end
        end
    end

    if TacRP.TTTReplaceCache[key][1] > 0 then
        local rng = math.random() * TacRP.TTTReplaceCache[key][1]
        for k, v in pairs(TacRP.TTTReplaceCache[key][2]) do
            rng = rng - v
            if rng <= 0 then
                return k
            end
        end
    end
end

if engine.ActiveGamemode() != "terrortown" then return end
local function setupttt()
    for i, wep in pairs(weapons.GetList()) do
        local weap = weapons.Get(wep.ClassName)
        if !weap or !weap.ArcticTacRP or wep.ClassName == "tacrp_base" or wep.ClassName == "tacrp_base_nade" then
            continue
        end

        if TacRP.ConVars["ttt_shortname"]:GetBool() and wep.AbbrevName then
            wep.FullName = wep.PrintName
            wep.PrintName = wep.AbbrevName
        end

        if wep.AmmoTTT then
            wep.Ammo = wep.AmmoTTT
        elseif TacRP.AmmoToTTT[wep.Ammo] then
            wep.Ammo = TacRP.AmmoToTTT[wep.Ammo]
        end

        wep.AmmoEnt = TacRP.TTTAmmoToEntity[wep.Ammo] or ""
        if wep.AutoSpawnable == nil then
            wep.AutoSpawnable = wep.Spawnable and !wep.AdminOnly
        end
        wep.AllowDrop = wep.AllowDrop or true

        -- We have to do this here because TTT2 does a check for .Kind in WeaponEquip,
        -- earlier than Initialize() which assigns .Kind
        if !wep.Kind and !wep.CanBuy then
            if wep.PrimaryGrenade then
                wep.Slot = 3
                wep.Kind = WEAPON_NADE
                wep.spawnType = wep.spawnType or WEAPON_TYPE_NADE
            elseif wep.Slot == 0 then
                -- melee weapons
                wep.Slot = 6
                wep.Kind = WEAPON_MELEE or WEAPON_EQUIP1
                wep.spawnType = wep.spawnType or WEAPON_TYPE_MELEE
            elseif wep.Slot == 1 then
                -- sidearms
                wep.Kind = WEAPON_PISTOL
                wep.spawnType = wep.spawnType or WEAPON_TYPE_PISTOL
            else
                -- other weapons are considered primary
                -- try to determine spawntype if none exists
                if !wep.spawnType then
                    if wep.Ammo == "357" or (wep.Slot == 3 and (wep.Num or 1) == 1) then
                        wep.spawnType = WEAPON_TYPE_SNIPER
                    elseif wep.Ammo == "buckshot" or (wep.Num or 1) > 1 then
                        wep.spawnType = WEAPON_TYPE_SHOTGUN
                    else
                        wep.spawnType = WEAPON_TYPE_HEAVY
                    end
                end

                wep.Slot = 2
                wep.Kind = WEAPON_HEAVY
            end
        end

        local class = wep.ClassName
        local path = "tacrp/weaponicons/" .. class
        local path2 = "tacrp/ttticons/" .. class .. ".png"
        local path3 = "vgui/ttt/" .. class
        local path4 = "entities/" .. class .. ".png"

        if !Material(path2):IsError() then
            -- TTT icon (png)
            wep.Icon = path2
        elseif !Material(path3):IsError() then
            -- TTT icon (vtf)
            wep.Icon = path3
        elseif !Material(path4):IsError() then
            -- Entity spawn icon
            wep.Icon = path4
        elseif !Material(path):IsError() then
            -- Kill icon
            wep.Icon = path
        else
            -- fallback: display _something_
            wep.Icon = "entities/npc_headcrab.png"
        end

        if CLIENT then
            local lang = TTT2 and "en" or "english"
            LANG.AddToLanguage(lang, "tacrp_search_dmg_buckshot", "This terrorist was blasted to shreds by buckshot.")
        end
    end
end
hook.Add("OnGamemodeLoaded", "TacRP_TTT", setupttt)
hook.Add("TacRP_LoadAtts", "TacRP_TTT", setupttt)

hook.Add( "OnEntityCreated", "TacRP_TTT_Spawn", function(ent)
    if CLIENT then return end
    if TacRP.ConVars["ttt_weapon_include"]:GetBool()
            and TacRP.TTTReplaceLookup[ent:GetClass()]
            and math.random() <= TacRP.ConVars["ttt_weapon_replace"]:GetFloat() then

        timer.Simple(0, function()
            if !IsValid(ent) or IsValid(ent:GetOwner()) then return end

            local class = ent:GetClass()
            local wpn = TacRP.GetRandomTTTWeapon(class)

            if wpn then
                local wpnent = ents.Create(wpn)
                wpnent:SetPos(ent:GetPos())
                wpnent:SetAngles(ent:GetAngles())
                wpnent:Spawn()
                timer.Simple(0, function()
                    if !ent:IsValid() then return end
                    -- wpnent:OnDrop(true)
                    ent:Remove()
                end)
            end
        end)
    end
end)

hook.Add("TTTPrepareRound", "TacRP_TTT", function()
    if CLIENT then return end
    local give = TacRP.ConVars["ttt_atts_giveonspawn"]:GetInt()
    if give <= 0 then return end

    for _, ply in pairs(player.GetAll()) do
        ply.TacRP_AttInv = {}
        for i = 1, give do
            local id
            for j = 1, 5 do -- up to 5 random attempts
                id = TacRP.Attachments_Index[math.random(1, TacRP.Attachments_Count)]
                if !TacRP.Attachments[id].InvAtt and (!ply.TacRP_AttInv or ply.TacRP_AttInv[id] == 0) then break end
            end
            TacRP:PlayerGiveAtt(ply, id, 1)
        end
        TacRP:PlayerSendAttInv(ply)
    end
end)