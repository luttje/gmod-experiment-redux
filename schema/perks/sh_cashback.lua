local PERK = {}

PERK = {}
PERK.name = "Cashback"
PERK.price = 3000
PERK.backgroundImage = "experiment-redux/symbol_background"
PERK.backgroundColor = Color(0,145,255,255)
PERK.foregroundImage = "experiment-redux/symbol/dollar"
PERK.description = "You can cash in items in your inventory for 25% of their original price."

PRK_CASHBACK = Schema.perk.Register(PERK)
