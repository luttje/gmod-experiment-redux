function EFFECT:Init(data)
    if CurTime() < 1 then self:Remove() return end

    local pos = data:GetOrigin()
    local dir = data:GetNormal()

    self.EndTime = CurTime() + 0.25
    self.TrailEnt = data:GetEntity()
    if !IsValid(self.TrailEnt) then self:Remove() return end

    local emitter = ParticleEmitter(pos)
    local amt = 16

    if IsValid(self.TrailEnt) and self.TrailEnt:IsOnGround() then
        pos = pos + Vector(0, 0, 2)

        for i = 1, amt do
            local smoke = emitter:Add("particle/smokestack", pos)
            smoke:SetVelocity(dir * -200 + VectorRand() * 128 + Vector(0, 0, math.Rand(50, 100)))
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
            smoke:SetDieTime(0.5)
        end
    else
        for i = 1, amt do
            local _, a = LocalToWorld(Vector(), Angle((i / amt) * 360, 90, 0), pos, dir:Angle())
            local smoke = emitter:Add("particle/smokestack", pos)
            smoke:SetVelocity(dir * -50 + 150 * a:Up())
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
            smoke:SetDieTime(0.5)
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    if CurTime() > self.EndTime or !IsValid(self.TrailEnt) or (self.TrailEnt:IsPlayer() and !self.TrailEnt:Alive()) then
        return false
    end
    return true
end

function EFFECT:Render()
    local pos = self.TrailEnt:GetPos() + Vector( 0, 0, 1 )
    local emitter = ParticleEmitter(pos)
    local d = math.Clamp((self.EndTime - CurTime()) / 0.15, 0, 1) ^ 2

    local smoke = emitter:Add("particle/smokestack", pos)
    smoke:SetVelocity(VectorRand() * 4)
    smoke:SetStartAlpha(d * 150)
    smoke:SetEndAlpha(0)
    smoke:SetStartSize(4)
    smoke:SetEndSize(24)
    smoke:SetRoll(math.Rand(-180, 180))
    smoke:SetRollDelta(math.Rand(-0.2, 0.2))
    smoke:SetColor(200, 200, 200)
    smoke:SetAirResistance(15)
    smoke:SetCollide(false)
    smoke:SetBounce(0.2)
    smoke:SetLighting(true)
    smoke:SetDieTime(0.25)

    emitter:Finish()
end
