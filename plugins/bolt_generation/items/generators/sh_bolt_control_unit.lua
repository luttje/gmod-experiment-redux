local ITEM = ITEM

ITEM.name = "BCU 'Bolt Control Unit'"
ITEM.price = 150
ITEM.model = "models/props_combine/suit_charger001.mdl"
ITEM.width = 2
ITEM.height = 3
ITEM.uniqueID = "exp_bolt_control_unit"
ITEM.category = "Wealth Generation & Protection"
ITEM.description = "Generates a steady rate of bolts over time and can be upgraded"
ITEM.maximum = 1
ITEM.data = {
	upgrades = 0
}

if (CLIENT) then
    function ITEM:PopulateTooltip(tooltip)
        self.baseTable.PopulateTooltip(self, tooltip)

		local panel = tooltip:AddRowAfter("name", "upgrades")
		panel:SetBackgroundColor(derma.GetColor("Info", tooltip))
		panel:SetText("Upgrades: " .. self:GetData("upgrades", 0))
		panel:SizeToContents()
	end
end

ITEM.generator = {
	powerPlural = "Power",
	powerName = "Power",
	uniqueID = "exp_bolt_control_unit",
	currency = 50,
    health = 200,
	produce = 100, -- Base production
	power = 4,
	name = "Bolt Control Unit",
	upgrades = {
		{
			name = "Minor Augmentation",
			price = 350,
			produce = 100
		},
		{
			name = "Major Augmentation",
			price = 500,
			produce = 200
		},
		{
			name = "Ultra Augmentation",
			price = 850,
			produce = 300
		},
		{
			name = "Minor+",
			price = 350,
			produce = 100,
			condition = function(client, entity)
				if(client ~= entity.expClient)then
					return false, "You can not upgrade this CBU to a Master of Logistics upgrade!"
				end

				return Schema.perk.GetOwned(PRK_LOGISTICS, client), "You do not have the master of logistics perk!"
			end
		},
		{
			name = "Major+",
			price = 500,
			produce = 200,
			condition = function(client, entity)
				if(client ~= entity.expClient)then
					return false, "You can not upgrade this CBU to a Master of Logistics upgrade!"
				end

				return Schema.perk.GetOwned(PRK_LOGISTICS, client), "You do not have the master of logistics perk!"
			end
		},
		{
			name = "Ultra+",
			price = 850,
			produce = 300,
			condition = function(client, entity)
				if(client ~= entity.expClient)then
					return false, "You can not upgrade this CBU to a Master of Logistics upgrade!"
				end

				return Schema.perk.GetOwned(PRK_LOGISTICS, client), "You do not have the master of logistics perk!"
			end
		}
	}
}
