function SWEP:GetReloadTime(base)
    local vm = self:GetVM()
    local valfunc = base and self.GetBaseValue or self.GetValue

    if !valfunc(self, "ShotgunReload") then
        local seq = vm:LookupSequence(self:TranslateSequence("reload"))
        local basetime = vm:SequenceDuration(seq)
        local mult = valfunc(self, "ReloadTimeMult") / TacRP.ConVars["mult_reloadspeed"]:GetFloat()

        return basetime * mult
    else
        local seq1 = vm:LookupSequence(self:TranslateSequence("reload_start"))
        local seq2 = vm:LookupSequence(self:TranslateSequence("reload"))
        local seq3 = vm:LookupSequence(self:TranslateSequence("reload_finish"))

        local time_1 = vm:SequenceDuration(seq1)
        local time_2 = vm:SequenceDuration(seq2)
        local time_3 = vm:SequenceDuration(seq3)

        local mult = valfunc(self, "ReloadTimeMult") / TacRP.ConVars["mult_reloadspeed"]:GetFloat()

        local basetime = time_1 + (time_2 * valfunc(self, "ClipSize")) + time_3

        if valfunc(self, "ShotgunThreeload") then
            basetime = time_1 + (time_2 * valfunc(self, "ClipSize") / 3) + time_3
        end

        return basetime * mult
    end
end

function SWEP:GetDeployTime(base)
    local vm = self:GetVM()
    local valfunc = base and self.GetBaseValue or self.GetValue

    local anim = "deploy"
    local mult = valfunc(self, "DeployTimeMult")

    if valfunc(self, "TryUnholster") then
        anim = "unholster"
        mult = mult * valfunc(self, "UnholsterTimeMult")
    end

    local seq = vm:LookupSequence(self:TranslateSequence(anim))
    local basetime = vm:SequenceDuration(seq)

    return basetime * mult
end

function SWEP:CalcHolsterTime(base)
    local vm = self:GetVM()
    local valfunc = base and self.GetBaseValue or self.GetValue

    local anim = "holster"
    if valfunc(self, "NoHolsterAnimation") then
        anim = "deploy"
    end

    local mult = valfunc(self, "HolsterTimeMult")

    local seq = vm:LookupSequence(self:TranslateSequence(anim))
    local basetime = vm:SequenceDuration(seq)

    return basetime * mult
end

function SWEP:GetMuzzleVelocity(base)
    local valfunc = base and self.GetBaseValue or self.GetValue

    local basetime = valfunc(self, "MuzzleVelocity")

    if valfunc(self, "ShootEnt") then
        basetime = valfunc(self, "ShootEntForce")
    end

    return math.ceil(0.3048 * basetime / 12)
end

-- function SWEP:GetMeanShotsToFail(base)
--     local valfunc = base and self.GetBaseValue or self.GetValue
--     local shootchance = valfunc(self, "ShootChance")

--     return 1 / (1 - shootchance)
-- end

function SWEP:GetBestFiremode(base)
    local valfunc = base and self.GetBaseValue or self.GetValue

    if valfunc(self, "Firemodes") then
        local bfm, bfm_i
        for k, v in pairs(valfunc(self, "Firemodes")) do
            if !bfm or v == 2 or (bfm <= 1 and v < bfm) then
                bfm = v
                bfm_i = k
            end
        end
        return bfm, bfm_i
    else
        return valfunc(self, "Firemode") or 0, 1
    end
end

function SWEP:GetSubClassName(tier)
    if self.SubCatType then
        local type_txt = TacRP:TryTranslate(self.SubCatType)
        if tier and self.SubCatTier and self.SubCatTier != "9Special" then
            type_txt = TacRP:GetPhrase("cust.type_tier", {tier = TacRP:TryTranslate(self.SubCatTier), type = type_txt})
        end
        return type_txt
    end
    return "Weapon"
end



local hitgroups = {
    [HITGROUP_HEAD] = 0.1,
    [HITGROUP_CHEST] = 0.2,
    [HITGROUP_STOMACH] = 0.3,
    [HITGROUP_LEFTARM] = 0.2,
    [HITGROUP_LEFTLEG] = 0.2,
}

local mssd_scoring = {
    [HITGROUP_HEAD]    = {0.15, 0.5,  {1, 0.6,  0.3, 0.15, 0.05}},
    [HITGROUP_CHEST]   = {0.25, 0.75, {1, 0.75, 0.4, 0.2,  0.1}},
    [HITGROUP_STOMACH] = {0.25, 0.8,  {1, 0.8,  0.5, 0.25, 0.15, 0.05}},
    [HITGROUP_LEFTARM] = {0.2,  0.5,  {1, 0.85, 0.6, 0.3,  0.2,  0.1, 0.05}},
    [HITGROUP_LEFTLEG] = {0.15, 0.5,  {1, 0.9,  0.7, 0.4,  0.25, 0.15, 0.1}},
}

local mssd_scoring_ttt = {
    [HITGROUP_HEAD]    = {0.25, 0.5,  {1, 0.75, 0.50, 0.25, 0.15, 0.10, 0.05, 0.025}},
    [HITGROUP_CHEST]   = {0.25, 0.75, {1, 0.90, 0.75, 0.55, 0.45, 0.35, 0.25, 0.15, 0.10, 0.05}},
    [HITGROUP_STOMACH] = {0.25, 1,    {1, 1.00, 0.90, 0.80, 0.60, 0.40, 0.30, 0.20, 0.15, 0.10, 0.05}},
    [HITGROUP_LEFTARM] = {0.15, 1,    {1, 1.00, 0.80, 0.70, 0.50, 0.30, 0.25, 0.15, 0.10, 0.05, 0.025}},
    [HITGROUP_LEFTLEG] = {0.10, 1,    {1, 1.00, 0.90, 0.75, 0.60, 0.50, 0.40, 0.30, 0.25, 0.20, 0.15, 0.10, 0.05}},
}

SWEP.StatGroupGrades = {
    {88, "S", Color(230, 60, 60)},
    {75, "A", Color(230, 180, 60)},
    {60, "B", Color(230, 230, 60)},
    {40, "C", Color(60, 230, 60)},
    {20, "D", Color(60, 60, 230)},
    { -math.huge, "F", Color(150, 150, 150)},
}
SWEP.StatGroups = {
    {
        Name = "rating.lethality",
        Description = "rating.lethality.desc",
        RatingFunction = function(self, base)
            -- local score = 0
            local valfunc = base and self.GetBaseValue or self.GetValue

            local bfm = self:GetBestFiremode(base)
            local rrpm = self:GetRPM(base, bfm)
            local pbd = valfunc(self, "PostBurstDelay")
            local ttt = TacRP.GetBalanceMode() == TacRP.BALANCE_TTT
            local pve = TacRP.GetBalanceMode() == TacRP.BALANCE_PVE
            local health = pve and 50 or 100

            local num = valfunc(self, "Num")
            local bdm = self:GetBodyDamageMultipliers(base)
            local bdm_add = 0
            for k, v in pairs(hitgroups) do
                bdm_add = bdm_add + bdm[k] * v
            end

            local d_max, d_min = valfunc(self, "Damage_Max"), valfunc(self, "Damage_Min")
            local dmg_max = math.max(d_max, d_min)
            local dmg_avg = Lerp(0.2, math.max(d_max, d_min), math.min(d_max, d_min)) * bdm_add

            -- max single shot damage
            local mssd = 0
            for k, v in pairs(ttt and mssd_scoring_ttt or mssd_scoring) do
                local stk = math.ceil(health / (dmg_max * (bdm[k] or 1) * (1 + (num - 1) * v[2])))
                mssd = mssd + (v[3][stk] or 0) * v[1]
                -- print(bdm[k], stk, (mssd_scoring[k][stk] or 0))
            end
            if pve then
                mssd = mssd ^ 1
            elseif ttt then
                mssd = mssd ^ 0.75
            end

            -- avg time to kill
            local stk = math.ceil(health / (dmg_avg * num))
            local ttk_s
            if stk == 1 then
                ttk_s = math.Clamp(rrpm / 120, 0, 1) ^ 0.75
            else
                local ttk = (stk - 1) * (60 / rrpm)
                if bfm < 0 then
                    ttk = ttk + math.floor(ttk / -bfm) * pbd
                end
                if pve then
                    ttk_s = math.Clamp(1 - ttk / 2, 0, 1) ^ 2
                elseif ttt then
                    ttk_s = math.Clamp(1 - ttk / 3, 0, 1) ^ 3
                else
                    ttk_s = math.Clamp(1 - ttk / 1.5, 0, 1) ^ 1.5
                end
            end

            local scores = {mssd, ttk_s}
            table.sort(scores)

            return scores[2] * 70 + scores[1] * 30

        end,
    },
    {
        Name = "rating.suppression",
        Description = "rating.suppression.desc",
        RatingFunction = function(self, base)
            local valfunc = base and self.GetBaseValue or self.GetValue

            local bfm = self:GetBestFiremode(base)
            local rrpm = self:GetRPM(base, bfm)
            local erpm = rrpm
            local pbd = valfunc(self, "PostBurstDelay")
            local ttt = TacRP.GetBalanceMode() == TacRP.BALANCE_TTT
            local pve = TacRP.GetBalanceMode() == TacRP.BALANCE_PVE

            if bfm == 1 then
                erpm = math.min(rrpm, 600) + math.max(rrpm - 600, 0) ^ 0.75 -- you can't click *that* fast
            elseif bfm < 0 then
                erpm = 60 / ((1 / (rrpm / 60)) + (pbd / -bfm))
            end

            local num = valfunc(self, "Num")
            local bdm = self:GetBodyDamageMultipliers(base)
            local bdm_add = 0
            for k, v in pairs(hitgroups) do
                bdm_add = bdm_add + bdm[k] * v
            end

            local d_max, d_min = valfunc(self, "Damage_Max"), valfunc(self, "Damage_Min")
            -- local dmg_max = math.max(d_max, d_min)
            local dmg_avg = Lerp(0.2, math.max(d_max, d_min), math.min(d_max, d_min)) * bdm_add

            -- raw dps
            local dps = dmg_avg * num * erpm / 60
            -- average dps over time
            local dot = dmg_avg * num / (60 / erpm + self:GetReloadTime(base) / (valfunc(self, "ClipSize") / valfunc(self, "AmmoPerShot")))
            local dps_s, dot_s
            if pve then
                dps_s = math.Clamp((dps - 12.5) / 150, 0, 1)
                dot_s = math.Clamp((dot - 5) / 100, 0, 1) ^ 0.9
            elseif ttt then
                dps_s = math.Clamp((dps - 25) / 200, 0, 1)
                dot_s = math.Clamp((dot - 10) / 100, 0, 1)
            else
                dps_s = math.Clamp((dps - 50) / 400, 0, 1) ^ 0.9
                dot_s = math.Clamp((dot - 20) / 200, 0, 1) ^ 0.9
            end

            local scores = {dps_s, dot_s}
            table.sort(scores)

            return scores[2] * 70 + scores[1] * 30
        end,
    },
    {
        Name = "rating.range",
        Description = "rating.range.desc",
        RatingFunction = function(self, base)
            local score = 0
            local valfunc = base and self.GetBaseValue or self.GetValue

            local d_max, d_min = valfunc(self, "Damage_Max"), valfunc(self, "Damage_Min")
            local r_min, r_max = self:GetMinMaxRange(base)
            local ttt = TacRP.GetBalanceMode() == TacRP.BALANCE_TTT

            local r_mid = r_min + (r_max - r_min) / 2
            local d_diff = math.abs(d_max - d_min) / math.max(d_max, d_min)
            if d_max > d_min then
                -- [60] 50% damage falloff range
                score = score + math.Clamp((r_mid - (ttt and 250 or 500)) / (ttt and 1500 or 3000), 0, 1) * 60

                -- [40] damage reduction from range
                score = score + math.Clamp(1 - d_diff, 0, 1) ^ 0.8 * 40
            else
                -- [40] free points
                -- [40] 50% damage rampup range
                score = score + 40 + math.Clamp(r_mid / (ttt and 1500 or 3000), 0, 1) * 40
                -- print(r_mid, math.Clamp(1 - r_mid / 5000, 0, 1))

                -- [20] damage reduction from range
                score = score + math.Clamp(1 - d_diff, 0, 1) * 20
            end

            return score
        end,
    },
    {
        Name = "rating.precision",
        Description = "rating.precision.desc",
        RatingFunction = function(self, base)
            local score = 0
            local valfunc = base and self.GetBaseValue or self.GetValue

            local bfm = self:GetBestFiremode(base)
            local rpm = valfunc(self, "RPM")

            local num = valfunc(self, "Num")
            local spread = valfunc(self, "Spread")
            local rps = valfunc(self, "RecoilPerShot")
            local rsp = valfunc(self, "RecoilSpreadPenalty")
            local rrt = self:GetRecoilResetTime(base)
            local rdr = valfunc(self, "RecoilDissipationRate")
            local dt = math.max(0, -rrt)
            local rbs = dt * rdr -- amount of recoil we can recover between shots even if fired ASAP

            if TacRP.ConVars["altrecoil"]:GetBool() then
                local min = 0.0001
                local tgt = 0.015
                if num > 2 then tgt = 0.04 end
                score = math.Clamp(1 - (spread - min) / tgt, 0, 1) * 100
            else
                -- [50] base spread
                local min = 0.001
                local tgt = 0.015
                if num > 2 then tgt = 0.04 end
                score = score + math.Clamp(1 - (spread - min) / tgt, 0, 1) * 50

                local fss = valfunc(self, "RecoilFirstShotMult") * rps
                -- score = score + math.Clamp(1 - (spread + fss * rsp - rbs) / tgt, 0, 1) * 25

                -- [50] spread over 0.3s (or one burst)
                local shots = math.min(math.ceil(rpm / 60 * 0.3), math.floor(self:GetBaseValue("ClipSize") * 0.5))
                if bfm < 0 then
                    shots = -bfm
                end
                if rbs <= fss then
                    local so1 = (fss - rbs + shots * (rps - rbs)) * rsp
                    score = score + math.Clamp(1 - so1 / 0.03, 0, 1) ^ 1.25 * 50
                else
                    -- delay is so long we always get first shot
                    score = score + 50
                end
            end

            -- recoil reset time
            -- score = score + math.Clamp(1 - math.max(0, rrt - delay) / 0.25, 0, 1) * 10

            return score
        end,
    },
    {
        Name = "rating.control",
        Description = "rating.control.desc",
        RatingFunction = function(self, base)
            local score = 0
            local valfunc = base and self.GetBaseValue or self.GetValue

            local bfm = self:GetBestFiremode(base)
            local erpm = valfunc(self, "RPM")
            local pbd = valfunc(self, "AutoBurst") and valfunc(self, "PostBurstDelay") or math.max(0.15, valfunc(self, "PostBurstDelay"))
            if bfm == 1 then
                erpm = math.min(erpm, 600) -- you can't click *that* fast
            elseif bfm < 0 then
                erpm = 60 / ((1 / (erpm / 60)) + (pbd / -bfm))
            end
            local rps = valfunc(self, "RecoilPerShot")
            local rsp = valfunc(self, "RecoilSpreadPenalty")
            local rrt = self:GetRecoilResetTime(base)
            local rdr = valfunc(self, "RecoilDissipationRate")
            local dt = math.max(0, -rrt)
            local rbs = dt * rdr -- amount of recoil we can recover between shots even if fired ASAP
            local fss = valfunc(self, "RecoilFirstShotMult")
            local rmax = valfunc(self, "RecoilMaximum")
            local rk = math.abs(valfunc(self, "RecoilKick"))

            -- local rrec_s = math.Clamp(rdr / rps / rmax / 5, 0, 1) ^ 0.9
            -- local mspr_s = math.Clamp(1 - rmax * rsp / 0.04, 0, 1)
            -- score = score + mspr_s * 20

            -- [50] recoil kick over 1s
            local score_rk1 = 50
            local shots = math.ceil(erpm / 60 * 1)
            score = score + math.Clamp(1 - (rk * shots * rrt - 3) / 12, 0, 1) * score_rk1
            -- print("rk1", rk * shots * rrt, math.Clamp(1 - rk * shots * rrt / 15, 0, 1) * score_rk1)

            -- [50] bloom over 1s
            local score_sg = 50
            if bfm < 0 then
                local rbb = math.max(0, pbd - rrt) * rdr -- recovery between bursts
                local rpb = -bfm * rps - (-bfm - 1) * rbs - rbb -- recoil per full burst
                score = score + math.Clamp(1 - (rpb * rsp * 2) / 0.03, 0, 1) ^ 1.5 * score_sg
                -- print("spb", rpb * rsp, math.Clamp(1 - (rpb * rsp * 3) / 0.04, 0, 1) ^ 2 * score_sg)
            else
                -- local sg = math.min(shots, math.ceil(rmax / rsp))
                local sot = math.min(rmax, fss - rbs + (shots - 1) * (rps - rbs)) * rsp
                -- print("sot", sot, math.Clamp(1 - (sot - 0.01) / 0.03, 0, 1) ^ 0.75 * score_sg)
                score = score + math.Clamp(1 - (sot - 0.01) / 0.02, 0, 1) ^ 1.5 * score_sg
            end

            return score
        end,
    },
    {
        Name = "rating.handling",
        Description = "rating.handling.desc",
        RatingFunction = function(self, base)
            local score = 0

            -- [40] sprint
            score = score + math.Clamp(1 - (self:GetSprintToFireTime(base) - 0.15) / 0.5, 0, 1) * 40

            -- [45] ads
            score = score + math.Clamp(1 - (self:GetAimDownSightsTime(base) - 0.15) / 0.5, 0, 1) * 45

            -- [15] deploy
            score = score + math.Clamp(1 - (self:GetDeployTime(base) - 0.5) / 1.5, 0, 1) * 15

            return score
        end,
    },
    {
        Name = "rating.maneuvering",
        Description = "rating.maneuvering.desc",
        RatingFunction = function(self, base)
            local score = 0
            local valfunc = base and self.GetBaseValue or self.GetValue

            -- [50] free aim + sway (if both are disabled, score goes to other 2)
            local bonus = 50
            local freeaim_s = 1
            if TacRP.ConVars["freeaim"]:GetBool() then
                if valfunc(self, "FreeAim") then
                    freeaim_s = math.Clamp(1 - (valfunc(self, "FreeAimMaxAngle") - 2) / 8, 0, 1) ^ 0.8
                end
                bonus = 0
            end
            local sway_s = 1
            if TacRP.ConVars["sway"]:GetBool() then
                sway_s = math.Clamp(1 - (valfunc(self, "Sway") - 0.75) / 2.25, 0, 1)
                bonus = 0
            end
            if bonus == 0 then
                score = score + math.min(freeaim_s, sway_s) * 30 + math.max(freeaim_s, sway_s) * 20
            end

            -- local diff = valfunc(self, "HipFireSpreadPenalty") / math.Clamp(self:GetBaseValue("Spread"), 0.015, 0.03)
            local hipspread = valfunc(self, "Spread") + valfunc(self, "HipFireSpreadPenalty")

            -- [0] peeking
            -- score = score + math.Clamp(1 - (hipspread * valfunc(self, "PeekPenaltyFraction") - 0.01) / 0.015, 0, 1) * (10 + bonus * 0.25)

            -- [40] hip spread + spread
            score = score + math.Clamp(1 - (hipspread - 0.015) / 0.05, 0, 1) * (40 + bonus * 0.75)

            -- [10] mid-air spread
            score = score + math.Clamp(1 - (valfunc(self, "MidAirSpreadPenalty") ) / 0.1, 0, 1) * (10 + bonus * 0.25)

            return score
        end,
    },
    {
        Name = "rating.mobility",
        Description = "rating.mobility.desc",
        RatingFunction = function(self, base)
            local score = 0
            local valfunc = base and self.GetBaseValue or self.GetValue
            local ttt = TacRP.GetBalanceMode() == TacRP.BALANCE_TTT

            if ttt then
                -- [30] move
                score = score + math.Clamp((valfunc(self, "MoveSpeedMult") - 0.6) / 0.4, 0, 1) * 30

                -- [25] sighted
                score = score + math.Clamp((valfunc(self, "SightedSpeedMult") - 0.2) / 0.8, 0, 1) * 25

                -- [25] shooting
                score = score + math.Clamp((valfunc(self, "ShootingSpeedMult") - 0.2) / 0.8, 0, 1) * 25

                -- [20] reload
                score = score + math.Clamp((valfunc(self, "ReloadSpeedMult") - 0.4) / 0.6, 0, 1) * 20
            else
                -- [50] move
                score = score + math.Clamp((math.min(1, valfunc(self, "MoveSpeedMult")) - 0.6) / 0.4, 0, 1) ^ 2 * 50

                -- [25] sighted
                score = score + math.Clamp((math.min(1, valfunc(self, "SightedSpeedMult")) - 0.3) / 0.7, 0, 1) * 25

                -- [25] shooting
                score = score + math.Clamp((math.min(1, valfunc(self, "ShootingSpeedMult")) - 0.4) / 0.6, 0, 1) * 25

                -- [-20] reload
                score = score - math.Clamp(1 - (math.min(1, valfunc(self, "ReloadSpeedMult")) - 0.4) / 0.6, 0, 1) * 20
            end


            return score
        end,
    },
    {
        Name = "rating.stability",
        Description = "rating.stability.desc",
        RatingFunction = function(self, base)
            local score = 0
            local valfunc = base and self.GetBaseValue or self.GetValue

            -- [40] sway
            score = score + math.Clamp(1 - valfunc(self, "Sway") / 2.5, 0, 1) ^ 0.8 * 40

            -- [60] sighted sway
            score = score + math.Clamp(1 - valfunc(self, "ScopedSway") / 1, 0, 1) ^ 1.5 * 60

            -- blindfire sway
            -- score = score + math.Clamp(1 - valfunc(self, "BlindFireSway") / 2, 0, 1) * 10

            return score
        end,
    },
}

SWEP.StatDisplay = {
    -- {
    --     Name = "",
    --     Value = "",
    --     LowerIsBetter = false,
    --     AggregateFunction = nil,
    --     Unit = ""
    -- }
    {
        Name = "spacer.damage",
        Description = "spacer.damage.desc",
        Spacer = true,
    },
    {
        Name = "stat.damage",
        Description = "stat.damage.desc",
        Value = "Damage_Max",
        AggregateFunction = function(self, base, val)
            if !(self:IsDamageConstant(false) and self:IsDamageConstant(true)) then return end
            -- local valfunc = base and self.GetBaseValue or self.GetValue
            -- return math.Round(val * valfunc(self, "Num"), 0)
            return math.floor(val)
        end,
    },
    {
        Name = "stat.damage_max",
        Description = "stat.damage_max.desc",
        Value = "Damage_Max",
        AggregateFunction = function(self, base, val)
            if self:IsDamageConstant(false) and self:IsDamageConstant(true) then return end
            -- local valfunc = base and self.GetBaseValue or self.GetValue
            -- return math.Round(val * valfunc(self, "Num"), 0)
            return math.floor(val)
        end,
    },
    {
        Name = "stat.damage_min",
        Description = "stat.damage_min.desc",
        Value = "Damage_Min",
        AggregateFunction = function(self, base, val)
            if self:IsDamageConstant(false) and self:IsDamageConstant(true) then return end
            -- local valfunc = base and self.GetBaseValue or self.GetValue
            -- return math.Round(val * valfunc(self, "Num"), 0)
            return math.floor(val)
        end,
    },
    {
        Name = "stat.explosivedamage",
        Description = "stat.explosivedamage.desc",
        Value = "ExplosiveDamage",
        DefaultValue = 0,
    },
    {
        Name = "stat.explosiveradius",
        Description = "stat.explosiveradius.desc",
        Value = "ExplosiveRadius",
        DefaultValue = 0,
        DisplayFunction = function(self, base, val)
            return self:RangeUnitize(val)
        end,
    },
    {
        Name = "stat.num",
        Description = "stat.num.desc",
        Value = "Num",
        DefaultValue = 1,
    },
    {
        Name = "stat.range_min",
        Description = "stat.range_min.desc",
        Value = "Range_Min",
        AggregateFunction = function(self, base, val)
            if self:IsDamageConstant(base) then return end
            return val
        end,
        DisplayFunction = function(self, base, val)
            if val == 0 then return "∞" end
            return self:RangeUnitize(val)
        end,
    },
    {
        Name = "stat.range_max",
        Description = "stat.range_max.desc",
        Value = "Range_Max",
        AggregateFunction = function(self, base, val)
            if self:IsDamageConstant(base) then return end
            return val
        end,
        DisplayFunction = function(self, base, val)
            if val == 0 then return "∞" end
            return self:RangeUnitize(val)
        end,
    },
    {
        Name = "stat.raw_dps",
        Description = "stat.raw_dps.desc",
        Value = "",
        AggregateFunction = function(self, base, val)
            local valfunc = base and self.GetBaseValue or self.GetValue

            local bfm = self:GetBestFiremode(base)
            local rrpm = self:GetRPM(base, bfm)
            local erpm = rrpm
            local pbd = valfunc(self, "PostBurstDelay")

            if bfm < 0 then
                erpm = 60 / ((1 / (rrpm / 60)) + (pbd / -bfm))
            end

            local num = valfunc(self, "Num")
            -- local hi, lo = valfunc(self, "Damage_Max"), valfunc(self, "Damage_Min")
            -- if lo > hi then
            --     hi, lo = valfunc(self, "Damage_Min"), valfunc(self, "Damage_Max")
            -- end
            -- local dmg = Lerp(0.25, hi, lo)
            local dmg = math.max(valfunc(self, "Damage_Max"), valfunc(self, "Damage_Min"))
            return math.Round(dmg * num * erpm / 60, 1)
        end,
    },
    {
        Name = "stat.min_ttk",
        Description = "stat.min_ttk.desc",
        Value = "",
        Unit = "unit.second",
        LowerIsBetter = true,
        AggregateFunction = function(self, base, val)
            local valfunc = base and self.GetBaseValue or self.GetValue

            local bfm = self:GetBestFiremode(base)
            local rpm = self:GetRPM(base, bfm)

            local num = valfunc(self, "Num")
            local dmg = math.max(valfunc(self, "Damage_Max"), valfunc(self, "Damage_Min"))
            local stk = math.ceil(100 / (dmg * num))
            local ttk = stk * (60 / rpm)

            if bfm < 0 and stk > -bfm then
                local pbd = valfunc(self, "PostBurstDelay")
                ttk = ttk + pbd * math.floor(stk / -bfm)
            end
            return math.Round(ttk, 2)
        end,
    },
    {
        Name = "spacer.action",
        Description = "spacer.action.desc",
        Spacer = true,
    },
    {
        Name = "stat.clipsize",
        Description = "stat.clipsize.desc",
        Value = "ClipSize",
    },
    {
        Name = "stat.ammopershot",
        Description = "stat.ammopershot.desc",
        Value = "AmmoPerShot",
        DefaultValue = 1,
    },
    {
        Name = "stat.rpm",
        Description = "stat.rpm.desc",
        Value = "RPM",
        AggregateFunction = function(self, base, val)
            return math.Round(val, 0)
        end,
    },
    {
        Name = "stat.rpm_burst",
        Description = "stat.rpm_burst.desc",
        Value = "RPMMultBurst",
        AggregateFunction = function(self, base, val)
            if !self:HasFiremode(-1) then return end
            local valfunc = base and self.GetBaseValue or self.GetValue
            return math.Round(val * valfunc(self, "RPM"), 0)
        end,
        DefaultValue = 1,
    },
    {
        Name = "stat.rpm_burst_peak",
        Description = "stat.rpm_burst_peak.desc",
        Value = "PostBurstDelay",
        AggregateFunction = function(self, base, val)
            if !self:HasFiremode(-1) then return end
            local valfunc = base and self.GetBaseValue or self.GetValue
            local cfm = -self:GetCurrentFiremode()
            local delay = 60 / ( valfunc(self, "RPM") * valfunc(self, "RPMMultBurst") ) -- delay
            local nerd = 0
            nerd = nerd + (delay * (cfm-1))
            nerd = nerd + math.max( delay, valfunc(self, "PostBurstDelay") )
            nerd = nerd / cfm
            nerd = 60 / nerd
            return math.Round( nerd )
        end,
        --DefaultValue = 0,
    },
    {
        Name = "stat.rpm_semi",
        Description = "stat.rpm_semi.desc",
        Value = "RPMMultSemi",
        AggregateFunction = function(self, base, val)
            if !self:HasFiremode(1) then return end
            local valfunc = base and self.GetBaseValue or self.GetValue
            return math.Round(val * valfunc(self, "RPM"), 0)
        end,
        DefaultValue = 1,
    },
    {
        Name = "stat.shotstofail",
        Description = "stat.shotstofail.desc",
        AggregateFunction = function(self, base, val)
            return math.Round(1 / self:GetJamChance(base), 0)
        end,
        DisplayFunction = function(self, base, val)
            if val == 0 then return "∞" end
            return math.Round(1 / self:GetJamChance(base), 0)
        end,
        DefaultValue = 0,
        Value = "JamFactor",
    },
    {
        Name = "stat.postburstdelay",
        Description = "stat.postburstdelay.desc",
        Value = "PostBurstDelay",
        AggregateFunction = function(self, base, val)
            if !self:HasFiremode(-1) then return end
            return math.Round(val, 2)
        end,
        Unit = "unit.second",
        LowerIsBetter = true,
        DefaultValue = 0,
    },
    {
        Name = "stat.firemode",
        Description = "stat.firemode.desc",
        AggregateFunction = function(self, base, val)
            if !val then
                val = {base and self:GetTable()["Firemode"] or self:GetValue("Firemode")}
            end
            if #val == 1 then
                if val[1] == 2 then
                    return "Auto"
                elseif val[1] == 1 then
                    return "Semi"
                elseif val[1] < 0 then
                    return (-val[1]) .. "-Burst"
                end
            else
                local tbl = table.Copy(val)
                table.sort(tbl, function(a, b)
                    if a == 2 then
                        return b == 2
                    elseif b == 2 then
                        return a != 2
                    end
                    return math.abs(a) <= math.abs(b)
                end)
                local str = "S-"
                for i = 1, #tbl do
                    str = str .. (tbl[i] == 2 and "F" or math.abs(tbl[i])) .. (i < #tbl and "-" or "")
                end
                return str
            end
            return table.ToString(val)
        end,
        BetterFunction = function(self, old, new)
            if !old then
                old = {self:GetBaseValue("Firemode")}
            end
            if !new then
                new = {self:GetValue("Firemode")}
            end
            local oldbest, newbest = 0, 0
            for i = 1, #old do
                local v = math.abs(old[i])
                if math.abs(old[i]) > oldbest or old[i] == 2 then
                    oldbest = (old[i] == 2 and math.huge) or v
                end
            end
            for i = 1, #new do
                local v = math.abs(new[i])
                if v > newbest or new[i] == 2 then
                    newbest = (new[i] == 2 and math.huge) or v
                end
            end
            if oldbest == newbest then
                return #old != #new , #old < #new
            else
                return true, oldbest < newbest
            end
        end,
        DifferenceFunction = function(self, orig, value)
            if !orig then
                orig = {self:GetBaseValue("Firemode")}
            end
            if !value then
                value = {self:GetValue("Firemode")}
            end
            local old_best = self:GetBestFiremode(true)
            local new_best = self:GetBestFiremode(false)
            if old_best == new_best then return end
            if new_best == 2 then
                return "+Auto"
            elseif old_best == 2 then
                return "-Auto"
            elseif new_best < 0 then
                return "+Burst"
            end
        end,
        Value = "Firemodes",
        -- HideIfSame = true,
    },
    {
        Name = "stat.reloadtime",
        Description = "stat.reloadtime.desc",
        AggregateFunction = function(self, base, val)
            return math.Round(self:GetReloadTime(base), 2)
        end,
        Value = "ReloadTimeMult",
        LowerIsBetter = true,
        Unit = "unit.second",
    },
    {
        Name = "spacer.ballistics",
        Description = "spacer.ballistics.desc",
        Spacer = true,
    },
    {
        Name = "stat.spread",
        Description = "stat.spread.desc",
        AggregateFunction = function(self, base, val)
            return math.Round(math.deg(val) * 60, 2)
        end,
        Unit = "′",
        Value = "Spread",
        LowerIsBetter = true,
    },
    {
        Name = "stat.muzzlevelocity",
        Description = "stat.muzzlevelocity.desc",
        AggregateFunction = function(self, base, val)
            return math.Round(self:GetMuzzleVelocity(base), 2)
        end,
        ConVarCheck = "tacrp_physbullet",
        Value = "MuzzleVelocity",
        LowerIsBetter = false,
        Unit = "unit.mps",
    },
    {
        Name = "stat.penetration",
        Description = "stat.penetration.desc",
        Value = "Penetration",
        Unit = "\""
    },
    {
        Name = "stat.armorpenetration",
        Description = "stat.armorpenetration.desc",
        Value = "ArmorPenetration",
        AggregateFunction = function(self, base, val)
            return math.max(math.Round(val * 100, 1), 0)
        end,
        Unit = "%",
    },
    {
        Name = "stat.armorbonus",
        Description = "stat.armorbonus.desc",
        Value = "ArmorBonus",
        AggregateFunction = function(self, base, val)
            return math.Round(val * 1, 2)
        end,
        Unit = "x",
    },
    {
        Name = "spacer.recoilbloom",
        Description = "spacer.recoilbloom.desc",
        Spacer = true,
    },
    {
        Name = "stat.recoilkick",
        Description = "stat.recoilkick.desc",
        Value = "RecoilKick",
        LowerIsBetter = true,
    },
    {
        Name = "stat.recoilstability",
        Description = "stat.recoilstability.desc",
        Value = "RecoilStability",
        AggregateFunction = function(self, base, val)
            return math.Clamp(math.Round(val * 100), 0, 90)
        end,
        Unit = "%",
        LowerIsBetter = false,
    },
    -- For use when bloom is modifying spread. (default)
    {
        Name = "stat.recoilspread",
        Description = "stat.recoilspread.desc",
        AggregateFunction = function(self, base, val)
            return math.Round(math.deg(val) * 60, 1)
        end,
        Unit = "′",
        Value = "RecoilSpreadPenalty",
        LowerIsBetter = true,
        ConVarCheck = "tacrp_altrecoil",
        ConVarInvert = true,
    },
    -- For use when in "Bloom Modifies Recoil"
    {
        Name = "stat.recoilspread2",
        Description = "stat.recoilspread2.desc",
        AggregateFunction = function(self, base, val)
            return math.Round(val * (base and self:GetBaseValue("RecoilAltMultiplier") or self:GetValue("RecoilAltMultiplier")), 2)
        end,
        Unit = nil,
        Value = "RecoilSpreadPenalty",
        LowerIsBetter = true,
        ConVarCheck = "tacrp_altrecoil",
        ConVarInvert = false,
    },
    {
        Name = "stat.recoildissipation",
        Description = "stat.recoildissipation.desc",
        AggregateFunction = function(self, base, val)
            return math.Round(val, 2)
            --return math.Round(math.deg(val * (base and self:GetTable().RecoilSpreadPenalty or self:GetValue("RecoilSpreadPenalty"))), 1)
        end,
        Unit = "unit.persecond",
        Value = "RecoilDissipationRate",
    },
    {
        Name = "stat.recoilresettime",
        Description = "stat.recoilresettime.desc",
        Value = "RecoilResetTime",
        LowerIsBetter = true,
        Unit = "s",
    },
    {
        Name = "stat.recoilmaximum",
        Description = "stat.recoilmaximum.desc",
        Value = "RecoilMaximum",
        LowerIsBetter = true,
    },
    {
        Name = "stat.recoilfirstshot",
        Description = "stat.recoilfirstshot.desc",
        Value = "RecoilFirstShotMult",
        AggregateFunction = function(self, base, val)
            return math.Round(val * (base and self:GetBaseValue("RecoilPerShot") or self:GetValue("RecoilPerShot")), 2)
        end,
        DefaultValue = 1,
        LowerIsBetter = true,
    },
    {
        Name = "stat.recoilpershot",
        Description = "stat.recoilpershot.desc",
        AggregateFunction = function(self, base, val)
            return math.Round(val, 2)
        end,
        Unit = "x",
        Value = "RecoilPerShot",
        HideIfSame = true,
        LowerIsBetter = true,
    },
    {
        Name = "stat.recoilcrouch",
        Description = "stat.recoilcrouch.desc",
        AggregateFunction = function(self, base, val)
            return math.min(100, math.Round(val * 100, 0))
        end,
        Unit = "%",
        Value = "RecoilCrouchMult",
        LowerIsBetter = true,
        -- HideIfSame = true,
    },
    {
        Name = "spacer.mobility",
        Description = "spacer.mobility.desc",
        Spacer = true,
    },
    {
        Name = "stat.movespeed",
        Description = "stat.movespeed.desc",
        AggregateFunction = function(self, base, val)
            return math.min(100, math.Round(val * 100, 0))
        end,
        Unit = "%",
        Value = "MoveSpeedMult",
    },
    {
        Name = "stat.shootingspeed",
        Description = "stat.shootingspeed.desc",
        AggregateFunction = function(self, base, val)
            return math.min(100, math.Round(val * 100, 0))
        end,
        Unit = "%",
        Value = "ShootingSpeedMult",
    },
    {
        Name = "stat.sightedspeed",
        Description = "stat.sightedspeed.desc",
        AggregateFunction = function(self, base, val)
            return math.min(100, math.Round(val * 100, 0))
        end,
        Unit = "%",
        Value = "SightedSpeedMult",
        ValueCheck = "Scope",
    },
    {
        Name = "stat.reloadspeed",
        Description = "stat.reloadspeed.desc",
        AggregateFunction = function(self, base, val)
            return math.min(100, math.Round(val * 100, 0))
        end,
        Unit = "%",
        Value = "ReloadSpeedMult",
        DefaultValue = 1,
    },
    {
        Name = "stat.meleespeed",
        Description = "stat.meleespeed.desc",
        AggregateFunction = function(self, base, val)
            return math.min(100, math.Round(val * 100, 0))
        end,
        Unit = "%",
        Value = "MeleeSpeedMult",
        DefaultValue = 1,
    },
    {
        Name = "spacer.handling",
        Description = "spacer.handling.desc",
        Spacer = true,
    },
    {
        Name = "stat.sprinttofire",
        Description = "stat.sprinttofire.desc",
        Value = "SprintToFireTime",
        AggregateFunction = function(self, base, val)
            return math.Round(self:GetSprintToFireTime(base), 3)
        end,
        Unit = "unit.second",
        LowerIsBetter = true,
    },
    {
        Name = "stat.aimdownsights",
        Description = "stat.aimdownsights.desc",
        Value = "AimDownSightsTime",
        AggregateFunction = function(self, base, val)
            return math.Round(self:GetAimDownSightsTime(base), 3)
        end,
        Unit = "unit.second",
        LowerIsBetter = true,
        ValueCheck = "Scope",
    },
    {
        Name = "stat.deploytime",
        Description = "stat.deploytime.desc",
        AggregateFunction = function(self, base, val)
            return math.Round(self:GetDeployTime(base), 2)
        end,
        Value = "DeployTimeMult",
        LowerIsBetter = true,
        -- HideIfSame = true,
        Unit = "unit.second",
    },
    {
        Name = "stat.holstertime",
        Description = "stat.holstertime.desc",
        AggregateFunction = function(self, base, val)
            return math.Round(self:CalcHolsterTime(base), 2)
        end,
        Value = "HolsterTimeMult",
        LowerIsBetter = true,
        Unit = "unit.second",
        ConVarCheck = "tacrp_holster",
    },
    {
        Name = "spacer.maneuvering",
        Description = "spacer.maneuvering.desc",
        Spacer = true,
    },
    {
        Name = "stat.freeaimangle",
        Description = "stat.freeaimangle.desc",
        Unit = "°",
        Value = "FreeAimMaxAngle",
        AggregateFunction = function(self, base, val)
            return math.max(0, math.Round(val, 1))
        end,
        LowerIsBetter = true,
        -- HideIfSame = true,
        ConVarCheck = "tacrp_freeaim",
    },
    {
        Name = "stat.midairspread",
        Description = "stat.midairspread.desc",
        AggregateFunction = function(self, base, val)
            return math.Round(math.deg(val), 1)
        end,
        Unit = "°",
        Value = "MidAirSpreadPenalty",
        LowerIsBetter = true,
        -- HideIfSame = true,
    },
    {
        Name = "stat.hipfirespread",
        Description = "stat.hipfirespread.desc",
        AggregateFunction = function(self, base, val)
            return math.Round(math.deg(val), 1)
        end,
        Unit = "°",
        Value = "HipFireSpreadPenalty",
        LowerIsBetter = true,
        -- HideIfSame = true,
    },
    {
        Name = "spacer.sway",
        Description = "spacer.sway.desc",
        Spacer = true,
    },
    {
        Name = "stat.sway",
        Description = "stat.sway.desc",

        Value = "Sway",
        LowerIsBetter = true,
        ConVarCheck = "tacrp_sway",
    },
    {
        Name = "stat.scopedsway",
        Description = "stat.scopedsway.desc",
        Value = "ScopedSway",
        LowerIsBetter = true,
        ConVarCheck = "tacrp_sway",
        ValueCheck = "Scope",
    },
    {
        Name = "stat.swaycrouch",
        Description = "stat.swaycrouch.desc",
        Value = "SwayCrouchMult",
        AggregateFunction = function(self, base, val)
            return math.min(100, math.Round(val * 100, 0))
        end,
        Unit = "%",
        LowerIsBetter = true,
        -- HideIfSame = true,
        ConVarCheck = "tacrp_sway",
    },
    {
        Name = "spacer.misc",
        Description = "spacer.misc.desc",
        Spacer = true,
    },
    {
        Name = "stat.meleedamage",
        Description = "stat.meleedamage.desc",
        Value = "MeleeDamage",
        HideIfSame = false,
    },
    {
        Name = "stat.peekpenalty",
        Description = "stat.peekpenalty.desc",
        Value = "PeekPenaltyFraction",
        AggregateFunction = function(self, base, val)
            return math.min(100, math.Round(val * 100, 0))
        end,
        Unit = "%",
        LowerIsBetter = true,
    },
    {
        Name = "stat.quickscope",
        Description = "stat.quickscope.desc",
        Value = "QuickScopeSpreadPenalty",
        AggregateFunction = function(self, base, val)
            return math.Round(math.deg(val) * 60, 1)
        end,
        Unit = "′",
        LowerIsBetter = true,
    },
}

SWEP.StatGroupsMelee = {
    {
        Name = "stat.damage",
        Description = "stat.damage.desc_melee",
        RatingFunction = function(self, base)
            local valfunc = base and self.GetBaseValue or self.GetValue

            return Lerp((valfunc(self, "MeleeDamage") - 10) / 50, 0, 100)
        end,
    },
    {
        Name = "rating.meleeattacktime",
        Description = "rating.meleeattacktime.desc",
        RatingFunction = function(self, base)
            local valfunc = base and self.GetBaseValue or self.GetValue

            return Lerp(1 - (valfunc(self, "MeleeAttackTime") - 0.15) / 0.55, 0, 100)
        end,
    },
    -- {
    --     Name = "Reach",
    --     Description = "Attack distance.",
    --     RatingFunction = function(self, base)
    --         local valfunc = base and self.GetBaseValue or self.GetValue

    --         return Lerp((valfunc(self, "MeleeRange") - 64) / 128, 0, 100)
    --     end,
    -- },
    {
        Name = "stat.meleeperkstr",
        Description = "stat.meleeperkstr.desc",
        RatingFunction = function(self, base)
            local valfunc = base and self.GetBaseValue or self.GetValue
            return Lerp(valfunc(self, "MeleePerkStr"), 0, 100)

        end,
    },
    {
        Name = "stat.meleeperkagi",
        Description = "stat.meleeperkagi.desc",
        RatingFunction = function(self, base)
            local valfunc = base and self.GetBaseValue or self.GetValue
            return Lerp(valfunc(self, "MeleePerkAgi"), 0, 100)
        end,
    },
    {
        Name = "stat.meleeperkint",
        Description = "stat.meleeperkint.desc",
        RatingFunction = function(self, base)
            local valfunc = base and self.GetBaseValue or self.GetValue
            return Lerp(valfunc(self, "MeleePerkInt"), 0, 100)
        end,
    },
}
-- self:GetHeavyAttackDamage()

SWEP.StatDisplayMelee = {
    {
        Name = "stat.damage",
        Description = "stat.damage.desc_melee",
        Value = "MeleeDamage",
        AggregateFunction = function(self, base, val)
            return math.floor(val)
        end,
    },
    {
        Name = "stat.meleeattacktime",
        Description = "stat.meleeattacktime.desc",
        Value = "MeleeAttackTime",
        Unit = "unit.second",
        LowerIsBetter = true,
    },
    {
        Name = "stat.meleeattackmisstime",
        Description = "stat.meleeattackmisstime.desc",
        Value = "MeleeAttackMissTime",
        Unit = "unit.second",
        LowerIsBetter = true,
    },
    {
        Name = "stat.meleerange",
        Description = "stat.meleerange.desc",
        Value = "MeleeRange",
        DisplayFunction = function(self, base, val)
            return self:RangeUnitize(val)
        end,
    },
    {
        Name = "stat.meleedelay",
        Description = "stat.meleedelay.desc",
        Value = "MeleeDelay",
        Unit = "unit.second",
        LowerIsBetter = true,
    },
    {
        Name = "stat.meleeperkstr",
        Description = "stat.meleeperkstr.desc",
        Value = "MeleePerkStr",
        AggregateFunction = function(self, base, val)
            return math.floor(val * 100)
        end,
    },
    {
        Name = "stat.meleeperkagi",
        Description = "stat.meleeperkagi.desc",
        Value = "MeleePerkAgi",
        AggregateFunction = function(self, base, val)
            return math.floor(val * 100)
        end,
    },
    {
        Name = "stat.meleeperkint",
        Description = "stat.meleeperkint.desc",
        Value = "MeleePerkInt",
        AggregateFunction = function(self, base, val)
            return math.floor(val * 100)
        end,
    },


    {
        Name = "stat.melee2damage",
        Description = "stat.melee2damage.desc",
        Value = "Melee2Damage",
        ValueCheck = "HeavyAttack",
        AggregateFunction = function(self, base, val)
            return math.Round(self:GetHeavyAttackDamage(base))
        end,
    },
    {
        Name = "stat.melee2attacktime",
        Description = "stat.melee2attacktime.desc",
        Value = "Melee2AttackTime",
        ValueCheck = "HeavyAttack",
        AggregateFunction = function(self, base, val)
            return math.Round(self:GetHeavyAttackTime(false, base), 2)
        end,
        Unit = "unit.second",
        LowerIsBetter = true,
    },
    {
        Name = "stat.melee2attackmisstime",
        Description = "stat.melee2attackmisstime.desc",
        Value = "Melee2AttackMissTime",
        ValueCheck = "HeavyAttack",
        AggregateFunction = function(self, base, val)
            return math.Round(self:GetHeavyAttackTime(true, base), 2)
        end,
        Unit = "unit.second",
        LowerIsBetter = true,
    },
    {
        Name = "stat.meleethrowdamage",
        Description = "stat.meleethrowdamage.desc",
        Value = "MeleeDamage",
        ValueCheck = "ThrowAttack",
        AggregateFunction = function(self, base, val)
            return math.floor(val * self:GetMeleePerkDamage(base))
        end,
    },
    {
        Name = "stat.meleethrowvelocity",
        Description = "stat.meleethrowvelocity.desc",
        Value = "MeleeThrowForce",
        ValueCheck = "ThrowAttack",
        AggregateFunction = function(self, base, val)
            return math.Round(0.3048 * self:GetMeleePerkVelocity(base) / 12, 1)
        end,
        Unit = "unit.mps",
    },
    {
        Name = "stat.meleethrowtime",
        Description = "stat.meleethrowtime.desc",
        Value = "MeleeAttackTime",
        ValueCheck = "ThrowAttack",
        AggregateFunction = function(self, base, val)
            return math.Round(val * 3 * self:GetMeleePerkCooldown(base), 2)
        end,
        Unit = "unit.second",
        LowerIsBetter = true,
    },

    {
        Name = "stat.lifesteal",
        Description = "stat.lifesteal.desc",
        Value = "Lifesteal",
        DefaultValue = 0,
        AggregateFunction = function(self, base, val)
            return math.Round(val * 100, 2)
        end,
        Unit = "%",
    },
    {
        Name = "stat.damagecharge",
        Description = "stat.damagecharge.desc",
        Value = "DamageCharge",
        DefaultValue = 0,
        AggregateFunction = function(self, base, val)
            return math.Round(val * 10000, 2)
        end,
        Unit = "%",
    },
}