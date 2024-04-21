include("shared.lua")

ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(tooltip)
	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText(L("lockers"))
    name:SizeToContents()

	local description = tooltip:AddRow("description")
    description:SetText(L("lockersDesc"))
    description:SizeToContents()
end
