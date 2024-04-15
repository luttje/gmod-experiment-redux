AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

DEFINE_BASECLASS("base_ai")

local randomModels = {
	"models/Humans/Group02/Male_02.mdl",
	"models/Humans/Group02/Male_04.mdl",
	"models/Humans/Group02/Male_06.mdl",
	"models/Humans/Group02/Male_08.mdl",
	"models/Humans/Group02/Female_02.mdl",
	"models/Humans/Group02/Female_04.mdl",
	"models/Humans/Group02/Female_07.mdl",
}

AccessorFunc(ENT, "expVoiceSet", "VoiceSet")
AccessorFunc(ENT, "expVoicePitch", "VoicePitch", FORCE_NUMBER)

function ENT:SpawnFunction(client, trace, className)
	if (not trace.Hit) then
		return
	end

	local spawnPos = trace.HitPos + trace.HitNormal

	local trace = util.TraceLine({
		start = spawnPos,
		endpos = spawnPos - Vector(0, 0, 512),
		filter = self
	})

	spawnPos = trace.HitPos

	local ent = ents.Create(className)
	ent:SetPos(spawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()

	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_STEP)
	self:SetUseType(SIMPLE_USE)

	self:CapabilitiesAdd(bit.bor(CAP_MOVE_GROUND, CAP_ANIMATEDFACE, CAP_TURN_HEAD))

	if (self:GetModel() == nil) then
		self:SetModel(randomModels[math.random(#randomModels)])
	end

	if (self:GetVoicePitch() == nil) then
		self:SetVoicePitch(math.random(90, 110))
	end

	local model = self:GetModel()

	if (self:GetVoiceSet() == nil) then
		self:SetupRandomVoiceSet(model)
	end

	if (self:GetDisplayName() == "") then
		if (model:find("female", nil, true) ~= nil) then
			self:SetDisplayName("Jane Doe")
		else
			self:SetDisplayName("John Doe")
		end
	end
end

function ENT:SetupRandomVoiceSet(model)
	local randomVoiceLines = {
		"vo/npc/male01/excuseme01.wav",
		"vo/npc/male01/excuseme01.wav",
		"vo/npc/male01/excuseme01.wav",
		"vo/npc/male01/question19.wav",
		"vo/npc/male01/hi01.wav",
		"vo/npc/male01/hi01.wav",
		"vo/npc/male01/hi01.wav",
		"vo/npc/male01/hi01.wav",
		"vo/npc/male01/hi02.wav",
		"vo/npc/male01/hi02.wav",
		"vo/npc/male01/hi02.wav",
		"vo/npc/male01/hi02.wav",
		"vo/npc/male01/hi02.wav",
		"vo/npc/male01/hi02.wav",
		"vo/npc/male01/doingsomething.wav",
		"vo/npc/male01/doingsomething.wav",
	}

	if (model:find("female", nil, true) ~= nil) then
		for i = 1, #randomVoiceLines do
			randomVoiceLines[i] = randomVoiceLines[i]:gsub("male", "female")
		end
	end

	self:SetVoiceSet(randomVoiceLines)
end

function ENT:SetupNPC(npc)
	self.expNpcData = npc
	self:SetNpcId(npc.uniqueID)

	if (npc.name) then
		self:SetDisplayName(npc.name)
	end

	if (npc.description) then
		self:SetDescription(npc.description)
	end

	if (npc.model) then
		self:SetModel(npc.model)
	end

	if (npc.skin) then
		self:SetSkin(npc.skin)
	end

	if (npc.bodygroups) then
		for k, v in pairs(npc.bodygroups) do
			self:SetBodygroup(k, v)
		end
	end

	if (npc.voiceSet) then
		self:SetVoiceSet(npc.voiceSet)
	end

	if (npc.voicePitch) then
		self:SetVoicePitch(npc.voicePitch)
	end
end

function ENT:Think()
	if (not self.expNpcData) then
		return
	end

	if (self.nextCheckThink and self.nextCheckThink > CurTime()) then
		return
	end

	self.nextCheckThink = CurTime() + 1

	if (self.expNpcData.OnThink) then
		self.expNpcData:OnThink(self)
	end
end

function ENT:PrintChat(message, isYelling)
	local range = ix.config.Get("chatRange", 280) * (isYelling and 2 or 1)
	local receivers = {}

	for _, entity in ipairs(ents.FindInSphere(self:GetPos(), range)) do
		if (entity:IsPlayer()) then
			receivers[#receivers + 1] = entity
		end
	end

	ix.chat.Send(nil, "npc", message, false, receivers, {
		name = self:GetDisplayName(),
		yelling = isYelling or false
	})
end

function ENT:SpeakFromSet(randomVoiceLines, index)
	randomVoiceLines = randomVoiceLines or self:GetVoiceSet()
	local randomVoiceLine = randomVoiceLines[index or math.random(#randomVoiceLines)]

	self:SpeakSound(randomVoiceLine)
end

function ENT:SpeakSound(sound)
	self:EmitSound(sound, 75, self:GetVoicePitch())
end

function ENT:Use(activator, caller)
	if (not Schema.util.Throttle("npcInteract", 2, activator)) then
		Schema.npc.StartInteraction(activator, self)
	end

	if (Schema.util.Throttle("npcSpeak", 2, self)) then
		return
	end

	self:SpeakFromSet()
end
