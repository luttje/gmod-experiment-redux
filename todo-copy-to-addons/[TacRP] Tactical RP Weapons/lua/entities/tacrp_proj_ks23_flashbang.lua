AddCSLuaFile()

ENT.Base                     = "tacrp_proj_base"
ENT.PrintName                = "KS-23 Flashbang"
ENT.Spawnable                = false

ENT.Model                    = "models/weapons/tacint/grenade_40mm.mdl"

ENT.IsRocket = false // projectile has a booster and will not drop.

ENT.InstantFuse = true // projectile is armed immediately after firing.
ENT.RemoteFuse = false // allow this projectile to be triggered by remote detonator.
ENT.ImpactFuse = false // projectile explodes on impact.

ENT.ExplodeOnDamage = false // projectile explodes when it takes damage.
ENT.ExplodeUnderwater = true
ENT.ExplodeOnImpact = true

ENT.Delay = 0.2

ENT.ExplodeSounds = {
    "TacRP/weapons/grenade/flashbang_explode-1.wav",
}

ENT.AudioLoop = ""

ENT.SmokeTrail = false

function ENT:Detonate()
    // util.BlastDamage(self, self:GetOwner(), self:GetPos(), 150, 25)

    local fx = EffectData()
    fx:SetOrigin(self:GetPos())

    if self:WaterLevel() > 0 then
        util.Effect("WaterSurfaceExplosion", fx)
        self:Remove()
        return
    else
        fx:SetRadius(328)
        util.Effect("TacRP_flashexplosion", fx)
    end

    TacRP.Flashbang(self, self:GetPos(), 328, 1, 0.1, 0.3)

    self:EmitSound(table.Random(self.ExplodeSounds), 125)

    self:Remove()
end