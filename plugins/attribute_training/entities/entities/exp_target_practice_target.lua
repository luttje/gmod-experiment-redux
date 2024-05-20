AddCSLuaFile()
DEFINE_BASECLASS("base_gmodentity")

ENT.PrintName = "Target Practice Target"
ENT.Colors = {
    Color(255, 255, 255),
    Color(30, 255, 30),
    Color(200, 200, 200),
    Color(30, 30, 30),
}

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Force")

	if (SERVER) then
		self:NetworkVarNotify("Force", function()
			self:PhysWake()
		end)
	end
end

function ENT:PhysicsSimulate(physicsObject, deltaTime)
	local linearForce = Vector(0, 0, self:GetForce() * 5000) * deltaTime
	local angularForce = vector_origin

	return angularForce, linearForce, SIM_GLOBAL_FORCE
end

if (not SERVER) then
	return
end

AccessorFunc(ENT, "expKillAt", "KillAt", FORCE_NUMBER)

function ENT:Initialize()
	self:SetModel("models/maxofs2d/balloon_classic.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)

	local physicsObject = self:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		physicsObject:SetMass(100)
		physicsObject:Wake()
		physicsObject:EnableGravity(false)
	end

	local scale = math.Rand(1, 3)

    self:SetForce(math.random(10, 20) * scale)
    self:SetColor(self.Colors[math.random(1, #self.Colors)])
	self:SetModelScale(scale, 0)
	self:Activate() -- update physics size to scale
	self:StartMotionController()
	self:SetKillAt(CurTime() + 1.5)
end

function ENT:SetTrainees(trainees)
	self.trainees = trainees
end

function ENT:Pop()
	local color = self:GetColor()

    local effectData = EffectData()

	effectData:SetOrigin(self:GetPos())
    effectData:SetStart(Vector(color.r, color.g, color.b))

	util.Effect("exp_target_pop", effectData)

	self:Remove()
end

function ENT:Think()
	if ((self:GetKillAt() or 0) < CurTime()) then
		self:Pop()
	end
end

function ENT:OnTakeDamage(dmginfo)
    local attacker = dmginfo:GetAttacker()

	if (self.trainees and IsValid(attacker) and attacker:IsPlayer()) then
		-- Only count damage from trainees
		local isTrainee = false

		for k, v in ipairs(self.trainees) do
			if (v == attacker) then
				isTrainee = true
				break
			end
		end

		if (isTrainee) then
			attacker.expTargetPracticeScore = attacker.expTargetPracticeScore + (1 / self:GetModelScale())
			attacker:SetCharacterNetVar("targetPracticeScore", attacker.expTargetPracticeScore)
		end
	end

	self:Pop()
end
