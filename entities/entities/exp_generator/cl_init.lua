include("shared.lua")

ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(tooltip)
	local ownerName = L"someone"
    local upgrades = self:GetUpgrades() or 0

    local character = ix.char.loaded[self:GetOwnerID()]

	if (character) then
        local ourCharacter = LocalPlayer():GetCharacter()

		if (ourCharacter and character and ourCharacter:DoesRecognize(character) and hook.Run("IsPlayerRecognized", client) ~= false) then
			ownerName = character:GetName()
		end
	end

	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText(L("generatorOwnerName", ownerName))
    name:SizeToContents()

    local itemTable = self:GetItemTable()

    if (not itemTable) then
        return
    end

    local powerBar = tooltip:Add("expGeneratorPower")
    powerBar:SetPower(self:GetPower())
    powerBar:SetMaxPower(itemTable.generator.power)
	powerBar:Dock(BOTTOM)

	local description = tooltip:AddRow("description")
    description:SetText("Upgrades: " .. upgrades .. " / " .. #itemTable.generator.upgrades)
    description:SizeToContents()

	local teleportEarnings = ix.config.Get("teleportGeneratorEarnings")

	if (not teleportEarnings) then
		local earnings = tooltip:AddRow("earnings")
		earnings:SetText("Earnings: " .. ix.currency.Get(self:GetHeldBolts() or 0))
		earnings:SizeToContents()
	end
end

function ENT:GetEntityMenu(client)
	local itemTable = self:GetItemTable()
	local options = {}

	if (not itemTable) then
		return false
	end

	local characterID = self:GetOwnerID()

	itemTable.entity = self
    itemTable.player = client

	if (characterID and characterID == client:GetCharacter():GetID()) then
        options[L("pickup")] = function() end
	end

	local nextUpgrade, upgradeLabel = self:GetNextUpgrade()

	if (nextUpgrade) then
		options[upgradeLabel] = function() end
	end

	local teleportEarnings = ix.config.Get("teleportGeneratorEarnings")

    if (not teleportEarnings) then
        local heldBolts = self:GetHeldBolts() or 0

        if (heldBolts > 0) then
            options[L("withdraw", heldBolts)] = function() end
        end
    end

    local power = self:GetPower()

	if (power < itemTable.generator.power) then
		options[L("generatorRecharge")] = function() end
	end

	itemTable.player = nil
    itemTable.entity = nil

	return options
end
