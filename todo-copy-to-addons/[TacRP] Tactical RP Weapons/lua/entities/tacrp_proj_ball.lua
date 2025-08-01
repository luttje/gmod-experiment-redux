AddCSLuaFile()

ENT.Base                     = "tacrp_proj_base"
ENT.PrintName                = "Thrown Ball"
ENT.Spawnable                = false

ENT.Model                    = "models/weapons/tacint_extras/w_baseball.mdl" --"models/weapons/w_models/w_baseball.mdl" -- TODO replace with hexed model

ENT.IsRocket = false

ENT.InstantFuse = false
ENT.RemoteFuse = false
ENT.ImpactFuse = true

ENT.ExplodeOnDamage = false
ENT.ExplodeUnderwater = true

ENT.Delay = 0

ENT.SmokeTrail = false

ENT.Damage = 25

DEFINE_BASECLASS(ENT.Base)

function ENT:Initialize()
    BaseClass.Initialize(self)
    if SERVER then
        self:GetPhysicsObject():SetDragCoefficient(0)
        self.StartPos = self:GetPos()
        self.Trail = util.SpriteTrail(self, 0, color_white, true, 4, 0, 0.1, 2, "trails/tube")
    end
end

function ENT:StartTouch(ent)
    if self.Impacted and (CurTime() - self.SpawnTime) > 0.05 and IsValid(ent) and ent:IsPlayer() and ent:GetNWFloat("TacRPScoutBall", 0) > CurTime() then
        ent:SetNWFloat("TacRPScoutBall", 0)
        SafeRemoveEntity(self)
    end
end

function ENT:PhysicsCollide(data, collider)

    if IsValid(data.HitEntity) and data.HitEntity:GetClass() == "func_breakable_surf" then
        self:FireBullets({
            Attacker = self:GetOwner(),
            Inflictor = self,
            Damage = 0,
            Distance = 32,
            Tracer = 0,
            Src = self:GetPos(),
            Dir = data.OurOldVelocity:GetNormalized(),
        })
        local pos, ang, vel = self:GetPos(), self:GetAngles(), data.OurOldVelocity
        self:SetAngles(ang)
        self:SetPos(pos)
        self:GetPhysicsObject():SetVelocityInstantaneous(vel * 0.5)
        return
    end

    if self.Impacted then return end
    self.Impacted = true
    self:SetTrigger(true)
    self:UseTriggerBounds(true, 8)
    if IsValid(self.Trail) then
        self.Trail:Remove()
    end
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local attacker = self.Attacker or self:GetOwner() or self
    if IsValid(data.HitEntity) then
        local d = data.OurOldVelocity:GetNormalized()

        local tgtpos = data.HitPos
        local dist = (tgtpos - self.StartPos):Length()
        self.Damage = Lerp(math.Clamp(dist / 1500, 0, 1) ^ 1.5, 15, 50) * (data.HitEntity:IsPlayer() and 1 or 1.5)

        local dmg = DamageInfo()
        dmg:SetAttacker(attacker)
        dmg:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
        dmg:SetDamage(self.Damage)
        dmg:SetDamageType(DMG_SLASH)
        dmg:SetDamageForce(d * 10000)
        dmg:SetDamagePosition(data.HitPos)

        if dist > 200 then
            data.HitEntity.TacRPBashSlow = true
        end

        if data.HitEntity:IsPlayer() or data.HitEntity:IsNPC() or data.HitEntity:IsNextBot() then
            if dist >= 1500 then
                data.HitEntity:EmitSound("tacrp/sandman/pl_impact_stun_range.wav", 100)
            else
                data.HitEntity:EmitSound("tacrp/sandman/pl_impact_stun.wav", 90)
            end
        else
            data.HitEntity:EmitSound("tacrp/sandman/baseball_hitworld" .. math.random(1, 3) .. ".wav", 90)
        end

        if data.HitEntity:IsNPC() or data.HitEntity:IsNextBot() then
            data.HitEntity:SetVelocity(Vector(0, 0, 200))
            if data.HitEntity:IsNPC() then
                data.HitEntity:SetSchedule(SCHED_FLINCH_PHYSICS)
            end
        end

        local atktr = util.TraceLine({
            start = self:GetPos(),
            endpos = tgtpos,
            filter = self
        })

        TacRP.CancelBodyDamage(data.HitEntity, dmg, atktr.HitGroup)
        data.HitEntity:SetPhysicsAttacker(attacker, 3)
        data.HitEntity:DispatchTraceAttack(dmg, atktr)

        self:SetOwner(nil)
    else
        data.HitEntity:EmitSound("tacrp/sandman/baseball_hitworld" .. math.random(1, 3) .. ".wav", 90)
    end

    SafeRemoveEntityDelayed(self, 5)
    -- self:GetPhysicsObject():SetVelocity(-data.HitNormal * data.OurNewVelocity:Length())
end