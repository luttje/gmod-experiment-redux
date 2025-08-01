TacRP.Attachments = {}
TacRP.Attachments_Index = {}

TacRP.Attachments_Count = 0

TacRP.Attachments_Bits = 16

function TacRP.InvalidateCache()
    for _, e in pairs(ents.GetAll()) do
        if e:IsWeapon() and e.ArcticTacRP then
            e:InvalidateCache()
            e:SetBaseSettings()
        end
    end
end

function TacRP.LoadAtt(atttbl, shortname, id)
    if atttbl.Ignore then return end

    if !id then
        TacRP.Attachments_Count = TacRP.Attachments_Count + 1
        id = TacRP.Attachments_Count
    end

    atttbl.ShortName = shortname
    atttbl.ID = id

    TacRP.Attachments[shortname] = atttbl
    TacRP.Attachments_Index[id] = shortname

    if TacRP.ConVars["generateattentities"]:GetBool() and !atttbl.DoNotRegister and !atttbl.InvAtt and !atttbl.Free then
        local attent = {}
        attent.Base = "tacrp_att"
        attent.Icon = atttbl.Icon
        if attent.Icon then
            attent.IconOverride = string.Replace( attent.Icon:GetTexture( "$basetexture" ):GetName() .. ".png", "0001010", "" )
        end
        attent.PrintName = atttbl.FullName or atttbl.PrintName or shortname
        attent.Spawnable = true
        attent.AdminOnly = atttbl.AdminOnly or false
        attent.AttToGive = shortname
        attent.Category = "Tactical RP - Attachments"

        scripted_ents.Register(attent, "tacrp_att_" .. shortname)
    end
end

function TacRP.LoadAtts()
    TacRP.Attachments_Count = 0
    TacRP.Attachments = {}
    TacRP.Attachments_Index = {}

    local searchdir = "tacrp/shared/atts/"
    local searchdir_bulk = "tacrp/shared/atts_bulk/"

    local files = file.Find(searchdir .. "/*.lua", "LUA")

    for _, filename in pairs(files) do
        AddCSLuaFile(searchdir .. filename)
    end

    files = file.Find(searchdir .. "/*.lua", "LUA")

    for _, filename in pairs(files) do
        if filename == "default.lua" then continue end

        ATT = {}

        local shortname = string.sub(filename, 1, -5)

        include(searchdir .. filename)

        if ATT.Ignore then continue end

        TacRP.LoadAtt(ATT, shortname)
    end

    local bulkfiles = file.Find(searchdir_bulk .. "/*.lua", "LUA")

    for _, filename in pairs(bulkfiles) do
        AddCSLuaFile(searchdir_bulk .. filename)
    end

    bulkfiles = file.Find(searchdir_bulk .. "/*.lua", "LUA")

    for _, filename in pairs(bulkfiles) do
        if filename == "default.lua" then continue end

        include(searchdir_bulk .. filename)
    end

    TacRP.Attachments_Bits = math.min(math.ceil(math.log(TacRP.Attachments_Count + 1, 2)), 32)
    hook.Run("TacRP_LoadAtts")

    TacRP.InvalidateCache()
end

function TacRP.GetAttTable(name)
    local shortname = name
    if isnumber(shortname) then
        shortname = TacRP.Attachments_Index[name]
    end

    if TacRP.Attachments[shortname] then
        return TacRP.Attachments[shortname]
    else
        // assert(false, "!!!! TacRP tried to access invalid attachment " .. (shortname or "NIL") .. "!!!")
        return {}
    end
end

function TacRP.GetAttsForCats(cats)
    if !istable(cats) then
        cats = {cats}
    end

    local atts = {}

    for i, k in pairs(TacRP.Attachments) do
        local attcats = k.Category
        if !istable(attcats) then
            attcats = {attcats}
        end

        for _, cat in pairs(cats) do
            if table.HasValue(attcats, cat) then
                table.insert(atts, k.ShortName)
                break
            end
        end
    end

    return atts
end

if CLIENT then

concommand.Add("tacrp_reloadatts", function()
    if !LocalPlayer():IsSuperAdmin() then return end

    net.Start("tacrp_reloadatts")
    net.SendToServer()
end)

net.Receive("tacrp_reloadatts", function(len, ply)
    TacRP.LoadAtts()
    TacRP.InvalidateCache()
end)

elseif SERVER then

net.Receive("tacrp_reloadatts", function(len, ply)
    if !ply:IsSuperAdmin() then return end

    TacRP.LoadAtts()
    TacRP.InvalidateCache()

    net.Start("tacrp_reloadatts")
    net.Broadcast()
end)

end

TacRP.Benches = ents.FindByClass("tacrp_bench") or {}
TacRP.BenchDistSqr = 128 * 128

function TacRP.NearBench(ply)
    local nearbench = false
    for i, ent in pairs(TacRP.Benches) do
        if !IsValid(ent) then table.remove(TacRP.Benches, i) continue end
        if ent:GetPos():DistToSqr(ply:GetPos()) <= TacRP.BenchDistSqr then
            nearbench = true
            break
        end
    end
    if !nearbench then return false end
    return true
end

function TacRP.CanCustomize(ply, wep, att, slot)

    if engine.ActiveGamemode() == "terrortown" then
        local role = ply:GetTraitor() or ply:IsDetective()

        // disabled across role
        if (role and !TacRP.ConVars["ttt_cust_role_allow"]:GetBool()) or (!role and !TacRP.ConVars["ttt_cust_inno_allow"]:GetBool()) then
            return false, "Restricted for role"
        end

        // disabled during round
        if GetRoundState() == ROUND_ACTIVE and ((role and !TacRP.ConVars["ttt_cust_role_round"]:GetBool()) or (!role and !TacRP.ConVars["ttt_cust_inno_round"]:GetBool())) then
            return false, "Restricted during round"
        end

        // disabled when not near bench
        if ((role and TacRP.ConVars["ttt_cust_role_needbench"]:GetBool()) or (!role and TacRP.ConVars["ttt_cust_inno_needbench"]:GetBool())) and !TacRP.NearBench(ply) then
            return false, "Requires Customization Bench"
        end
    else
        // check bench
        if TacRP.ConVars["rp_requirebench"]:GetBool() and !TacRP.NearBench(ply) then
            return false, "Restricted during round"
        end
    end

    return true
end

TacRP.LoadAtts()