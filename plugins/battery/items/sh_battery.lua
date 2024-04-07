local ITEM = ITEM

ITEM.name = "Battery Charge"
ITEM.price = 50
ITEM.model = "models/Items/car_battery01.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Consumables"
ITEM.description = "A battery, it can charge your electronics instantly."

ITEM.functions.Charge = {
	OnRun = function(item)
		if(item.player._NextChargeBattery and item.player._NextChargeBattery > CurTime())then
			item.player:Notify("You can't use this for another " ..
			math.ceil(item.player._NextChargeBattery - CurTime()) .. " second(s)!")

			return false
		end

		local character = item.player:GetCharacter()

		item.player._NextChargeBattery = CurTime() + 10

		character:SetData("battery", PLUGIN.batteryMax)
	end
}
