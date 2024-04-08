local ITEM = ITEM

ITEM.base = "base_outfit"
ITEM.name = "Degrading Outfit"
ITEM.description = "A suitcase full of tathered equipment. It looks like it can fall apart at any moment."
ITEM.model = Model("models/props_c17/suitcase_passenger_physics.mdl")
ITEM.category = "Armor"
ITEM.width = 1
ITEM.height = 1
ITEM.baseCondition = 100
ITEM.degredationPerSecond = 0.005

if (CLIENT) then
	function ITEM:PopulateTooltip(tooltip)
		local after = "name"

		local panel = tooltip:AddRowAfter(after, "quality")
		panel:SetBackgroundColor(derma.GetColor("Info", tooltip))
		panel:SetText("Condition: " .. math.Round(self:GetData("quality", self.baseCondition), 2))
		panel:SizeToContents()

        after = "quality"

		if (self.attribBoosts) then
			for attributeKey, boostAmount in pairs(self.attribBoosts) do
				local attribute = ix.attributes.list[attributeKey]
				local panel = tooltip:AddRowAfter(after, "boost" .. attributeKey)
				panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
				panel:SetText("Boosts " .. attribute.name .. " by " .. math.Round(boostAmount, 2))
				panel:SizeToContents()
			end
		end
	end
end

function ITEM:OnEquipped()
    local client = self.player

	self:SetData("quality", self:GetData("quality", self.baseCondition))

	client:EmitSound("physics/body/body_medium_impact_soft5.wav", 25, 50)
end

function ITEM:OnUnequipped()
	local client = self.player

	if (not IsValid(client)) then
		return
	end

	client:EmitSound("physics/body/body_medium_impact_soft2.wav", 25, 50)
end

if (SERVER) then
	hook.Add("PlayerSecondElapsed", "expDegradeOutfitsOverTime", function(client)
		local character = client:GetCharacter()

		if (not character) then
			return
		end

		local inventory = character:GetInventory()
		local degradableItems = inventory:GetItemsByBase(ITEM.uniqueID)

		for _, item in pairs(degradableItems) do
			local quality = item:GetData("quality", item.baseCondition)
			local newQuality = quality - item.degredationPerSecond

			if (newQuality <= 0) then
				item:Remove()
				client:EmitSound("physics/body/body_medium_impact_hard1.wav", 25, 50)
			else
				item:SetData("quality", newQuality)
			end
		end
	end)
end
