function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local dir = data:GetNormal()

    local emitter = ParticleEmitter(pos)
    local amt = 24

    if IsValid(data:GetEntity()) and data:GetEntity():IsOnGround() and data:GetEntity():Crouching() then
        pos = pos + Vector(0, 0, 4)
        for i = 1, amt / 2 do
            local _, a = LocalToWorld(Vector(), Angle((i / amt) * 360, 90, 0), pos, dir:Angle())
            local smoke = emitter:Add("particle/smokestack", pos)
            smoke:SetVelocity(dir * -50 + 300 * a:Up() + VectorRand() * 128)
            smoke:SetGravity(Vector(0, 0, -200))
            smoke:SetStartAlpha(200)
            smoke:SetEndAlpha(0)
            smoke:SetStartSize(8)
            smoke:SetEndSize(64)
            smoke:SetRoll(math.Rand(-180, 180))
            smoke:SetRollDelta(math.Rand(-0.2, 0.2))
            smoke:SetColor(200, 200, 200)
            smoke:SetAirResistance(150)
            smoke:SetCollide(true)
            smoke:SetBounce(0.2)
            smoke:SetLighting(true)
            smoke:SetDieTime(1)
        end

        for i = 1, amt / 2 do
            local smoke = emitter:Add("particle/smokestack", pos)
            smoke:SetVelocity(dir * math.Rand(400, 800) + VectorRand() * 128)
            smoke:SetStartAlpha(200)
            smoke:SetEndAlpha(0)
            smoke:SetStartSize(8)
            smoke:SetEndSize(32)
            smoke:SetRoll(math.Rand(-180, 180))
            smoke:SetRollDelta(math.Rand(-0.2, 0.2))
            smoke:SetColor(200, 200, 200)
            smoke:SetAirResistance(150)
            smoke:SetCollide(true)
            smoke:SetBounce(0.2)
            smoke:SetLighting(true)
            smoke:SetDieTime(0.75)
        end
    elseif IsValid(data:GetEntity()) and data:GetEntity():IsOnGround() then
        pos = pos + Vector(0, 0, 2)

        local dir2 = Vector(dir)
        dir2.z = 0
        dir2:Normalize()

        for i = 1, amt do
            local smoke = emitter:Add("particle/smokestack", pos)
            smoke:SetVelocity(dir2 * math.Rand(-600, -200) + VectorRand() * 128 + Vector(0, 0, math.Rand(250, 400)))
            smoke:SetGravity(Vector(0, 0, -300))
            smoke:SetStartAlpha(150)
            smoke:SetEndAlpha(0)
            smoke:SetStartSize(8)
            smoke:SetEndSize(32)
            smoke:SetRoll(math.Rand(-180, 180))
            smoke:SetRollDelta(math.Rand(-0.2, 0.2))
            smoke:SetColor(200, 200, 200)
            smoke:SetAirResistance(200)
            smoke:SetCollide(true)
            smoke:SetBounce(0.2)
            smoke:SetLighting(true)
            smoke:SetDieTime(1)
        end
    else
        for i = 1, amt do
            local _, a = LocalToWorld(Vector(), Angle((i / amt) * 360, 90, 0), pos, dir:Angle())
            local smoke = emitter:Add("particle/smokestack", pos)
            smoke:SetVelocity(dir * -50 + 150 * a:Up() + VectorRand() * 8)
            smoke:SetStartAlpha(200)
            smoke:SetEndAlpha(0)
            smoke:SetStartSize(8)
            smoke:SetEndSize(24)
            smoke:SetRoll(math.Rand(-180, 180))
            smoke:SetRollDelta(math.Rand(-0.2, 0.2))
            smoke:SetColor(200, 200, 200)
            smoke:SetAirResistance(150)
            smoke:SetCollide(true)
            smoke:SetBounce(0.2)
            smoke:SetLighting(true)
            smoke:SetDieTime(0.75)
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end
