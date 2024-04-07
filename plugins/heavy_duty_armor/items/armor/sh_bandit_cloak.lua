local ITEM = ITEM

ITEM.price = 1320
ITEM.name = "Bandit Cloak"
ITEM.maxArmor = 50
ITEM.description = "A bandit uniform with a mandatory hood and trenchcoat."
ITEM.width = 2
ITEM.height = 1

ITEM.replacements = "models/stalkertnb/banditboss1.mdl"

ix.anim.SetModelClass(ITEM.replacements, "player")
