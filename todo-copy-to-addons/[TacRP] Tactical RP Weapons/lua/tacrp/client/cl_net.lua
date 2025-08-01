net.Receive("tacrp_networkweapon", function(len)
    local wpn = net.ReadEntity()

    -- When the server immediately calls NetworkWeapon on a new weapon,
    -- the client entity may not be valid or correct instantly.
    -- (in SP, the entity will appear valid but the functions/variables will all be nil.)
    if !IsValid(wpn) or !wpn.ArcticTacRP then
        local tname = "wait" .. engine.TickCount() .. math.random(100, 999)

        -- Read bits now (can't do it in a timer)
        -- WriteEntity always uses 13 bits, so we can derive amount of attachments
        local ids = {}
        for i = 1, (len - 13) / TacRP.Attachments_Bits do
            table.insert(ids, net.ReadUInt(TacRP.Attachments_Bits))
        end

        -- Wait until entity properly exists to pass on attachment info.
        -- Usually won't take more than 1 tick but ping may cause issues
        timer.Create(tname, 0, 100, function()
            if !IsValid(wpn) or !wpn.ArcticTacRP then return end

            wpn:ReceiveWeapon(ids)
            wpn:UpdateHolster()

            timer.Remove(tname)
        end)
    else
        wpn:ReceiveWeapon()
        wpn:UpdateHolster()
    end
end)

net.Receive("TacRP_updateholster", function()
    local ply = net.ReadEntity()
    --local slot = net.ReadUInt(TacRP.HolsterNetBits)
    local item = net.ReadEntity()

    if !IsValid(item) or !item.GetValue then return end

    local visible = item:GetValue("HolsterVisible")
    local slot = item:GetValue("HolsterSlot")

    if visible and slot then
        ply.TacRP_Holster = ply.TacRP_Holster or {}
        if !IsValid(item) then
            ply.TacRP_Holster[slot] = nil
        else
            ply.TacRP_Holster[slot] = item
        end
    end
end)

net.Receive("tacrp_doorbust", function()
    local door = net.ReadEntity()
    if IsValid(door) then
        local mins, maxs = door:GetCollisionBounds()
        door:SetRenderBounds(mins, maxs, Vector(4, 4, 4))
    end
end)

gameevent.Listen("player_spawn")
hook.Add("player_connect", "TacRP_Holster", function(userid)
    local ply = Player(userid)
    ply.TacRP_Holster = {}
end)

net.Receive("tacrp_flashbang", function()
    local time = net.ReadFloat()

    if time > 0 then
        LocalPlayer():ScreenFade( SCREENFADE.IN, TacRP.ConVars["flash_dark"]:GetBool() and Color(0, 0, 0, 255) or Color(255, 255, 255, 255), math.min(time * 2, 2.5), time)
    end

    if TacRP.ConVars["flash_dark"]:GetBool() then
        LocalPlayer():SetDSP(32, time == 0)
    else
        LocalPlayer():SetDSP(37, time == 0)
    end

end)
net.Receive("tacrp_addshieldmodel", function(len, ply)
    local wpn = net.ReadEntity()
    local mdl = net.ReadEntity()
    mdl.mmRHAe = net.ReadFloat()
    mdl.TacRPShield = true

    if !IsValid(wpn) or !wpn.ArcticTacRP then return end

    wpn.Shields = wpn.Shields or {}
    table.insert(wpn.Shields, mdl)
end)