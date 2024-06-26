if (SERVER) then
    AddCSLuaFile()
end

DEFINE_BASECLASS("exp_generator")

ENT.Type = "anim"
ENT.Base = "exp_generator"
ENT.Model = "models/props_combine/suit_charger001.mdl"
ENT.PrintName = "Bolt Generator"
ENT.Author = "Experiment Redux"
ENT.Category = "Experiment Redux"
ENT.PhysgunDisabled = true
ENT.IsBoltControlUnit = true
ENT.Spawnable = false
ENT.AdminOnly = true

DEFINE_BASECLASS("exp_generator")

if (not SERVER) then
	return
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:ResetSequence("idle")
end

function ENT:Think()
    local power = self:GetPower()

    if (power <= 0) then
        self:StopSound("ambient/machines/thumper_amb.wav")
        self:ResetSequence("emptyclick")
        self:NextThink(CurTime() + 1)
        return true
    end

    if (self:IsSequenceFinished()) then
        self:ResetSequence("idle")
        self:StopSound("ambient/machines/thumper_amb.wav")
        self:EmitSound("ambient/machines/thumper_amb.wav", 40, 250, 1)
    end

    self:FrameAdvance()
    self:NextThink(CurTime())

    return true
end

function ENT:OnRemove()
    BaseClass.OnRemove(self)

	self:StopSound("ambient/machines/thumper_amb.wav")
end
