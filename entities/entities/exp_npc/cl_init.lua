include("shared.lua")

DEFINE_BASECLASS("base_ai")

ENT.PopulateEntityInfo = true

ENT.BubblePosForward = 2
ENT.BubblePosZ = 76

function ENT:CreateBubble()
	self.bubble = ClientsideModel("models/extras/info_speech.mdl", RENDERGROUP_OPAQUE)
	local forward = self:GetForward() * self.BubblePosForward
	self.bubble:SetPos(self:GetPos() + forward + Vector(0, 0, self.BubblePosZ))
	self.bubble:SetModelScale(0.2, 0)
	self.bubble:SetColor(Color(255, 255, 255, 150))
	self.bubble:SetRenderMode(RENDERMODE_TRANSALPHA)
end

function ENT:Draw()
	local bubble = self.bubble

	if (IsValid(bubble)) then
		local realTime = RealTime()

		local forward = self:GetForward() * self.BubblePosForward

		bubble:SetRenderOrigin(self:GetPos() + forward + Vector(0, 0, self.BubblePosZ + math.sin(realTime * 3) * 0.5))
		bubble:SetRenderAngles(Angle(0, realTime * 100, 0))
	end

	self:DrawModel()
end

function ENT:Think()
	local noBubble = self:GetNoBubble()

	if (IsValid(self.bubble) and noBubble) then
		self.bubble:Remove()
	elseif (not IsValid(self.bubble) and not noBubble) then
		self:CreateBubble()
	end

	if ((self.nextAnimCheck or 0) < CurTime()) then
		self:SetAnim()
		self.nextAnimCheck = CurTime() + 60
	end

	self:SetNextClientThink(CurTime() + 0.25)

	return true
end

function ENT:OnRemove()
	if (IsValid(self.bubble)) then
		self.bubble:Remove()
	end
end

function ENT:OnPopulateEntityInfo(container)
	local name = container:AddRow("name")
	name:SetImportant()
	name:SetText(self:GetDisplayName())
	name:SizeToContents()

	local descriptionText = self:GetDescription()

	if (descriptionText ~= "") then
		local description = container:AddRow("description")
		description:SetText(self:GetDescription())
		description:SizeToContents()
	end
end
