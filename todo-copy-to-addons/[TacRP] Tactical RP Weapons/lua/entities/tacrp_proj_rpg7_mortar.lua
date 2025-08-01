AddCSLuaFile()

ENT.Base                     = "tacrp_proj_base"
ENT.PrintName                = "RPG-7 Mortar Rocket"
ENT.Spawnable                = false

ENT.Model                    = "models/weapons/tacint/rocket_deployed.mdl"

ENT.IsRocket = true

ENT.InstantFuse = false
ENT.RemoteFuse = false
ENT.ImpactFuse = true

ENT.ExplodeOnDamage = true
ENT.ExplodeUnderwater = true

ENT.Delay = 0
ENT.SafetyFuse = 0.7
ENT.BoostTime = 0.25

ENT.AudioLoop = "TacRP/weapons/rpg7/rocket_flight-1.wav"

ENT.SmokeTrail = true

ENT.FlareColor = Color(255, 50, 0)

DEFINE_BASECLASS(ENT.Base)

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Weapon")
    self:NetworkVar("Bool", 0, "NoBooster")
end

function ENT:Initialize()
    BaseClass.Initialize(self)

    if SERVER then
        -- self:SetAngles(self:GetAngles() + Angle(-5, 0, 0))
        local phys = self:GetPhysicsObject()
        phys:SetMass(30)
        phys:SetDragCoefficient(1)
        phys:SetVelocity(self:GetForward() * 4000)
    end
end


function ENT:Impact(data, collider)
    if self.SpawnTime + self.BoostTime > CurTime() and !self.NPCDamage then
        local attacker = self.Attacker or self:GetOwner()
        local ang = data.OurOldVelocity:Angle()
        local fx = EffectData()
        fx:SetOrigin(data.HitPos)
        fx:SetNormal(-ang:Forward())
        fx:SetAngles(-ang)
        util.Effect("ManhackSparks", fx)

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

        self:EmitSound("weapons/rpg/shotdown.wav", 80)

        for i = 1, 4 do
            local prop = ents.Create("prop_physics")
            prop:SetPos(self:GetPos())
            prop:SetAngles(self:GetAngles())
            prop:SetModel("models/weapons/tacint/rpg7_shrapnel_p" .. i .. ".mdl")
            prop:Spawn()
            prop:GetPhysicsObject():SetVelocityInstantaneous(data.OurNewVelocity * 0.5 + VectorRand() * 75)
            prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

            SafeRemoveEntityDelayed(prop, 3)
        end

        self:Remove()
        return true
    end
end


function ENT:Detonate()
    local attacker = self.Attacker or self:GetOwner()

    local fx = EffectData()
    fx:SetOrigin(self:GetPos())

    local mult = TacRP.ConVars["mult_damage_explosive"]:GetFloat()

    if self.NPCDamage then
        if self:WaterLevel() > 0 then
            util.Effect("WaterSurfaceExplosion", fx)
        else
            util.Effect("HelicopterMegaBomb", fx)
        end
        util.BlastDamage(self, attacker, self:GetPos(), 512, 150 * mult)
    else
        if self.SpawnTime + self.SafetyFuse >= CurTime() then
            if self:WaterLevel() > 0 then
                util.Effect("WaterSurfaceExplosion", fx)
            else
                util.Effect("HelicopterMegaBomb", fx)
            end
            util.BlastDamage(self, attacker, self:GetPos(), 256, 100 * mult)
        else
            if self:WaterLevel() > 0 then
                util.Effect("WaterSurfaceExplosion", fx)
            else
                util.Effect("Explosion", fx)
            end
            self:EmitSound("^ambient/explosions/explode_3.wav", 100, 90, 0.75, CHAN_AUTO)
            util.BlastDamage(self, attacker, self:GetPos(), 200, 300 * mult)
            util.BlastDamage(self, attacker, self:GetPos(), 328, 120 * mult)
            util.BlastDamage(self, attacker, self:GetPos(), 768, 80 * mult)
            local count = 8
            for i = 1, count do
                local tr = util.TraceLine({
                    start = self:GetPos(),
                    endpos = self:GetPos() + Angle(0, i / count * 360, 0):Forward() * 328 * math.Rand(0.75, 1),
                    mask = MASK_SHOT,
                    filter = self,
                })
                fx:SetOrigin(tr.HitPos)
                util.Effect("HelicopterMegaBomb", fx)
            end
        end
    end
    self:EmitSound("TacRP/weapons/rpg7/explode.wav", 125, 95)

    self:Remove()
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
        self:GetPhysicsObject():SetVelocityInstantaneous(self:GetVelocity() * 0.5)
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

        if CurTime() >= (self.SpawnTime + self.SafetyFuse) and !self.Sparked then
            self.Sparked = true
            for i = 1, 15 do
                local fire = emitter:Add("effects/spark", self:GetPos())
                fire:SetVelocity(VectorRand() * 512 + self:GetVelocity() * 0.25)
                fire:SetGravity(Vector(math.Rand(-5, 5), math.Rand(-5, 5), -1000))
                fire:SetDieTime(math.Rand(0.2, 0.4))
                fire:SetStartAlpha(255)
                fire:SetEndAlpha(0)
                fire:SetStartSize(8)
                fire:SetEndSize(0)
                fire:SetRoll(math.Rand(-180, 180))
                fire:SetRollDelta(math.Rand(-0.2, 0.2))
                fire:SetColor(255, 255, 255)
                fire:SetAirResistance(50)
                fire:SetLighting(false)
                fire:SetCollide(true)
                fire:SetBounce(0.8)
            end
        end

        emitter:Finish()

        self.LastNoBooster = self:GetNoBooster()
    end

    self:OnThink()
end

local g = Vector(0, 0, -9.81)
function ENT:PhysicsUpdate(phys)
    if phys:IsGravityEnabled() then
        local v = phys:GetVelocity()
        self:SetAngles(v:Angle())
        phys:SetVelocityInstantaneous(v + g)
    end

    -- local v = phys:GetVelocity()
    -- self:SetAngles(v:Angle() + Angle(2, 0, 0))
    -- phys:SetVelocityInstantaneous(self:GetForward() * v:Length())
end

local mat = Material("effects/ar2_altfire1b")

function ENT:Draw()
    self:DrawModel()

    if self.FlareColor and !self:GetNoBooster() then
        render.SetMaterial(mat)
        render.DrawSprite(self:GetPos() + (self:GetAngles():Forward() * -16), math.Rand(100, 150), math.Rand(100, 150), self.FlareColor)
    end
end