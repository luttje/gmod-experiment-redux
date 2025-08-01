AddCSLuaFile()

ENT.Base                     = "tacrp_proj_base"
ENT.PrintName                = "40mm LVG"
ENT.Spawnable                = false

ENT.Model                    = "models/weapons/tacint/grenade_40mm.mdl"

ENT.IsRocket = false // projectile has a booster and will not drop.

ENT.InstantFuse = false // projectile is armed immediately after firing.
ENT.RemoteFuse = false // allow this projectile to be triggered by remote detonator.
ENT.ImpactFuse = true // projectile explodes on impact.

ENT.ExplodeOnDamage = false // projectile explodes when it takes damage.
ENT.ExplodeUnderwater = true

ENT.Delay = 0.3

ENT.ExplodeSounds = {
    "^TacRP/weapons/grenade/frag_explode-1.wav",
    "^TacRP/weapons/grenade/frag_explode-2.wav",
    "^TacRP/weapons/grenade/frag_explode-3.wav",
}

ENT.SmokeTrail = true

function ENT:Detonate()
    local attacker = self.Attacker or self:GetOwner() or self
    local mult = TacRP.ConVars["mult_damage_explosive"]:GetFloat() * (self.NPCDamage and 0.5 or 1)

    local dmg = DamageInfo()
    dmg:SetAttacker(attacker)
    dmg:SetInflictor(self)
    dmg:SetDamageType(DMG_SONIC)
    dmg:SetDamagePosition(self:GetPos())
    dmg:SetDamage(100 * mult)
    util.BlastDamageInfo(dmg, self:GetPos(), 300)
    dmg:SetDamage(10)
    util.BlastDamageInfo(dmg, self:GetPos(), 512)

    local fx = EffectData()
    fx:SetOrigin(self:GetPos())

    if self:WaterLevel() > 0 then
        util.Effect("WaterSurfaceExplosion", fx)
    else
        fx:SetRadius(512)
        util.Effect("TacRP_flashexplosion", fx)
        util.Effect("HelicopterMegaBomb", fx)
    end

    TacRP.Flashbang(self, self:GetPos(), 1024, 2.5, 0.25, 1)

    self:EmitSound(table.Random(self.ExplodeSounds), 125, 110)
    self:EmitSound("TacRP/weapons/grenade/flashbang_explode-1.wav", 125, 90, 0.8)

    self:Remove()
end

function ENT:Impact()
    self:EmitSound("weapons/rpg/shotdown.wav", 90, 115)
end