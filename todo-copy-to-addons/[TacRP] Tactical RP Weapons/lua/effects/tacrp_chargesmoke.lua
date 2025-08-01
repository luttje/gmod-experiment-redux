function EFFECT:Init(data)
    if CurTime() < 1 then self:Remove() return end

    self.TrailEnt = data:GetEntity()
    if !IsValid(self.TrailEnt) then self:Remove() return end

    local pos = data:GetOrigin() + Vector(0, 0, 4)
    local dir = data:GetNormal()

    local emitter = ParticleEmitter(pos)
    local amt = 24

    for i = 1, amt do
        local smoke = emitter:Add("particle/smokestack", pos)
        smoke:SetVelocity(dir * math.Rand(-300, -100) + VectorRand() * 256 + Vector(0, 0, math.Rand(100, 300)))
        smoke:SetGravity(Vector(0, 0, -300))
        smoke:SetStartAlpha(75)
        smoke:SetEndAlpha(0)
        smoke:SetStartSize(math.Rand(8, 12))
        smoke:SetEndSize(math.Rand(48, 64))
        smoke:SetRoll(math.Rand(-180, 180))
        smoke:SetRollDelta(math.Rand(-0.2, 0.2))
        smoke:SetColor(200, 200, 200)
        smoke:SetAirResistance(200)
        smoke:SetCollide(true)
        smoke:SetBounce(0.2)
        smoke:SetLighting(true)
        smoke:SetDieTime(math.Rand(0.9, 1.25))
    end
end

function EFFECT:Think()
    if !IsValid(self.TrailEnt) or (self.TrailEnt:IsPlayer() and !self.TrailEnt:Alive()) or !self.TrailEnt:GetNWBool("TacRPChargeState") then
        return false
    end
    return true
end

function EFFECT:Render()
    --if self.TrailEnt:IsOnGround() then
        local pos = self.TrailEnt:GetPos() + Vector(math.Rand(-8, 8), math.Rand(-8, 8), 4)

        local emitter = ParticleEmitter(pos)

        local smoke = emitter:Add("particle/smokestack", pos)
        if self.TrailEnt:IsOnGround() then
            smoke:SetVelocity(self.TrailEnt:GetVelocity() * 0.2 + VectorRand() * 32 + Vector(0, 0, math.Rand(32, 64)))
            smoke:SetGravity(Vector(0, 0, -128))

            smoke:SetStartSize(math.Rand(8, 12))
            smoke:SetEndSize(math.Rand(48, 64))
            smoke:SetDieTime(math.Rand(0.8, 1))
        else
            smoke:SetPos(pos + Vector(0, 0, 16))
            smoke:SetVelocity(VectorRand() * 32)
            smoke:SetGravity(Vector(0, 0, -128))
            smoke:SetStartSize(16)
            smoke:SetEndSize(32)
            smoke:SetDieTime(math.Rand(0.4, 0.6))
        end

        smoke:SetStartAlpha(25)
        smoke:SetEndAlpha(0)

        smoke:SetRoll(math.Rand(-180, 180))
        smoke:SetRollDelta(math.Rand(-0.2, 0.2))
        smoke:SetColor(200, 200, 200)
        smoke:SetAirResistance(25)
        smoke:SetCollide(true)
        smoke:SetBounce(0.2)
        smoke:SetLighting(true)

        emitter:Finish()
    --end
end
