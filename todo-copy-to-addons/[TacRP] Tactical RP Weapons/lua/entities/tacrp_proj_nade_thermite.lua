AddCSLuaFile()

ENT.Base                     = "tacrp_proj_base"
ENT.PrintName                = "Thermite Grenade"
ENT.Spawnable                = false

ENT.Model                    = "models/weapons/tacint/smoke.mdl"

ENT.Material = "models/tacint/weapons/w_models/smoke/thermite-1"

ENT.IsRocket = false // projectile has a booster and will not drop.

ENT.InstantFuse = true // projectile is armed immediately after firing.
ENT.RemoteFuse = false // allow this projectile to be triggered by remote detonator.
ENT.ImpactFuse = false // projectile explodes on impact.

ENT.ExplodeOnDamage = false // projectile explodes when it takes damage.
ENT.ExplodeUnderwater = true

ENT.Delay = 2

ENT.ExplodeSounds = {
    "TacRP/weapons/grenade/frag_explode-1.wav",
    "TacRP/weapons/grenade/frag_explode-2.wav",
    "TacRP/weapons/grenade/frag_explode-3.wav",
}

function ENT:Detonate()
    if self:WaterLevel() > 0 then self:Remove() return end
    local attacker = self.Attacker or self:GetOwner() or self

    -- local dmg = 50
    -- if self.ImpactFuse then dmg = dmg * 0.5 end
    -- util.BlastDamage(self, attacker, self:GetPos(), 350, dmg)

    self:EmitSound("ambient/fire/gascan_ignite1.wav", 80, 110)

    local cloud = ents.Create( "TacRP_fire_cloud" )

    if !IsValid(cloud) then return end

    local t = 8
    if self.ImpactFuse then t = t * 0.5 end

    cloud.FireTime = t
    cloud:SetPos(self:GetPos())
    cloud:SetAngles(self:GetAngles())
    cloud:SetOwner(attacker)
    cloud:Spawn()

    self:Remove()
end

ENT.NextDamageTick = 0