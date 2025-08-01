AddCSLuaFile()

ENT.Type                     = "anim"
ENT.Base                     = "base_entity"
ENT.RenderGroup              = RENDERGROUP_TRANSLUCENT

ENT.PrintName                = "Dropped Magazine"
ENT.Category                 = ""

ENT.Spawnable                = false
ENT.Model                    = ""
ENT.FadeTime = 5
ENT.CanHavePrints = true -- TTT

ENT.ImpactSounds = {
    ["pistol"] = {
        "TacRP/weapons/drop_magazine_pistol-1.wav",
        "TacRP/weapons/drop_magazine_pistol-2.wav",
        "TacRP/weapons/drop_magazine_pistol-3.wav",
        "TacRP/weapons/drop_magazine_pistol-4.wav",
        "TacRP/weapons/drop_magazine_pistol-5.wav",
    },
    ["metal"] = {
        "TacRP/weapons/drop_magazine_metal-1.wav",
        "TacRP/weapons/drop_magazine_metal-2.wav",
        "TacRP/weapons/drop_magazine_metal-3.wav",
        "TacRP/weapons/drop_magazine_metal-4.wav",
    },
    ["plastic"] = {
        "TacRP/weapons/drop_magazine_plastic-1.wav",
        "TacRP/weapons/drop_magazine_plastic-2.wav"
    },
    ["bullet"] = {
        "player/pl_shell1.wav",
        "player/pl_shell2.wav",
        "player/pl_shell3.wav"
    },
    ["shotgun"] = {
        "weapons/fx/tink/shotgun_shell1.wav",
        "weapons/fx/tink/shotgun_shell2.wav",
        "weapons/fx/tink/shotgun_shell3.wav",
    },
    ["spoon"] = {
        "TacRP/weapons/grenade/spoon_bounce-1.wav",
        "TacRP/weapons/grenade/spoon_bounce-2.wav",
        "TacRP/weapons/grenade/spoon_bounce-3.wav",
    }
}

ENT.ImpactType = "pistol"

ENT.AmmoType = nil
ENT.AmmoCount = nil

function ENT:Initialize()
    self:SetModel(self.Model)

    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        self:SetUseType(SIMPLE_USE)

        self:PhysWake()

        local phys = self:GetPhysicsObject()
        if !phys:IsValid() then
            self:PhysicsInitBox(Vector(-1, -1, -1), Vector(1, 1, 1))
        end
    end

    self.SpawnTime = CurTime()
    if engine.ActiveGamemode() == "terrortown" and TacRP.ConVars["ttt_magazine_dna"]:GetBool() then
        self.FadeTime = 600
        if SERVER then
            self.fingerprints = {}
            table.insert(self.fingerprints, self:GetOwner())
        end
    end

    if self.AmmoType and self.AmmoCount then
        self.FadeTime = math.max(self.FadeTime, 120)
        self:SetOwner(NULL) -- Owner can't +USE their own entities
    end
end

function ENT:PhysicsCollide(colData, collider)
    if colData.DeltaTime < 0.5 then return end

    local tbl = self.ImpactSounds[self.ImpactType]

    local snd = ""

    if tbl then
        snd = table.Random(tbl)
    end

    self:EmitSound(snd)
end

function ENT:Think()
    if !self.SpawnTime then
        self.SpawnTime = CurTime()
    end

    if SERVER and (self.SpawnTime + self.FadeTime) <= CurTime() then

        self:SetRenderFX( kRenderFxFadeFast )

        if (self.SpawnTime + self.FadeTime + 1) <= CurTime() then

            if IsValid(self:GetPhysicsObject()) then
                self:GetPhysicsObject():EnableMotion(false)
            end

            if SERVER then
                if (self.SpawnTime + self.FadeTime + 1.5) <= CurTime() then
                    self:Remove()
                    return
                end
            end
        end
    end
end

function ENT:Use(ply)
    if self.AmmoType and (self.AmmoCount or 0) > 0 and (self.SpawnTime + 0.5 <= CurTime()) then
        local given = ply:GiveAmmo(self.AmmoCount, self.AmmoType)
        self.AmmoCount = self.AmmoCount - given
        if self.AmmoCount <= 0 then
            self:Remove()
        end
    end
end

function ENT:DrawTranslucent()
    self:Draw()
end

function ENT:Draw()
    self:DrawModel()
end