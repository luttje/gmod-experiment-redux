function EFFECT:Init(data)
    if CurTime() < 1 then self:Remove() return end

    local pos = data:GetOrigin()
    local dir = data:GetNormal()

    self.EndTime = CurTime() + 0.2
    self.TrailEnt = data:GetEntity()
    if !IsValid(self.TrailEnt) then self:Remove() return end

    local emitter = ParticleEmitter(pos)

    local tr = util.TraceLine({
        start = pos,
        endpos = pos - Vector(0, 0, 2048),
        mask = MASK_SOLID_BRUSHONLY
    })

    pos = pos - dir * 32
    local amt = 12 + math.ceil(tr.Fraction / 20)

    for i = 1, amt do
        local _, a = LocalToWorld(Vector(), Angle((i / amt) * 360, 90, 0), pos, dir:Angle())
        local smoke = emitter:Add("particle/smokestack", pos)
        smoke:SetVelocity(dir * -(150 + tr.Fraction * 100) + (300 - tr.Fraction * 100) * a:Up())
        smoke:SetStartAlpha(20 + tr.Fraction * 50)
        smoke:SetEndAlpha(0)
        smoke:SetStartSize(8)
        smoke:SetEndSize(24 + tr.Fraction * 16)
        smoke:SetRoll(math.Rand(-180, 180))
        smoke:SetRollDelta(math.Rand(-0.2, 0.2))
        smoke:SetColor(200, 200, 200)
        smoke:SetAirResistance(50)
        smoke:SetCollide(false)
        smoke:SetBounce(0.2)
        smoke:SetLighting(false)
        smoke:SetDieTime(0.15 + tr.Fraction * 0.6)
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
    if self.TrailEnt:IsOnGround() then
        local pos = self.TrailEnt:GetPos() + Vector(math.Rand(-8, 8), math.Rand(-8, 8), 4)
        local dir = self.TrailEnt:GetVelocity():GetNormalized()
        local vel = self.TrailEnt:GetVelocity():Length()

        local emitter = ParticleEmitter(pos)

        if engine.TickCount() % 2 == 0 then
            local smoke = emitter:Add("particle/smokestack", pos)
            smoke:SetVelocity(VectorRand() * (50 + math.min(vel, 500) * 0.25) + dir * math.min(vel, 500) + Vector(0, 0, 200 - math.min(vel, 200)))
            smoke:SetGravity(Vector(0, 0, -400))
            smoke:SetStartAlpha(50)
            smoke:SetEndAlpha(0)
            smoke:SetStartSize(4)
            smoke:SetEndSize(32)
            smoke:SetRoll(math.Rand(-180, 180))
            smoke:SetRollDelta(math.Rand(-0.2, 0.2))
            smoke:SetColor(200, 200, 200)
            smoke:SetAirResistance(25)
            smoke:SetCollide(true)
            smoke:SetBounce(0.2)
            smoke:SetLighting(true)
            smoke:SetDieTime(math.Rand(0.75, 1))
        end

        emitter:Finish()
    end
end
