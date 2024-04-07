include("shared.lua")

function ENT:OnPopulateEntityInfo(tooltip)
    local guarding = self:GetProtectedCount()

	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText("Bolt Informer")
	name:SizeToContents()

	local description = tooltip:AddRow("description")
	description:SetText("This will be informing about " .. guarding .. " bolt generators(s).")
	description:SizeToContents()
end

function ENT:GetEntityMenu(client)
	local options = {}

	options[L("pickup")] = function() end

	return options
end
