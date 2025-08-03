DEFINE_BASECLASS("base_ai")

function ENT:InitializeVoiceSystem()
	self.expVoiceSounds = {}
	self.expVoiceSoundThrottle = {}
	self:SetupVoiceSounds()
end

function ENT:SpeakFromTypedVoiceSet(type, throttle, playOnPrivateChannel, volumeOverride, pitchOverride)
	if (GetConVar("ai_disabled"):GetBool()) then
		return
	end

	if (throttle and self.expVoiceSoundThrottle[type] and self.expVoiceSoundThrottle[type] > CurTime()) then
		return
	end

	if (throttle) then
		self.expVoiceSoundThrottle[type] = CurTime() + throttle
	end

	local sounds = self.expVoiceSounds[type]
	local sound = sounds and sounds[math.random(#sounds)]

	if (not sound) then
		return
	end

	if (playOnPrivateChannel) then
		self.expPrivateSound = CreateSound(self, sound)
		self.expPrivateSound:PlayEx(volumeOverride or 1, pitchOverride or self:GetVoicePitch())
		return
	end

	if (self.expCurrentSound) then
		self.expCurrentSound:Stop()
		self.expCurrentSound = nil
	end

	self.expCurrentSound = CreateSound(self, sound)
	self.expCurrentSound:PlayEx(volumeOverride or 1, pitchOverride or self:GetVoicePitch())
end

function ENT:HasTypedVoiceSet(type)
	return self.expVoiceSounds[type] ~= nil
end

function ENT:SetTypedVoiceSet(type, sounds)
	if (not istable(sounds)) then
		sounds = { sounds }
	end

	self.expVoiceSounds[type] = sounds
end
