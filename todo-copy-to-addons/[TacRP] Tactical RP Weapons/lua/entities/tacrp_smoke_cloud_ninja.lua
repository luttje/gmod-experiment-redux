ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Smoke Cloud"
ENT.Author = ""
ENT.Information = ""
ENT.Spawnable = false
ENT.AdminSpawnable = false

local smokeimages = {"particle/smokesprites_0001", "particle/smokesprites_0002", "particle/smokesprites_0003", "particle/smokesprites_0004", "particle/smokesprites_0005", "particle/smokesprites_0006", "particle/smokesprites_0007", "particle/smokesprites_0008", "particle/smokesprites_0009", "particle/smokesprites_0010", "particle/smokesprites_0011", "particle/smokesprites_0012", "particle/smokesprites_0013", "particle/smokesprites_0014", "particle/smokesprites_0015", "particle/smokesprites_0016"}

local function GetSmokeImage()
    return smokeimages[math.random(#smokeimages)]
end

ENT.TacRPSmoke = true
ENT.Particles = nil
ENT.SmokeRadius = 256
ENT.SmokeColor = Color(220, 220, 220)
ENT.BillowTime = 0.5
ENT.Life = 8

AddCSLuaFile()

function ENT:Initialize()
    if SERVER then
        self:SetModel( "models/weapons/w_eq_smokegrenade_thrown.mdl" )
        self:SetMoveType( MOVETYPE_NONE )
        self:SetSolid( SOLID_NONE )
        self:DrawShadow( false )
    else

        table.insert(TacRP.ClientSmokeCache, self)

        local emitter = ParticleEmitter(self:GetPos())

        self.Particles = {}

        local amt = 20

        for i = 1, amt do
            local smoke = emitter:Add(GetSmokeImage(), self:GetPos())
            smoke:SetVelocity( VectorRand() * 8 + (Angle(0, i * (360 / amt), 0):Forward() * 220) )
            smoke:SetStartAlpha( 0 )
            smoke:SetEndAlpha( 255 )
            smoke:SetStartSize( 0 )
            smoke:SetEndSize( self.SmokeRadius )
            smoke:SetRoll( math.Rand(-180, 180) )
            smoke:SetRollDelta( math.Rand(-0.2,0.2) )
            smoke:SetColor( self.SmokeColor.r, self.SmokeColor.g, self.SmokeColor.b )
            smoke:SetAirResistance( 75 )
            smoke:SetPos( self:GetPos() )
            smoke:SetCollide( true )
            smoke:SetBounce( 0.2 )
            smoke:SetLighting( false )
            smoke:SetNextThink( CurTime() + FrameTime() )
            smoke.bt = CurTime() + self.BillowTime
            smoke.dt = CurTime() + self.BillowTime + self.Life
            smoke.ft = CurTime() + self.BillowTime + self.Life + math.Rand(1, 3)
            smoke:SetDieTime(smoke.ft)
            smoke.life = self.Life
            smoke.billowed = false
            smoke.radius = self.SmokeRadius
            smoke:SetThinkFunction( function(pa)
                if !pa then return end

                local prog = 1
                local alph = 0

                if pa.ft < CurTime() then
                    // pass
                elseif pa.dt < CurTime() then
                    local d = (CurTime() - pa.dt) / (pa.ft - pa.dt)

                    alph = 1 - d
                elseif pa.bt < CurTime() then
                    alph = 1
                else
                    local d = math.Clamp(pa:GetLifeTime() / (pa.bt - CurTime()), 0, 1)

                    prog = (-d ^ 2) + (2 * d)

                    alph = d
                end

                pa:SetEndSize( pa.radius * prog )
                pa:SetStartSize( pa.radius * prog )

                pa:SetStartAlpha(255 * alph)
                pa:SetEndAlpha(255 * alph)

                -- pa:SetLifeTime(pa:GetLifeTime() + FrameTime())
                pa:SetNextThink( CurTime() + FrameTime() )
            end )

            table.insert(self.Particles, smoke)
        end

        emitter:Finish()
    end

    self.dt = CurTime() + self.Life + self.BillowTime + 2
end

function ENT:Think()


    if SERVER then
        if !self:GetOwner():IsValid() then self:Remove() return end

        -- local o = self:GetOwner()
        -- local origin = self:GetPos() + Vector(0, 0, 16)

        -- local dmg = DamageInfo()
        -- dmg:SetAttacker(self:GetOwner())
        -- dmg:SetInflictor(self)
        -- dmg:SetDamageType(DMG_NERVEGAS)
        -- dmg:SetDamageForce(Vector(0, 0, 0))
        -- dmg:SetDamagePosition(self:GetPos())
        -- dmg:SetDamageCustom(1024) -- immersive death

        -- util.BlastDamageInfo(dmg, self:GetPos(), 300)

        -- for i, k in pairs(ents.FindInSphere(origin, 300)) do
        --     if k == self:GetOwner() then continue end

        --     if k:IsPlayer() or k:IsNPC() or k:IsNextBot() then
        --         local tr = util.TraceLine({
        --             start = origin,
        --             endpos = k:EyePos() or k:WorldSpaceCenter(),
        --             filter = self,
        --             mask = MASK_SOLID_BRUSHONLY
        --         })
        --         if tr.Fraction < 1 then continue end
        --         local dist = (tr.HitPos - tr.StartPos):Length()
        --         local delta = dist / 320

        --         dmg:SetDamage(k:IsPlayer() and math.Rand(1, 3) or math.Rand(5, 15))

        --         k:TakeDamageInfo(dmg)

        --         if k:IsPlayer() then
        --             k:ScreenFade( SCREENFADE.IN, Color(150, 150, 50, 100), 2 * delta, 0 )

        --             local timername = "tacrp_ninja_gas_" .. k:EntIndex()
        --             local reps = 3

        --             if timer.Exists(timername) then
        --                 reps = math.Clamp(timer.RepsLeft(timername) + 3, reps, 10)
        --                 timer.Remove(timername)
        --             end
        --             timer.Create(timername, 2, reps, function()
        --                 if !IsValid(k) or !k:Alive() then
        --                     timer.Remove(timername)
        --                     return
        --                 end
        --                 k:ScreenFade( SCREENFADE.IN, Color(150, 150, 50, 5), 0.1, 0 )
        --                 if k:Health() > 1 then
        --                     local d = DamageInfo()
        --                     d:SetDamageType(DMG_NERVEGAS)
        --                     d:SetDamage(math.random(1, 2))
        --                     d:SetInflictor(IsValid(self) and self or o)
        --                     d:SetAttacker(o)
        --                     d:SetDamageForce(k:GetForward())
        --                     d:SetDamagePosition(k:GetPos())
        --                     d:SetDamageCustom(1024)
        --                     k:TakeDamageInfo(d)
        --                 else
        --                     k:ViewPunch(Angle(math.Rand(-2, 2), 0, 0))
        --                 end
        --                 if math.random() <= 0.3 then
        --                     k:EmitSound("ambient/voices/cough" .. math.random(1, 4) .. ".wav", 80, math.Rand(95, 105))
        --                 end
        --             end)

        --             if math.random() <= 0.3 then
        --                 k:EmitSound("ambient/voices/cough" .. math.random(1, 4) .. ".wav", 80, math.Rand(95, 105))
        --             end
        --         elseif k:IsNPC() then
        --             k:SetSchedule(SCHED_STANDOFF)
        --         end
        --     end
        -- end

        -- self:NextThink(CurTime() + 1)

        if self.dt < CurTime() then
            SafeRemoveEntity(self)
        end

        return true

    end
end

function ENT:OnRemove()
    if CLIENT then
        timer.Simple(0, function()
            if !IsValid(self) then
                table.RemoveByValue(TacRP.ClientSmokeCache, self)
            end
        end)
    end
end

function ENT:Draw()
    return false
end