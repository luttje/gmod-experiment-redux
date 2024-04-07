local PLUGIN = PLUGIN

include("shared.lua")

ENT.PopulateEntityInfo = true

local glowMaterial = Material("sprites/redglow8")

function ENT:OnPopulateEntityInfo(tooltip)
	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText(L("broadcaster"))
	name:SizeToContents()

	local state = tooltip:AddRow("state")

	if (not self:GetTurnedOff()) then
		state:SetText(L("broadcasterBroadcasting"))
	else
		state:SetText(L("broadcasterTurnedOff"))
	end

	state:SizeToContents()
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
