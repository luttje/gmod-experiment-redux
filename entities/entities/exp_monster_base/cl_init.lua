DEFINE_BASECLASS("base_ai")

include("shared.lua")

ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(container)
	local name = container:AddRow("name")
	name:SetImportant()
	name:SetText(self:GetDisplayName())
	name:SizeToContents()
end

-- Override this to dress up the monster
function ENT:GetPacData()
	return nil
end

function ENT:Draw()
	-- Only draw the base model if PAC3 is not enabled
	if (not self.expSetupPAC) then
		self:DrawModel()
	end
end

function ENT:Think()
	if (self.expSetupPAC) then
		return
	end

	local pacData = self:GetPacData()

	if (not pacData) then
		return
	end

    if (not isfunction(self.AttachPACPart)) then
        pac.SetupENT(self)
    end

	self.expSetupPAC = true
	self:AttachPACPart(pacData)
    self:SetPACDrawDistance(0) -- Always draw
end
