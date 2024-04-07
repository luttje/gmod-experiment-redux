local ITEM = ITEM

ITEM.name = "Cyanide"
ITEM.price = 100
ITEM.model = "models/props_junk/garbage_plasticbottle002a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A bottle of cyanide, warnings are plastered all over it."

ITEM.functions.Drink = {
	OnRun = function(item)
		local client = item.player

		client:Notify("You drink the cyanide.")

		timer.Simple(1, function()
			if (IsValid(client) and client:Alive()) then
				client:TakeDamage(50, client, game.GetWorld())
			end
		end)
	end
}
