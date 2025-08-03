DEFINE_BASECLASS("base_ai")

function ENT:InitializeTargetingSystem()
	self.targetingSystem = {
		currentTarget = nil,
		primaryTarget = nil,
		obstacleTarget = nil,
		lostTargetCount = 0,
		ignoredTargets = {},
		lastSenseTime = 0
	}
end

-- Main target validation
function ENT:IsValidTarget(entity)
	if not IsValid(entity) or entity == self then
		return false
	end

	-- Check if target is in ignore list
	if self:IsTargetIgnored(entity) then
		return false
	end

	-- Check basic target validity
	if entity:IsPlayer() then
		return entity:Alive() and entity:GetMoveType() ~= MOVETYPE_NOCLIP
	elseif entity:IsDoor() then
		return self:IsDoorObstacle(entity)
	end

	-- Use disposition system for other entities
	local disposition = self:Disposition(entity)
	return disposition == D_HT
end

function ENT:IsDoorObstacle(door)
	-- Only target doors that are closed
	if door:GetInternalVariable("m_eDoorState") ~= 0 then
		return false
	end

	-- If we don't have a primary target, doors can still be obstacles if they're close
	if not IsValid(self.targetingSystem.primaryTarget) then
		return self:GetPos():DistToSqr(door:GetPos()) < self:GetRangeSquared(self:GetAttackMeleeRange() * 2)
	end

	-- Check if door is between us and our primary target
	local doorPos = door:GetPos()
	local ourPos = self:GetPos()
	local targetPos = self.targetingSystem.primaryTarget:GetPos()

	local toDoor = (doorPos - ourPos):GetNormalized()
	local toTarget = (targetPos - ourPos):GetNormalized()

	-- If door is roughly in the direction of our target and close to us
	return toDoor:Dot(toTarget) > 0.7 and
		ourPos:DistToSqr(doorPos) < self:GetRangeSquared(self:GetAttackMeleeRange() * 2)
end

function ENT:IsTargetInMeleeRange(target)
	if not IsValid(target) then return false end
	return self:GetPos():DistToSqr(target:GetPos()) < self:GetRangeSquared(self:GetAttackMeleeRange())
end

function ENT:GetTargetPriority(entity)
	if entity:IsPlayer() then
		return 100 -- Highest priority
	elseif entity:IsDoor() then
		return 50 -- Medium priority (obstacles)
	end
	return 10 -- Low priority
end

-- Clean target selection
function ENT:FindBestTarget()
	local bestTarget = nil
	local bestPriority = -1
	local senseRange = self:GetSenseRange()
	local ourPos = self:GetPos()
	local ourEyePos = self:EyePos()
	local ourAngles = self:EyeAngles()
	local fieldOfView = math.cos(math.rad(70))

	-- First try to find targets in our cone of vision
	local entities = ents.FindInCone(ourEyePos, ourAngles:Forward(), senseRange, fieldOfView)

	for _, entity in pairs(entities) do
		if self:IsValidTarget(entity) and self:CanSeeTarget(entity) then
			local priority = self:GetTargetPriority(entity)

			-- Prefer closer targets of same priority
			local distance = ourPos:DistToSqr(entity:GetPos())
			local adjustedPriority = priority - (distance / 10000)

			if adjustedPriority > bestPriority then
				bestTarget = entity
				bestPriority = adjustedPriority
			end
		end
	end

	-- If we didn't find anything in our cone, search in a sphere for close targets
	if not IsValid(bestTarget) then
		local closeEntities = ents.FindInSphere(ourPos, senseRange * 0.5)
		for _, entity in pairs(closeEntities) do
			if self:IsValidTarget(entity) and self:CanSeeTarget(entity) then
				local priority = self:GetTargetPriority(entity)
				local distance = ourPos:DistToSqr(entity:GetPos())
				local adjustedPriority = priority - (distance / 5000) -- Less distance penalty for close targets

				if adjustedPriority > bestPriority then
					bestTarget = entity
					bestPriority = adjustedPriority
				end
			end
		end
	end

	return bestTarget
end

-- Set target with proper categorization
function ENT:SetTargetEntity(target)
	if target == self.targetingSystem.currentTarget then
		return
	end

	local oldTarget = self.targetingSystem.currentTarget
	self.targetingSystem.currentTarget = target

	if IsValid(target) then
		if target:IsPlayer() then
			self.targetingSystem.primaryTarget = target
			self.targetingSystem.obstacleTarget = nil
			-- Alert when we first see a player
			if not IsValid(oldTarget) or not oldTarget:IsPlayer() then
				self:SpeakFromTypedVoiceSet("Alert", 5)
			end
		elseif target:IsDoor() then
			self.targetingSystem.obstacleTarget = target
			-- Keep primary target if we have one
		end

		self:SetEnemy(target, true)
		self:UpdateEnemyMemory(target, target:GetPos())
		self.targetingSystem.lostTargetCount = 0

		-- Start chasing immediately
		if self:GetSchedule() ~= self.expSchedules.Chase and not self:IsTargetInMeleeRange(target) then
			self:StartSchedule(self.expSchedules.Chase)
		elseif self:IsTargetInMeleeRange(target) then
			self:StartAttackSchedule(target)
		end
	else
		self:SetEnemy(nil, false)
		if IsValid(oldTarget) then
			self:OnTargetLost(oldTarget)
		end
	end
end

function ENT:OnTargetLost(target)
	self.targetingSystem.lostTargetCount = self.targetingSystem.lostTargetCount + 1

	if self.targetingSystem.lostTargetCount >= 3 then
		self:SpeakFromTypedVoiceSet("Lost", 5)
		self.targetingSystem.primaryTarget = nil
		self.targetingSystem.obstacleTarget = nil
		self.targetingSystem.lostTargetCount = 0
	end
end

-- Target ignore system
function ENT:IgnoreTarget(target, duration)
	duration = duration or 20
	self.targetingSystem.ignoredTargets[target] = CurTime() + duration
end

function ENT:IsTargetIgnored(target)
	local ignoreUntil = self.targetingSystem.ignoredTargets[target]
	if ignoreUntil then
		if ignoreUntil > CurTime() then
			return true
		else
			self.targetingSystem.ignoredTargets[target] = nil
		end
	end
	return false
end

-- Clean line of sight check
function ENT:CanSeeTarget(target)
	if not IsValid(target) then return false end

	local trace = util.TraceLine({
		start = self:EyePos(),
		endpos = target:EyePos(),
		filter = self
	})

	return trace.Entity == target
end
