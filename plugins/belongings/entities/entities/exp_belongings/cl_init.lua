include("shared.lua")

ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(tooltip)
	local ownerName, isOwner = self:GetOwnerName()

	local name = tooltip:AddRow("name")
    name:SetImportant()

    if (isOwner) then
        name:SetText(L("belongingsOwnerSelf"))
    else
        name:SetText(L("belongingsOwnerName", ownerName))
    end

    name:SizeToContents()

	local description = tooltip:AddRow("description")
	description:SetText(L("belongingsDesc"))
	description:SizeToContents()
end
