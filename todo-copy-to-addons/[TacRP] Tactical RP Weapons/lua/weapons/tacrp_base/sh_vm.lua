local customizedelta = 0
local sightdelta = 0
local sprintdelta = 0
local peekdelta = 0
local bipoddelta = 0
local blindfiredelta, blindfiredeltaleft, blindfiredeltaright, blindfiredeltakys = 0, 0, 0, 0
local freeaim_p, freeaim_y = 0, 0
local nearwalldelta = 0

local angle_zero = Angle(0, 0, 0)
local vector_origin = Vector(0, 0, 0)

local peekvector = Vector(0, 0, -2)

local m_appor = math.Approach
local f_lerp = function(dlt, from, to) return from + (to - from) * dlt end
local function ApproachMod(usrobj, to, dlt)
    usrobj[1] = m_appor(usrobj[1], to[1], dlt)
    usrobj[2] = m_appor(usrobj[2], to[2], dlt)
    usrobj[3] = m_appor(usrobj[3], to[3], dlt)
end

local function LerpMod(usrobj, to, dlt, clamp_ang)
    usrobj[1] = f_lerp(dlt, usrobj[1], to[1])
    usrobj[2] = f_lerp(dlt, usrobj[2], to[2])
    usrobj[3] = f_lerp(dlt, usrobj[3], to[3])
    if clamp_ang then
        for i = 1, 3 do usrobj[i] = math.NormalizeAngle(usrobj[i]) end
    end
end

SWEP.BenchPos = SWEP.BenchPos or Vector(0, 0, 0)
SWEP.BenchAng = SWEP.BenchAng or Angle(0, 0, 0)

SWEP.ViewModelPos = Vector(0, 0, 0)
SWEP.ViewModelAng = Angle(0, 0, 0)

function SWEP:GetViewModelPosition(pos, ang)
    if !IsValid(self:GetOwner()) then
        return Vector(0, 0, 0), Angle(0, 0, 0)
    end

    if TacRP.ConVars["dev_benchgun"]:GetBool() then
        return self.BenchPos, self.BenchAng
    end
    self.BenchPos = pos
    self.BenchAng = ang

    local vm = self:GetOwner():GetViewModel()
    local FT = self:DeltaSysTime() -- FrameTime()

    ang = ang - (self:GetOwner():GetViewPunchAngles() * 0.5)

    local oldang = Angle(0, 0, 0)

    oldang:Set(ang)

    local offsetpos = Vector(self.PassivePos)
    local offsetang = Angle(self.PassiveAng)

    local extra_offsetpos = Vector(0, 0, 0)
    local extra_offsetang = Angle(0, 0, 0)

    -- local cor_val = (self.ViewModelFOV / self:GetShouldFOV())
    local cor_val = 0.75

    ---------------------------------------------
    -- Blindfire
    ---------------------------------------------
    local bfmode = self:GetBlindFireMode()
    local bfl = bfmode == TacRP.BLINDFIRE_LEFT
    local bfr = bfmode == TacRP.BLINDFIRE_RIGHT
    local bfs = bfmode == TacRP.BLINDFIRE_KYS
    blindfiredelta = math.Approach(blindfiredelta, self:GetBlindFire() and 1 or 0, FT / 0.3)
    blindfiredeltaleft = math.Approach(blindfiredeltaleft, bfl and 1 or 0, FT / (bfr and 0.45 or 0.3))
    blindfiredeltaright = math.Approach(blindfiredeltaright, bfr and 1 or 0, FT / (bfl and 0.45 or 0.3))
    blindfiredeltakys = math.Approach(blindfiredeltakys, bfs and 1 or 0, FT / (bfs and 0.75 or 0.3))
    if blindfiredelta > 0 then
        local curvedblindfiredelta = self:Curve(blindfiredelta)
        local curvedblindfiredeltaleft = self:Curve(blindfiredeltaleft)
        local curvedblindfiredeltaright = self:Curve(blindfiredeltaright)
        local curvedblindfiredeltakys = self:Curve(blindfiredeltakys)

        offsetpos = LerpVector(curvedblindfiredelta, offsetpos, self:GetValue("BlindFirePos"))
        offsetang = LerpAngle(curvedblindfiredelta, offsetang, self:GetValue("BlindFireAng"))

        if curvedblindfiredeltaleft > 0 then
            offsetpos = LerpVector(curvedblindfiredeltaleft, offsetpos, self:GetValue("BlindFireLeftPos"))
            offsetang = LerpAngle(curvedblindfiredeltaleft, offsetang,  self:GetValue("BlindFireLeftAng"))
        end

        if curvedblindfiredeltaright > 0 then
            offsetpos = LerpVector(curvedblindfiredeltaright, offsetpos, self:GetValue("BlindFireRightPos"))
            offsetang = LerpAngle(curvedblindfiredeltaright, offsetang,  self:GetValue("BlindFireRightAng"))
        end

        if curvedblindfiredeltakys > 0 then
            offsetpos = LerpVector(curvedblindfiredeltakys, offsetpos, self:GetValue("BlindFireSuicidePos"))
            offsetang = LerpAngle(curvedblindfiredeltakys, offsetang,  self:GetValue("BlindFireSuicideAng"))
        end
    end

    ---------------------------------------------
    -- Aiming & Peeking
    ---------------------------------------------
    local ads = self:GetAimDownSightsTime()
    if self:GetScopeLevel() > 0 then
        if self:GetSprintLockTime() > CurTime() then
            ads = ads + self:GetSprintToFireTime()
        end
        sightdelta = m_appor(sightdelta, 1, FT / ads)
    else
        sightdelta = m_appor(sightdelta, 0, FT / ads)
    end

    if self:GetPeeking() then
        peekdelta = m_appor(peekdelta, 1, FT / 0.2)
    else
        peekdelta = m_appor(peekdelta, 0, FT / 0.2)
    end

    local curvedsightdelta = self:Curve(sightdelta)
    local curvedpeekdelta = self:Curve(peekdelta)

    -- cor_val = Lerp(sightdelta, cor_val, 1)

    local ppos = Vector(self:GetValue("PeekPos")) * curvedpeekdelta
    local pang = Angle(self:GetValue("PeekAng")) * curvedpeekdelta

    if sightdelta > 0 then
        local sightpos, sightang = self:GetSightPositions()

        if self:DoLowerIrons() then
            sightpos = sightpos + LerpVector(curvedpeekdelta, peekvector, vector_origin)
        end

        LerpMod(offsetpos, sightpos + ppos, curvedsightdelta)
        LerpMod(offsetang, sightang + pang, curvedsightdelta, true)

        local eepos, eeang = self:GetExtraSightPosition()
        local im = self:GetValue("SightMidPoint")
        local midpoint = curvedsightdelta * math.cos(curvedsightdelta * (math.pi / 2)) * (1 - curvedpeekdelta)
        local joffset = (im and im.Pos or Vector(0, 0, 0) + ppos) * midpoint
        local jaffset = (im and im.Ang or Angle(0, 0, 0) + pang) * midpoint

        LerpMod(extra_offsetpos, -eepos + joffset, curvedsightdelta)
        LerpMod(extra_offsetang, -eeang + jaffset, curvedsightdelta)
    end

    ---------------------------------------------
    -- Bipod
    ---------------------------------------------
    local amt = math.Clamp(self:GetBipodPos():Distance(self:GetOwner():EyePos()) / 60, 0.15, 0.3)
    bipoddelta = math.Approach(bipoddelta, self:GetInBipod() and 1 or 0, FT / (self:GetInBipod() and 0.4 or amt))

    if bipoddelta > 0 then
        local curvedbipoddelta = self:Curve(bipoddelta)
        pos = LerpVector(math.Clamp(curvedbipoddelta - curvedsightdelta, 0, 1), pos, self:GetBipodPos())
    end

    ---------------------------------------------
    -- Procedural Firing
    ---------------------------------------------
    if IsValid(vm) and self.ProceduralIronFire then
        local dt = math.max(0, UnPredictedCurTime() - self:GetLastProceduralFireTime() + self:GetPingOffsetScale())

        if dt <= self.ProceduralIronFire.tmax then
            self.ProceduralIronCleanup = false
            if !(self:GetValue("LastShot") and self:Clip1() == 0) then
                for k, v in pairs(self.ProceduralIronFire.bones or {}) do
                    local bone = vm:LookupBone(v.bone or "")
                    if !bone then continue end

                    local f = 1
                    if v.t0 == 0 then
                        f = v.t1 and math.Clamp(1 - dt / v.t1, 0, 1) or 0
                    else
                        f = v.t1 and (dt > v.t0 and math.Clamp(1 - (dt - v.t0) / (v.t1 - v.t0), 0, 1) or (dt / v.t0)) or (dt > v.t0 and 1 or (dt / v.t0))
                    end
                    if v.pos then
                        local offset = LerpVector(f, vector_origin, v.pos)
                        vm:ManipulateBonePosition(bone, offset, false)
                    end
                    if v.ang then
                        local offset = LerpAngle(f, angle_zero, v.ang)
                        vm:ManipulateBoneAngles(bone, offset, false)
                    end
                end
            end

            local dtc = math.ease.InQuad(math.Clamp(1 - dt / self.ProceduralIronFire.t, 0, 1))

            if dtc > 0 and self.ProceduralIronFire.vm_pos then
                LerpMod(offsetpos, offsetpos + self.ProceduralIronFire.vm_pos, dtc)
            end
            if dtc > 0 and self.ProceduralIronFire.vm_ang then
                LerpMod(offsetang, offsetang + self.ProceduralIronFire.vm_ang, dtc, true)
            end
        elseif !self.ProceduralIronCleanup then
            self.ProceduralIronCleanup = true
            for k, v in pairs(self.ProceduralIronFire.bones or {}) do
                local bone = vm:LookupBone(v.bone or "")
                if !bone then continue end
                if v.pos then
                    vm:ManipulateBonePosition(bone, vector_origin, false)
                end
                if v.ang then
                    vm:ManipulateBoneAngles(bone, angle_zero, false)
                end
            end
        end
    end

    ---------------------------------------------
    -- Free Aim & Sway
    ---------------------------------------------
    local swayang = self:GetSwayAngles()
    extra_offsetang.y = extra_offsetang.y - (swayang.p * cor_val)
    extra_offsetang.p = extra_offsetang.p + (swayang.y * cor_val)

    local idlesway = Lerp(self:GetSightDelta(), 1 / 3, 0)
    extra_offsetpos.x = extra_offsetpos.x + (swayang.y * cor_val * idlesway)
    extra_offsetpos.z = extra_offsetpos.z + (swayang.p * cor_val * idlesway)

    local freeaimang = self:GetFreeAimOffset()

    freeaim_p = f_lerp(0.5, freeaim_p, freeaimang.p)
    freeaim_y = f_lerp(0.5, freeaim_y, freeaimang.y)
    freeaim_p = m_appor(freeaim_p, freeaimang.p, FT)
    freeaim_y = m_appor(freeaim_y, freeaimang.y, FT)

    extra_offsetang.y = extra_offsetang.y - (freeaim_p * cor_val)
    extra_offsetang.p = extra_offsetang.p + (freeaim_y * cor_val)

    ---------------------------------------------
    -- Customization
    ---------------------------------------------
    if self:GetCustomize() then
        customizedelta = m_appor(customizedelta, 1, FT * 1 / 0.15)
    else
        customizedelta = m_appor(customizedelta, 0, FT * 1 / 0.15)
    end

    if customizedelta > 0 then
        local curvedcustomizedelta = self:Curve(customizedelta)
        LerpMod(offsetpos, self:GetValue("CustomizePos"), curvedcustomizedelta)
        LerpMod(offsetang, self:GetValue("CustomizeAng"), curvedcustomizedelta)

        LerpMod(extra_offsetang, angle_zero, curvedcustomizedelta, true)
    end

    ---------------------------------------------
    -- Sprinting
    ---------------------------------------------
    local stf = self:GetSprintToFireTime()
    if self:GetCustomize() or self:GetInBipod() or (!self:GetSafe() and !self.LastWasSprinting) then
        -- not accurate to how sprint progress works but looks much smoother
        if self:GetScopeLevel() > 0 and self:GetSprintLockTime() > UnPredictedCurTime() then
            stf = stf + self:GetAimDownSightsTime() * 0.5
        end
        sprintdelta = m_appor(sprintdelta, 0, FT / stf)
        self.LastReloadEnd = nil
    elseif self:GetReloading() then
        if self.LastWasSprinting and self:GetEndReload() then
            self.LastReloadEnd = self.LastReloadEnd or (self:GetReloadFinishTime() - UnPredictedCurTime())
            sprintdelta = 1 - self:Curve((self:GetReloadFinishTime() - UnPredictedCurTime()) / self.LastReloadEnd)
        else
            sprintdelta = m_appor(sprintdelta, 0, FT / 0.5)
        end
    else
        if self:GetLastMeleeTime() + 0.5 > CurTime() or self:GetStartPrimedGrenadeTime() + 0.8 > CurTime() then
            sprintdelta = m_appor(sprintdelta, 0, FT / 0.2)
        else
            sprintdelta = m_appor(sprintdelta, 1, FT / stf)
        end
        self.LastReloadEnd = nil
    end
    local curvedsprintdelta = self:Curve(sprintdelta)
    if curvedsprintdelta > 0 then
        LerpMod(offsetpos, self:GetValue("SprintPos"), curvedsprintdelta)
        LerpMod(offsetang, self:GetValue("SprintAng"), curvedsprintdelta)
        LerpMod(extra_offsetang, angle_zero, curvedsprintdelta, true)

        local sim = self:GetValue("SprintMidPoint")
        local spr_midpoint = curvedsprintdelta * math.cos(curvedsprintdelta * (math.pi / 2))
        local spr_joffset = (sim and sim.Pos or Vector(0, 0, 0)) * spr_midpoint
        local spr_jaffset = (sim and sim.Ang or Angle(0, 0, 0)) * spr_midpoint
        extra_offsetpos:Add(spr_joffset)
        extra_offsetang:Add(spr_jaffset)
    end

    ---------------------------------------------
    -- Near Walling
    ---------------------------------------------
    nearwalldelta = m_appor(nearwalldelta, self:GetNearWallAmount(), FT / 0.3)
    local curvednearwalldelta = self:Curve(nearwalldelta) - customizedelta - sightdelta
    if curvednearwalldelta > 0 then
        local sprpos = LerpVector(curvednearwalldelta, vector_origin, self:GetValue("NearWallPos"))
        local sprang = LerpAngle(curvednearwalldelta, angle_zero, self:GetValue("NearWallAng"))

        local pointdir = self:GetOwner():WorldToLocalAngles(self:GetShootDir())

        extra_offsetpos:Add(pointdir:Right() * sprpos[2])
        extra_offsetpos:Add(pointdir:Forward() * sprpos[1])
        extra_offsetpos:Add(pointdir:Up() * sprpos[3])

        extra_offsetang:Add(sprang)
    end

    self.SwayScale = f_lerp(sightdelta, 1, 0.1)
    self.BobScale = 0

    local speed = 15 * FT * (game.SinglePlayer() and 1 or 2)

    LerpMod(self.ViewModelPos, offsetpos, speed)
    LerpMod(self.ViewModelAng, offsetang, speed, true)
    ApproachMod(self.ViewModelPos, offsetpos, speed * 0.1)
    ApproachMod(self.ViewModelAng, offsetang, speed * 0.1)

    self.ViewModelAng:Normalize()

    pos = pos + (ang:Right() * offsetpos[1])
    pos = pos + (ang:Forward() * offsetpos[2])
    pos = pos + (ang:Up() * offsetpos[3])

    ang:RotateAroundAxis(ang:Up(), offsetang[1])
    ang:RotateAroundAxis(ang:Right(), offsetang[2])
    ang:RotateAroundAxis(ang:Forward(), offsetang[3])

    pos = pos + (oldang:Right() * extra_offsetpos[1])
    pos = pos + (oldang:Forward() * extra_offsetpos[2])
    pos = pos + (oldang:Up() * extra_offsetpos[3])

    ang:RotateAroundAxis(oldang:Up(), extra_offsetang[1])
    ang:RotateAroundAxis(oldang:Right(), extra_offsetang[2])
    ang:RotateAroundAxis(oldang:Forward(), extra_offsetang[3])

    pos, ang = self:GetViewModelBob(pos, ang)
    pos, ang = self:GetViewModelSway(pos, ang)

    self.ViewModelPos = pos
    self.ViewModelAng = ang

    self.LastSysTime = SysTime()
    return pos, ang
end

function SWEP:TranslateFOV(fov)
    return fov
end