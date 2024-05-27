local PLUGIN = PLUGIN

if (SERVER) then
	AddCSLuaFile()
end

ENT.Type = "anim"
ENT.PrintName = "Experiment Monitor (Static)"
ENT.Author = "Experiment Redux"
ENT.Category = "Experiment Redux"

-- This entity is replaced at map startup with the real monitor entity, based on the monitorPreset keyvalue
-- It can not be physgunned or moved
ENT.Spawnable = false
ENT.AdminOnly = false

if (not SERVER) then
    return
end

function ENT:Initialize()
    local preset = PLUGIN.presets[self.monitorPreset]

    PLUGIN:SetupParentEntity(self, preset)
	self:SetSolid(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)

	-- We do not draw this parent, since it only communicates the angles of a static prop with the real monitor parent
    self:SetNoDraw(true)

	for _, monitor in ipairs(preset.monitors) do
		PLUGIN:SpawnMonitor(self, monitor)
	end
end

function ENT:KeyValue(key, value)
	if (key:lower() == "monitorpreset") then
		self.monitorPreset = value
	end
end
