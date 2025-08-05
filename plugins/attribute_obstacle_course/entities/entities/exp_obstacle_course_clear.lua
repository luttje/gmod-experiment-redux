local PLUGIN = PLUGIN

AddCSLuaFile()
DEFINE_BASECLASS("base_brush")

ENT.Base = "base_brush"
ENT.PrintName = "Obstacle Course Clear"
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
	end
end

function ENT:StartTouch(entity)
	if (not entity:IsPlayer() or not self.courseID) then
		return
	end

	local courseData = PLUGIN.obstacleCourses[self.courseID]

	if (courseData and courseData.activePlayers[entity]) then
		PLUGIN:DisqualifyPlayer(entity, self.courseID, "Reached clear zone before finishing")
	end
end
