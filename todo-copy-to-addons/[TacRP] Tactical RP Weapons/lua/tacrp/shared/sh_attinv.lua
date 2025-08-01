function TacRP:PlayerGetAtts(ply, att)
    if !IsValid(ply) then return 0 end

    local atttbl = TacRP.GetAttTable(att)
    if !atttbl then return 0 end
    if atttbl.InvAtt then att = atttbl.InvAtt end
    if !ply:IsAdmin() and atttbl.AdminOnly then return 0 end
    if atttbl.Free or TacRP.ConVars["free_atts"]:GetBool() then return 9999 end
    if engine.ActiveGamemode() == "terrortown" and TacRP.ConVars["ttt_bench_freeatts"]:GetBool() and TacRP.NearBench(ply) then return 9999 end

    local ret = hook.Run("TacRP_PlayerAttCount", ply, att)
    if ret != nil then return ret end

    if !ply.TacRP_AttInv then return 0 end
    if !ply.TacRP_AttInv[att] then return 0 end

    return ply.TacRP_AttInv[att]
end

function TacRP:PlayerGiveAtt(ply, att, amt)
    amt = amt or 1

    if !IsValid(ply) then return false end

    if !ply.TacRP_AttInv then ply.TacRP_AttInv = {} end

    local atttbl = TacRP.GetAttTable(att)

    if !atttbl then print("Invalid att " .. att) return false end
    if atttbl.Free then return false end -- You can't give a free attachment, silly
    if atttbl.AdminOnly and !(ply:IsPlayer() and ply:IsAdmin()) then return false end
    if atttbl.InvAtt then att = atttbl.InvAtt end

    if TacRP.ConVars["free_atts"]:GetBool() then return true end
    local ret = hook.Run("TacRP_PlayerGiveAtt", ply, att, amt)
    if ret != nil then return ret end

    if TacRP.ConVars["lock_atts"]:GetBool() then
        if ply.TacRP_AttInv[att] == 1 then return end
        ply.TacRP_AttInv[att] = 1
        return true
    else
        ply.TacRP_AttInv[att] = (ply.TacRP_AttInv[att] or 0) + amt
        return true
    end
end

function TacRP:PlayerTakeAtt(ply, att, amt)
    amt = amt or 1

    if !IsValid(ply) then return end

    if !ply.TacRP_AttInv then ply.TacRP_AttInv = {} end

    local atttbl = TacRP.GetAttTable(att)
    if !atttbl then return false end
    if atttbl.Free then return true end
    if atttbl.InvAtt then att = atttbl.InvAtt end

    if TacRP.ConVars["free_atts"]:GetBool() then return true end
    local ret = hook.Run("TacRP_PlayerTakeAtt", ply, att, amt)
    if ret != nil then return ret end

    if (ply.TacRP_AttInv[att] or 0) < (TacRP.ConVars["lock_atts"]:GetBool() and 1 or amt) then return false end

    if !TacRP.ConVars["lock_atts"]:GetBool() then
        ply.TacRP_AttInv[att] = ply.TacRP_AttInv[att] - amt
        if ply.TacRP_AttInv[att] <= 0 then
            ply.TacRP_AttInv[att] = nil
        end
    end
    return true
end

if CLIENT then
    net.Receive("TacRP_sendattinv", function(len, ply)
        LocalPlayer().TacRP_AttInv = {}

        local count = net.ReadUInt(32)

        for i = 1, count do
            local attid = net.ReadUInt(TacRP.Attachments_Bits)
            local acount = net.ReadUInt(32)

            local att = TacRP.Attachments_Index[attid]

            LocalPlayer().TacRP_AttInv[att] = acount
        end
    end)
elseif SERVER then
    hook.Add("PlayerSpawn", "TacRP_SpawnAttInv", function(ply, trans)
        if trans then return end
        if engine.ActiveGamemode() != "terrortown" and TacRP.ConVars["loseattsondie"]:GetInt() > 0 then
            ply.TacRP_AttInv = {}
            TacRP:PlayerSendAttInv(ply)
        end
    end)

    function TacRP:PlayerSendAttInv(ply)
        if TacRP.ConVars["free_atts"]:GetBool() then return end
        if !IsValid(ply) then return end
        if !ply.TacRP_AttInv then return end

        net.Start("TacRP_sendattinv")
        net.WriteUInt(table.Count(ply.TacRP_AttInv), 32)
        for att, count in pairs(ply.TacRP_AttInv) do
            local atttbl = TacRP.GetAttTable(att)
            local attid = atttbl.ID
            net.WriteUInt(attid, TacRP.Attachments_Bits)
            net.WriteUInt(count, 32)
        end
        net.Send(ply)
    end

end
