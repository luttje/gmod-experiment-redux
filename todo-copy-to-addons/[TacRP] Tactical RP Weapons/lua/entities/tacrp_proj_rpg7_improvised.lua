AddCSLuaFile()

ENT.Base                     = "tacrp_proj_base"
ENT.PrintName                = "RPG-7 Improvised Rocket"
ENT.Spawnable                = false

ENT.Model                    = "models/weapons/tacint/rocket_deployed.mdl"

ENT.IsRocket = true // projectile has a booster and will not drop.

ENT.InstantFuse = false // projectile is armed immediately after firing.
ENT.RemoteFuse = false // allow this projectile to be triggered by remote detonator.
ENT.ImpactFuse = true // projectile explodes on impact.

ENT.ExplodeOnDamage = true
ENT.ExplodeUnderwater = true

ENT.Delay = 0
ENT.SafetyFuse = 0
ENT.BoostTime = 5

ENT.AudioLoop = "TacRP/weapons/rpg7/rocket_flight-1.wav"

ENT.SmokeTrail = true

ENT.FlareColor = Color(255, 255, 75)

DEFINE_BASECLASS(ENT.Base)

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "NoBooster")
    self:NetworkVar("Entity", 0, "Weapon")
end

function ENT:Initialize()
    BaseClass.Initialize(self)

    if SERVER then
        local phys = self:GetPhysicsObject()
        local rng = math.random()
        if rng <= 0.01 then
            self:EmitSound("weapons/rpg/shotdown.wav", 80, 95)
            local fx = EffectData()
            fx:SetOrigin(self:GetPos() + self:GetForward() * 32)
            fx:SetStart(Vector(math.Rand(0, 255), math.Rand(0, 255), math.Rand(0, 255)))
            util.Effect("balloon_pop", fx)
            self:GetOwner():EmitSound("tacrp/kids_cheering.mp3", 100, 100, 1)
            SafeRemoveEntity(self)
        elseif rng <= 0.25 then
            self.BoostTime = math.Rand(0.5, 5)

            self:EmitSound("weapons/rpg/shotdown.wav", 80, 95)

            self:SetNoBooster(math.random() <= 0.2)
            phys:EnableGravity(true)

            if self:GetNoBooster() then
                phys:SetVelocityInstantaneous(self:GetOwner():GetVelocity() + self:GetForward() * math.Rand(25, 75) + self:GetUp() * math.Rand(75, 150))
            else
                phys:SetVelocityInstantaneous(self:GetOwner():GetVelocity() + self:GetForward() * math.Rand(100, 500) + self:GetUp() * math.Rand(50, 200))
            end
            phys:AddAngleVelocity(VectorRand() * 180)
        else
            self.BoostTime = math.Rand(1, 3)
            phys:SetVelocityInstantaneous(self:GetForward() * math.Rand(3000, 6000))
        end
    end
end

function ENT:Impact(data, collider)
    if self.Impacted then return end
    self.Impacted = true

    local attacker = self.Attacker or self:GetOwner() or self
    if IsValid(data.HitEntity) then
        local dmginfo = DamageInfo()
        dmginfo:SetAttacker(attacker)
        dmginfo:SetInflictor(self)
        dmginfo:SetDamageType(DMG_CRUSH + DMG_CLUB)
        dmginfo:SetDamage(250 * (self.NPCDamage and 0.5 or 1))
        dmginfo:SetDamageForce(data.OurOldVelocity * 25)
        dmginfo:SetDamagePosition(data.HitPos)
        data.HitEntity:TakeDamageInfo(dmginfo)
    end
end


function ENT:Detonate()
    local attacker = self.Attacker or self:GetOwner()

    if math.random() <= 0.05 then
        self:EmitSound("physics/metal/metal_barrel_impact_hard3.wav", 125, 115)
        local fx = EffectData()
        fx:SetOrigin(self:GetPos())
        fx:SetMagnitude(4)
        fx:SetScale(4)
        fx:SetRadius(4)
        fx:SetNormal(self:GetVelocity():GetNormalized())
        util.Effect("Sparks", fx)

        for i = 1, 4 do
            local prop = ents.Create("prop_physics")
            prop:SetPos(self:GetPos())
            prop:SetAngles(self:GetAngles())
            prop:SetModel("models/weapons/tacint/rpg7_shrapnel_p" .. i .. ".mdl")
            prop:Spawn()
            prop:GetPhysicsObject():SetVelocityInstantaneous(self:GetVelocity() * 0.5 + VectorRand() * 75)
            prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

            SafeRemoveEntityDelayed(prop, 3)
        end

        self:Remove()
        return
    end

    local mult = TacRP.ConVars["mult_damage_explosive"]:GetFloat()
    if self.NPCDamage then
        util.BlastDamage(self, attacker, self:GetPos(), 350, 100)
    else
        // util.BlastDamage(self, attacker, self:GetPos(), 128, math.Rand(300, 700))
        util.BlastDamage(self, attacker, self:GetPos(), 400, math.Rand(100, 150) * mult)
        self:FireBullets({
            Attacker = attacker,
            Damage = math.Rand(500, 1000) * mult,
            Tracer = 0,
            Src = self:GetPos(),
            Dir = self:GetForward(),
            HullSize = 0,
            Distance = 32,
            IgnoreEntity = self,
            Callback = function(atk, btr, dmginfo)
                dmginfo:SetDamageType(DMG_AIRBOAT + DMG_BLAST) // airboat damage for helicopters and LVS vehicles
                dmginfo:SetDamageForce(self:GetForward() * math.Rand(10000, 20000)) // LVS uses this to calculate penetration!
            end,
        })
    end

    local fx = EffectData()
    fx:SetOrigin(self:GetPos())

    if self:WaterLevel() > 0 then
        util.Effect("WaterSurfaceExplosion", fx)
    else
        util.Effect("Explosion", fx)
    end

    self:EmitSound("TacRP/weapons/rpg7/explode.wav", 125)

    self:Remove()
end

function ENT:PhysicsUpdate(phys)
    if self:GetNoBooster() then return end
    local len = phys:GetVelocity():Length()
    local f = math.Clamp(len / 5000, 0, 1)
    if phys:IsGravityEnabled() then
        phys:AddVelocity(self:GetForward() * math.Rand(0, Lerp(f, 100, 10)))
        phys:AddAngleVelocity(VectorRand() * Lerp(f, 8, 2))
    elseif self.SpawnTime < CurTime() and len < 500 then
        phys:EnableGravity(true)
    else
        phys:AddVelocity(VectorRand() * Lerp(f, 5, 50) + self:GetForward() * Lerp(f, 10, 0))
    end
end

local smokeimages = {"particle/smokesprites_0001", "particle/smokesprites_0002", "particle/smokesprites_0003", "particle/smokesprites_0004", "particle/smokesprites_0005", "particle/smokesprites_0006", "particle/smokesprites_0007", "particle/smokesprites_0008", "particle/smokesprites_0009", "particle/smokesprites_0010", "particle/smokesprites_0011", "particle/smokesprites_0012", "particle/smokesprites_0013", "particle/smokesprites_0014", "particle/smokesprites_0015", "particle/smokesprites_0016"}

local function GetSmokeImage()
    return smokeimages[math.random(#smokeimages)]
end

function ENT:Think()
    if !IsValid(self) or self:GetNoDraw() then return end

    if !self.SpawnTime then
        self.SpawnTime = CurTime()
    end

    if !self.Armed and isnumber(self.TimeFuse) and self.SpawnTime + self.TimeFuse < CurTime() then
        self.ArmTime = CurTime()
        self.Armed = true
    end

    if self.Armed and self.ArmTime + self.Delay < CurTime() then
        self:PreDetonate()
    end

    if SERVER and !self:GetNoBooster() and self.SpawnTime + self.BoostTime < CurTime() then
        self:SetNoBooster(true)
        self:GetPhysicsObject():EnableGravity(true)
    end

    if self.LoopSound and self:GetNoBooster() then
        self.LoopSound:Stop()
    end

    if self.ExplodeUnderwater and self:WaterLevel() > 0 then
        self:PreDetonate()
    end

    if self.SmokeTrail and CLIENT then
        local emitter = ParticleEmitter(self:GetPos())
        if !self:GetNoBooster() then
            local smoke = emitter:Add(GetSmokeImage(), self:GetPos())

            smoke:SetStartAlpha(50)
            smoke:SetEndAlpha(0)

            smoke:SetStartSize(10)
            smoke:SetEndSize(math.Rand(50, 75))

            smoke:SetRoll(math.Rand(-180, 180))
            smoke:SetRollDelta(math.Rand(-1, 1))

            smoke:SetPos(self:GetPos())
            smoke:SetVelocity(-self:GetAngles():Forward() * 400 + (VectorRand() * 10))

            smoke:SetColor(200, 200, 200)
            smoke:SetLighting(true)

            smoke:SetDieTime(math.Rand(0.75, 1.25))

            smoke:SetGravity(Vector(0, 0, 0))

        elseif !self.LastNoBooster then

            for i = 1, 10 do
                local smoke = emitter:Add(GetSmokeImage(), self:GetPos())
                smoke:SetStartAlpha(50)
                smoke:SetEndAlpha(0)
                smoke:SetStartSize(25)
                smoke:SetEndSize(math.Rand(100, 150))
                smoke:SetRoll(math.Rand(-180, 180))
                smoke:SetRollDelta(math.Rand(-1, 1))
                smoke:SetPos(self:GetPos())
                smoke:SetVelocity(VectorRand() * 200)
                smoke:SetColor(200, 200, 200)
                smoke:SetLighting(true)
                smoke:SetDieTime(math.Rand(0.75, 1.75))
                smoke:SetGravity(Vector(0, 0, -200))
            end
        else
            local smoke = emitter:Add(GetSmokeImage(), self:GetPos())

            smoke:SetStartAlpha(30)
            smoke:SetEndAlpha(0)

            smoke:SetStartSize(10)
            smoke:SetEndSize(math.Rand(25, 50))

            smoke:SetRoll(math.Rand(-180, 180))
            smoke:SetRollDelta(math.Rand(-1, 1))

            smoke:SetPos(self:GetPos())
            smoke:SetVelocity(VectorRand() * 10)

            smoke:SetColor(150, 150, 150)
            smoke:SetLighting(true)

            smoke:SetDieTime(math.Rand(0.2, 0.3))

            smoke:SetGravity(Vector(0, 0, 0))
        end
        emitter:Finish()

        self.LastNoBooster = self:GetNoBooster()

    end


    self:OnThink()
end

local mat = Material("effects/ar2_altfire1b")

function ENT:Draw()
    self:DrawModel()

    if self.FlareColor and !self:GetNoBooster() then
        render.SetMaterial(mat)
        render.DrawSprite(self:GetPos() + (self:GetAngles():Forward() * -16), math.Rand(100, 150), math.Rand(100, 150), self.FlareColor)
    end
end