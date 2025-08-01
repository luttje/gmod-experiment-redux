TacRP.PhysBullets = {
}

function TacRP:SendBullet(bullet, attacker)
    net.Start("TacRP_sendbullet", true)
    net.WriteVector(bullet.Pos)
    net.WriteAngle(bullet.Vel:Angle())
    net.WriteFloat(bullet.Vel:Length())
    net.WriteFloat(bullet.Drag)
    net.WriteFloat(bullet.Gravity)
    net.WriteEntity(bullet.Weapon)

    if attacker and attacker:IsValid() and attacker:IsPlayer() and !game.SinglePlayer() then
        net.SendOmit(attacker)
    else
        if game.SinglePlayer() then
            net.WriteEntity(attacker)
        end
        net.Broadcast()
    end
end

function TacRP:ShootPhysBullet(wep, pos, vel, tbl)
    tbl = tbl or {}
    local bullet = {
        Penleft = wep:GetValue("Penetration"),
        Gravity = 1,
        Pos = pos,
        StartPos = Vector(pos),
        Vel = vel,
        Drag = 1,
        Travelled = 0,
        StartTime = CurTime(),
        Imaginary = false,
        Underwater = false,
        Weapon = wep,
        Attacker = wep:GetOwner(),
        Filter = {wep:GetOwner()},
        Damaged = {},
        Dead = false,
        NPC = wep:GetOwner():IsNPC()
    }

    if wep:GetValue("TracerNum") == 0 then
        bullet.Invisible = true
    else
        if wep:Clip1() % wep:GetValue("TracerNum") != 0 then
            bullet.Invisible = true
        end
    end

    for i, k in pairs(tbl) do
        bullet[i] = k
    end

    if bit.band( util.PointContents( pos ), CONTENTS_WATER ) == CONTENTS_WATER then
        bullet.Underwater = true
    end

    local add = game.SinglePlayer() or !TacRP.ConVars["client_damage"]:GetBool() or CLIENT
    if add then
        table.insert(TacRP.PhysBullets, bullet)
    end

    --[[]
    if wep:GetOwner():IsPlayer() and SERVER then
        local ping = wep:GetOwner():Ping() / 1000
        ping = math.Clamp(ping, 0, 0.5)
        local timestep = engine.TickInterval()

        while ping > 0 do
            TacRP:ProgressPhysBullet(bullet, math.min(timestep, ping))
            ping = ping - timestep
        end
    end
    ]]
    if wep:GetOwner():IsPlayer() and SERVER and add then
        local latency = math.floor(engine.TickCount() - wep:GetOwner():GetCurrentCommand():TickCount() - 1) -- FIXME: this math.floor does nothing
        local timestep = engine.TickInterval()
        while latency > 0 do
            TacRP:ProgressPhysBullet(bullet, timestep)
            latency = latency - 1
        end
    end

    if SERVER then
        TacRP:SendBullet(bullet, wep:GetOwner())
    end
end

if CLIENT then

net.Receive("TacRP_sendbullet", function(len, ply)
    local pos = net.ReadVector()
    local ang = net.ReadAngle()
    local vel = net.ReadFloat()
    local drag = net.ReadFloat()
    local grav = net.ReadFloat()
    local weapon = net.ReadEntity()

    if game.SinglePlayer() then
        ent = net.ReadEntity()
    end

    if !weapon:IsValid() or !weapon.GetValue then return end

    local bullet = {
        Pos = pos,
        StartPos = pos,
        Vel = ang:Forward() * vel,
        Travelled = 0,
        StartTime = CurTime(),
        Imaginary = false,
        Underwater = false,
        Dead = false,
        Damaged = {},
        Drag = drag,
        Gravity = grav,
        Weapon = weapon,
        Filter = {weapon:GetOwner()},
    }

    if weapon:GetValue("TracerNum") == 0 then
        bullet.Invisible = true
    else
        if weapon:Clip1() % weapon:GetValue("TracerNum") != 0 then
            bullet.Invisible = true
        end
    end

    if bit.band( util.PointContents( pos ), CONTENTS_WATER ) == CONTENTS_WATER then
        bullet.Underwater = true
    end

    table.insert(TacRP.PhysBullets, bullet)
end)

end

function TacRP:DoPhysBullets()
    local new = {}
    for _, i in pairs(TacRP.PhysBullets) do
        TacRP:ProgressPhysBullet(i, FrameTime())

        if !i.Dead then
            table.insert(new, i)
        end
    end

    TacRP.PhysBullets = new
end

hook.Add("Think", "TacRP_DoPhysBullets", TacRP.DoPhysBullets)

local function indim(vec, maxdim)
    if math.abs(vec.x) > maxdim or math.abs(vec.y) > maxdim or math.abs(vec.z) > maxdim then
        return false
    else
        return true
    end
end

function TacRP:ProgressPhysBullet(bullet, timestep)
    timestep = timestep or FrameTime()

    if bullet.Dead then return end

    local oldpos = bullet.Pos
    local oldvel = bullet.Vel
    local dir = bullet.Vel:GetNormalized()
    local spd = bullet.Vel:Length() * timestep
    local drag = bullet.Drag * spd * spd * (1 / 150000)
    local gravity = timestep * (bullet.Gravity or 1) * 600
    local first = math.abs(bullet.StartTime - CurTime()) <= 0.001

    local attacker = bullet.Attacker or NULL
    local weapon = bullet.Weapon

    if SERVER and !IsValid(attacker) then
        bullet.Dead = true
        return
    elseif CLIENT and !IsValid(attacker) then
        attacker = game.GetWorld()
    end

    if !IsValid(weapon) then
        bullet.Dead = true
        return
    end

    if bullet.Underwater then
        drag = drag * 3
    end

    if spd <= 0.001 then bullet.Dead = true return end

    local newpos = oldpos + (oldvel * timestep)
    local newvel = oldvel - (dir * drag)
    newvel = newvel - (Vector(0, 0, 1) * gravity)

    if bullet.Imaginary then
        -- the bullet has exited the map, but will continue being visible.
        bullet.Pos = newpos
        bullet.Vel = newvel
        bullet.Travelled = bullet.Travelled + spd
    else
        if !first and attacker:IsPlayer() then
            attacker:LagCompensation(true)
        end

        local tr = util.TraceLine({
            start = oldpos,
            endpos = newpos,
            filter = bullet.Filter,
            mask = MASK_SHOT
        })

        if !first and attacker:IsPlayer() then
            attacker:LagCompensation(false)
        end

        if GetConVar("developer"):GetInt() > 1 then
            if SERVER then
                debugoverlay.Line(oldpos, tr.HitPos, 5, Color(100,100,255), true)
            else
                debugoverlay.Line(oldpos, tr.HitPos, 5, Color(255,200,100), true)
            end
        end

        if tr.HitSky then
            if CLIENT then
                bullet.Imaginary = true
            else
                bullet.Dead = true
            end

            bullet.Pos = newpos
            bullet.Vel = newvel
            bullet.Travelled = bullet.Travelled + spd

            if SERVER then
                bullet.Dead = true
            end
        elseif tr.Hit then
            bullet.Travelled = bullet.Travelled + (oldpos - tr.HitPos):Length()
            bullet.Pos = tr.HitPos
            -- if we're the client, we'll get the bullet back when it exits.

            if !first and attacker:IsPlayer() then
                attacker:LagCompensation(true)
            end

            if SERVER then
                debugoverlay.Cross(tr.HitPos, 5, 5, Color(100,100,255), true)
            else
                debugoverlay.Cross(tr.HitPos, 5, 5, Color(255,200,100), true)
            end

            local eid = tr.Entity:EntIndex()

            if CLIENT then
                -- do an impact effect and forget about it
                if !game.SinglePlayer() then
                    attacker:FireBullets({
                        Src = oldpos,
                        Dir = dir,
                        Distance = spd + 16,
                        Tracer = 0,
                        Damage = 0,
                        IgnoreEntity = attacker,
                        Callback = function(att, btr, dmg)
                            if TacRP.ConVars["client_damage"]:GetBool() then
                                net.Start("tacrp_clientdamage")
                                    net.WriteEntity(weapon)
                                    net.WriteEntity(btr.Entity)
                                    net.WriteVector(dir)
                                    net.WriteVector(btr.Entity:WorldToLocal(btr.HitPos))
                                    net.WriteUInt(btr.HitGroup, 8)
                                    net.WriteFloat(bullet.Travelled or 0)
                                    net.WriteFloat(bullet.Penleft or 0)
                                    net.WriteUInt(#bullet.Damaged, 4)
                                    for i = 1, #bullet.Damaged do net.WriteEntity(bullet.Damaged[i]) end
                                net.SendToServer()
                            end
                        end
                    })
                end
                bullet.Dead = true
                return
            elseif SERVER then
                bullet.Damaged[eid] = true
                bullet.Dead = true
                if game.SinglePlayer() or !TacRP.ConVars["client_damage"]:GetBool() then
                    bullet.Attacker:FireBullets({
                        Damage = weapon:GetValue("Damage_Max"),
                        Force = 8,
                        Tracer = 0,
                        Num = 1,
                        Dir = bullet.Vel:GetNormalized(),
                        Src = oldpos,
                        Spread = Vector(0, 0, 0),
                        Callback = function(att, btr, dmg)
                            local range = bullet.Travelled
                            if !IsValid(weapon) then return end
                            weapon:AfterShotFunction(btr, dmg, range, bullet.Penleft, bullet.Damaged)
                        end
                    })
                end
            end

            if !first and attacker:IsPlayer() then
                attacker:LagCompensation(false)
            end
        else
            -- bullet did not impact anything
            -- break glass in the way
            -- attacker:FireBullets({
            --     Src = oldpos,
            --     Dir = dir,
            --     Distance = spd,
            --     Tracer = 0,
            --     Damage = 0,
            --     IgnoreEntity = bullet.Attacker
            -- })

            bullet.Pos = tr.HitPos
            bullet.Vel = newvel
            bullet.Travelled = bullet.Travelled + spd

            if bullet.Underwater then
                if bit.band( util.PointContents( tr.HitPos ), CONTENTS_WATER ) != CONTENTS_WATER then
                    local utr = util.TraceLine({
                        start = tr.HitPos,
                        endpos = oldpos,
                        filter = bullet.Attacker,
                        mask = MASK_WATER
                    })

                    if utr.Hit then
                        local fx = EffectData()
                        fx:SetOrigin(utr.HitPos)
                        fx:SetScale(5)
                        fx:SetFlags(0)
                        util.Effect("gunshotsplash", fx)
                    end

                    bullet.Underwater = false
                end
            else
                if bit.band( util.PointContents( tr.HitPos ), CONTENTS_WATER ) == CONTENTS_WATER then
                    local utr = util.TraceLine({
                        start = oldpos,
                        endpos = tr.HitPos,
                        filter = bullet.Attacker,
                        mask = MASK_WATER
                    })

                    if utr.Hit then
                        local fx = EffectData()
                        fx:SetOrigin(utr.HitPos)
                        fx:SetScale(5)
                        fx:SetFlags(0)
                        util.Effect("gunshotsplash", fx)
                    end

                    bullet.Underwater = true
                end
            end
        end
    end

    local MaxDimensions = 16384 * 4
    local WorldDimensions = 16384

    if bullet.StartTime <= (CurTime() - 10) then
        bullet.Dead = true
    elseif !indim(bullet.Pos, MaxDimensions) then
        bullet.Dead = true
    elseif !indim(bullet.Pos, WorldDimensions) then
        bullet.Imaginary = true
    end
end

local head = Material("particle/fire")
local tracer = Material("tacrp/tracer")

function TacRP:DrawPhysBullets()
    cam.Start3D()
    for _, i in pairs(TacRP.PhysBullets) do
        if i.Invisible then continue end
        --if i.Travelled <= 1024 then continue end
        local pos = i.Pos

        local speedvec = -i.Vel:GetNormalized()
        local vec = speedvec
        local shoulddraw = true

        if IsValid(i.Weapon) then
            local fromvec = (i.Weapon:GetTracerOrigin() - pos):GetNormalized()

            local d = math.min(i.Travelled / 1024, 1)
            if i.Indirect then
                d = 1
            end

            vec = LerpVector(d, fromvec, speedvec)
        end

        if !shoulddraw then continue end

        local size = math.Clamp(math.log(EyePos():DistToSqr(pos) - math.pow(512, 2)), 0, math.huge)

        local vel = i.Vel - LocalPlayer():GetVelocity()

        local dot = math.abs(EyeAngles():Forward():Dot(vel:GetNormalized()))
        -- dot = math.Clamp(((dot * dot) - 0.25) * 5, 0, 1)
        local headsize = size * dot * 2 -- * math.min(EyePos():DistToSqr(pos) / math.pow(2500, 2), 1)

        local col = i.Color or Color(255, 225, 200)

        render.SetMaterial(head)
        render.DrawSprite(pos, headsize, headsize, col)

        render.SetMaterial(tracer)

        local tail = (vec:GetNormalized() * math.min(vel:Length() / 25, 512, i.Travelled - 64))

        render.DrawBeam(pos, pos + tail, size * 0.75, 0, 1, col)

    end
    cam.End3D()
end

hook.Add("PreDrawEffects", "TacRP_DrawPhysBullets", TacRP.DrawPhysBullets)

hook.Add("PostCleanupMap", "TacRP_CleanPhysBullets", function()
    TacRP.PhysBullets = {}
end)

if SERVER then
    net.Receive("tacrp_clientdamage", function(len, ply)
        local weapon = net.ReadEntity()
        local tgt = net.ReadEntity()
        local dir = net.ReadVector()
        local hitpos = tgt:LocalToWorld(net.ReadVector())
        local hitgroup = net.ReadUInt(8)
        local range = net.ReadFloat()
        local penleft = net.ReadFloat()
        local count = net.ReadUInt(3)
        local damaged = {}
        for i = 1, count do
            table.insert(damaged, net.ReadEntity())
        end

        if !ply:Alive() or !IsValid(weapon) or weapon:GetOwner() != ply then return end
        -- if math.abs(ply:GetPos():DistToSqr(hitpos) - ply:GetPos():DistToSqr(tgt:GetPos())) > 64 * 64 then return end

        local suppress = !(tgt:IsNPC() or tgt:IsNextBot())
        if suppress then
            SuppressHostEvents(ply)
        end

        local dmg = DamageInfo()
        dmg:SetAttacker(ply)
        dmg:SetInflictor(ply)
        dmg:SetDamagePosition(hitpos)
        local btr = util.TraceLine({
            start = hitpos - dir * 2,
            endpos = hitpos,
            mask = MASK_SHOT,
        })
        btr.Entity = tgt
        btr.HitGroup = hitgroup
        weapon:AfterShotFunction(btr, dmg, range, penleft, damaged, true)
        tgt:DispatchTraceAttack(dmg, btr, dir)

        -- ply:FireBullets({
        --     Damage = weapon:GetValue("Damage_Max"),
        --     Force = 8,
        --     Tracer = 0,
        --     Num = 1,
        --     Dir = dir * 2,
        --     Src = hitpos - dir * 1,
        --     Spread = Vector(0, 0, 0),
        --     Callback = function(att, btr, dmg)
        --         debugoverlay.Line(btr.StartPos, btr.HitPos, 3, btr.Entity == tgt and Color(0, 255, 0) or Color(255, 255, 0))
        --         weapon:AfterShotFunction(btr, dmg, range, penleft, damaged, true)
        --     end
        -- })
        if suppress then
            SuppressHostEvents()
        end
    end)
end