local ITEM = ITEM

ITEM.name = "Phase Gate Trials"
ITEM.model = Model("models/props_lab/binderbluelabel.mdl")
ITEM.description = "Research notes on early teleportation experiments."
ITEM.chanceToScavenge = Schema.RARITY_RARE

function ITEM:GetText()
	return [[
		Day 14 — First animal subject vaporized on entry.
		Day 22 — Larger animals exhibit cellular collapse during transfer.
		Day 31 — First human trial. Transfer complete… subject deceased. Cause: systemic organ liquefaction.

		I'm told to keep logging. I'm also told the budget for this is somehow increasing.

		<b>- T. Okada, Research Intern</b>
	]]
end
