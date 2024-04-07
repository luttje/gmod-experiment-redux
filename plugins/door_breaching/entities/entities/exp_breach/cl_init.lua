include("shared.lua")

function ENT:OnPopulateEntityInfo(tooltip)
	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText("Breach")
	name:SizeToContents()

	local description = tooltip:AddRow("description")
	description:SetText("Will forcefully open doors if damaged.")
	description:SizeToContents()
end
