local ITEM = ITEM

ITEM.name = "Trapped in the City"
ITEM.model = Model("models/props_lab/bindergreen.mdl")
ITEM.description = "A hand-written survivor account."
ITEM.chanceToScavenge = Schema.RARITY_RARE

function ITEM:GetText()
	return [[
		Gates won't open. No food drops for days. Nemesis drones patrol the streets like we're the threat.
		Some of us thought it was part of the show. It's not.
		There's no exit, and every time you think you've found one, you end up back here.

		I think this is the real test.

		<b>Test Subject #47 (Deke)</b>
	]]
end
