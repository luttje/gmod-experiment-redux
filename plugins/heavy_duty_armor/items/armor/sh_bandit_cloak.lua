local ITEM = ITEM

ITEM.price = 450
ITEM.shipmentSize = 5
ITEM.name = "Bandit Cloak"
ITEM.maxArmor = 50
ITEM.description = "A bandit uniform with a mandatory hood and trenchcoat."
ITEM.width = 2
ITEM.height = 1
ITEM.replacement = "models/stalkertnb/banditboss1.mdl"
ITEM.requiresArmadillo = true

ix.anim.SetModelClass(ITEM.replacement, "player")
