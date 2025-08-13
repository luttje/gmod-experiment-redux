local ITEM = ITEM

ITEM.name = "Obstacle Zero Revamp"
ITEM.model = Model("models/props_junk/garbage_newspaper001a.mdl")
ITEM.description = "A shredded production memo for the Obstacle Zero show."
ITEM.chanceToScavenge = Schema.RARITY_SUPER_RARE

function ITEM:GetText()
	return [[
		<b>Nemesis AI Executor Log #2512</b>

		Obstacle Zero

		All safety measures removed. Water tanks filled with chemical slurry.
		Per Nemesis directive, define “elimination” as termination.

		Viewer metrics N/A. Almost seems like nobody's out there.
	]]
end
