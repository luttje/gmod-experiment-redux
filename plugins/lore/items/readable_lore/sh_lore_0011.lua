local ITEM = ITEM

ITEM.name = "The Dead Walk Again"
ITEM.model = Model("models/props_c17/paper01.mdl")
ITEM.description = "A note scribbled on the back of a newspaper."
ITEM.chanceToScavenge = Schema.RARITY_RARE

function ITEM:GetText()
	return [[
		I saw Ellis yesterday. He took a sniper round to the chest two days ago. Dead.
		Now he's walking, laughing, eating beans like nothing happened.
		He doesn't remember dying. He doesn't even believe me.

		I think we're trapped forever. Even death's not an escape.

		- Harper
	]]
end
