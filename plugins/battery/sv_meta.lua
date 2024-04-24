local PLUGIN = PLUGIN

local playerMeta = FindMetaTable("Player")

function playerMeta:EnableStealth()
    local character = self:GetCharacter()

	if (not self:IsBot() and character:GetData("battery", 0) < 5) then
		return false
	end

    Schema.achievement.Progress("go_stealth", self)

	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self:SetColor(Color(255, 255, 255, 0))

    self:EmitSound("items/nvg_on.wav")

    character:SetData("stealth", true)
	self:SetCharacterNetVar("expStealth", true)

	return true
end

function playerMeta:DisableStealth()
    local character = self:GetCharacter()

    self:SetColor(Color(255, 255, 255, 255))

	self:EmitSound("items/nvg_off.wav")

	character:SetData("stealth", false)
    self:SetCharacterNetVar("expStealth", false)
end

function playerMeta:ToggleStealth()
    local character = self:GetCharacter()

    if (not self:HasStealthActivated()) then
        if (character:GetData("battery", 0) > 5) then
            self:EnableStealth()
        end
    else
        self:DisableStealth()
    end
end

function playerMeta:EnableThermal()
    local character = self:GetCharacter()

	if (not self:IsBot() and character:GetData("battery", 0) < 5) then
		return false
	end

    Schema.achievement.Progress("go_thermal", self)
    self:EmitSound("items/nvg_on.wav")

    character:SetData("thermal", true)
	self:SetCharacterNetVar("expThermal", true)
end

function playerMeta:DisableThermal()
    local character = self:GetCharacter()

	self:EmitSound("items/nvg_off.wav")

    character:SetData("thermal", false)
	self:SetCharacterNetVar("expThermal", false)
end

function playerMeta:ToggleThermal()
	if (not self:HasThermalActivated()) then
		self:EnableThermal()
	else
		self:DisableThermal()
	end
end

-- Checks the battery of the player's implants, disabling them if the battery is too low.
-- Also disables the implants if the player is dead or ragdolled.
function playerMeta:CheckImplants()
    local character = self:GetCharacter()
	local lowBattery = character:GetData("battery", 0) < 5
	local isRagdolled = self:IsRagdoll()
    local isAlive = self:Alive()

    local isThermal = character:GetData("thermal", false)

    if (isThermal) then
		if (not isAlive or lowBattery or isRagdolled) then
        	self:DisableThermal()
		end
    end

    if (self:HasStealthActivated()) then
        if (not isAlive or lowBattery or isRagdolled) then
            self:DisableStealth()
        end
    end
end
