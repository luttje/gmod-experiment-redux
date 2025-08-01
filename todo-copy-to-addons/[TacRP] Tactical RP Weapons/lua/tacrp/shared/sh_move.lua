function TacRP.Move(ply, mv, cmd)
    local wpn = ply:GetActiveWeapon()
    local iscurrent = true

    local origspeed = ply:GetMaxSpeed()
    local basespd = math.min((Vector(cmd:GetForwardMove(), cmd:GetUpMove(), cmd:GetSideMove())):Length(), mv:GetMaxClientSpeed())

    local totalmult = 1

    if ply:GetNWFloat("TacRPLastBashed", 0) + 3 > CurTime() then
        local slow = TacRP.ConVars["melee_slow"]:GetFloat()
        local mult = slow
        if ply:GetNWFloat("TacRPLastBashed", 0) + 1.5 < CurTime() then
            mult = Lerp((CurTime() - ply:GetNWFloat("TacRPLastBashed", 0) - 1.5) / (3 - 1.5), slow, 1)
        end

        -- local basespd = math.min((Vector(cmd:GetForwardMove(), cmd:GetUpMove(), cmd:GetSideMove())):Length(), mv:GetMaxClientSpeed())
        -- mv:SetMaxSpeed(basespd * mult)
        -- mv:SetMaxClientSpeed(basespd * mult)
        totalmult = totalmult * mult
    end

    local stunstart, stundur = ply:GetNWFloat("TacRPStunStart", 0), ply:GetNWFloat("TacRPStunDur", 0)
    if stunstart + stundur > CurTime() then
        local slow = TacRP.ConVars["flash_slow"]:GetFloat()
        local mult = slow
        if stunstart + stundur * 0.7 < CurTime() then
            mult = Lerp((CurTime() - stunstart - stundur * 0.7) / (stundur * 0.3), slow, 1)
        end

        -- local basespd = math.min((Vector(cmd:GetForwardMove(), cmd:GetUpMove(), cmd:GetSideMove())):Length(), mv:GetMaxClientSpeed())
        -- mv:SetMaxSpeed(basespd * mult)
        -- mv:SetMaxClientSpeed(basespd * mult)
        totalmult = totalmult * mult
    end

    if totalmult < 1 then
        mv:SetMaxSpeed(basespd * totalmult)
        mv:SetMaxClientSpeed(basespd * totalmult)
    end

    -- Remember last weapon to keep applying slowdown on shooting and melee
    if !wpn.ArcticTacRP then
        if !IsValid(ply.LastTacRPWeapon) or ply.LastTacRPWeapon:GetOwner() != ply then
            return
        else
            wpn = ply.LastTacRPWeapon
            iscurrent = false
        end
    else
        ply.LastTacRPWeapon = wpn
    end

    -- try not to apply slowdown on top of crouching or slowwalk speed
    -- basespd = math.min((Vector(cmd:GetForwardMove(), cmd:GetUpMove(), cmd:GetSideMove())):Length(), mv:GetMaxClientSpeed())
    basespd = math.min((Vector(cmd:GetForwardMove(), cmd:GetUpMove(), cmd:GetSideMove())):Length(), math.max(mv:GetMaxClientSpeed(), ply:GetWalkSpeed()))

    -- mult1: lowest between move speed and shooting speed
    local mult = 1
    if iscurrent and (!wpn:GetSafe() or wpn:GetIsSprinting()) and TacRP.ConVars["penalty_move"]:GetBool() then
        mult = mult * math.Clamp(wpn:GetValue("MoveSpeedMult"), 0.0001, 1)
    end

    if TacRP.ConVars["penalty_firing"]:GetBool() then
        local shotdelta = 0 -- how close should we be to the shoot speed mult
        local rpmd = wpn:GetValue("RPM") / 900
        local fulldur = Lerp(rpmd, 1, 0.25) -- time considered "during shot". cant be just primary fire since it hurts slow guns too much
        local delay = Lerp(rpmd, 0.25, 0.5)
        local shottime = wpn:GetNextPrimaryFire() - (60 / wpn:GetValue("RPM")) - CurTime() + fulldur

        -- slowdown based on recoil intensity (firing longer means heavier slowdown)
        if shottime > -delay then
            local aftershottime = math.Clamp(1 + shottime / delay, 0, 1)
            shotdelta = Lerp((wpn:GetRecoilAmount() / (wpn:GetValue("RecoilMaximum") * 0.75)) ^ 1.5, 0.25, 1) * aftershottime
        end
        local shootmove = math.Clamp(wpn:GetValue("ShootingSpeedMult"), 0.0001, 1)
        mult = math.min(mult, Lerp(shotdelta, 1, shootmove))
    end

    -- mult2: lowest between sighted, reloading, melee
    local mult2 = 1
    if iscurrent and wpn:GetScopeLevel() > 0 and TacRP.ConVars["penalty_aiming"]:GetBool() then
        mult2 = math.Clamp(wpn:GetValue("SightedSpeedMult"), 0.0001, 1)
    end

    if iscurrent and TacRP.ConVars["penalty_reload"]:GetBool() then
        local rsmt = wpn:GetValue("ReloadSpeedMultTime")

        if wpn:GetReloading() then
            -- mult = mult * math.Clamp(wpn:GetValue("ReloadSpeedMult"), 0.0001, 1)
            mult2 = math.min(mult2, math.Clamp(wpn:GetValue("ReloadSpeedMult"), 0.0001, 1))
        elseif wpn:GetReloadFinishTime() + rsmt > CurTime() then
            local mt = CurTime() - wpn:GetReloadFinishTime()
            local d = mt / rsmt

            d = math.Clamp(d, 0, 1)

            mult2 = math.min(mult2, Lerp(d, math.Clamp(wpn:GetValue("ReloadSpeedMult"), 0.0001, 1), 1))
            -- mult = mult * Lerp(d, math.Clamp(wpn:GetValue("ReloadSpeedMult"), 0.0001, 1), 1)
        end
    end

    if TacRP.ConVars["penalty_melee"]:GetBool() then
        local msmt = wpn:GetValue("MeleeSpeedMultTime")

        if wpn:GetLastMeleeTime() + msmt > CurTime() then
            local mt = CurTime() - wpn:GetLastMeleeTime()
            local d = mt / msmt

            d = math.Clamp(d, 0, 1)

            mult2 = math.min(mult2, Lerp(d, math.Clamp(wpn:GetValue("MeleeSpeedMult"), 0.0001, 1), 1))
            -- mult = mult * Lerp(d, math.Clamp(wpn:GetValue("MeleeSpeedMult"), 0.0001, 1), 1)
        end
    end

    local tgtspeed = basespd * mult * mult2

    -- print(tgtspeed, mv:GetMaxClientSpeed(), mv:GetMaxSpeed())

    if mult * mult2 < 1 and tgtspeed < mv:GetMaxSpeed() then
        mv:SetMaxSpeed(tgtspeed)
        mv:SetMaxClientSpeed(tgtspeed)
    end

    if !iscurrent then return end

    -- Semi auto click buffer
    if !wpn.NoBuffer and !wpn:GetCharge() and (wpn:GetCurrentFiremode() <= 1) and mv:KeyPressed(IN_ATTACK)
            and wpn:StillWaiting() and !wpn:GetReloading() and !wpn:GetCustomize() and wpn:Clip1() >= wpn:GetValue("AmmoPerShot")
            and wpn:GetNextSecondaryFire() < CurTime() and wpn:GetAnimLockTime() < CurTime() and (wpn:GetNextPrimaryFire() - CurTime()) < 0.15 then
        wpn:SetCharge(true)
    elseif !wpn.NoBuffer and wpn:GetCharge() and !wpn:StillWaiting() and !owner then
        wpn:SetCharge(false)
        wpn:PrimaryAttack()
    end
end

hook.Add("SetupMove", "ArcticTacRP.SetupMove", TacRP.Move)

TacRP.LastEyeAngles = Angle(0, 0, 0)
TacRP.RecoilRise = Angle(0, 0, 0)

function TacRP.StartCommand(ply, cmd)
    local wpn = ply:GetActiveWeapon()
    local mt_notair = ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetMoveType() == MOVETYPE_LADDER

    if !mt_notair then
        if ply:IsOnGround() and !ply.TacRP_LastOnGround then
            ply.TacRP_LastAirDuration = CurTime() - (ply.TacRP_LastLeaveGroundTime or 0)
            ply.TacRP_LastOnGroundTime = CurTime()
        elseif !ply:IsOnGround() and ply.TacRP_LastOnGround then
            ply.TacRP_LastLeaveGroundTime = CurTime()
        end
    end
    ply.TacRP_LastOnGround = ply:IsOnGround() or mt_notair

    if !wpn.ArcticTacRP then
        TacRP.RecoilRise = Angle(0, 0, 0)
        TacRP.LastEyeAngles = ply:EyeAngles()
        return
    end

    local diff = TacRP.LastEyeAngles - cmd:GetViewAngles()
    local recrise = TacRP.RecoilRise

    if recrise.p > 0 then
        recrise.p = math.Clamp(recrise.p, 0, recrise.p - diff.p)
    elseif recrise.p < 0 then
        recrise.p = math.Clamp(recrise.p, recrise.p - diff.p, 0)
    end

    if recrise.y > 0 then
        recrise.y = math.Clamp(recrise.y, 0, recrise.y - diff.y)
    elseif recrise.y < 0 then
        recrise.y = math.Clamp(recrise.y, recrise.y - diff.y, 0)
    end

    recrise:Normalize()
    TacRP.RecoilRise = recrise

    if wpn:GetLastRecoilTime() + wpn:RecoilDuration() > CurTime() then
        local kick = wpn:GetValue("RecoilKick")
        local recoildir = wpn:GetRecoilDirection()
        local rec = 1

        if TacRP.ConVars["altrecoil"]:GetBool() then
            rec = 1 + math.Clamp((wpn:GetRecoilAmount() - 1) / (wpn:GetValue("RecoilMaximum") - 1), 0, 1)
            kick = kick + wpn:GetValue("RecoilSpreadPenalty") * wpn:GetValue("RecoilAltMultiplier")
            -- local recgain = rec * wpn:GetValue("RecoilSpreadPenalty") * 250
            -- kick = kick + recgain
        end

        if wpn:GetInBipod() then
            kick = kick * math.min(1, wpn:GetValue("BipodKick"))
        end

        kick = kick * TacRP.ConVars["mult_recoil_kick"]:GetFloat()

        local eyeang = cmd:GetViewAngles()

        local suppressfactor = 1
        if wpn:UseRecoilPatterns() and wpn:GetCurrentFiremode() != 1 then
            local stab = math.Clamp(wpn:GetValue("RecoilStability"), 0, 0.9)
            local max = wpn:GetBaseValue("RPM") / 60 * (0.75 + stab * 0.833)
            suppressfactor = math.min(3, 1 + (wpn:GetPatternCount() / max))
        end

        local uprec = math.sin(math.rad(recoildir)) * FrameTime() * rec * kick / suppressfactor
        local siderec = math.cos(math.rad(recoildir)) * FrameTime() * rec * kick

        eyeang.p = eyeang.p + uprec
        eyeang.y = eyeang.y + siderec

        recrise = TacRP.RecoilRise

        if TacRP.ConVars["freeaim"]:GetBool() and wpn:GetValue("FreeAim") and wpn:GetScopeLevel() == 0 then
            local freeaimang = wpn:GetFreeAimAngle()
            siderec = siderec * 0.5
            freeaimang:Add(Angle(0, siderec, 0))
            wpn:SetFreeAimAngle(freeaimang)
        end

        recrise = recrise + Angle(uprec, siderec, 0)

        TacRP.RecoilRise = recrise

        cmd:SetViewAngles(eyeang)

        -- local aim_kick_v = rec * math.sin(CurTime() * 15) * FrameTime() * (1 - sightdelta)
        -- local aim_kick_h = rec * math.sin(CurTime() * 12.2) * FrameTime() * (1 - sightdelta)

        -- wpn:SetFreeAimAngle(wpn:GetFreeAimAngle() - Angle(aim_kick_v, aim_kick_h, 0))
    end

    local ping = 0
    if !game.SinglePlayer() then
        ping = ply:Ping()
    end
    if TacRP.ConVars["recoilreset"]:GetBool()
            and wpn:GetLastRecoilTime() + wpn:RecoilDuration() - (ping * 0.5) < CurTime()
            and wpn:GetRecoilAmount() == 0 then

        recrise = TacRP.RecoilRise

        local recreset = recrise * FrameTime() * 6

        recrise = recrise - recreset

        recrise:Normalize()

        local eyeang = cmd:GetViewAngles()

        -- eyeang.p = math.AngleDifference(eyeang.p, recreset.p)
        -- eyeang.y = math.AngleDifference(eyeang.y, recreset.y)

        eyeang = eyeang - recreset

        cmd:SetViewAngles(eyeang)

        TacRP.RecoilRise = recrise
    end

    if wpn:GetInBipod() then
        local bipang = wpn:GetBipodAngle()
        local eyeang = cmd:GetViewAngles()

        local dy, dp = math.AngleDifference(bipang.y, eyeang.y), math.AngleDifference(bipang.p, eyeang.p)

        if dy < -60 then
            eyeang.y = bipang.y + 60
        elseif dy > 60 then
            eyeang.y = bipang.y - 60
        end

        if dp > 20 then
            eyeang.p = bipang.p - 20
        elseif dp < -20 then
            eyeang.p = bipang.p + 20
        end

        cmd:SetViewAngles(eyeang)

        if game.SinglePlayer() then
            ply:SetEyeAngles(eyeang)
        end
    end

    TacRP.LastEyeAngles = cmd:GetViewAngles()

    if cmd:KeyDown(IN_SPEED) and (
        -- Sprint cannot interrupt a runaway burst
        (!wpn:CanShootInSprint() and wpn:GetBurstCount() > 0 and wpn:GetValue("RunawayBurst"))

        -- Stunned by a flashbang and cannot sprint
        or (ply:GetNWFloat("TacRPStunStart", 0) + ply:GetNWFloat("TacRPStunDur", 0) > CurTime())

        -- Cannot reload and sprint (now sprint takes priority)
        -- or (!wpn:CanReloadInSprint() and wpn:GetReloading())\

        -- Trying to aim disables sprinting if option is set
        or (wpn:GetValue("Scope") and !wpn:DoOldSchoolScopeBehavior() and (ply:KeyDown(IN_ATTACK2) or wpn:GetScopeLevel() > 0) and ply:GetInfoNum("tacrp_aim_cancels_sprint", 0) > 0 and wpn:CanStopSprinting())
    ) then
        cmd:SetButtons(cmd:GetButtons() - IN_SPEED)
        cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_RUN)) -- Abuse unused IN_ enum
        ply.TacRP_SprintBlock = true -- for some reason KeyDown(IN_SPEED) doesn't seem to see the modified buttons, so we set this
    else
        ply.TacRP_SprintBlock = false
    end

    -- Used for sprint checking
    ply.TacRP_Moving = cmd:GetForwardMove() != 0 or cmd:GetSideMove() != 0
end

hook.Add("StartCommand", "TacRP_StartCommand", TacRP.StartCommand)