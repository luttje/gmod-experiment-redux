AddCSLuaFile()

ENT.Base                     = "tacrp_proj_base"
ENT.PrintName                = "C4"
ENT.Spawnable                = false

ENT.Model                    = "models/weapons/tacint/c4_charge-1.mdl"

ENT.Sticky = true

ENT.IsRocket = false // projectile has a booster and will not drop.

ENT.InstantFuse = false // projectile is armed immediately after firing.
ENT.RemoteFuse = true // allow this projectile to be triggered by remote detonator.
ENT.ImpactFuse = false // projectile explodes on impact.

ENT.ExplodeOnDamage = false // projectile explodes when it takes damage.
ENT.ExplodeUnderwater = false

ENT.Defusable = true
ENT.DefuseOnDamage = true

ENT.Delay = 0.5

ENT.PickupAmmo = "ti_c4"

ENT.ExplodeSounds = {
    "TacRP/weapons/breaching_charge-1.wav"
}

function ENT:Detonate()
    local attacker = self.Attacker or self:GetOwner() or self

    local ttt = TacRP.GetBalanceMode() == TacRP.BALANCE_TTT
    local dmg = (ttt and 200 or 400) * TacRP.ConVars["mult_damage_explosive"]:GetFloat()

    util.BlastDamage(self, attacker, self:GetPos(), 256, dmg)
    util.BlastDamage(self, attacker, self:GetPos(), 512, dmg * 0.5)

    local fx = EffectData()
    fx:SetOrigin(self:GetPos())

    if self:WaterLevel() > 0 then
        util.Effect("WaterSurfaceExplosion", fx)
    else
        util.Effect("Explosion", fx)
    end

    self:EmitSound(table.Random(self.ExplodeSounds), 125)

    self:SetParent(NULL)
    for _, door in pairs(ents.FindInSphere(self:GetPos(), 256)) do
        if IsValid(door) and string.find(door:GetClass(), "door") and !door.TacRP_DoorBusted then
            local vel = (door:GetPos() - self:GetPos()):GetNormalized() * 200000
            for _, otherDoor in pairs(ents.FindInSphere(door:GetPos(), 72)) do
                if door != otherDoor and otherDoor:GetClass() == door:GetClass() then
                    TacRP.DoorBust(otherDoor, vel, attacker)
                    break
                end
            end
            TacRP.DoorBust(door, vel, attacker)
        end
    end

    self:Remove()
end

function ENT:Stuck()
    // you are already dead
    if IsValid(self:GetParent()) and self:GetParent():IsPlayer() and !IsValid(self:GetParent().nadescream) then
        self:GetParent().nadescream = self
        self:GetParent():EmitSound("vo/npc/male01/ohno.wav")
    end
end