DEFINE_BASECLASS("exp_monster_base")

if (SERVER) then
	AddCSLuaFile()
end

ENT.Base = "exp_monster_base"
ENT.PrintName = "Experiment Runner"
ENT.Author = "Experiment Redux"
ENT.Category = "Experiment Redux"

ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:GetDisplayName()
	return "Runner"
end

if (not SERVER) then
	return
end

function ENT:Initialize()
    BaseClass.Initialize(self)

    self:SetModel("models/zombie/fast.mdl")
    self:SetHealth(500)
	self:Activate()
end

function ENT:SetupVoiceSounds()
    self:SetTypedVoiceSet("Idle", {
        "NPC_FastZombie.Idle"
    })

    self:SetTypedVoiceSet("Pain", {
        "NPC_FastZombie.Pain"
    })

    self:SetTypedVoiceSet("Die", {
        "NPC_FastZombie.Die"
    })

    self:SetTypedVoiceSet("Alert", {
        "npc/fast_zombie/fz_scream1.wav"
    })

    self:SetTypedVoiceSet("Chase", {
        -- "npc/fast_zombie/gurgle_loop1.wav",
    })

    self:SetTypedVoiceSet("Lost", {
        "npc/fast_zombie/fz_alert_far1.wav"
    })

    self:SetTypedVoiceSet("Attack", {
        "NPC_FastZombie.Attack"
    })

    self:SetTypedVoiceSet("AttackMiss", {
        "NPC_FastZombie.AttackMiss"
    })

    self:SetTypedVoiceSet("AttackHit", {
        "NPC_FastZombie.AttackHit"
    })

    self:SetTypedVoiceSet("Victory", {
        "npc/fast_zombie/leap1.wav"
    })

    self:SetTypedVoiceSet("FootstepLeft", {
        "NPC_FastZombie.FootstepLeft"
    })

    self:SetTypedVoiceSet("FootstepRight", {
        "NPC_FastZombie.FootstepRight"
    })

    self:SetTypedVoiceSet("FootstepFastLeft", {
        "NPC_FastZombie.GallopLeft"
    })

    self:SetTypedVoiceSet("FootstepFastRight", {
        "NPC_FastZombie.GallopRight"
    })
end
