ATT.PrintName = "Guard"
ATT.FullName = "High Guard"

ATT.Icon = Material("entities/tacrp_att_melee_tech_block.png", "mips smooth")
ATT.Description = "Defense is the best offense. It is, coinicidently, also the best defense."
ATT.Pros = {"ALT-FIRE: Block melee attacks or projectiles", "Gain disarming counter-attack on block"}

ATT.Category = {"melee_tech"}

ATT.SortOrder = 2

ATT.MeleeBlock = true

local function hold(wep)
    return wep:GetOwner():KeyDown(IN_ATTACK2)
            and wep:GetHoldBreathAmount() > 0
            and wep:GetNextSecondaryFire() < CurTime()
end

--[[]
ATT.Hook_SecondaryAttack = function(wep)
    -- if wep:StillWaiting() then return end
    if wep:GetNWFloat("TacRPNextBlock", 0) > CurTime() then return end
    wep:SetNextSecondaryFire(CurTime() + 0.25)
    wep:SetNWFloat("TacRPNextBlock", CurTime() + 1)
    wep:PlayAnimation("idle_defend", 1)
    wep:SetHoldType("magic")
    wep:SetNWFloat("TacRPKnifeParry", CurTime() + 0.5)
    wep:EmitSound("tacrp/weapons/pistol_holster-" .. math.random(1, 4) .. ".wav", 75, 110)

    wep:SetNextIdle(CurTime() + 0.5)
    if SERVER then
        wep:SetTimer(0.75, function()
            wep:SetShouldHoldType()
        end, "BlockReset")
    end
end
]]

ATT.Hook_PreShoot = function(wep)
    if wep:GetNWFloat("TacRPKnifeCounter", 0) > CurTime() then
        wep:SetHoldBreathAmount(math.max(0, wep:GetHoldBreathAmount() - 0.5))
        wep:Melee(true)
        wep:SetOutOfBreath(false)
        wep:SetNWFloat("TacRPKnifeCounter", 0)
        return true
    end
    if wep:GetOutOfBreath() then return true end
end

ATT.Hook_PostThink = function(wep)
    local canhold = hold(wep)
    if !wep:GetOutOfBreath() then
        if canhold and wep:GetHoldBreathAmount() > 0.1 then
            if IsFirstTimePredicted() then
                wep:SetHoldBreathAmount(wep:GetHoldBreathAmount() - 0.1)
                wep:SetOutOfBreath(true)
                wep:SetNextIdle(math.huge)
            end
            wep:PlayAnimation("idle_defend", 1)
            wep:SetHoldType("magic")
        else
            wep:SetHoldBreathAmount(math.min(1, wep:GetHoldBreathAmount() + FrameTime() * Lerp(wep:GetValue("MeleePerkInt"), 0.1, 0.5)))
        end
    else
        if !canhold then
            if IsFirstTimePredicted() then
                wep:SetOutOfBreath(false)
            end
            wep:SetNextIdle(CurTime())
            wep:SetShouldHoldType()
            wep:SetNextSecondaryFire(CurTime() + 0.1)
        else
            wep:SetHoldBreathAmount(math.max(0, wep:GetHoldBreathAmount() - FrameTime() * Lerp(wep:GetValue("MeleePerkStr"), 0.6, 0.2)))
        end
    end

    -- cancel attack post swing into block since SecondaryAttack won't be called at all otherwise
    -- if wep:GetOwner():KeyDown(IN_ATTACK2) and wep:GetNextSecondaryFire() - CurTime() <= 0.25 and wep:GetNWFloat("TacRPNextBlock", 0) <= CurTime() then
    --     wep:SetNextSecondaryFire(CurTime())
    -- end
end

local breath_a = 0
local last = 1
local lastt = 0
function ATT.TacticalDraw(self)
    local scrw = ScrW()
    local scrh = ScrH()

    local w = TacRP.SS(48)
    local h = TacRP.SS(4)

    local x = scrw / 2
    local y = scrh * 0.65 + TacRP.SS(6)

    if CurTime() > lastt + 1 then
        breath_a = math.Approach(breath_a, 0, FrameTime() * 2)
    elseif breath_a < 1 then
        breath_a = math.Approach(breath_a, 1, FrameTime())
    end
    local breath = self:GetHoldBreathAmount()
    if last != breath then
        lastt = CurTime()
        last = breath
    end
    if breath_a == 0 then return end

    x = x - w / 2
    y = y - h / 2

    surface.SetDrawColor(90, 90, 90, 200 * breath_a)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2, 1)
    surface.SetDrawColor(0, 0, 0, 75 * breath_a)
    surface.DrawRect(x, y, w, h)

    surface.SetDrawColor(255, 255, 255, 150 * breath_a)

    surface.DrawRect(x, y, w * breath, h)
end

hook.Add("EntityTakeDamage", "TacRP_Block", function(ent, dmginfo)
    if !IsValid(dmginfo:GetAttacker()) or !ent:IsPlayer() then return end
    local wep = ent:GetActiveWeapon()

    if !IsValid(wep) or !wep.ArcticTacRP or !wep:GetValue("MeleeBlock") or !wep:GetOutOfBreath() then return end
    if !(dmginfo:IsDamageType(DMG_GENERIC) or dmginfo:IsDamageType(DMG_CLUB) or dmginfo:IsDamageType(DMG_CRUSH) or dmginfo:IsDamageType(DMG_SLASH) or dmginfo:GetDamageType() == 0) then return end
    -- if dmginfo:GetAttacker():GetPos():DistToSqr(ent:GetPos()) >= 22500 then return end
    if (dmginfo:GetAttacker():GetPos() - ent:EyePos()):GetNormalized():Dot(ent:EyeAngles():Forward()) < 0.5 and ((dmginfo:GetDamagePosition() - ent:EyePos()):GetNormalized():Dot(ent:EyeAngles():Forward()) < 0.5) then return end

    -- get guard broken bitch
    if ent.PalmPunched then
        ent:SetActiveWeapon(NULL)
        ent:DropWeapon(wep, dmginfo:GetAttacker():GetPos())
        return
    end

    local ang = ent:EyeAngles()
    local fx = EffectData()
    fx:SetOrigin(ent:EyePos())
    fx:SetNormal(ang:Forward())
    fx:SetAngles(ang)
    util.Effect("ManhackSparks", fx)

    if dmginfo:GetAttacker():IsNPC() and dmginfo:GetAttacker():GetClass() != "npc_antlionguard" and dmginfo:GetAttacker():GetPos():DistToSqr(ent:GetPos()) < 22500 then
        dmginfo:GetAttacker():SetSchedule(SCHED_FLINCH_PHYSICS)
    end

    ent:EmitSound("physics/metal/metal_solid_impact_hard5.wav", 90, math.Rand(105, 110))
    ent:ViewPunch(AngleRand(-1, 1) * (dmginfo:GetDamage() ^ 0.5))

    -- wep:SetNextSecondaryFire(CurTime())
    wep:SetNWFloat("TacRPKnifeCounter", CurTime() + 1)

    -- wep:KillTimer("BlockReset")
    -- wep:SetNWFloat("TacRPNextBlock", CurTime() + 0.75)
    -- wep:PlayAnimation("idle_defend", 1)
    -- wep:SetNWFloat("TacRPKnifeParry", CurTime() + 1)
    -- wep:SetNextIdle(CurTime() + 1)
    -- if SERVER then
    --     wep:SetTimer(1, function()
    --         wep:SetShouldHoldType()
    --     end, "BlockReset")
    -- end

    local inflictor = dmginfo:GetInflictor()
    timer.Simple(0, function()
        if IsValid(inflictor) and inflictor:IsScripted() and scripted_ents.IsBasedOn(inflictor:GetClass(), "tacrp_proj_base") and IsValid(inflictor:GetPhysicsObject()) then
            inflictor:GetPhysicsObject():SetVelocityInstantaneous(ent:EyeAngles():Forward() * 2000)
            inflictor:SetOwner(ent)
        end
    end)

    return true
end)

hook.Add("EntityTakeDamage", "TacRP_Counter", function(ent, dmginfo)
    if !IsValid(dmginfo:GetAttacker()) or !dmginfo:GetAttacker():IsPlayer() then return end
    local wep = dmginfo:GetAttacker():GetActiveWeapon()

    if !IsValid(wep) or !wep.ArcticTacRP or wep:GetNWFloat("TacRPKnifeCounter", 0) < CurTime() or (dmginfo:GetInflictor() != wep and dmginfo:GetInflictor() != dmginfo:GetAttacker()) then return end
    local dropwep = ent:IsPlayer() and ent:GetActiveWeapon()

    if ent.IsLambdaPlayer then
        -- drop client weapon model; delay a tick so we don't duplicate on death
        timer.Simple(0, function()
            if !IsValid(ent) or ent:Health() < 0 then return end
            if ent.l_DropWeaponOnDeath and !ent:IsWeaponMarkedNodraw() then
                net.Start( "lambdaplayers_createclientsidedroppedweapon" )
                    net.WriteEntity( ent:GetWeaponENT() )
                    net.WriteEntity( ent )
                    net.WriteVector( ent:GetPhysColor() )
                    net.WriteString( ent:GetWeaponName() )
                    net.WriteVector( dmginfo:GetDamageForce() )
                    net.WriteVector( dmginfo:GetDamagePosition() )
                net.Broadcast()
            end
        end)

        local run = math.Rand(1, 3)
        ent.l_WeaponUseCooldown = CurTime() + run

        -- wait a bit before swapping because client relies on the entity to set model
        ent:GetWeaponENT():SetNoDraw(true)
        ent:GetWeaponENT():DrawShadow(false)
        ent:SetHasCustomDrawFunction(false)
        ent:RetreatFrom(dmginfo:GetAttacker(), run)
        timer.Simple(1, function()
            if !IsValid(ent) or ent:Health() < 0 then return end
            ent.l_Weapon = "none" -- holster function? never heard of 'em
            ent:PreventWeaponSwitch(false)
            ent:SwitchWeapon("none", true)
        end)
        timer.Simple(run, function()
            if !IsValid(ent) or ent:Health() < 0 then return end
            ent:AttackTarget(dmginfo:GetAttacker())
        end)
    elseif !IsValid(dropwep) or dropwep:GetHoldType() == "fists" or dropwep:GetHoldType() == "normal" or string.find(dropwep:GetClass(), "fist") or string.find(dropwep:GetClass(), "unarmed") or string.find(dropwep:GetClass(), "hand") then
        dmginfo:ScaleDamage(1.5)
    else
        ent:SetActiveWeapon(NULL)
        ent:DropWeapon(dropwep, dmginfo:GetAttacker():GetPos())
    end
end)

ATT.Hook_GetHintCapabilities = function(self, tbl)
    tbl["+attack2"] = {so = 0.1, str = "Block"}
end