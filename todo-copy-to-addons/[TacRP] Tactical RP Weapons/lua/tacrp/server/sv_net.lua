util.AddNetworkString("tacrp_toggleblindfire")
util.AddNetworkString("tacrp_togglecustomize")
util.AddNetworkString("tacrp_reloadatts")
util.AddNetworkString("tacrp_networkweapon")
util.AddNetworkString("tacrp_attach")
util.AddNetworkString("tacrp_receivepreset")
util.AddNetworkString("tacrp_sendattinv")
util.AddNetworkString("tacrp_sendbullet")

util.AddNetworkString("tacrp_updateholster")
util.AddNetworkString("tacrp_clientdamage")
util.AddNetworkString("tacrp_container")
util.AddNetworkString("tacrp_toggletactical")
util.AddNetworkString("tacrp_doorbust")
util.AddNetworkString("tacrp_togglepeek")
util.AddNetworkString("tacrp_flashbang")
util.AddNetworkString("tacrp_togglenade")
util.AddNetworkString("tacrp_addshieldmodel")
util.AddNetworkString("tacrp_updateslot")
util.AddNetworkString("tacrp_givenadewep")
util.AddNetworkString("tacrp_reloadlangs")
util.AddNetworkString("tacrp_npcweapon")
util.AddNetworkString("tacrp_applyconfig")

net.Receive("tacrp_togglepeek", function(len, ply)
    local bf = net.ReadBool()

    local wpn = ply:GetActiveWeapon()

    if !wpn or !IsValid(wpn) or !wpn.ArcticTacRP then return end

    wpn:SetPeeking(bf)
    if bf and wpn:GetSightAmount() > 0 then
        wpn:SetLastScopeTime(CurTime())
    end
end)

net.Receive("tacrp_togglenade", function(len, ply)
    local bf = net.ReadUInt(TacRP.QuickNades_Bits)
    local throw = net.ReadBool()
    local under = false
    if throw then under = net.ReadBool() end

    local wpn = ply:GetActiveWeapon()

    if !wpn or !IsValid(wpn) or !wpn.ArcticTacRP then return end

    wpn:SelectGrenade(bf)
    if throw then
        wpn:PrimeGrenade()
        wpn.GrenadeThrowOverride = under
    end
end)

net.Receive("tacrp_givenadewep", function(len, ply)
    local bf = net.ReadUInt(TacRP.QuickNades_Bits)
    local wpn = ply:GetActiveWeapon()
    if !wpn or !IsValid(wpn) or !wpn.ArcticTacRP or !TacRP.AreTheGrenadeAnimsReadyYet then return end

    local nade = TacRP.QuickNades[TacRP.QuickNades_Index[bf]]
    if !nade or !nade.GrenadeWep or !wpn:CheckGrenade(bf, true) then return end

    ply:Give(nade.GrenadeWep, true)
end)

net.Receive("tacrp_toggleblindfire", function(len, ply)
    local bf = net.ReadUInt(TacRP.BlindFireNetBits)

    local wpn = ply:GetActiveWeapon()

    if !wpn or !IsValid(wpn) or !wpn.ArcticTacRP then return end

    wpn:ToggleBlindFire(bf)
end)

net.Receive("tacrp_togglecustomize", function(len, ply)
    local bf = net.ReadBool()

    local wpn = ply:GetActiveWeapon()

    if !wpn or !IsValid(wpn) or !wpn.ArcticTacRP then return end

    wpn:ToggleCustomize(bf)
end)

net.Receive("tacrp_toggletactical", function(len, ply)
    local wpn = ply:GetActiveWeapon()

    if !wpn or !IsValid(wpn) or !wpn.ArcticTacRP or !wpn:GetValue("CanToggle") then return end

    wpn:SetTactical(!wpn:GetTactical())
end)

net.Receive("tacrp_networkweapon", function(len, ply)
    local wpn = net.ReadEntity()

    if !wpn.ArcticTacRP then return end

    wpn:NetworkWeapon(ply)
end)

net.Receive("tacrp_attach", function(len, ply)
    local wpn = net.ReadEntity()

    local attach = net.ReadBool()
    local slot = net.ReadUInt(8)
    local attid = 0

    if attach then
        attid = net.ReadUInt(TacRP.Attachments_Bits)
    end

    if ply:GetActiveWeapon() != wpn or !wpn.ArcticTacRP then return end

    if attach then
        local att = TacRP.Attachments_Index[attid]

        wpn:Attach(slot, att, true)
    else
        wpn:Detach(slot, true)
    end
end)

net.Receive("tacrp_receivepreset", function(len, ply)
    local wpn = net.ReadEntity()

    if !wpn.ArcticTacRP or wpn:GetOwner() != ply then return end
    wpn:ReceivePreset()
end)