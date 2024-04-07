include("shared.lua")

ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(tooltip)
	local displayName = self:GetDisplayName()

	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText(displayName)
	name:SizeToContents()

	local description = tooltip:AddRow("description")
	description:SetText(L("belongingsDesc"))
	description:SizeToContents()
end
