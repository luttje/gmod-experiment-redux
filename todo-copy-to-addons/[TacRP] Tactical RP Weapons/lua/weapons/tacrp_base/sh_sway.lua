function SWEP:GetSwayAmount(pure)
    if self:GetOwner():IsNPC() then return 0 end

    local sway = self:GetValue("Sway")

    local d = self:GetSightDelta() - (self:GetPeeking() and self:GetValue("PeekPenaltyFraction") or 0)
    sway = Lerp(d, sway, self:GetValue("ScopedSway"))

    if self:GetBreath() < 1 then
        sway = sway + (1 * (1 - self:GetBreath()) * (self:GetOutOfBreath() and 1 or 0.5))
    end
    sway = Lerp(self:GetHoldBreathAmount() ^ 0.75, sway, 0)

    if self:GetBlindFire() then
        sway = sway + self:GetValue("BlindFireSway")
    end

    if self:GetOwner():Crouching() and !(self:GetOwner():KeyDown(IN_FORWARD) or self:GetOwner():KeyDown(IN_MOVELEFT) or self:GetOwner():KeyDown(IN_MOVERIGHT) or self:GetOwner():KeyDown(IN_BACK)) then
        sway = sway * self:GetValue("SwayCrouchMult")
    end

    if !pure then
        sway = sway + self:GetForcedSwayAmount()
    end

    if self:GetValue("Bipod") then
        local f = self:Curve(math.Clamp((CurTime() - self.LastBipodTime) / 0.15, 0, 1))
        if self:GetInBipod() then
            sway = Lerp(f, sway, 0)
        else
            sway = Lerp(f, 0, sway)
        end
    end

    return sway
end

function SWEP:GetForcedSwayAmount()
    local sway = 0

    if self:GetOwner():GetNWFloat("TacRPGasEnd", 0) > CurTime() then
        sway = sway + TacRP.ConVars["gas_sway"]:GetFloat() * Lerp(self:GetSightAmount(), 1, 0.25) * math.Clamp((self:GetOwner():GetNWFloat("TacRPGasEnd") - CurTime()) / 2, 0, 1)
    end

    return sway
end

function SWEP:GetSwayAngles()
    local swayamt = self:IsSwayEnabled() and self:GetSwayAmount() or self:GetForcedSwayAmount()
    local swayspeed = 1

    if swayamt <= 0 then return Angle(0, 0, 0) end

    local ct = CLIENT and UnPredictedCurTime() or CurTime()

    local ang = Angle(math.sin(ct * 0.6 * swayspeed) + (math.cos(ct * 2) * 0.5), math.sin(ct * 0.4 * swayspeed) + (math.cos(ct * 1.6) * 0.5), 0)

    ang = ang * swayamt

    return ang
end

function SWEP:IsSwayEnabled()
    return TacRP.ConVars["sway"]:GetBool()
end

function SWEP:ThinkHoldBreath()
    local owner = self:GetOwner()
    if !owner:IsPlayer() then return end

    local ft = FrameTime() * (game.SinglePlayer() and 1 or 0.5)

    if self:HoldingBreath() then

        self:SetBreath(math.max(0, self:GetBreath() - ft * self:GetBreathDrain() * (self:HasOptic() and 1 or 0.75) * (self:GetRecoilAmount() > 0 and 1.5 or 1)))

        if self:GetBreath() <= 0 then
            self:SetOutOfBreath(true)
        end

        if self:GetHoldBreathAmount() < 1 then
            self:SetHoldBreathAmount(math.min(1, self:GetHoldBreathAmount() + ft * self:GetBreathSpeed()))
        end
    else
        if self:GetHoldBreathAmount() > 0 then
            self:SetHoldBreathAmount(math.max(0, self:GetHoldBreathAmount() - ft * self:GetBreathSpeed() * 2))
        end

        if self:GetOutOfBreath() and self:GetBreath() >= 1 then
            self:SetOutOfBreath(false)
        end

        self:SetBreath(math.min(1, self:GetBreath() + ft * self:GetValue("BreathRecovery") * (self:GetOutOfBreath() and 0.2 or 0.25)))
    end
end

function SWEP:CanHoldBreath()
    return self:GetValue("Scope") and TacRP.ConVars["sway"]:GetBool() and self:GetScopeLevel() > 0 and !self:GetReloading()
end

function SWEP:NotOutOfBreath()
    return self:GetBreath() > 0 and !self:GetOutOfBreath()
end

local lastpressed = false
SWEP.IsHoldingBreath = false
function SWEP:HoldingBreath()
    local holding = self:GetOwner():KeyDown(IN_SPEED) or self:GetOwner():KeyDown(IN_RUN)
    if self:GetOwner():GetInfoNum("tacrp_toggleholdbreath", 0) == 1 then
        if holding and !lastpressed then
            self.IsHoldingBreath = !self.IsHoldingBreath
        end
    else
        self.IsHoldingBreath = holding
    end

    lastpressed = holding

    return self:CanHoldBreath() and self:GetSightAmount() >= 1 and self:NotOutOfBreath() and self.IsHoldingBreath
end

function SWEP:GetBreathDrain()
    if self.MiscCache["breath_cost"] == nil then
        self.MiscCache["breath_cost"] = (math.Clamp(self:GetValue("ScopedSway"), 0.1, 0.3) ^ 0.75) * (1 - 0.3 * math.Clamp((4 - 90 / self:GetValue("ScopeFOV")) / 3, 0, 1))
    end
    return self.MiscCache["breath_cost"] * self:GetValue("BreathDrain")
end

function SWEP:GetBreathSpeed()
    if self.MiscCache["breath_rate"] == nil then
        self.MiscCache["breath_rate"] = (math.Clamp(self:GetValue("ScopedSway"), 0.1, 0.5) ^ 0.5) / 0.3 + (0.5 * math.Clamp((4 - 90 / self:GetValue("ScopeFOV")) / 3, 0, 1))
    end
    return self.MiscCache["breath_rate"]
end