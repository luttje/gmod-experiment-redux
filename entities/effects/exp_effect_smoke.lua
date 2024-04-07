function EFFECT:Init(data)
	local particleEmitter = ParticleEmitter(data:GetOrigin())
	local scale = data:GetScale() or 2

	for i = 1, (32 * scale) do
		local startSize = math.Rand(128 * scale, 256 * scale)
		local position = Vector(math.Rand(-24, 24), math.Rand(-24, 24), math.Rand(-24, 24) + 24)
		local particle = particleEmitter:Add("particle/particle_smokegrenade", data:GetOrigin() + position)

		if (particle) then
			particle:SetAirResistance(math.Rand(500, 600))
			particle:SetStartAlpha(255)
			particle:SetStartSize(startSize)
			particle:SetRollDelta(math.Rand(-0.2, 0.2))
			particle:SetEndAlpha(math.Rand(0, 128))
			particle:SetVelocity(VectorRand() * math.Rand(2000, 2200))
			particle:SetLifeTime(0)
			particle:SetLighting(0)
			particle:SetGravity(Vector(math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(16, -16)))
			particle:SetCollide(true)
			particle:SetEndSize(startSize * 2)
			particle:SetDieTime(math.random(16, 24))
			particle:SetBounce(0.5)
			particle:SetColor(math.random(220, 240), math.random(220, 240), math.random(220, 240))
			particle:SetRoll(math.Rand(-180, 180))
		end
	end

	particleEmitter:Finish()
end

function EFFECT:Render() end

function EFFECT:Think()
	return false
end
