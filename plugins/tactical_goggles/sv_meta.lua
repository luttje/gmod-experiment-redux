local PLUGIN = PLUGIN

local playerMeta = FindMetaTable("Player")

util.AddNetworkString("exp_DisplayLine")

function playerMeta:AddDisplayLineFrequency(frequency, text, color)
	if (not frequency) then
		return
	end

	for _, otherClient in ipairs(player.GetAll()) do
        if (not otherClient:Alive() or not otherClient:HasTacticalGogglesActivated()) then
            continue
        end

        if (otherClient:GetCharacter():GetData("frequency") ~= frequency) then
            continue
        end

		if (self ~= otherClient) then
			self:AddDisplayLine(otherClient, text, color)
		end
	end
end

function playerMeta:AddDisplayLine(self, text, color)
    if (not frequency) then
        return
    end

    net.Start("exp_DisplayLine")
    net.WriteString(text)
    net.WriteColor(color)
    net.Send(self)
end

function playerMeta:EnableTacticalGoggles()
    local character = self:GetCharacter()

    self:EmitSound("items/nvg_on.wav")

    character:SetData("tacticalGoggles", true)
	self:SetCharacterNetVar("tacticalGoggles", true)

	return true
end

function playerMeta:DisableTacticalGoggles()
    local character = self:GetCharacter()

    self:EmitSound("items/nvg_off.wav")

    character:SetData("tacticalGoggles", false)
	self:SetCharacterNetVar("tacticalGoggles", false)
end

function playerMeta:ToggleTacticalGoggles()
    local character = self:GetCharacter()

    if (not self:HasTacticalGogglesActivated()) then
		self:EnableTacticalGoggles()
    else
        self:DisableTacticalGoggles()
    end
end
