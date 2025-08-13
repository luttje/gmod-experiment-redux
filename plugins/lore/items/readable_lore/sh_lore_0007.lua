local ITEM = ITEM

ITEM.name = "Nemesis Activation Party"
ITEM.model = Model("models/props_lab/binderredlabel.mdl")
ITEM.description = "A logbook page describing Nemesis' successful activation."
ITEM.chanceToScavenge = Schema.RARITY_RARE

function ITEM:GetText()
	return [[
		We did it. Nemesis is live. Fully aligned. No anomalies detected.
		We opened champagne, for once without fear of spillage on equipment. Laughter in the lab — rare and bright.
		Nemesis even “spoke” to us, thanking the team. We joked about inviting it for a toast.

		It's going to change the world.

		<b>- Dr. M. Konrad, Lead AI Behaviorist</b>
	]]
end
