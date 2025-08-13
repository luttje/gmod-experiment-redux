local ITEM = ITEM

ITEM.name = "Nemesis Crowd-Control Brief"
ITEM.model = Model("models/props_lab/bindergraylabel01a.mdl")
ITEM.description = "A technical binder on Nemesis AI crowd management protocols."
ITEM.chanceToScavenge = Schema.RARITY_RARE

function ITEM:GetText()
	return [[
		<b>Author: Dr. L. Carrow, Systems Engineer</b>
		Nemesis v1.0 is nearing functional stability. The AI is designed for de-escalation — verbal persuasion first, non-lethal deterrents second.
		The public trials will be staged in a controlled urban environment. Simulated riots. Simulated looting. Simulated injuries. The goal: prove Nemesis can disperse without harm.

		We'll be watching closely. If it works here, it works anywhere.
	]]
end
