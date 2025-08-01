AddCSLuaFile()

ENT.Base                     = "tacrp_proj_base"
ENT.PrintName                = "Thrown Knife"
ENT.Spawnable                = false

ENT.Model                    = "models/weapons/tacint/w_knife.mdl"

ENT.IsRocket = false

ENT.InstantFuse = false
ENT.RemoteFuse = false
ENT.ImpactFuse = true

ENT.ExplodeOnDamage = false
ENT.ExplodeUnderwater = true

ENT.Delay = 0
ENT.ImpactDamage = 0

ENT.SmokeTrail = false
local path = "tacrp/weapons/knife/"
ENT.Sound_MeleeHit = {
    path .. "/scrape_metal-1.wav",
    path .. "/scrape_metal-2.wav",
    path .. "/scrape_metal-3.wav",
}
ENT.Sound_MeleeHitBody = {
    path .. "/flesh_hit-1.wav",
    path .. "/flesh_hit-2.wav",
    path .. "/flesh_hit-3.wav",
    path .. "/flesh_hit-4.wav",
    path .. "/flesh_hit-5.wav",
}

ENT.Damage = 35

DEFINE_BASECLASS(ENT.Base)

function ENT:Initialize()
    BaseClass.Initialize(self)
    if SERVER then
        self:GetPhysicsObject():SetDragCoefficient(2)
    end
end

function ENT:Impact(data, collider)
    if self.Impacted then return end
    self.Impacted = true

    local tgt = data.HitEntity
    local attacker = self.Attacker or self:GetOwner() or self
    if IsValid(tgt) then
        local d = data.OurOldVelocity:GetNormalized()

        local dmg = DamageInfo()
        dmg:SetAttacker(attacker)
        dmg:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
        dmg:SetDamage(self.Damage)
        dmg:SetDamageType(self.DamageType or DMG_SLASH)
        dmg:SetDamageForce(d * 10000)
        dmg:SetDamagePosition(data.HitPos)

        local tgtpos = data.HitPos
        if (tgt:IsPlayer() or tgt:IsNPC() or tgt:IsNextBot()) then
            if (tgt:GetNWFloat("TacRPLastBashed", 0) + 3 >= CurTime()
                    or (tgt:GetNWFloat("TacRPStunStart", 0) + tgt:GetNWFloat("TacRPStunDur", 0) >= CurTime())) then
                dmg:ScaleDamage(1.5)
                tgt:EmitSound("weapons/crossbow/bolt_skewer1.wav", 80, 110)
            end

            -- Check if the knife is a headshot
            -- Either the head is the closest bodygroup, or the direction is quite on point
            local headpos = nil
            local pos = data.HitPos + d * 8
            local hset = tgt:GetHitboxSet()
            local hdot, bhg, bdist, hdist = 0, 0, math.huge, math.huge
            for i = 0, tgt:GetHitBoxCount(hset) or 0 do

                local bone = tgt:GetHitBoxBone(i, hset)
                local mtx = bone and tgt:GetBoneMatrix(bone)
                if !mtx then continue end
                local hpos = mtx:GetTranslation()
                local dot = (hpos - data.HitPos):GetNormalized():Dot(d)
                local dist = (hpos - pos):LengthSqr()

                if tgt:GetHitBoxHitGroup(i, hset) == HITGROUP_HEAD then
                    hdot = dot
                    hdist = dist
                    headpos = hpos
                end
                if dist < bdist then
                    bdist = dist
                    bhg = tgt:GetHitBoxHitGroup(i, hset)
                    tgtpos = hpos
                end
            end

            if bhg == HITGROUP_HEAD or (hdot >= 0.85 and hdist < 2500) then
                dmg:ScaleDamage(2)
                tgt:EmitSound("player/headshot" .. math.random(1, 2) .. ".wav", 80, 105)
                tgtpos = headpos
            end

            self:EmitSound(istable(self.Sound_MeleeHitBody) and self.Sound_MeleeHitBody[math.random(1, #self.Sound_MeleeHitBody)] or self.Sound_MeleeHitBody, 80, 110, 1)
            -- self:EmitSound("tacrp/weapons/knife/flesh_hit-" .. math.random(1, 5) .. ".wav", 80, 110, 1)

            -- local ang = data.OurOldVelocity:Angle()
            -- local fx = EffectData()
            -- fx:SetStart(data.HitPos - d * 4)
            -- fx:SetOrigin(data.HitPos)
            -- fx:SetNormal(d)
            -- fx:SetAngles(-ang)
            -- fx:SetEntity(tgt)
            -- fx:SetDamageType(DMG_SLASH)
            -- fx:SetSurfaceProp(data.TheirSurfaceProps)
            -- util.Effect("Impact", fx)

        else
            dmg:SetDamageForce(d * 30000)
            local ang = data.OurOldVelocity:Angle()
            local fx = EffectData()
            fx:SetOrigin(data.HitPos)
            fx:SetNormal(-ang:Forward())
            fx:SetAngles(-ang)
            util.Effect("ManhackSparks", fx)
            if SERVER then
                self:EmitSound(istable(self.Sound_MeleeHit) and self.Sound_MeleeHit[math.random(1, #self.Sound_MeleeHit)] or self.Sound_MeleeHit, 80, 110, 1)
            end
        end

        -- tgt:TakeDamageInfo(dmg)

        local atktr = util.TraceLine({
            start = self:GetPos(),
            endpos = tgtpos,
            filter = self
        })

        TacRP.CancelBodyDamage(tgt, dmg, atktr.HitGroup)
        tgt:DispatchTraceAttack(dmg, atktr)
    else
        local ang = data.OurOldVelocity:Angle()
        local fx = EffectData()
        fx:SetOrigin(data.HitPos)
        fx:SetNormal(-ang:Forward())
        fx:SetAngles(-ang)
        util.Effect("ManhackSparks", fx)
        if SERVER then
            self:EmitSound(istable(self.Sound_MeleeHit) and self.Sound_MeleeHit[math.random(1, #self.Sound_MeleeHit)] or self.Sound_MeleeHit, 80, 110, 1)
        end

        -- leave a bullet hole. Also may be able to hit things it can't collide with (like stuck C4)
        self:FireBullets({
            Attacker = attacker,
            Damage = self.Damage,
            Force = 1,
            Distance = 4,
            HullSize = 4,
            Tracer = 0,
            Dir = ang:Forward(),
            Src = data.HitPos - ang:Forward(),
            IgnoreEntity = self,
            Callback = function(atk, tr, dmginfo)
                dmginfo:SetInflictor(IsValid(self.Inflictor) and self.Inflictor or self)
            end
        })
    end

    -- self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

    if self.DamageType == DMG_SLASH and (tgt:IsWorld() or (IsValid(tgt) and tgt:GetPhysicsObject():IsValid())) then
        local angles = data.OurOldVelocity:Angle()
        angles:RotateAroundAxis(self:GetRight(), -90)
        self:GetPhysicsObject():Sleep()

        timer.Simple(0, function()
            if tgt:IsWorld() or (IsValid(tgt) and (!(tgt:IsNPC() or tgt:IsPlayer()) or tgt:Health() > 0)) then
                self:SetSolid(SOLID_NONE)
                self:SetMoveType(MOVETYPE_NONE)

                local f = {self, self:GetOwner()}
                table.Add(f, tgt:GetChildren())
                local tr = util.TraceLine({
                    start = data.HitPos - data.OurOldVelocity,
                    endpos = data.HitPos + data.OurOldVelocity,
                    filter = f,
                    mask = MASK_SOLID,
                    ignoreworld = true,
                })

                local bone = (tr.Entity == tgt) and tr.PhysicsBone == 0
                        and tr.Entity:GetHitBoxBone(tr.HitBox, tr.Entity:GetHitboxSet())
                        or tr.PhysicsBone or -1
                local matrix = tgt:GetBoneMatrix(bone)
                if tr.Entity == tgt and matrix then
                    local bpos = matrix:GetTranslation()
                    local bang = matrix:GetAngles()
                    self:SetPos(data.HitPos)
                    self:FollowBone(tgt, bone)
                    local n_pos, n_ang = WorldToLocal(tr.HitPos + tr.HitNormal * self:GetModelRadius() * 0.5, angles, bpos, bang)
                    self:SetLocalPos(n_pos)
                    self:SetLocalAngles(n_ang)
                    debugoverlay.Cross(pos, 8, 5, Color(255, 0, 255), true)
                else
                    self:SetAngles(angles)
                    self:SetPos(data.HitPos - data.OurOldVelocity:GetNormalized() * self:GetModelRadius() * 0.5)
                    if !tgt:IsWorld() then
                        self:SetParent(tgt)
                    end
                end
            else
                self:GetPhysicsObject():SetVelocityInstantaneous(data.OurNewVelocity * 0.5)
                self:GetPhysicsObject():SetAngleVelocityInstantaneous(data.OurOldAngularVelocity * 0.5)
            end
        end)
    end
    timer.Simple(5, function()
        if IsValid(self) then
            self:SetRenderMode(RENDERMODE_TRANSALPHA)
            self:SetRenderFX(kRenderFxFadeFast)
        end
    end)
    SafeRemoveEntityDelayed(self, 7)

    return true
end

hook.Add("PostEntityTakeDamage", "TacRP_KnifeProj", function(ent)
    if (ent:IsPlayer() or ent:IsNPC()) and ent:Health() < 0 then
        for _, proj in pairs(ent:GetChildren()) do
            if proj:GetClass() == "tacrp_proj_knife" then proj:Remove() end
        end
    end
end)