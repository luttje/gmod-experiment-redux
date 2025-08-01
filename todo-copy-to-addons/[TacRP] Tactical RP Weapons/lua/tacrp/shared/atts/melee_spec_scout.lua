ATT.PrintName = "Scout"
ATT.FullName = "jerma tf2"
ATT.Icon = Material("entities/tacrp_att_melee_spec_scout.png", "mips smooth")
ATT.Description = "Grass grows, sun shines, birds fly, and brotha' - I hurt people."
ATT.Pros = {"RELOAD: Launch ball (slow on hit)", "Ball damage scales with distance", "Multi Jump"}

ATT.Category = {"melee_spec"}

ATT.SortOrder = 6

ATT.DoubleJump = true

ATT.Hook_GetHintCapabilities = function(self, tbl)
    tbl["+reload"] = {so = 0.4, str = "Launch Ball"}
end

local jumpcost = 1 / 5
ATT.Override_BreathSegmentSize = jumpcost


local balldelay = 5

ATT.Hook_PreReload = function(wep)
    local ply = wep:GetOwner()
    if ply:GetNWFloat("TacRPScoutBall", 0) > CurTime() then return end
    ply:SetNWFloat("TacRPScoutBall", CurTime() + balldelay)

    wep:SetNextPrimaryFire(CurTime() + 0.3)
    wep:PlayAnimation("melee", 0.5, false, true)
    wep:GetOwner():DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2)

    wep:EmitSound("tacrp/sandman/bat_baseball_hit" .. math.random(1, 2) .. ".wav")

    if SERVER then
        local src, ang = ply:GetShootPos(), wep:GetShootDir() --+ Angle(-1, 0, 0)
        local force = 2000
        local rocket = ents.Create("tacrp_proj_ball")
        rocket.Inflictor = wep
        rocket:SetPos(src)
        rocket:SetOwner(ply)
        rocket:SetAngles(ang)
        rocket:Spawn()
        rocket:SetPhysicsAttacker(ply, 10)

        local phys = rocket:GetPhysicsObject()

        if phys:IsValid() then
            phys:AddVelocity(ang:Forward() * force)
            phys:SetAngleVelocityInstantaneous(VectorRand() * 500)
        end
    end

    return true
end

local ballicon = Material("TacRP/grenades/baseball.png", "mips smooth")
local lastc = 0
function ATT.TacticalDraw(self)
    local scrw = ScrW()
    local scrh = ScrH()

    local w = TacRP.SS(16)
    local h = TacRP.SS(16)

    local x = (scrw - w) / 2
    local y = (scrh - h) * 7 / 8

    surface.SetDrawColor(0, 0, 0, 200)
    TacRP.DrawCorneredBox(x, y, w, h)

    local c = math.Clamp((self:GetOwner():GetNWFloat("TacRPScoutBall", 0) - CurTime()) / balldelay, 0, 1)
    surface.SetDrawColor(150, 150, 150, 75)
    surface.DrawRect(x, y + h * (1 - c), w, h * c)

    if c == 0 and lastc > 0 then
        LocalPlayer():EmitSound("tacrp/sandman/recharged.wav")
    end
    lastc = c

    local clr = c > 0 and 200 or 255
    surface.SetDrawColor(clr, clr, clr, 255)
    surface.SetMaterial(ballicon)
    surface.DrawTexturedRect(x, y, w, h)
end

local function GetMoveVector(mv)
    local ang = mv:GetAngles()

    local max_speed = mv:GetMaxSpeed()

    local forward = math.Clamp(mv:GetForwardSpeed(), -max_speed, max_speed)
    local side = math.Clamp(mv:GetSideSpeed(), -max_speed, max_speed)

    local abs_xy_move = math.abs(forward) + math.abs(side)

    if abs_xy_move == 0 then
        return Vector(0, 0, 0)
    end

    local mul = max_speed / abs_xy_move

    local vec = Vector()

    vec:Add(ang:Forward() * forward)
    vec:Add(ang:Right() * side)

    vec:Mul(mul)

    return vec
end
hook.Add("SetupMove", "tacrp_melee_spec_scout", function(ply, mv)
    local wep = ply:GetActiveWeapon()
    if !IsValid(wep) or !wep.ArcticTacRP or !wep:GetValue("DoubleJump") then return end
    if ply:OnGround() or ply:GetMoveType() != MOVETYPE_WALK then
        ply:SetNWBool("TacRPDoubleJump", true)
        return
    end

    if !mv:KeyPressed(IN_JUMP) then
        return
    end

    local add = Lerp(wep:GetValue("MeleePerkAgi"), 0.8, 1.4)
    if IsFirstTimePredicted() then
        if !ply:GetNWBool("TacRPDoubleJump") then
            if wep:GetBreath() < jumpcost then return end
            wep:SetBreath(wep:GetBreath() - jumpcost)
        else
            ply:SetNWBool("TacRPDoubleJump", false)
        end
    end

    local vel = GetMoveVector(mv)

    vel.z = ply:GetJumpPower() * add

    mv:SetVelocity(vel)

    ply:DoCustomAnimEvent(PLAYERANIMEVENT_JUMP , -1)

    local eff = EffectData()
    eff:SetOrigin(ply:GetPos() + Vector(0, 0, 0))
    eff:SetNormal(Vector(0, 0, 1))
    eff:SetEntity(ply)
    util.Effect("tacrp_jumpsmoke", eff)
end)

ATT.Hook_Recharge = function(wep)
    if !wep:GetOwner():GetNWBool("TacRPDoubleJump") then return true end
end