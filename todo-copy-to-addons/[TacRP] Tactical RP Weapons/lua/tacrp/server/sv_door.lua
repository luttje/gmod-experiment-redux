function TacRP.DoorBust(ent, vel, attacker)
    if !string.find(ent:GetClass(), "door") then return end
    local cvar = 1 --TacRP.ConVars["doorbust"]:GetInt()
    local t = 300 -- TacRP.ConVars["doorbust_time"]:GetFloat()
    if cvar == 0 or ent.TacRP_DoorBusted then return end
    ent.TacRP_DoorBusted = true

    local oldSpeed = ent:GetInternalVariable("m_flSpeed")
    ent:Fire("SetSpeed", tostring(oldSpeed * 10), 0)
    ent:Fire("Open", "", 0)
    ent:Fire("SetSpeed", oldSpeed, 0.3)

    if ent:GetPhysicsObject():IsValid() and cvar == 1 then

        -- Don't remove the door, that's a silly thing to do
        ent:SetNoDraw(true)
        ent:SetNotSolid(true)
        ent.original_pos = ent:GetPos()

        -- Make a busted door prop and fling it
        local prop = ents.Create("prop_physics")
        prop:SetModel(ent:GetModel())
        prop:SetPos(ent:GetPos())
        prop:SetAngles(ent:GetAngles())
        prop:SetSkin(ent:GetSkin() or 0)
        prop:Spawn()

        -- Shrink the door collision a little so it will slide through the door frame. Only do it to brush doors or the hl2 one in case some of them have custom collision
        if prop:GetModel() == "models/props_c17/door01_left.mdl" or string.Left(prop:GetModel(), 1) == "*" then
            local mins, maxs = prop:GetCollisionBounds()
            prop:PhysicsInitBox(mins + Vector(2, 2, 2), maxs - Vector(2, 2, 2))
        end

        prop:GetPhysicsObject():SetVelocityInstantaneous(vel)
        prop:SetPhysicsAttacker(attacker, 3)

        -- This is necessary to set the render bounds of func doors
        timer.Simple(0, function()
            net.Start("tacrp_doorbust")
                net.WriteEntity(prop)
            net.Broadcast()
        end)

        -- Make it not collide with players after a bit cause that's annoying
        timer.Create("TacRP_DoorBust_" .. prop:EntIndex(), 2, 1, function()
            if IsValid(prop) then
                prop:SetCollisionGroup(COLLISION_GROUP_WEAPON)
                local c = prop:GetColor()
                prop:SetRenderMode(RENDERMODE_TRANSALPHA)
                prop:SetColor(Color(c.r, c.g, c.b, c.a * 0.8))
            end
        end)

        -- Reset it after a while
        timer.Simple(1, function()
            ent:SetPos(ent.original_pos - Vector(0, 0, 100000))
        end)
        SafeRemoveEntityDelayed(prop, t)
        timer.Create("TacRP_DoorBust_" .. ent:EntIndex(), t, 1, function()
            if IsValid(ent) then
                ent:SetNoDraw(false)
                ent:SetNotSolid(false)
                ent.TacRP_DoorBusted = false
                ent:SetPos(ent.original_pos)
                ent.original_pos = nil
            end
        end)
    else

        timer.Create("TacRP_DoorBust_" .. ent:EntIndex(), 0.5, 1, function()
            if IsValid(ent) then
                ent.TacRP_DoorBusted = false
            end
        end)
    end
end