local PERK = {}

PERK = {}
PERK.name = "Mercantile"
PERK.price = 10000
PERK.backgroundImage = "experiment-redux/symbol_background"
PERK.backgroundColor = Color(170,85,64,255)
PERK.foregroundImage = "experiment-redux/symbol/cart"
PERK.priceModifier = 0.9
PERK.description = "Fancy yourself as a merchant? With this perk, you will receive ten percent off all business items."

PRK_MERCANTILE = Schema.perk.Register(PERK)
