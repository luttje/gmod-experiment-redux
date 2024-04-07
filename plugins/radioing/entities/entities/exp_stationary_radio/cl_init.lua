local PLUGIN = PLUGIN

include("shared.lua")

ENT.PopulateEntityInfo = true

local glowMaterial = Material("sprites/redglow8")

function ENT:OnPopulateEntityInfo(tooltip)
	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText(L("stationaryRadio"))
	name:SizeToContents()

	local state = tooltip:AddRow("state")

	if (not self:GetTurnedOff()) then
		state:SetText(L("radioTurnedOn"))
	else
		state:SetText(L("radioTurnedOff"))
	end

	state:SizeToContents()

	local frequency = tooltip:AddRow("frequency")
	frequency:SetText(L("frequency", self:GetFrequency()))
	frequency:SizeToContents()
end

function ENT:Draw()
	local position = self:GetPos()
	local _ , _, _, a = self:GetColor()
	local glowColor = self:GetTurnedOff() and Color(255, 0, 0, a) or Color(0, 255, 0, a)
	local forward = self:GetForward() * 9
	local right = self:GetRight() * 5
	local up = self:GetUp() * 8

	self:DrawModel()

	cam.Start3D(EyePos(), EyeAngles())
		render.SetMaterial(glowMaterial)
		render.DrawSprite(position + forward + right + up, 16, 16, glowColor)
	cam.End3D()
end

function ENT:GetEntityMenu(client)
	local itemTable = self:GetItemTable()
	local options = {}

	if (not itemTable) then
		return false
	end

	itemTable.player = client
	itemTable.entity = self

	options[L("setFrequency")] = function()
		Derma_StringRequest(L("setFrequency"), L("setFrequencyDesc"), self:GetFrequency(), function(text)
			local frequency = tonumber(text)
			local success, fault = PLUGIN:ValidateFrequency(frequency)

			if (not success) then
				client:Notify(fault)
				return
			end

			if (not IsValid(self)) then
				client:Notify(L("radioNoLongerThere"))
				return
			end

			ix.menu.NetworkChoice(self, L("setFrequency"), frequency)
		end)

		return false
	end

	if (self:GetTurnedOff()) then
		options[L("turnOn")] = function() end
	else
		options[L("turnOff")] = function() end
	end

	options[L("pickup")] = function() end

	itemTable.player = nil
	itemTable.entity = nil

	return options
end
