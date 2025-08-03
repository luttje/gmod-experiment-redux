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
	if (not IsValid(entity) or entity == self) then
		return false
	end

	-- Check if target is in ignore list
	if (self:IsTargetIgnored(entity)) then
		return false
	end

	-- Check basic target validity
	if (entity:IsPlayer()) then
		return entity:Alive() and entity:GetMoveType() ~= MOVETYPE_NOCLIP
	elseif (entity:IsDoor()) then
		return self:IsDoorObstacle(entity)
	end

	-- Use disposition system for other entities
	local disposition = self:Disposition(entity)
	return disposition == D_HT
end

function ENT:IsDoorObstacle(door)
	-- Only target doors that are closed
	if (door:GetInternalVariable("m_eDoorState") ~= 0) then
		return false
	end

	-- Always check if door is close enough to be an immediate obstacle
	local doorDistance = self:GetDistanceToEntitySqr(door)
	local maxDoorRange = self:GetRangeSquared(self:GetAttackMeleeRange())

	if (doorDistance > maxDoorRange) then
		return false
	end

	-- If we have a primary target, check if door is between us and target
	if IsValid(self.targetingSystem.primaryTarget) then
		local doorPos = door:GetPos()
		local ourPos = self:GetPos()
		local targetPos = self.targetingSystem.primaryTarget:GetPos()

		local toDoor = (doorPos - ourPos):GetNormalized()
		local toTarget = (targetPos - ourPos):GetNormalized()

		-- If door is roughly in the direction of our target
		if toDoor:Dot(toTarget) > 0.5 then
			return true
		end

		-- Additional check: if we recently had line of sight to our primary target
		-- but now we don't, and there's a door nearby, it's likely blocking us
		if not self:CanSeeTarget(self.targetingSystem.primaryTarget) then
			-- Check if the door is between us and where we last saw the target
			local lastKnownPos = self:GetEnemyLastKnownPos(self.targetingSystem.primaryTarget)
			if lastKnownPos and lastKnownPos ~= vector_origin then
				local toLastKnown = (lastKnownPos - ourPos):GetNormalized()
				if toDoor:Dot(toLastKnown) > 0.4 then
					return true
				end
			end
		end
	else
		-- If we don't have a primary target but we're close to a door, consider it an obstacle
		-- This handles cases where we lost our primary target but should still break through
		if (doorDistance < self:GetRangeSquared(self:GetAttackMeleeRange() * 1.5)) then
			return true
		end
	end

	return false
end

function ENT:IsTargetInMeleeRange(target)
	if (not IsValid(target)) then
		return false
	end

	-- For players, use a slightly different approach since they're usually moving
	if (target:IsPlayer()) then
		-- Use the closer of eye position or origin position
		local distToOrigin = self:GetPos():DistToSqr(target:GetPos())
		local distToEyes = self:GetPos():DistToSqr(target:EyePos())
		local closestDist = math.min(distToOrigin, distToEyes)
		return closestDist < self:GetRangeSquared(self:GetAttackMeleeRange())
	else
		-- For other entities (doors, NPCs), use bounding box calculation
		return self:GetDistanceToEntitySqr(target) < self:GetRangeSquared(self:GetAttackMeleeRange())
	end
end

function ENT:GetTargetPriority(entity)
	if (entity:IsPlayer()) then
		return 100 -- Highest priority
	elseif (entity:IsDoor()) then
		-- Higher priority for doors when we have a primary target behind them
		if (IsValid(self.targetingSystem.primaryTarget)) then
			return 80 -- High priority when chasing someone
		end

		return 50 -- Medium priority otherwise
	end

	return 10 -- Low priority
end

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
		if (self:IsValidTarget(entity) and self:CanSeeTarget(entity)) then
			local priority = self:GetTargetPriority(entity)

			-- Use proper distance calculation for priority adjustment
			local distance = self:GetDistanceToEntitySqr(entity)
			local adjustedPriority = priority - (distance / 10000)

			if adjustedPriority > bestPriority then
				bestTarget = entity
				bestPriority = adjustedPriority
			end
		end
	end

	-- If we didn't find anything in our cone, search in a sphere for close targets
	if (not IsValid(bestTarget)) then
		local closeEntities = ents.FindInSphere(ourPos, senseRange * 0.5)

		for _, entity in pairs(closeEntities) do
			if (self:IsValidTarget(entity) and self:CanSeeTarget(entity)) then
				local priority = self:GetTargetPriority(entity)
				local distance = self:GetDistanceToEntitySqr(entity)
				local adjustedPriority = priority - (distance / 5000) -- Less distance penalty for close targets

				if (adjustedPriority > bestPriority) then
					bestTarget = entity
					bestPriority = adjustedPriority
				end
			end
		end
	end

	-- Special case: if we have a primary target but can't see them,
	-- look for doors that might be blocking our path
	if (not IsValid(bestTarget) and IsValid(self.targetingSystem.primaryTarget)) then
		if (not self:CanSeeTarget(self.targetingSystem.primaryTarget)) then
			local nearbyDoors = ents.FindInSphere(ourPos, self:GetAttackMeleeRange())

			for _, entity in pairs(nearbyDoors) do
				if (entity:IsDoor() and self:IsValidTarget(entity)) then
					bestTarget = entity
					break
				end
			end
		end
	end

	return bestTarget
end

-- Set target with proper categorization
function ENT:SetTargetEntity(target)
	if (target == self.targetingSystem.currentTarget) then
		return
	end

	local oldTarget = self.targetingSystem.currentTarget
	self.targetingSystem.currentTarget = target

	if (IsValid(target)) then
		if (target:IsPlayer()) then
			self.targetingSystem.primaryTarget = target
			self.targetingSystem.obstacleTarget = nil

			-- Alert when we first see a player
			if (not IsValid(oldTarget) or not oldTarget:IsPlayer()) then
				self:SpeakFromTypedVoiceSet("Alert", 5)
			end
		elseif (target:IsDoor() and self:IsDoorObstacle(target)) then
			self.targetingSystem.obstacleTarget = target
			-- Keep primary target if we have one
		end

		self:SetEnemy(target, true)
		self:UpdateEnemyMemory(target, target:GetPos())
		self.targetingSystem.lostTargetCount = 0

		-- Start chasing immediately
		if (self:GetSchedule() ~= self.expSchedules.Chase and not self:IsTargetInMeleeRange(target)) then
			self:StartSchedule(self.expSchedules.Chase)
		elseif (self:IsTargetInMeleeRange(target)) then
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

	-- Don't give up on primary targets as quickly
	local maxLostCount = target:IsPlayer() and 5 or 3

	if (self.targetingSystem.lostTargetCount >= maxLostCount) then
		self:SpeakFromTypedVoiceSet("Lost", 5)

		-- Only clear primary target if it was the target we lost
		if (target == self.targetingSystem.primaryTarget) then
			self.targetingSystem.primaryTarget = nil
		end

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

	if (ignoreUntil) then
		if (ignoreUntil > CurTime()) then
			return true
		else
			self.targetingSystem.ignoredTargets[target] = nil
		end
	end

	return false
end

-- Clean line of sight check
function ENT:CanSeeTarget(target)
	if (not IsValid(target)) then
		return false
	end

	local trace = util.TraceLine({
		start = self:EyePos(),
		endpos = target:EyePos(),
		filter = self
	})

	return trace.Entity == target
end
