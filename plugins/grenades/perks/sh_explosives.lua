local PERK = {}

PERK = {}
PERK.name = "Explosives"
PERK.price = 9000
PERK.backgroundImage = "experiment-redux/symbol_background"
PERK.backgroundColor = Color(255,212,0,255)
PERK.foregroundImage = "experiment-redux/symbol/explosives"
PERK.description = "With this perk you will be able to purchase grenades."

PRK_EXPLOSIVES = Schema.perk.Register(PERK)
