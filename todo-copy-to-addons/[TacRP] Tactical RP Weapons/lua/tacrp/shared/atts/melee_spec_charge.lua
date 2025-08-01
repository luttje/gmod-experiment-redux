ATT.PrintName = "Charge"
ATT.FullName = "demoknight tf2"
ATT.Icon = Material("entities/tacrp_att_melee_spec_charge.png", "mips smooth")
ATT.Description = "Advance with reckless abandon, and break some laws of physics too."
ATT.Pros = {"RELOAD: Charge forwards", "WALK + RELOAD: Select charge mode", "Damage resistance during charge", "Self damage resistance"}
ATT.Cons = {}

ATT.Category = {"melee_spec"}

ATT.SortOrder = 5

ATT.MeleeCharge = true

ATT.Override_NoBreathBar = true

ATT.Hook_GetHintCapabilities = function(self, tbl)
    tbl["+reload"] = {so = 0.4, str = "Charge"}
    tbl["+walk/+reload"] = {so = 0.5, str = "Toggle Charge"}
end

local followup = 0.75

local modecount = 3
local modes = {
    -- name, desc, {speed, duration, turnrate, damagemult, resistance}
    [0] = {"Bravery", "Standard mode with average turn control.\nPrimary attack during charge or after impact to gain bonus damage from charge length, ending the charge.", {750, 1.5, 240, 1, 0.5}},
    [1] = {"Mastery", "Significantly increased turn control.\nLow damage resistance and damage output.\nTaking damage shortens charge duration.", {750, 1.5, 960, 0.75, 0.25}},
    [2] = {"Tenacity", "Increased charge speed, reduced turn control.\nVery high damage resistance and damage output.\nGains knockback immunity during charge.", {850, 1.5, 90, 2, 0.75}},
}

local stat_vel = 1
local stat_dur = 2
local stat_turn = 3
local stat_dmg = 4
local stat_res = 5
local function chargestats(ply, i)
    local mode = ply:GetNWInt("TacRPChargeMode", 0)
    if modes[mode] then
        if i then
            return modes[mode][3][i] or 0
        else
            return modes[mode][3]
        end
    else
        return 0
    end
end

local function ChargeFraction(ply)
    local g = 0.25
    return 1 - math.Clamp((ply:GetNWFloat("TacRPChargeTime", 0) + chargestats(ply, stat_dur) - CurTime() - g) / (chargestats(ply, stat_dur) - g), 0, 1)
end

local function wishspeedthreshold()
    return 100 * GetConVar("sv_friction"):GetFloat() / GetConVar("sv_accelerate"):GetFloat()
end

local function entercharge(ply)
    ply:SetNWFloat("TacRPChargeStrength", 0)
    ply:SetNWBool("TacRPChargeState", true)
    ply.TacRPPrevColCheck = ply:GetCustomCollisionCheck()
    ply:SetCustomCollisionCheck(true)
    ply.TacRPPrevFlag = ply:IsEFlagSet(EFL_NO_DAMAGE_FORCES)
    if ply:GetNWInt("TacRPChargeMode", 0) == 2 and !ply.TacRPPrevFlag then
        ply:AddEFlags(EFL_NO_DAMAGE_FORCES)
    end
end

local function exitcharge(ply, nohit)
    ply:SetNWFloat("TacRPChargeStrength", ChargeFraction(ply))
    ply:SetNWBool("TacRPChargeState", false)
    ply:SetNWFloat("TacRPChargeTime", 0)
    ply:SetNWFloat("TacRPChargeEnd", CurTime())

    if IsValid(ply:GetNWEntity("TacRPChargeWeapon")) then
        ply:GetNWEntity("TacRPChargeWeapon"):SetBreath(0)
    end

    if !nohit then
        ply:SetNWFloat("TacRPChargeFollowup", CurTime() + followup)
    end

    ply:SetCustomCollisionCheck(ply.TacRPPrevColCheck)
    if ply.TacRPPrevFlag then
        ply:RemoveEFlags(EFL_NO_DAMAGE_FORCES)
    end
    ply.TacRPPrevColCheck = nil
    ply.TacRPPrevFlag = nil
end

local function incharge(ply)
    return ply:Alive() and ply:GetNWBool("TacRPChargeState", false)
end

local function activecharge(ply)
    return ply:GetNWFloat("TacRPChargeTime", 0) + chargestats(ply, stat_dur) > CurTime()
end

local function chargemelee(self)
    if self:StillWaiting(false, true) then return end

    self:EmitSound(self:ChooseSound(self:GetValue("Sound_MeleeSwing")), 75, 100, 1)

    self:GetOwner():LagCompensation(true)

    local dmg = self:GetValue("MeleeDamage")
        * (1 + self:GetMeleePerkDamage())
        * (1 + self:GetOwner():GetNWFloat("TacRPChargeStrength", 0) ^ 1.5 * 2)
    local range = 200
    self:GetOwner():DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2)
    self:PlayAnimation("melee2", 1, false, true)

    local filter = {self:GetOwner()}

    table.Add(filter, self.Shields)

    local start = self:GetOwner():GetShootPos()
    local dir = self:GetOwner():GetAimVector()
    local tr = util.TraceLine({
        start = start,
        endpos = start + dir * range,
        filter = filter,
        mask = MASK_SHOT_HULL,
    })

    -- weapon_hl2mpbasebasebludgeon.cpp: do a hull trace if not hit
    if tr.Fraction == 1 or !IsValid(tr.Entity) then
        local dim = 32
        local pos2 = tr.HitPos - dir * (dim * 1.732)
        local tr2 = util.TraceHull({
            start = start,
            endpos = pos2,
            filter = filter,
            mask = MASK_SHOT_HULL,
            mins = Vector(-dim, -dim, -dim),
            maxs = Vector(dim, dim, dim)
        })
        if tr2.Fraction < 1 and IsValid(tr2.Entity) then
            local dot = (tr2.Entity:GetPos() - start):GetNormalized():Dot(dir)
            if dot >= 0.5 then
                tr = tr2
            end
        end
    end

    local dmginfo = DamageInfo()
    dmginfo:SetDamage(dmg)
    dmginfo:SetDamageForce(dir * dmg * (1000 + 500 * self:GetMeleePerkDamage()))
    dmginfo:SetDamagePosition(tr.HitPos)
    dmginfo:SetDamageType(self:GetValue("MeleeDamageType"))
    dmginfo:SetAttacker(self:GetOwner())
    dmginfo:SetInflictor(self)

    local t = self:GetValue("MeleeAttackTime") * 2

    if tr.Fraction < 1 then
        TacRP.CancelBodyDamage(tr.Entity, dmginfo, tr.HitGroup)

        if IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:IsNextBot()) then
            self:EmitSound(self:ChooseSound(self:GetValue("Sound_MeleeHitBody")), 75, 100, 1, CHAN_ITEM)

            if self:GetValue("MeleeBackstab") then
                local ang = math.NormalizeAngle(self:GetOwner():GetAngles().y - tr.Entity:GetAngles().y)
                if ang <= 60 and ang >= -60 then
                    dmginfo:ScaleDamage(self:GetValue("MeleeBackstabMult"))
                    self:EmitSound("tacrp/riki_backstab.wav", 70, 100, 0.4)
                end
            end
        else
            self:EmitSound(self:ChooseSound(self:GetValue("Sound_MeleeHit")), 75, 100, 1, CHAN_ITEM)
        end

        if IsValid(tr.Entity) and self:GetValue("MeleeSlow") then
            tr.Entity.TacRPBashSlow = true
        end

        if IsValid(tr.Entity) and !tr.HitWorld then
            --tr.Entity:TakeDamageInfo(dmginfo)
            tr.Entity:DispatchTraceAttack(dmginfo, tr)
        end
    end

    self:GetOwner():LagCompensation(false)

    self:SetLastMeleeTime(CurTime())
    self:SetNextSecondaryFire(CurTime() + t)

    self:SetTimer(0.5, function()
        self:SetShouldHoldType()
    end, "holdtype")
end

ATT.Hook_PreShoot = function(wep)
    if !IsFirstTimePredicted() then return end
    local ply = wep:GetOwner()
    if wep:StillWaiting() then return end

    if incharge(ply) then
        exitcharge(ply, true)
        ply:EmitSound("TacRP.Charge.End")
        chargemelee(wep)
        return true
    elseif ply:GetNWFloat("TacRPChargeFollowup", 0) > CurTime() then
        chargemelee(wep)
        ply:SetNWFloat("TacRPChargeFollowup", 0)
        return true
    end
end

ATT.Hook_PreReload = function(wep)
    wep.LastHintLife = CurTime()

    if !(game.SinglePlayer() or IsFirstTimePredicted()) then return end
    local ply = wep:GetOwner()

    if game.SinglePlayer() and CLIENT then
        entercharge(ply)
        return
    end

    if !incharge(ply) and ply:KeyDown(IN_WALK) and ply:KeyPressed(IN_RELOAD) then
        ply:SetNWInt("TacRPChargeMode", (ply:GetNWInt("TacRPChargeMode", 0) + 1) % 3)
        return true
    end

    if incharge(ply) or !ply:KeyPressed(IN_RELOAD) or ply:GetMoveType() != MOVETYPE_WALK
    or wep:GetBreath() < 1 then return end

    wep:SetBreath(0)
    -- ply:SetNWFloat("TacRPDashCharge", 0)
    ply:SetNWFloat("TacRPChargeTime", CurTime())
    ply:SetNWEntity("TacRPChargeWeapon", wep)

    entercharge(ply)

    wep:SetHoldType("melee2")

    wep:SetTimer(chargestats(ply, stat_dur) + followup, function()
        wep:SetShouldHoldType()
    end, "holdtype")

    if SERVER then
        ply:EmitSound("TacRP.Charge.Windup", 80)
    end

    -- so client can draw the effect. blehhhh
    if game.SinglePlayer() and SERVER then wep:CallOnClient("Reload") end

    local eff = EffectData()
    eff:SetOrigin(ply:GetPos())
    eff:SetNormal(Angle(0, ply:GetAngles().y, 0):Forward())
    eff:SetEntity(ply)
    util.Effect("tacrp_chargesmoke", eff)

    return true
end

--[[]
ATT.Hook_PostThink = function(wep)
    local ply = wep:GetOwner()
    if (game.SinglePlayer() or IsFirstTimePredicted()) and !incharge(ply) then
        ply:SetNWFloat("TacRPDashCharge", math.min(1, ply:GetNWFloat("TacRPDashCharge", 0) + FrameTime() / (wep:GetValue("MeleeDashChargeTime") or 7.5)))
    end
end
]]

function ATT.TacticalDraw(self)
    local ply = self:GetOwner()
    local scrw = ScrW()
    local scrh = ScrH()

    local w = TacRP.SS(128)
    local h = TacRP.SS(8)

    local x = (scrw - w) / 2
    local y = (scrh - h) * 7 / 8

    surface.SetDrawColor(0, 0, 0, 100)
    TacRP.DrawCorneredBox(x, y, w, h)

    x = x + TacRP.SS(1)
    y = y + TacRP.SS(1)
    w = w - TacRP.SS(2)
    h = h - TacRP.SS(2)

    local chargin = incharge(ply)

    local curmode = ply:GetNWInt("TacRPChargeMode", 0)
    if !chargin and ply:KeyDown(IN_WALK) then

        local w_mode = w / modecount - TacRP.SS(0.5) * (modecount - 1)
        for i = 0, modecount - 1 do
            local c_bg, c_cnr, c_txt = TacRP.GetPanelColors(curmode == i, curmode == i)
            surface.SetDrawColor(c_bg)
            TacRP.DrawCorneredBox(x + (i / modecount * w) + (i * TacRP.SS(0.5)), y - TacRP.SS(45), w_mode, TacRP.SS(6), c_cnr)
            draw.SimpleText(modes[i][1], "TacRP_HD44780A00_5x8_4", x + (i / modecount * w) + (i * TacRP.SS(0.5)) + w_mode / 2, y - TacRP.SS(45 - 3), c_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        surface.SetDrawColor(0, 0, 0, 240)
        TacRP.DrawCorneredBox(x, y - TacRP.SS(38), w, TacRP.SS(24))

        local desc = TacRP.MultiLineText(modes[curmode][2], w - TacRP.SS(6), "TacRP_Myriad_Pro_6")
        for j, text in ipairs(desc or {}) do
            draw.SimpleText(text, "TacRP_Myriad_Pro_6", x + TacRP.SS(3), y - TacRP.SS(38 - 2) + (j - 1) * TacRP.SS(6.5), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end


    local c = self:GetBreath() -- math.Clamp(ply:GetNWFloat("TacRPDashCharge", 0), 0, 1)
    local d = 1

    local c_bg, c_cnr, c_txt = TacRP.GetPanelColors(chargin, chargin)
    surface.SetDrawColor(c_bg)
    TacRP.DrawCorneredBox(x + w / 2 - w / 6, y - TacRP.SS(12), w / 3, TacRP.SS(9), c_cnr)
    draw.SimpleText(modes[curmode][1], "TacRP_HD44780A00_5x8_6", x + w / 2, y - TacRP.SS(8), c_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if chargin then
        c = math.Clamp((ply:GetNWFloat("TacRPChargeTime", 0) + chargestats(ply, stat_dur) - CurTime()) / chargestats(ply, stat_dur), 0, 1)
        d = 1 - ChargeFraction(ply)
        surface.SetDrawColor(255, 255 * d ^ 0.5, 255 * d, 150)
    elseif c < 1 then
        surface.SetDrawColor(150, 150, 150, 150)
    else
        surface.SetDrawColor(255, 255, 255, 150)
    end

    surface.DrawRect(x, y, w * c, h)

end

hook.Add("StartCommand", "TacRP_Charge", function(ply, cmd)
    if incharge(ply) then
        local ang = cmd:GetViewAngles()

        cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_DUCK + IN_JUMP + IN_FORWARD + IN_BACK + IN_MOVELEFT + IN_MOVERIGHT + IN_WALK + IN_SPEED)))
        cmd:SetForwardMove(chargestats(ply, stat_vel))
        cmd:SetUpMove(0)
        cmd:SetSideMove(0)

        ply.TacRPLastAngle = ply.TacRPLastAngle or ang
        local max = FrameTime() * chargestats(ply, stat_turn)
        cmd:SetViewAngles(Angle(ang.p, math.ApproachAngle(ply.TacRPLastAngle.y, ang.y, max), 0))

        ply.TacRPLastAngle = cmd:GetViewAngles()
    else
        ply.TacRPLastAngle = nil
    end
end)

local function TracePlayerBBox(ply, pos0, pos1)
    local bb1, bb2 = ply:GetCollisionBounds()
    return util.TraceHull({
        start = pos0,
        endpos = pos1,
        mask = MASK_PLAYERSOLID,
        collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
        mins = bb1,
        maxs = bb2,
        filter = ply,
    })
end

hook.Add("Move", "TacRP_Charge", function(ply, mv)
    if incharge(ply) then

        if ply:GetMoveType() != MOVETYPE_WALK then
            exitcharge(ply)
            return
        end

        local pos = mv:GetOrigin()

        -- naive implementation: always move in direction of aim.
        -- does not allow for cool stuff like charge strafing
        -- local v = mv:GetVelocity().z
        -- local speed = mv:GetVelocity():Dot(ply:GetForward())
        -- mv:SetVelocity(ply:GetForward() * math.max(ply:GetRunSpeed() + (ply:IsOnGround() and 450 or 350), speed) + Vector(0, 0, v))

        -- replicate demoknight charge mechanic
        -- https://github.com/OthmanAba/TeamFortress2/blob/master/tf2_src/game/shared/tf/tf_gamemovement.cpp
        local wishspeed = chargestats(ply, stat_vel)
        local wishdir = ply:GetForward()
        local flAccelerate = GetConVar("sv_accelerate"):GetFloat()

        -- Grounded friction is constantly trying to slow us down. Counteract it!
        -- TF2 doesn't have to deal with it since it disables friction in-engine. We can't since I don't want to reimplement gamemovement.cpp
        if ply:IsOnGround() and ply:WaterLevel() == 0 then
            wishspeed = wishspeed / 0.88 -- approximate grounded friciton with magic number
            if !game.SinglePlayer() then
                wishspeed = wishspeed / 0.88 -- ???????????
            end
        end

        -- if our wish speed is too low (attributes), we must increase acceleration or we'll never overcome friction
        -- Reverse the basic friction calculation to find our required acceleration
        if wishspeed < wishspeedthreshold() then
            local flSpeed = mv:GetVelocity():Length()
            local flControl = math.min(GetConVar("sv_stopspeed"):GetFloat(), flSpeed)
            flAccelerate = (flControl * GetConVar("sv_friction"):GetFloat()) / wishspeed + 1
        end

        -- Accelerate()
        -- https://github.com/ValveSoftware/source-sdk-2013/blob/master/mp/src/game/shared/gamemovement.cpp

        local currentspeed = mv:GetVelocity():Dot(wishdir)
        local addspeed = wishspeed - currentspeed

        if addspeed > 0 then
            accelspeed = math.min(addspeed, flAccelerate * FrameTime() * wishspeed) -- * player->m_surfaceFriction but it seems like it's 1 by default?

            mv:SetVelocity(mv:GetVelocity() + accelspeed * wishdir)
        end

        -- The player will double dip on air acceleration since engine also applies its acceleration.
        -- Stop engine behavior if we're in mid-air and not colliding. If we collide, let engine kick in.
        if !ply:IsOnGround() and ply:WaterLevel() == 0 then

            -- since we are about to override the rest of engine movement code, apply gravity ourselves
            mv:SetVelocity(mv:GetVelocity() + physenv.GetGravity() * FrameTime())
        end

        local dest = pos + mv:GetVelocity() * FrameTime()
        local tr = TracePlayerBBox(ply, pos, dest)
        -- If we made it all the way, then copy trace end as new player position.
        if tr.Fraction == 1 then
            if !ply:IsOnGround() and ply:WaterLevel() == 0 then
                mv:SetOrigin(tr.HitPos)
                -- mv:SetVelocity(mv:GetVelocity() - ply:GetBaseVelocity()) -- probably not relevant?
                return true
            end
        else
            if SERVER and IsValid(tr.Entity) then
                -- use this trace in FinishMove so we can punt/hit whatever is in our way
                ply.TacRPChargeTrace = tr
            end

            -- Sliding along a wall seems to increase velocity beyond desired value. Clamp it if so
            local v2d = mv:GetVelocity()
            v2d.z = 0
            if v2d:Length2D() > wishspeed then
                mv:SetVelocity(v2d:GetNormalized() * wishspeed + Vector(0, 0, mv:GetVelocity().z))
            end
        end
    end
end)

local mins, maxs = Vector(-24, -24, 16), Vector(24, 24, 72)
hook.Add("FinishMove", "TacRP_Charge", function(ply, mv)
    -- if true then return end
    --if !IsFirstTimePredicted() then return end
    if incharge(ply) then
        local wep = ply:GetNWEntity("TacRPChargeWeapon")
        local d = ChargeFraction(ply)

        -- https://github.com/OthmanAba/TeamFortress2/blob/1b81dded673d49adebf4d0958e52236ecc28a956/tf2_src/game/shared/tf/tf_gamemovement.cpp#L248
        -- some grace time to make point blank charges not awkward.
        if ply:GetNWFloat("TacRPChargeTime", 0) + engine.TickInterval() * 5 < CurTime() then
            local active = activecharge(ply)
            local vel = mv:GetVelocity():Length()

            if !active or vel < chargestats(ply, stat_vel) * 0.4 or IsValid(ply.TacRPTryCollide) then

                local tr = ply.TacRPChargeTrace
                local ent = ply.TacRPTryCollide

                if !tr and IsFirstTimePredicted() then
                    ply:LagCompensation(true)
                    tr = util.TraceHull({
                        start = ply:GetPos(),
                        endpos = ply:GetPos() + ply:GetForward() * 48,
                        filter = {ply},
                        mask = MASK_PLAYERSOLID,
                        mins = mins,
                        maxs = maxs,
                        ignoreworld = !active
                    })
                    ply:LagCompensation(false)
                    debugoverlay.Box(tr.HitPos, mins, maxs, FrameTime() * 10, Color(255, 255, 255, 0))
                end
                if !IsValid(ent) and tr then
                    ent = tr.Entity
                end

                local grace = false
                if IsValid(ent) and ent:GetOwner() != ply then
                    if SERVER then
                        local df = math.max(0.25, d) * (1 + wep:GetMeleePerkDamage())
                        local dmgscale = chargestats(ply, stat_dmg)
                        local dmginfo = DamageInfo()
                        dmginfo:SetDamageForce(ply:GetForward() * 5000 * df)
                        dmginfo:SetDamagePosition(tr.HitPos)
                        dmginfo:SetDamageType(DMG_CLUB)
                        dmginfo:SetAttacker(ply)
                        dmginfo:SetInflictor(IsValid(wep) and wep or ply)

                        local phys = ent:GetPhysicsObject()
                        if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
                            dmginfo:SetDamage((IsValid(wep) and wep:GetValue("MeleeDamage") or 25) * df)

                            ent:SetVelocity(ply:GetForward() * 500 * df + Vector(0, 0, 100 + 150 * d))
                            ent:SetGroundEntity(NULL)

                            -- we may be able to kill the target and go through them
                            grace = (ent.TacRPNextChargeHit or 0) <= CurTime() and ent:Health() <= dmginfo:GetDamage() * dmgscale

                            if grace then
                                mv:SetVelocity(ply:GetForward() * chargestats(ply, stat_vel))
                            elseif d >= 0.5 then
                                ply:EmitSound("TacRP.Charge.HitFlesh_Range", 80)
                            else
                                ply:EmitSound("TacRP.Charge.HitFlesh", 80)
                            end
                        elseif IsValid(phys) then
                            --phys:SetVelocityInstantaneous(ply:GetForward() * math.Rand(15000, 20000) * (d * 0.5 + 0.5) * ((1 / phys:GetMass()) ^ 0.5))

                            -- hitting a prop once will punt it, and we will not stop because of the prop for some time.
                            -- if we hit it again before the debounce, we probably failed to move it and will stop.
                            phys:ApplyForceOffset(ply:GetForward() * chargestats(ply, stat_vel) * (d * 0.5 + 0.5) * dmgscale * 10, ply:GetPos())

                            grace = phys:IsMotionEnabled() and ((ent.TacRPNextChargeHit or 0) <= CurTime() or (ply.TacRPGrace or 0) >= CurTime())
                            if !grace then
                                ply:EmitSound("TacRP.Charge.HitWorld", 80)
                            elseif (ent.TacRPNextChargeHit or 0) <= CurTime() then
                                dmginfo:SetDamage(math.max(vel, chargestats(ply, stat_vel) * 0.5))
                                dmginfo:SetDamageType(DMG_CLUB)
                                mv:SetVelocity(ply:GetForward() * chargestats(ply, stat_vel) * 0.75)
                            end
                        end

                        if (ent.TacRPNextChargeHit or 0) <= CurTime() then
                            dmginfo:ScaleDamage(dmgscale)
                            ent:TakeDamageInfo(dmginfo)
                        end
                    end
                elseif tr and tr.HitWorld then
                    ply:EmitSound("TacRP.Charge.HitWorld", 80)
                end
                -- In TF2, going below 300 velocity instantly cancels the charge.
                -- However, this feels really bad if you're trying to cancel your momentum mid-air!
                -- Also works poorly with props
                if !active or (!grace and ((tr and tr.Hit) or (ply.TacRPChargeTrace and IsValid(ent) and (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot())))) then
                    exitcharge(ply)

                    if !game.SinglePlayer() and CLIENT then
                        if IsValid(ent) and (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) then
                            if d >= 0.5 then
                                ply:EmitSound("TacRP.Charge.HitFlesh_Range", 80)
                            else
                                ply:EmitSound("TacRP.Charge.HitFlesh", 80)
                            end
                        else
                            ply:EmitSound("TacRP.Charge.HitWorld", 80)
                        end
                    end

                    if tr.Hit then
                        util.ScreenShake(tr.HitPos, 20, 125, d * 1, 750)
                    else
                        ply:EmitSound("TacRP.Charge.End") -- interrupt sound
                    end

                    if IsValid(wep) and wep.ArcticTacRP then
                        wep:SetShouldHoldType()
                    end
                elseif grace and IsValid(ent) and (ent.TacRPNextChargeHit or 0) <= CurTime() then
                    if game.SinglePlayer() then
                        ent.TacRPNextChargeHit = CurTime() + 0.5
                        ply.TacRPGrace = CurTime() + 0.3
                    else
                        ent.TacRPNextChargeHit = CurTime() + 0.3
                        ply.TacRPGrace = CurTime() + 0.15
                    end
                    util.ScreenShake(tr.HitPos, 10, 125, 0.25, 750)
                    ply:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav")
                end
            end

            ply.TacRPChargeTrace = nil
            ply.TacRPTryCollide = nil
        end
    end
end)

hook.Add("EntityTakeDamage", "TacRP_Charge", function(ply, dmginfo)
    if !IsValid(dmginfo:GetAttacker()) or !ply:IsPlayer() then return end
    local activewep = ply:GetActiveWeapon()

    if !incharge(ply) and ply:GetNWFloat("TacRPChargeEnd") + 0.25 < CurTime() then
        if dmginfo:GetAttacker() == ply
        and IsValid(activewep) and activewep.ArcticTacRP and activewep:GetValue("MeleeCharge") then
            ply:SetVelocity(dmginfo:GetDamageForce() * 0.02)
            dmginfo:ScaleDamage(0.5)
        end
        return
    end

    -- immune to physics damage regardless of mode or held weapon
    if dmginfo:IsDamageType(DMG_CRUSH) then
        return true
    end

    -- only get benefits if charging weapon is out
    local wep = ply:GetNWEntity("TacRPChargeWeapon")
    if !IsValid(wep) or wep != ply:GetActiveWeapon() then return end

    local resist = chargestats(ply, stat_res)
    dmginfo:ScaleDamage(1 - resist)
end)

hook.Add("PostEntityTakeDamage", "TacRP_Charge", function(ent, dmginfo, took)
    -- local ply = dmginfo:GetAttacker()
    -- local inflictor = dmginfo:GetInflictor()
    --[[]
    if took and IsValid(inflictor) and inflictor.ArcticTacRP and inflictor:GetValue("MeleeCharge")
            and (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) and ent != ply
            and ply:IsPlayer() and ply:GetNWInt("TacRPChargeMode", 0) == 1
            and incharge(ply) then
        ply:SetNWFloat("TacRPDashCharge", math.min(1, ply:GetNWFloat("TacRPDashCharge", 0) + dmginfo:GetDamage() * (ent:IsPlayer() and 0.01 or 0.005)))
    end
    ]]
    if took and dmginfo:GetAttacker() != ent and !dmginfo:IsFallDamage() and ent:IsPlayer() and incharge(ent) and ent:GetNWInt("TacRPChargeMode", 0) == 1 then
        local dur = chargestats(ent, stat_dur)
        local left = ent:GetNWFloat("TacRPChargeTime", 0) + dur - CurTime() - dmginfo:GetDamage() * 0.1 * dur
        ent:SetNWFloat("TacRPChargeTime", CurTime() - dur + left)
        if !incharge(ent) then
            exitcharge(ent)
        end
    end
end)

-- don't slide off stuff
-- blehhhhhhh
local col = {
    [COLLISION_GROUP_NONE] = true,
    [COLLISION_GROUP_INTERACTIVE_DEBRIS] = true,
    [COLLISION_GROUP_INTERACTIVE] = true,
    [COLLISION_GROUP_PLAYER] = true,
    [COLLISION_GROUP_BREAKABLE_GLASS] = true,
    [COLLISION_GROUP_VEHICLE] = true,
    [COLLISION_GROUP_PLAYER_MOVEMENT] = true,
    [COLLISION_GROUP_NPC] = true,
}
local mt = {
    [MOVETYPE_PUSH] = true,
    [MOVETYPE_NONE] = true,
}
local function touchy(ply, ent)
    if IsValid(ply) and IsValid(ent) and ply:IsPlayer() and !ent:IsPlayer() and incharge(ply) and ent:GetOwner() != ply and ent:GetParent() != ply and ply:GetParent() != ent
            and (!mt[ent:GetMoveType()] and col[ent:GetCollisionGroup()] and IsValid(ent:GetPhysicsObject()) and ent:GetPhysicsObject():IsMotionEnabled()) then

        local diff = ent:GetPos() - ply:GetPos()
        if diff:Length() <= ent:BoundingRadius() + ply:BoundingRadius() + 8 then
            local dot = diff:GetNormalized():Dot(ply:GetVelocity():GetNormalized())
            if dot >= 0.5 then
                ply.TacRPTryCollide = ent
            end
        end
        return true
    end
end
hook.Add("ShouldCollide", "TacRP_Charge", function(ent1, ent2)
    if IsValid(ent1.TacRPTryCollide) or IsValid(ent2.TacRPTryCollide) then return end
    if touchy(ent1, ent2) then return end
    if touchy(ent2, ent1) then return end
end)

hook.Add("DoPlayerDeath", "TacRP_Charge", function(ply)
    exitcharge(ply, true)
end)