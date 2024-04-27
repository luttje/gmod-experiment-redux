local PLUGIN = PLUGIN

if (SERVER) then
    AddCSLuaFile()
end

ENT.Type = "anim"
ENT.PrintName = "Custom Soundscape"
ENT.Author = "Experiment Redux"

if (not SERVER) then
	return
end

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)

	-- This collision group will collide with players, but let traces through.
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    self:SetSolid(SOLID_BBOX)
	self:SetNoDraw(true)

	self:SetModel("models/hunter/misc/sphere2x2.mdl") -- has radius of 47.7
	self:SetTrigger(true)
end

function ENT:SetReplaceSoundscape(soundscapeInfo, soundscapeKey)
	self.expSoundscapeKey = soundscapeKey

	-- dividing by 47.7 would make more sense to me, but 64 worked better from testing
    self:SetModelScale(soundscapeInfo.radius / 64, 0)
	self:Activate()
end

function ENT:StartTouch(entity)
	if (not IsValid(entity) or not entity:IsPlayer()) then
		return
	end

	PLUGIN:PlayerSetSoundscape(entity, self.expSoundscapeKey, self)
end
