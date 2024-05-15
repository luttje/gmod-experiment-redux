if SERVER then
	AddCSLuaFile()
end

local PLUGIN = PLUGIN

ENT.Type = "anim"
ENT.PrintName = "Spawn Point"
ENT.Author = "Experiment Redux"
ENT.IsSpawnPoint = true

if (not SERVER) then
	return
end

function ENT:Initialize()
	PLUGIN.mapSpawns[#PLUGIN.mapSpawns + 1] = {
		name = self.expName,
		position = self:GetPos(),
		angles = self:GetAngles(),
		shouldNotSave = true, -- The map will always dictate where this spawn point is
	}

	-- This entity only exists temporarily for mappers to mark a spawn point
	self:Remove()
end

function ENT:KeyValue(key, value)
	if (key == "name") then
		self.expName = value
	end
end
