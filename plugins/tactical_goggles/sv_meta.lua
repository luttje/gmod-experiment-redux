local PLUGIN = PLUGIN
local playerMeta = FindMetaTable("Player")

function playerMeta:AddDisplayLineFrequency(text, color)
	local radioPlugin = ix.plugin.Get("radioing")
	local frequencies = radioPlugin:GetCharacterFrequencies(self:GetCharacter())

	for _, otherClient in ipairs(player.GetAll()) do
		if (
				self == otherClient
				or not otherClient:Alive()
				or not otherClient:HasTacticalGogglesActivated()
			) then
			continue
		end

		if (not otherClient:IsCharacterOnFrequency(frequencies)) then
			continue
		end

		otherClient:AddDisplayLine(text, color)
	end
end

function playerMeta:AddDisplayLine(text, color)
	net.Start("expDisplayLine")
	net.WriteString(text)
	net.WriteColor(color)
	net.Send(self)
end

function playerMeta:EnableTacticalGoggles()
	local character = self:GetCharacter()

	self:EmitSound("items/night_vision_on.wav")

	character:SetData("tacticalGoggles", true)
	self:SetCharacterNetVar("tacticalGoggles", true)

	return true
end

function playerMeta:DisableTacticalGoggles()
	local character = self:GetCharacter()

	self:EmitSound("items/night_vision_off.wav")

	character:SetData("tacticalGoggles", false)
	self:SetCharacterNetVar("tacticalGoggles", false)
end

function playerMeta:ToggleTacticalGoggles()
	if (not self:HasTacticalGogglesActivated()) then
		self:EnableTacticalGoggles()
	else
		self:DisableTacticalGoggles()
	end
end
