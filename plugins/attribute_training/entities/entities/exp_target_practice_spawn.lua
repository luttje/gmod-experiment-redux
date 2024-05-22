AddCSLuaFile()
DEFINE_BASECLASS("base_gmodentity")

ENT.PrintName = "Target Practice Spawn"
ENT.Author = "Experiment Redux"
ENT.Category = "Experiment Redux"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.SpawnRadius = 32

if (not SERVER) then
	return
end

function ENT:Initialize()
	self:SetModel("models/props_phx/construct/metal_plate_curve360.mdl")

    self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(Color(10, 10, 10, 255))
end

function ENT:SpawnTarget(trainees)
	local target = ents.Create("exp_target_practice_target")

	if (not IsValid(target)) then
		return
	end

	target:SetOwner(self)
	target:SetTrainees(trainees)
	target:Spawn()

	local scale = target:GetModelScale()
	local spawnRadius = self.SpawnRadius / scale

	target:SetPos(
		self:GetPos()
		+ Vector(
			math.random(-spawnRadius, spawnRadius),
			math.random(-spawnRadius, spawnRadius),
			0
		)
	)
end

function ENT:StartSpawningForTrainees(trainees, duration)
	local timerName = "expTargetPracticeSpawnTimer#" .. self:EntIndex()

	if (timer.Exists(timerName)) then
		timer.Remove(timerName)
	end

	for _, trainee in ipairs(trainees) do
		if (IsValid(trainee)) then
			trainee.expTargetPracticeScore = 0
			trainee:SetCharacterNetVar("targetPracticeScore", trainee.expTargetPracticeScore)
		end
	end

	self.expPracticeForTrainees = trainees
	duration = duration or 30

	timer.Create(timerName, duration, 1, function()
		if (not IsValid(self)) then
			return
		end

		self.expPracticeForTrainees = nil
	end)
end

function ENT:Think()
	if (not self.expPracticeForTrainees) then
		return
	end

	if (self.expNextSpawn and self.expNextSpawn > CurTime()) then
		return
	end

	self.expNextSpawn = CurTime() + math.Rand(0.5, 2.5)

	self:SpawnTarget(self.expPracticeForTrainees)
end
