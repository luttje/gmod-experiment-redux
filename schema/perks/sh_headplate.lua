local PERK = {}

PERK = {}
PERK.name = "Headplate"
PERK.price = 8000
PERK.backgroundImage = "experiment-redux/symbol_background"
PERK.backgroundColor = Color(0,145,255,255)
PERK.foregroundImage = "experiment-redux/symbol/helmet"
PERK.chance = 0.05
PERK.description = "You have a 5% chance of taking no damage when headshotted."

PRK_HEADPLATE = Schema.perk.Register(PERK)
