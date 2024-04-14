function EFFECT:Init(data)
	local origin = data:GetOrigin()
	local color = data:GetStart()

	sound.Play("buttons/lightswitch2.wav", origin, 75, math.random(31, 49))

	local particleCount = 4
	local emitter = ParticleEmitter(origin, true)

	for i = 0, particleCount do
		local position = Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1))

		local particle = emitter:Add("particles/balloon_bit", origin + position * 8)

		if (not particle) then
			continue
		end

		particle:SetVelocity(position * 500)

		particle:SetLifeTime(0)
		particle:SetDieTime(10)

		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)

		local size = math.Rand(1, 3)
		particle:SetStartSize(size)
		particle:SetEndSize(0)

		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))

		particle:SetAirResistance(100)
		particle:SetGravity(Vector(0, 0, -300))

		local randomDarkness = math.Rand(0.8, 1.0)
		particle:SetColor(color.r * randomDarkness, color.g * randomDarkness, color.b * randomDarkness)

		particle:SetCollide(true)

		particle:SetAngleVelocity(Angle(math.Rand(-160, 160), math.Rand(-160, 160), math.Rand(-160, 160)))

		particle:SetBounce(1)
		particle:SetLighting(true)
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
