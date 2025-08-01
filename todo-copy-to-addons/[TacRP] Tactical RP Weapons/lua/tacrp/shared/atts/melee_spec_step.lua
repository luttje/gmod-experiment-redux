ATT.PrintName = "Airdash"
ATT.Icon = Material("entities/tacrp_att_melee_spec_step.png", "mips smooth")
ATT.Description = "Mobility tool used by blood-fueled robots and transgender women."
ATT.Pros = {"RELOAD: Dash in movement direction", "CROUCH (Mid-air + Looka down): Fastfall", "Invulnerable during dash", "No fall damage"}

ATT.Category = {"melee_spec"}

ATT.SortOrder = 1

ATT.Airdash = true

-- ATT.Add_MeleeRechargeRate = 0.5

local duration = 0.25

local cost = 1 / 3
ATT.Override_BreathSegmentSize = cost

local function makedashsound(ent, pitch)
    if TacRP.ShouldWeFunny() then
        ent:EmitSound("tacrp/vineboom.mp3", 75, pitch)
    else
        ent:EmitSound("player/suit_sprint.wav", 75, pitch)

    end
end

ATT.Hook_GetHintCapabilities = function(self, tbl)
    tbl["+reload"] = {so = 0.4, str = "Airdash"}
end

local function getcharge(wep)
    -- return ply:GetNWFloat("TacRPDashCharge", 0)
    return wep:GetBreath()
end

local function setcharge(wep, f)
    -- ply:SetNWFloat("TacRPDashCharge", f)
    wep:SetBreath(math.Clamp(f, 0, 1))
end

ATT.Hook_PreReload = function(wep)
    local ply = wep:GetOwner()

    if ply:GetNWFloat("TacRPDashTime", -1) + 0.25 > CurTime()
            or !ply:KeyPressed(IN_RELOAD)
            or ply:GetMoveType() == MOVETYPE_NOCLIP
            or getcharge(wep) < cost then return end

    setcharge(wep, getcharge(wep) - cost)
    -- ply:SetNWFloat("TacRPDashCharge", ply:GetNWFloat("TacRPDashCharge", 0) - 1 / 3)
    ply:SetNWVector("TacRPDashDir", Vector())
    ply:SetNWFloat("TacRPDashTime", CurTime())
    ply:SetNWFloat("TacRPDashSpeed", 1.5 + wep:GetValue("MeleePerkAgi") * 1)
    ply:SetNWBool("TacRPDashFall", false)

    if SERVER then
        makedashsound(ply, 95)
    end

    return true
end

ATT.Hook_PostThink = function(wep)
    local ply = wep:GetOwner()
    if IsFirstTimePredicted() and ply:KeyPressed(IN_DUCK) and !ply:IsOnGround() and !ply:GetNWBool("TacRPDashFall") then
        local dot = ply:GetAimVector():Dot(Vector(0, 0, -1))
        if dot > 0.707 then
            ply:SetVelocity(-Vector(0, 0, ply:GetVelocity().z + 500 + wep:GetValue("MeleePerkAgi") * 500))
            ply:SetNWBool("TacRPDashFall", true)
        end
    end
end

hook.Add("SetupMove", "TacRP_Quickstep", function(ply, mv, cmd)
    if !IsFirstTimePredicted() then return end
    if ply:GetNWFloat("TacRPDashTime", -1) + duration > CurTime() then
        if !ply.TacRPDashDir and !ply.TacRPDashCancel then
            ply.TacRPDashDir = TacRP.GetCmdVector(cmd, true)
            ply.TacRPDashStored = ply:GetVelocity():Length()
            ply.TacRPDashCancel = nil
            ply.TacRPDashPending = true
            ply.TacRPDashGrounded = ply:IsOnGround()

            local f, s = cmd:GetForwardMove(), cmd:GetSideMove()
            if math.abs(f + s) == 0 then f = 10000 end

            ply:ViewPunch(Angle(f / 2500, s / -5000, s / 2500))

            ply:SetVelocity(ply.TacRPDashDir * ply:GetRunSpeed() * ply:GetNWFloat("TacRPDashSpeed", 4) * (ply:IsOnGround() and 3 or 1))

            local eff = EffectData()
            eff:SetOrigin(ply:GetPos())
            eff:SetNormal(ply.TacRPDashDir)
            eff:SetEntity(ply)
            util.Effect("tacrp_dashsmoke", eff)
        end

        if ply.TacRPDashGrounded and ply.TacRPDashCancel == nil and cmd:KeyDown(IN_JUMP) then
            -- ply:SetVelocity(ply.TacRPDashDir * ply:GetRunSpeed() * 1 + Vector(0, 0, 5 * ply:GetJumpPower()))
            ply.TacRPDashGrounded = false
            ply.TacRPDashCancel = CurTime()
            ply:SetNWFloat("TacRPDashTime", -1)
        end
    elseif ply:GetNWFloat("TacRPDashTime", -1) + duration <= CurTime() then
        if ply.TacRPDashCancel != nil and CurTime() - ply.TacRPDashCancel > 0 and !ply:IsOnGround() then
            ply:SetVelocity(ply:GetVelocity():GetNegated() + ply.TacRPDashDir * ply:GetRunSpeed() * 2.5 + Vector(0, 0, 2 * ply:GetJumpPower()))
            ply.TacRPDashCancel = nil
            ply.TacRPDashDir = nil
        elseif ply.TacRPDashDir and ply.TacRPDashCancel == nil then
            ply.TacRPDashDir = nil
            if !ply:IsOnGround() then
                ply:SetVelocity(ply:GetVelocity():GetNegated() / 1.5)
            end
        elseif ply:IsOnGround() and ply:GetNWBool("TacRPDashFall") then
            ply:SetNWBool("TacRPDashFall", false)
        end
    end
end)

hook.Add("FinishMove", "TacRP_Quickstep", function(ply, mv)
    if ply:GetNWFloat("TacRPDashTime", -1) + duration > CurTime() and ply.TacRPDashCancel == nil then
        local v = mv:GetVelocity()
        v.z = 0
        mv:SetVelocity(v)
    end
end)

hook.Add("EntityTakeDamage", "TacRP_Quickstep", function(ent, dmginfo)
    if !ent:IsPlayer() or ent:GetNWFloat("TacRPDashTime", -1) + duration <= CurTime() then return end
    ent:EmitSound("weapons/fx/nearmiss/bulletltor0" .. math.random(3, 4) .. ".wav")
    local eff = EffectData()
    eff:SetOrigin(dmginfo:GetDamagePosition())
    eff:SetNormal(-dmginfo:GetDamageForce():GetNormalized())
    util.Effect("StunstickImpact", eff)
    return true
end)

hook.Add("GetFallDamage", "TacRP_Quickstep", function(ply, speed)
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep.ArcticTacRP and wep:GetValue("Airdash") then return true end
end)