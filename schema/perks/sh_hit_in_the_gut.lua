local PERK = {}

PERK = {}
PERK.name = "Hit in the gut"
PERK.price = 10000
PERK.backgroundImage = "experiment-redux/symbol_background"
PERK.backgroundColor = Color(255, 212, 0, 255)
PERK.foregroundImage = "experiment-redux/symbol/elkinda"
PERK.description = "With this perk you will have a 50% chance of saying 4 special words when hit."

PRK_HIT_IN_THE_GUT = Schema.perk.Register(PERK)
