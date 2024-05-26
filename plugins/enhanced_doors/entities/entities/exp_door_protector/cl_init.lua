include("shared.lua")

function ENT:OnPopulateEntityInfo(tooltip)
	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText("Door Protector")
    name:SizeToContents()

    local door = self:GetParent()
    local title = IsValid(door) and door:GetNetVar("title", L"dTitleOwned") or L"dTitleOwned"

	if (not title) then
		return
	end

	local description = tooltip:AddRow("description")
	description:SetText(title)
	description:SizeToContents()
end
