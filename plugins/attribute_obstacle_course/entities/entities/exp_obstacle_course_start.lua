local PLUGIN = PLUGIN

AddCSLuaFile()
DEFINE_BASECLASS("base_brush")

ENT.Base = "base_brush"
ENT.PrintName = "Obstacle Course Start"
ENT.Author = "Experiment Redux"
ENT.Type = "brush"

if (not SERVER) then
	return
end

function ENT:Initialize()
	self:SetTrigger(true)
	self:SetSolid(SOLID_TRIGGER)
	self:SetNotSolid(false)
end

function ENT:KeyValue(key, value)
	if (key == "courseID") then
		self.courseID = value
	elseif (key == "doorTarget") then
		self.doorTarget = value
	end
end

function ENT:GetCourseID()
	if (not self.courseID) then
		return ix.util.SchemaError("Obstacle Course Start entity does not have a courseID set.")
	end

	return self.courseID
end

function ENT:GetDoorTarget()
	if (not self.doorTarget) then
		return ix.util.SchemaError("Obstacle Course Start entity does not have a doorTarget set.")
	end

	return self.doorTarget
end

function ENT:StartTouch(entity)
	if (not entity:IsPlayer() or not self.courseID) then
		return
	end

	PLUGIN:AddPlayerToWaiting(entity, self.courseID)
end

function ENT:EndTouch(entity)
	if (not entity:IsPlayer() or not self.courseID) then
		return
	end

	PLUGIN:RemovePlayerFromWaiting(entity, self.courseID)
end

function ENT:Touch(entity)
	if (not entity:IsPlayer() or not self.courseID) then
		return
	end

	local courseData = PLUGIN.obstacleCourses[self.courseID]

	if (courseData and courseData.isDoorOpen and courseData.waitingPlayers[entity]) then
		PLUGIN:StartPlayerOnCourse(entity, self.courseID)
	end
end
