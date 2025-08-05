local PLUGIN = PLUGIN

AddCSLuaFile()
DEFINE_BASECLASS("base_brush")

ENT.Base = "base_brush"
ENT.PrintName = "Obstacle Course Start"
ENT.Author = "Experiment Redux"
ENT.Type = "brush"

function ENT:SetupDataTables()
	self:NetworkVar("String", "CourseID")
	self:NetworkVar("String", "DoorTarget")
end

if (not SERVER) then
	return
end

function ENT:Initialize()
	self:SetTrigger(true)

	-- Track players in trigger for networking
	self.playersInTrigger = {}
end

function ENT:KeyValue(key, value)
	if (key == "courseID") then
		self:SetCourseID(value)
	elseif (key == "doorTarget") then
		self:SetDoorTarget(value)
	end
end

function ENT:StartTouch(entity)
	if (not entity:IsPlayer() or not self:GetCourseID()) then
		return
	end

	local courseID = self:GetCourseID()

	-- Add to waiting list
	PLUGIN:AddPlayerToWaiting(entity, courseID)

	-- Track player for networking
	self.playersInTrigger[entity] = true

	-- Send initial course data to player
	self:NetworkCourseDataToPlayer(entity, courseID)
end

function ENT:EndTouch(entity)
	if (not entity:IsPlayer() or not self:GetCourseID()) then
		return
	end

	local courseID = self:GetCourseID()

	-- Remove from waiting list
	PLUGIN:RemovePlayerFromWaiting(entity, courseID)

	-- Stop tracking player
	self.playersInTrigger[entity] = nil
end

function ENT:Touch(entity)
	if (not entity:IsPlayer() or not self:GetCourseID()) then
		return
	end

	local courseID = self:GetCourseID()
	local courseData = PLUGIN.obstacleCourses[courseID]

	if (courseData and courseData.isDoorOpen and courseData.waitingPlayers[entity]) then
		PLUGIN:StartPlayerOnCourse(entity, courseID)
	end
end

function ENT:NetworkCourseDataToPlayer(player, courseID)
	if not IsValid(player) or not courseID then return end

	local courseData = PLUGIN.obstacleCourses[courseID]
	if not courseData then return end

	-- Convert course data to networkable format
	local networkData = {
		isDoorOpen = courseData.isDoorOpen,
		isActive = courseData.isActive,
		waitingPlayers = {},
		activePlayers = {},
		finishedPlayers = {}
	}

	-- Convert waiting players
	for client, data in pairs(courseData.waitingPlayers) do
		if IsValid(client) then
			table.insert(networkData.waitingPlayers, {
				name = client:Name(),
				joinedAt = data.joinedAt
			})
		end
	end

	-- Convert active players
	for client, data in pairs(courseData.activePlayers) do
		if IsValid(client) then
			table.insert(networkData.activePlayers, {
				name = client:Name(),
				startedAt = data.startedAt
			})
		end
	end

	-- Convert finished players
	for _, data in ipairs(courseData.finishedPlayers) do
		if IsValid(data.client) then
			table.insert(networkData.finishedPlayers, {
				name = data.client:Name(),
				position = data.position,
				finishTime = data.finishTime,
				finishedAt = data.finishedAt
			})
		end
	end

	-- Send to client
	net.Start("expObstacleCourseUpdate")
	net.WriteString(courseID)
	net.WriteTable(networkData)
	net.Send(player)
end

function ENT:NetworkCourseDataToAll(courseID)
	-- Network to all players in this trigger
	for player, _ in pairs(self.playersInTrigger) do
		if IsValid(player) then
			self:NetworkCourseDataToPlayer(player, courseID)
		end
	end
end
