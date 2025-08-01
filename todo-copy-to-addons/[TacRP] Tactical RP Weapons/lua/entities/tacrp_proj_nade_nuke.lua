AddCSLuaFile()

ENT.Base                     = "tacrp_proj_base"
ENT.PrintName                = "Nuke"
ENT.Spawnable                = false

ENT.Model                    = "models/weapons/tacint/props_misc/briefcase_bomb-1.mdl"

ENT.Sticky = false

ENT.IsRocket = false // projectile has a booster and will not drop.

ENT.InstantFuse = false // projectile is armed immediately after firing.
ENT.RemoteFuse = true // allow this projectile to be triggered by remote detonator.
ENT.ImpactFuse = false // projectile explodes on impact.

ENT.ExplodeOnDamage = true // projectile explodes when it takes damage.
ENT.ExplodeUnderwater = false

ENT.Defusable = true
ENT.PickupAmmo = "ti_nuke"

ENT.Delay = 0.5

ENT.ExplodeSounds = {
    "ambient/explosions/explode_6.wav"
}

function ENT:Detonate()
    local attacker = self.Attacker or self:GetOwner() or self

    local fx = EffectData()
    fx:SetOrigin(self:GetPos())

    if self:WaterLevel() > 0 then
        self:Remove()
        return
    else
        util.Effect("TacRP_nukeexplosion", fx)
    end

    util.BlastDamage(self, attacker, self:GetPos(), 1024, 100000)

    local cloud = ents.Create( "TacRP_nuke_cloud" )

    if !IsValid(cloud) then return end

    cloud:SetPos(self:GetPos())
    cloud:SetOwner(attacker)
    cloud:Spawn()

    self:EmitSound(table.Random(self.ExplodeSounds), 149)

    self:Remove()
end