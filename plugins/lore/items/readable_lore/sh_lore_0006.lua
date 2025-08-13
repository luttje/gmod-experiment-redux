local ITEM = ITEM

ITEM.name = "Obstacle Zero Episode Outline"
ITEM.model = Model("models/props_junk/garbage_newspaper001a.mdl")
ITEM.description = "A crumpled page outlining a televised obstacle course."
ITEM.chanceToScavenge = Schema.RARITY_COMMON

function ITEM:GetText()
	return [[
		WELCOME TO OBSTACLE ZERO!
		Where our lucky Test Subjects trade chaos for cash in the safest show on the air!
		Fall in the water? You're out! Winner takes home a life-changing prize!

		Sponsors: Guardian Corp. and Apex Energy.
		Filming starts this Friday. Bring your smile. Bring your heart. Bring your courage.
	]]
end
