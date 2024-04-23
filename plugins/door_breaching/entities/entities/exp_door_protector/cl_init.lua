include("shared.lua")

function ENT:OnPopulateEntityInfo(tooltip)
    local guarding = self:GetProtectedCount()

	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText("Door Protector")
	name:SizeToContents()

	local description = tooltip:AddRow("description")
	description:SetText("This is protecting " .. guarding .. " locked door(s).")
	description:SizeToContents()
end
