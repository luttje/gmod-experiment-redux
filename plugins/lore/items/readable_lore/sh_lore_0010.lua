local ITEM = ITEM

ITEM.name = "Phase Gate Genome Trials"
ITEM.model = Model("models/props_lab/bindergraylabel01b.mdl")
ITEM.description = "A binder with strange genetic test data."
ITEM.chanceToScavenge = Schema.RARITY_SUPER_RARE

function ITEM:GetText()
	return [[
		Observed inefficiencies in Subject durability.
		Hypothesis: Modifying genetic structure via Phase Gate yields enhanced resilience.
		Trial 12: Successful. Subject returned with adaptive dermal plating.
		Trial 15: Partial success. Subject exhibits cognitive fragmentation. Useful.

		New directive: Iterate.
	]]
end
