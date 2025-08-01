ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Nuclear Radiation"
ENT.Author = ""
ENT.Information = ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.Life = 10

ENT.MaxRadius = 7500

ENT.TacRPSmoke = true

AddCSLuaFile()

function ENT:Initialize()
    if SERVER then
        self:SetModel( "models/weapons/w_eq_smokegrenade_thrown.mdl" )
        self:SetMoveType( MOVETYPE_NONE )
        self:SetSolid( SOLID_NONE )
        self:DrawShadow( false )
    end

    self.SpawnTime = CurTime()
    self.dt = CurTime() + self.Life

    util.ScreenShake(self:GetPos(), 16, 30, self.Life, self.MaxRadius)

    if CLIENT then return end

    for i, k in pairs(ents.FindInSphere(self:GetPos(), self.MaxRadius)) do
        if k:GetClass() == "func_breakable_surf" then
            k:Fire("shatter", "", 0)
        elseif k:GetClass() == "func_breakable" then
            k:Fire("break", "", 0)
        end

        local phys = k:GetPhysicsObject()

        if IsValid(phys) then
            local vec = (k:GetPos() - self:GetPos()) * 500
            phys:ApplyForceCenter(vec)
        end
    end
end

function ENT:RadiationAttack()
    local d = (CurTime() - self.SpawnTime) / self.Life
    local radius = self.MaxRadius * d

    local dmg = DamageInfo()
    dmg:SetDamage((1 - d) * 5000)
    dmg:SetDamageType(DMG_RADIATION)
    dmg:SetDamagePosition(self:GetPos())
    dmg:SetAttacker(self:GetOwner() or self.Attacker)
    dmg:SetInflictor(self)

    for i, k in pairs(ents.FindInSphere(self:GetPos(), radius)) do
        if !IsValid(k) then continue end
        constraint.RemoveAll(k)
        k:TakeDamageInfo(dmg)

    end
end

function ENT:Think()
    if SERVER then
        if !self:GetOwner():IsValid() then self:Remove() return end

        self:RadiationAttack()

        self:NextThink(CurTime() + 1)

        if self.dt < CurTime() then
            SafeRemoveEntity(self)
        end
    end

    return true
end

function ENT:Draw()
    return false
end