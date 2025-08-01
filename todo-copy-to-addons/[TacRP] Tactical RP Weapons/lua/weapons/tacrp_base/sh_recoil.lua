function SWEP:GetRecoilResetTime(base)
    if base then
        return (self:GetBaseValue("RecoilResetInstant") and 0 or math.min(0.5, 60 / self:GetBaseValue("RPM"))) + self:GetBaseValue("RecoilResetTime")
    else
        return (self:GetValue("RecoilResetInstant") and 0 or math.min(0.5, 60 / self:GetValue("RPM"))) + self:GetValue("RecoilResetTime")
    end
end

function SWEP:ThinkRecoil()
    -- if ((IsFirstTimePredicted() and CLIENT) or game.SinglePlayer()) and self:GetRecoilAmount() > 0 then
    --     local kick = self:GetValue("RecoilKick")

    --     if self:GetOwner():Crouching() and !(self:GetOwner():KeyDown(IN_FORWARD) or self:GetOwner():KeyDown(IN_MOVELEFT) or self:GetOwner():KeyDown(IN_MOVERIGHT) or self:GetOwner():KeyDown(IN_BACK)) then
    --         kick = kick * self:GetValue("RecoilCrouchMult")
    --     end

    --     -- local rec = math.min(self:GetRecoilAmount(), 1)
    --     -- local sightdelta = self:GetSightDelta()

    --     -- local aim_kick_v = rec * kick * math.sin((CurTime() - kick) * 15) * FrameTime() * (1 - sightdelta)
    --     -- local aim_kick_h = rec * kick * math.sin(CurTime() * 12.2) * FrameTime() * (1 - sightdelta)

    --     -- self:SetFreeAimAngle(self:GetFreeAimAngle() - Angle(aim_kick_v, aim_kick_h, 0))
    -- end

    if self:GetLastRecoilTime() + engine.TickInterval() + self:GetRecoilResetTime() < CurTime() then
        local rec = self:GetRecoilAmount()

        rec = rec - (FrameTime() * self:GetValue("RecoilDissipationRate"))
        rec = math.Clamp(rec, 0, self:GetValue("RecoilMaximum"))

        self:SetRecoilAmount(rec)
    end
end

function SWEP:ApplyRecoil()
    local rec = self:GetRecoilAmount()

    local rps = self:GetValue("RecoilPerShot")

    if rec == 0 then
        rps = rps * self:GetValue("RecoilFirstShotMult")
    end

    if self:GetOwner():Crouching() and self:GetOwner():OnGround() then
        rps = rps * self:GetValue("RecoilCrouchMult")
    end

    if self:GetInBipod() then
        rps = rps * math.min(1, self:GetValue("BipodRecoil"))
    end

    rec = rec + rps

    rec = math.Clamp(rec, 0, self:GetValue("RecoilMaximum"))

    if self:UseRecoilPatterns() then
        self:SetRecoilDirection(self:GetRecoilPatternDirection(self:GetPatternCount()))
    else
        local stab = math.Clamp(self:GetValue("RecoilStability"), 0, 0.9)
        self:SetRecoilDirection(util.SharedRandom("tacrp_recoildir", -180 + stab * 90, -stab * 90))
    end

    -- self:SetRecoilDirection(-90)
    self:SetRecoilAmount(rec)
    self:SetLastRecoilTime(CurTime())

    local vis_kick = self:GetValue("RecoilVisualKick")
    local vis_shake = 0

    vis_kick = vis_kick * TacRP.ConVars["mult_recoil_vis"]:GetFloat()
    vis_shake = 0

    if self:GetInBipod() then
        vis_kick = vis_kick * math.min(1, self:GetValue("BipodKick"))
        vis_shake = math.max(0, 1 - self:GetValue("BipodKick"))
    end

    local vis_kick_v = vis_kick * 1
    local vis_kick_h = vis_kick * util.SharedRandom("tacrp_vis_kick_h", -1, 1)

    self:GetOwner():SetViewPunchAngles(Angle(vis_kick_v, vis_kick_h, vis_shake))

    -- self:GetOwner():SetFOV(self:GetOwner():GetFOV() * 0.99, 0)
    -- self:GetOwner():SetFOV(self:GetOwner():GetFOV(), 60 / (self:GetValue("RPM")))
end

function SWEP:RecoilDuration()
    -- return self:GetValue("RecoilResetTime")
    return 0.04 + math.Clamp(math.abs(self:GetValue("RecoilKick")) ^ 0.5, 0, 4) * 0.04
end

function SWEP:UseRecoilPatterns()
    if !TacRP.ConVars["recoilpattern"]:GetBool() then return false end
    if self:GetValue("ShootEnt") or self:GetValue("NoRecoilPattern") then return false end
    if self:GetValue("RPM") <= 100 then return false end
    if self:GetCurrentFiremode() < 0 then return false end

    return true
end

SWEP.RecoilPatternCache = {}
SWEP.RecoilPatternSeedCache = nil
function SWEP:GetRecoilPatternDirection(shot)
    local dir = 0

    if !self.RecoilPatternSeedCache then
        local cacheseed = self.RecoilPatternSeed or self:GetClass()
        if isstring(cacheseed) then
            local numseed = 0
            for _, i in ipairs(string.ToTable(cacheseed)) do
                numseed = numseed + string.byte(i)
            end
            numseed = numseed % 16777216
            cacheseed = numseed
        end
        self.RecoilPatternSeedCache = cacheseed
    end

    local seed = self.RecoilPatternSeedCache + shot

    if self.RecoilPatternCache[shot] then
        dir = self.RecoilPatternCache[shot]
    else
        self.RecoilPatternCache[1] = 0
        if self.RecoilPatternCache[shot - 1] then
            --dir = self.RecoilPatternCache[shot - 1]
            math.randomseed(seed)
            local stab = math.Clamp(self:GetValue("RecoilStability"), 0, 0.9)
            local max = self:GetBaseValue("RPM") / 60 * (1.1 + stab * 1.1)
            local cap = 120 --math.Clamp(30 + shot * (90 / max), 30, 120)
            --dir = dir + math.Rand(-stab * 90, stab * 90)
            dir = Lerp(0.4 + (shot / max) * 0.6, self.RecoilPatternCache[shot - 1], math.Rand(-(1 - stab) * cap, (1 - stab) * cap))
            if self:GetCurrentFiremode() != 1 then
                dir = Lerp(shot / max, dir, math.Clamp(dir * 1.667, -cap, cap))
            end
            math.randomseed(CurTime() + self:EntIndex())
            self.RecoilPatternCache[shot] = dir
            -- print(shot, cap, max, dir)
        else
            dir = 0
        end
    end

    return math.NormalizeAngle(dir - 90)
end