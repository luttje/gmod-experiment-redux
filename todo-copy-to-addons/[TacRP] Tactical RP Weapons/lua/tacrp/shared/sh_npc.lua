hook.Add("InitPostEntity", "TacRP_Register", function()
    for _, wpn in pairs(weapons.GetList()) do
        local tbl = weapons.Get(wpn.ClassName)

        if !tbl.ArcticTacRP or !tbl.NPCUsable or !tbl.Spawnable then continue end

        list.Add("NPCUsableWeapons",
            {
                class = wpn.ClassName,
                title = wpn.PrintName
            }
        )
    end
end)

if CLIENT then
    local no_tiered_random = {
        ["6Launcher"] = true,
        ["9Special"] = true,
        ["8Melee Weapon"] = true,
        ["7Special Weapon"] = true,
        ["9Equipment"] = true,
        ["9Throwable"] = true,
    }
    hook.Add("PopulateMenuBar", "TacRP_NPCWeaponMenu", function (menubar)
        timer.Simple(0.1, function()
            local wpns = menubar:AddOrGetMenu("TacRP NPC Weapons")

            wpns:AddCVar( "#menubar.npcs.defaultweapon", "gmod_npcweapon", "" )
            wpns:AddCVar( "#menubar.npcs.noweapon", "gmod_npcweapon", "none" )

            local random = wpns:AddSubMenu("Random...")
            random:SetDeleteSelf(false)

            random:AddCVar("[Any TacRP Weapon]", "gmod_npcweapon", "!tacrp|npc|")
            random:AddCVar("[Consumer Tier]", "gmod_npcweapon", "!tacrp|npc|4Consumer")
            random:AddCVar("[Security Tier]", "gmod_npcweapon", "!tacrp|npc|3Security")
            random:AddCVar("[Operator Tier]", "gmod_npcweapon", "!tacrp|npc|2Operator")
            random:AddCVar("[Elite Tier]", "gmod_npcweapon", "!tacrp|npc|1Elite")

            wpns:AddSpacer()

            wpns:SetDeleteSelf(false)

            local weaponlist = weapons.GetList()

            local catdict = {}
            local catnames = {}
            local catcontents = {}

            -- table.SortByMember(weaponlist, "PrintName", true)

            local cats = {}

            for _, k in pairs(weaponlist) do
                local weptbl = weapons.Get(k.ClassName)
                if weptbl and weptbl.ArcticTacRP and weptbl.Spawnable
                        and weptbl.NPCUsable and !weptbl.PrimaryMelee and !weptbl.PrimaryGrenade then
                    local cat = k.SubCatType
                    if !catdict[cat] then
                        catdict[cat] = true
                        table.insert(catnames, cat)
                    end
                    catcontents[cat] = catcontents[cat] or {}
                    table.insert(catcontents[cat], {k.PrintName, k.ClassName})
                end
            end

            for _, cat in SortedPairsByValue(catnames) do
                cats[cat] = wpns:AddSubMenu(string.sub(cat, 2))
                cats[cat]:SetDeleteSelf(false)

                cats[cat]:AddCVar("[Random]", "gmod_npcweapon", "!tacrp|" .. cat .. "|")
                if !no_tiered_random[cat] then
                    cats[cat]:AddCVar("[Consumer Tier]", "gmod_npcweapon", "!tacrp|" .. cat .. "|4Consumer")
                    cats[cat]:AddCVar("[Security Tier]", "gmod_npcweapon", "!tacrp|" .. cat .. "|3Security")
                    cats[cat]:AddCVar("[Operator Tier]", "gmod_npcweapon", "!tacrp|" .. cat .. "|2Operator")
                    cats[cat]:AddCVar("[Elite Tier]", "gmod_npcweapon", "!tacrp|" .. cat .. "|1Elite")
                end
                cats[cat]:AddSpacer()

                for _, info in SortedPairsByMemberValue(catcontents[cat], 1) do
                    cats[cat]:AddCVar(info[1], "gmod_npcweapon", info[2])
                end
            end
        end)
    end)

    net.Receive("tacrp_npcweapon", function(len, ply)
        local class = GetConVar("gmod_npcweapon"):GetString()

        net.Start("tacrp_npcweapon")
        net.WriteString(class)
        net.SendToServer()
    end)
elseif SERVER then
    hook.Add("PlayerSpawnedNPC", "TacRP_NPCWeapon", function(ply, ent)
        net.Start("tacrp_npcweapon")
        net.Send(ply)

        ply.TacRP_LastSpawnedNPC = ent
    end)

    net.Receive("tacrp_npcweapon", function(len, ply)
        local class = net.ReadString()
        local ent = ply.TacRP_LastSpawnedNPC

        if !IsValid(ent) or !ent:IsNPC() or (class or "") == "" then return end

        local cap = ent:CapabilitiesGet()
        if bit.band(cap, CAP_USE_WEAPONS) != CAP_USE_WEAPONS then return end

        local wpn
        if string.Left(class, 6) == "!tacrp" then
            local args = string.Explode("|", class, false)
            class = TacRP.GetRandomWeapon(args[2], args[3])
            wpn = weapons.Get(class or "")
            if !class or !wpn then return end
        else
            wpn = weapons.Get(class)
        end

        if !wpn or (wpn.AdminOnly and !ply:IsPlayer()) then return end

        if wpn.ArcticTacRP and wpn.NPCUsable and wpn.Spawnable and (!wpn.AdminOnly or ply:IsAdmin()) then
            ent:Give(class)
        end
    end)
end
