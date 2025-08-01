EFFECT.StartPos = Vector(0, 0, 0)
EFFECT.EndPos = Vector(0, 0, 0)
EFFECT.StartTime = 0
EFFECT.LifeTime = 0.15
EFFECT.LifeTime2 = 0.15
EFFECT.DieTime = 0
EFFECT.Color = Color(255, 255, 255)
EFFECT.Speed = 5000

local head = Material("particle/fire")
local tracer = Material("tacrp/tracer")

function EFFECT:Init(data)

    local hit = data:GetOrigin()
    local wep = data:GetEntity()

    if !IsValid(wep) then return end
    local tacrp = wep.ArcticTacRP and wep.GetValue

    local start = data:GetStart()
    if wep:GetOwner() == LocalPlayer() and tacrp and wep:GetValue("ScopeHideWeapon") and wep:IsInScope() then
        start = EyePos()
                + EyeAngles():Right() * wep.PassivePos.x
                + EyeAngles():Forward() * wep.PassivePos.y
                + EyeAngles():Up() * wep.PassivePos.z
    elseif wep.GetTracerOrigin then
        start = wep:GetTracerOrigin()
    end

    if !start then
        start = wep:GetPos() -- ???
    end

    local diff = hit - start
    local dist = diff:Length()

    if !tacrp then
        self.Speed = 15000
    elseif TacRP.ConVars["physbullet"]:GetBool() then
        self.Speed = math.max(wep:GetValue("MuzzleVelocity") or data:GetScale(), 5000)
    else
        self.Speed = math.max(wep:GetValue("MuzzleVelocity") or data:GetScale(), dist / 0.4)
    end

    self.LifeTime = dist / self.Speed
    self.StartTime = UnPredictedCurTime()
    self.DieTime = UnPredictedCurTime() + math.max(self.LifeTime, self.LifeTime2)

    self.StartPos = start
    self.EndPos = hit
    self.Dir = diff:GetNormalized()
end

function EFFECT:Think()
    return self.DieTime > UnPredictedCurTime()
end

function EFFECT:Render()

    if !self.Dir then return end

    local d = (UnPredictedCurTime() - self.StartTime) / self.LifeTime
    local startpos = self.StartPos + (d * 0.2 * (self.EndPos - self.StartPos))
    local endpos = self.StartPos + (d * (self.EndPos - self.StartPos))

    --[[]
    local col = LerpColor(d, self.Color, Color(0, 0, 0, 0))
    local col2 = LerpColor(d2, Color(255, 255, 255, 255), Color(0, 0, 0, 0))

    render.SetMaterial(head)
    render.DrawSprite(endpos, size * 3, size * 3, col)

    render.SetMaterial(tracer)
    render.DrawBeam(endpos, startpos, size, 0, 1, col)
    ]]

    local size = math.Clamp(math.log(EyePos():DistToSqr(endpos) - math.pow(256, 2)), 0, math.huge)

    local vel = self.Dir * self.Speed - LocalPlayer():GetVelocity()

    local dot = math.abs(EyeAngles():Forward():Dot(vel:GetNormalized()))
    --dot = math.Clamp(((dot * dot) - 0.25) * 5, 0, 1)
    local headsize = size * dot * 2 -- * math.min(EyePos():DistToSqr(pos) / math.pow(2500, 2), 1)
    -- cam.Start3D()

    local col = Color(255, 225, 200)
    -- local col = Color(255, 225, 200)

    render.SetMaterial(head)
    render.DrawSprite(endpos, headsize, headsize, col)

    -- local tailpos = startpos
    -- if (endpos - startpos):Length() > 512 then
    --     tailpos = endpos - self.Dir * 512
    -- end
    local tail = (self.Dir * math.min(self.Speed / 25, 512, (endpos - startpos):Length() - 64))

    render.SetMaterial(tracer)
    render.DrawBeam(endpos, endpos - tail, size * 0.75, 0, 1, col)
end
