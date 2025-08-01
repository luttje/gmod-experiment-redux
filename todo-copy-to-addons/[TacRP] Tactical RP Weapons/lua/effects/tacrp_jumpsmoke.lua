function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local dir = data:GetNormal()
    self.TrailEnt = data:GetEntity()
    if !IsValid(self.TrailEnt) then self:Remove() return end

    local emitter = ParticleEmitter(pos)
    local amt = 16

    for i = 1, amt do
        local _, a = LocalToWorld(Vector(0, 0, 2), Angle((i / amt) * 360, 90, 0), pos, dir:Angle())
        local smoke = emitter:Add("particle/smokestack", pos)
        smoke:SetVelocity(150 * a:Up())
        smoke:SetStartAlpha(50)
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
        smoke:SetDieTime(0.4)
    end

    emitter:Finish()
end

function EFFECT:Think()
    return true
end

function EFFECT:Render()
end
