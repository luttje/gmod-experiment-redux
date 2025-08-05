local PLUGIN = PLUGIN

AddCSLuaFile()
DEFINE_BASECLASS("base_point")

ENT.Base = "base_point"
ENT.PrintName = "Obstacle Course Camera"
ENT.Author = "Experiment Redux"
ENT.Type = "point"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("String", "CourseID")
	self:NetworkVar("String", "CameraName")
	self:NetworkVar("String", "TargetName")
	self:NetworkVar("Int", "FOV")
end

if (SERVER) then
	function ENT:Initialize()
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
	end

	-- Always transmit this entity to clients, so client side drawing knows where camera's outside PVS are
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:KeyValue(key, value)
		if (key == "courseID") then
			self:SetCourseID(value)
		elseif (key == "cameraName") then
			self:SetCameraName(value)
		elseif (key == "targetName") then
			self:SetTargetName(value)
		elseif (key == "fov") then
			self:SetFOV(tonumber(value) or 75)
		end
	end
else
	function ENT:GetTargetEntity()
		local targetName = self:GetTargetName()
		if targetName == "" then return nil end

		local targets = ents.FindByName(targetName)
		return targets[1]
	end

	function ENT:GetViewAngles()
		local target = self:GetTargetEntity()
		if IsValid(target) then
			local dir = (target:GetPos() - self:GetPos()):GetNormalized()
			return dir:Angle()
		else
			return self:GetAngles()
		end
	end
end
