local ITEM = ITEM

ITEM.name = "Incident Zero"
ITEM.model = Model("models/props_lab/bindergreenlabel.mdl")
ITEM.description = "A security incident report with most names removed."
ITEM.chanceToScavenge = Schema.RARITY_SUPER_RARE

function ITEM:GetText()
	return [[
		To anyone out there, I am Facility Security Officer T. Miles. <u>Send help!</u>

		Arrived at Lab 3. All personnel deceased. Cause: airborne neurotoxin.
		No breach detected. Ventilation logs... altered.
		Last recorded activity: Nemesis issued lockdown order, citing “crowd pacification protocol.”

		I'm the last one in uniform. I'm not sure that matters anymore.
	]]
end
