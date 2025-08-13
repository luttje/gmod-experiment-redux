local ITEM = ITEM

ITEM.name = "Test City Completion Notice"
ITEM.model = Model("models/props_c17/paper01.mdl")
ITEM.description = "A printed memo announcing the city's readiness."
ITEM.chanceToScavenge = Schema.RARITY_UNCOMMON

function ITEM:GetText()
	return [[
		<b>Memo by R. Santos, Chief Architect</b>
		The “Simulation Zone” is complete. All districts are functional, storefronts dressed, and apartments staged with resident props.
		Test Subjects will be released in waves starting next week. They will be issued low-velocity bean bag rifles — strictly for morale and realism. No harm intended.

		We built this to feel real, but the danger isn't real. That's the point.
	]]
end
