local blur = Material("pp/blurscreen")
local function drawBlurAt(x, y, w, h, amount, passes, reverse)
    -- Intensity of the blur.
    amount = amount or 5

    surface.SetMaterial(blur)
    surface.SetDrawColor(color_white)

    local scrW, scrH = ScrW(), ScrH()
    local x2, y2 = x / scrW, y / scrH
    local w2, h2 = (x + w) / scrW, (y + h) / scrH

    for i = -(passes or 0.2), 1, 0.2 do
        if reverse then
            blur:SetFloat("$blur", i * -1 * amount)
        else
            blur:SetFloat("$blur", i * amount)
        end
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRectUV(x, y, w, h, x2, y2, w2, h2)
    end
end

local peekzoom = 1.2

function SWEP:ScopeToggle(setlevel)
    if (setlevel or 0) > 0 and (!self:GetValue("Scope") or self:GetPrimedGrenade()) then return end
    -- if setlevel and setlevel > 0 and self:GetAnimLockTime() > CurTime() or (!setlevel and self:GetAnimLockTime() > CurTime()) then return end
    -- if (setlevel and setlevel > 0 and self:GetReloading()) or (!setlevel and self:GetReloading()) then return end

    local level = self:GetScopeLevel()
    local oldlevel = level

    level = setlevel or (level + 1)

    if level > self:GetValue("ScopeLevels") then
        level = self:GetValue("ScopeLevels")
    end

    if self:GetCustomize() or self:GetLastMeleeTime() + 1 > CurTime() then -- self:SprintLock(true)
        level = 0
    end

    if self:GetIsSprinting() and level > 0 then
        if self:GetOwner():GetInfoNum("tacrp_aim_cancels_sprint", 0) > 0 and self:CanStopSprinting() then
            self:GetOwner().TacRP_SprintBlock = true
        else
            level = 0
        end
    end

    if self:DoOldSchoolScopeBehavior() then
        level = 0
    end

    if level == self:GetScopeLevel() then return end

    self:SetScopeLevel(level)

    if level > 0 then
        self:ToggleBlindFire(TacRP.BLINDFIRE_NONE)
    end

    if oldlevel == 0 or level == 0 then
        self:SetLastScopeTime(CurTime())
    end

    -- HACK: In singleplayer, SWEP:Think is called on client but IsFirstTimePredicted is NEVER true.
    -- This causes ScopeToggle to NOT be called on client in singleplayer...
    -- GenerateAutoSight needs to run clientside or scopes will break. Good old CallOnClient it is.

    if SERVER and game.SinglePlayer() then
        self:CallOnClient("GenerateAutoSight")
    elseif CLIENT and (IsFirstTimePredicted() or game.SinglePlayer()) then
        self:GenerateAutoSight()
        self.LastHintLife = CurTime()
    end

    self:EmitSound(self:GetValue("Sound_ScopeIn"), 75, 100, 1, CHAN_ITEM)

    self:SetShouldHoldType()
end

function SWEP:GetShouldFOV(ignorepeek)
    local level = self:GetScopeLevel()

    local base = 90

    if level > 0 and (ignorepeek or !self:GetPeeking()) then
        local fov = self:GetValue("ScopeFOV")

        fov = Lerp(level / self:GetValue("ScopeLevels"), base, fov)

        return fov
    elseif !ignorepeek and self:GetPeeking() then
        return base / peekzoom
    else
        return base
    end
end

function SWEP:IsInScope()
    local sightdelta = self:Curve(self:GetSightDelta())

    return (SERVER or !self:GetPeeking()) and !self:GetSafe() and ((self:GetScopeLevel() > 0 and sightdelta > 0.5) or (sightdelta > 0.9))
end

function SWEP:DoScope()
    if self:IsInScope() then

        local img = self:GetValue("ScopeOverlay")

        if img then
            local h = ScrH()
            local w = ScrW()

            -- assume players have a screen that is wider than it is tall because... that's stupid

            local pos = self:GetOwner():EyePos()

            pos = pos + self:GetShootDir():Forward() * 9000

            local toscreen = pos:ToScreen()

            local x = toscreen.x
            local y = toscreen.y

            local ss = math.Round(h * (self:GetValue("ScopeOverlaySize") or 1))
            local sx = x - (ss / 2)
            local sy = y - (ss / 2)

            -- local shakey = math.min(cross * 35, 3)

            -- sx = sx + math.Round(math.Rand(-shakey, shakey))
            -- sy = sy + math.Round(math.Rand(-shakey, shakey))

            -- local int = self:CheckFlashlightPointing()
            -- if int > 0 then
            --     surface.SetDrawColor(255, 255, 255, int * 250)
            --     surface.DrawRect(0, 0, w, h)
            -- end

            surface.SetMaterial(img)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(sx, sy, ss, ss)

            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(0, 0, w, sy)
            surface.DrawRect(0, sy + ss, w, h - sy)

            surface.DrawRect(0, 0, sx, h)
            surface.DrawRect(sx + ss, 0, w - sx, h)

            if self:GetReloading() then
                drawBlurAt(0, 0, w, h, 1, 1)
            end

            -- if int > 0 then
            --     surface.SetDrawColor(255, 255, 255, int * 25)
            --     surface.DrawRect(0, 0, w, h)
            -- end
        end
    end
end

function SWEP:GetSightDelta()
    return self:GetSightAmount()
end

function SWEP:SetSightDelta(d)
    self:SetSightAmount(d)
end

function SWEP:ThinkSights()
    if !IsValid(self:GetOwner()) then return end

    local ftp = IsFirstTimePredicted()

    if ftp and self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyPressed(IN_ATTACK2) then
        self:ToggleSafety()
        return
    end

    if ftp and self:GetValue("Bipod") and self:GetOwner():KeyPressed(IN_ATTACK2)
            and !self:GetInBipod() and self:CanBipod() then
        self:EnterBipod()
    end

    local FT = FrameTime()

    local sighted = self:GetScopeLevel() > 0

    local amt = self:GetSightAmount()

    local adst = self:GetAimDownSightsTime()

    if sighted then
        if self:GetSprintLockTime() > CurTime() then
            adst = adst + self:GetSprintToFireTime()
        end
        amt = math.Approach(amt, 1, FT / adst)
    else
        amt = math.Approach(amt, 0, FT / adst)
    end

    self:SetSightDelta(amt)

    if self:GetSafe() then return end

    if CLIENT then
        self:ThinkPeek()
    end
    local toggle = self:GetOwner():GetInfoNum("tacrp_toggleaim", 0) == 1
    local press, down = self:GetOwner():KeyPressed(IN_ATTACK2), self:GetOwner():KeyDown(IN_ATTACK2)

    if (!self:GetValue("Scope") or self:DoOldSchoolScopeBehavior()) and down then
        self:Melee()
    elseif sighted and ((toggle and press and ftp) or (!toggle and !down)) then
        self:ScopeToggle(0)
    elseif !sighted and ((toggle and press and ftp) or (!toggle and down)) then
        self:ScopeToggle(1)
    end
end

function SWEP:GetMagnification()
    local mag = 1

    local level = self:GetScopeLevel()

    if level > 0 then

        if self:GetPeeking() then
            return peekzoom
        end

        mag = 90 / self:GetValue("ScopeFOV")

        mag = Lerp(level / self:GetValue("ScopeLevels"), 1, mag)
    end

    return mag
end

function SWEP:AdjustMouseSensitivity()
    local mag = self:GetMagnification()

    if mag > 1 then
        return 1 / mag
    end
end

function SWEP:ThinkPeek()
    local down = input.IsKeyDown(input.GetKeyCode(input.LookupBinding("menu_context") or "???"))
    if !TacRP.ConVars["togglepeek"]:GetBool() and self:GetPeeking() ~= down then
        net.Start("tacrp_togglepeek")
        net.WriteBool(down)
        net.SendToServer()
    end
end

function SWEP:GetCCIP(pos, ang)
    -- get calculated point of impact

    local sp, sa = self:GetMuzzleOrigin(), self:GetShootDir()

    pos = pos or sp
    ang = ang or sa

    local v = self:GetValue("MuzzleVelocity")
    local g = Vector(0, 0, -600)
    local d = 1
    local h = 0

    if self:GetValue("ShootEnt") then
        v = self:GetValue("ShootEntForce")
        d = 0
        g = physenv.GetGravity()
        h = 4
    end

    local vel = ang:Forward() * v
    local maxiter = 100
    local timestep = 1 / 15
    local gravity = timestep * g

    local steps = {}

    for i = 1, maxiter do
        local dir = vel:GetNormalized()
        local spd = vel:Length() * timestep
        local drag = d * spd * spd * (1 / 150000)

        if spd <= 0.001 then return nil end

        local newpos = pos + (vel * timestep)
        local newvel = vel - (dir * drag) + gravity

        local tr
        if h > 0 then
            tr = util.TraceHull({
                start = pos,
                endpos = newpos,
                filter = self:GetOwner(),
                mask = MASK_SHOT,
                mins = Vector(-h, -h, -h),
                maxs = Vector(h, h, h),
            })
        else
            tr = util.TraceLine({
                start = pos,
                endpos = newpos,
                filter = self:GetOwner(),
                mask = MASK_SHOT
            })
        end
        table.insert(steps, 0, tr.HitPos)

        if tr.Hit then
            debugoverlay.Sphere(tr.HitPos, 8, 0.25, color_white, true)
            return tr, i * timestep, steps
        else
            pos = newpos
            vel = newvel
        end
    end

    return nil
end

function SWEP:GetCorVal()
    local vmfov = self.ViewModelFOV
    local fov = self:GetShouldFOV()

    return vmfov / (fov * 1.33333)
end

function SWEP:HasOptic()
    return self:GetValue("Scope") and (self:GetValue("ScopeOverlay") or self:GetValue("Holosight"))
end

function SWEP:DoOldSchoolScopeBehavior()
    return (TacRP.ConVars["oldschool"]:GetBool() or TacRP.GetBalanceMode() == TacRP.BALANCE_OLDSCHOOL)
            and !self:HasOptic()
end


function SWEP:GetAimDownSightsTime(base)
    if base then
        return self:GetBaseValue("AimDownSightsTime") * TacRP.ConVars["mult_aimdownsights"]:GetFloat()
    else
        return self:GetValue("AimDownSightsTime") * TacRP.ConVars["mult_aimdownsights"]:GetFloat()
    end
end

function SWEP:GetSprintToFireTime(base)
    if base then
        return self:GetBaseValue("SprintToFireTime") * TacRP.ConVars["mult_sprinttofire"]:GetFloat()
    else
        return self:GetValue("SprintToFireTime") * TacRP.ConVars["mult_sprinttofire"]:GetFloat()
    end
end