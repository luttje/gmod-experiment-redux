include("shared.lua")

function ENT:OnPopulateEntityInfo(tooltip)
    local guarding = self:GetProtectedCount()

	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText("Bolt Protector")
	name:SizeToContents()

	local description = tooltip:AddRow("description")
	description:SetText("This is protecting " .. guarding .. " bolt generators(s).")
	description:SizeToContents()
end

function ENT:GetEntityMenu(client)
	local options = {}

	options[L("pickup")] = {
		callback = function() end,
		forceListEnd = true,
	}

	return options
end
