local images_smoke = {"particle/smokesprites_0001", "particle/smokesprites_0002", "particle/smokesprites_0003", "particle/smokesprites_0004", "particle/smokesprites_0005", "particle/smokesprites_0006", "particle/smokesprites_0007", "particle/smokesprites_0008", "particle/smokesprites_0009", "particle/smokesprites_0010", "particle/smokesprites_0011", "particle/smokesprites_0012", "particle/smokesprites_0013", "particle/smokesprites_0014", "particle/smokesprites_0015", "particle/smokesprites_0016"}

local function TableRandomChoice(tbl)
    return tbl[math.random(#tbl)]
end

local effecttime = 30

function EFFECT:Init(data)
    self.Origin = data:GetOrigin()

    self.SpawnTime = CurTime()

    util.Decal("FadingScorch", self.Origin, self.Origin - Vector(0, 0, 16))

    local emitter = ParticleEmitter( self.Origin + Vector( 0, 0, 16 ) )

    // smoke cloud

    for i = 1,25 do
        local particle = emitter:Add( TableRandomChoice(images_smoke) , self.Origin )
        local scol = math.Rand( 200, 225 )

        particle:SetVelocity( 250 * VectorRand() )
        particle:SetDieTime( math.Rand(0.9, 1.1) * effecttime )
        particle:SetStartAlpha( 255 )
        particle:SetEndAlpha( 0 )
        particle:SetStartSize( math.Rand(300,400) )
        particle:SetEndSize( math.Rand(2000,2500) )
        particle:SetRoll( math.Rand(0,360) )
        particle:SetRollDelta( math.Rand(-1,1) )
        particle:SetColor( scol,scol,scol )
        particle:SetAirResistance( 50 )
        particle:SetGravity( Vector( math.Rand(-250, 250), math.Rand(-250, 250), 500) )
        particle:SetLighting( false )
    end

    // stack

    for i = 1,25 do
        local particle = emitter:Add( TableRandomChoice(images_smoke) , self.Origin )
        local scol = math.Rand( 200, 225 )

        particle:SetVelocity( 250 * VectorRand() )
        particle:SetDieTime( math.Rand(0.9, 1.1) * effecttime )
        particle:SetStartAlpha( 255 )
        particle:SetEndAlpha( 0 )
        particle:SetStartSize( math.Rand(300,400) )
        particle:SetEndSize( math.Rand(1000,1500) )
        particle:SetRoll( math.Rand(0,360) )
        particle:SetRollDelta( math.Rand(-1,1) )
        particle:SetColor( scol,scol,scol )
        particle:SetAirResistance( 50 )
        particle:SetGravity( Vector( math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(0, 500)) )
        particle:SetLighting( false )
    end

    // wave

    local amt = 50

    for i = 1, amt do
        local particle = emitter:Add( TableRandomChoice(images_smoke) , self.Origin )
        local scol = math.Rand( 200, 225 )

        particle:SetVelocity( VectorRand() * 8 + (Angle(0, i * (360 / amt), 0):Forward() * 750) )
        particle:SetDieTime( math.Rand(0.9, 1.1) * effecttime )
        particle:SetStartAlpha( 255 )
        particle:SetEndAlpha( 0 )
        particle:SetStartSize( math.Rand(300,400) )
        particle:SetEndSize( math.Rand(1000,1500) )
        particle:SetRoll( math.Rand(0,360) )
        particle:SetRollDelta( math.Rand(-1,1) )
        particle:SetColor( scol,scol,scol )
        particle:SetAirResistance( 5 )
        particle:SetLighting( false )
        particle:SetCollide( false )
    end

    local particle = emitter:Add( "sprites/heatwave", self.Origin )
    particle:SetAirResistance( 0 )
    particle:SetDieTime( effecttime )
    particle:SetStartAlpha( 255 )
    particle:SetEndAlpha( 255 )
    particle:SetStartSize( 5000 )
    particle:SetEndSize( 0 )
    particle:SetRoll( math.Rand(180,480) )
    particle:SetRollDelta( math.Rand(-5,5) )
    particle:SetColor( 255, 255, 255 )

    emitter:Finish()

    local light = DynamicLight(self:EntIndex())
    if (light) then
        light.Pos = self.Origin
        light.r = 255
        light.g = 255
        light.b = 255
        light.Brightness = 9
        light.Decay = 2500
        light.Size = 2048
        light.DieTime = CurTime() + 10
    end

end

function EFFECT:Think()
    if (self.SpawnTime + effecttime) < CurTime() then
        return false
    else
        return true
    end
end

local glaremat = Material("effects/ar2_altfire1b")

function EFFECT:Render()
    local d = (CurTime() - self.SpawnTime) / 15

    d = 1 - d

    d = math.Clamp(d, 0, 1)

    cam.IgnoreZ(true)

    render.SetMaterial(glaremat)
    render.DrawSprite(self.Origin, 15000 * d, 15000 * d, Color(255, 255, 255))

    cam.IgnoreZ(false)
end