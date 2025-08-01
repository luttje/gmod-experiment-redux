ATT.PrintName = "Throw"
ATT.FullName = "Knife Throw"
ATT.Icon = Material("entities/tacrp_att_melee_tech_throw.png", "mips smooth")
ATT.Description = "Bar trick turned lethal."
ATT.Pros = {"ALT-FIRE: Throw knife", "Does not consume weapon or ammo", "Bonus damage on headshot", "Bonus damage on slowed/stunned targets"}

ATT.Category = {"melee_tech"}

ATT.SortOrder = 3

ATT.ThrowAttack = true

ATT.Hook_SecondaryAttack = function(self)

    if self:StillWaiting() or self:GetNextSecondaryFire() > CurTime() then return end

    local s = self:GetValue("MeleeAttackTime") * 3 * self:GetMeleePerkCooldown()
    self:PlayAnimation("meleethrow", s, false, true)
    --self:GetOwner():DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_THROW)
    self:GetOwner():DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)

    self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, 120, 1)

    self:SetTimer(0.15, function()
        if CLIENT then return end

        local rocket = ents.Create("tacrp_proj_knife")

        if !IsValid(rocket) then return end

        local src, ang = self:GetOwner():GetShootPos(), self:GetShootDir() --+ Angle(-1, 0, 0)
        local spread = 0
        local force = self:GetMeleePerkVelocity()
        local dispersion = Angle(math.Rand(-1, 1), math.Rand(-1, 1), 0)
        dispersion = dispersion * spread * 36

        rocket.Model = self.ThrownKnifeModel or self.WorldModel
        rocket.Damage = self:GetValue("MeleeDamage") * self:GetMeleePerkDamage()
        rocket.Inflictor = self
        rocket.DamageType = self:GetValue("MeleeDamageType")
        rocket.Sound_MeleeHit = istable(self.Sound_MeleeHit) and table.Copy(self.Sound_MeleeHit) or self.Sound_MeleeHit
        rocket.Sound_MeleeHitBody = istable(self.Sound_MeleeHitBody) and table.Copy(self.Sound_MeleeHitBody) or self.Sound_MeleeHitBody

        rocket:SetPos(src)
        rocket:SetOwner(self:GetOwner())
        rocket:SetAngles(ang + dispersion)
        rocket:Spawn()
        rocket:SetPhysicsAttacker(self:GetOwner(), 10)

        local phys = rocket:GetPhysicsObject()

        if phys:IsValid() then
            phys:ApplyForceCenter((ang + dispersion):Forward() * force + self:GetOwner():GetVelocity())
            phys:SetAngleVelocityInstantaneous(VectorRand() * 10 + Vector(0, 1800, 0))
        end
    end)

    local throwtimewait = math.max(0, s - 0.75) --self:GetValue("MeleeThrowTimeWait")
    self:SetTimer(throwtimewait, function()
        self:PlayAnimation("deploy", 1, false, true)
    end)

    self:SetNextSecondaryFire(CurTime() + s)
    return true
end


ATT.Hook_GetHintCapabilities = function(self, tbl)
    tbl["+attack2"] = {so = 0.1, str = "Knife Throw"}
end