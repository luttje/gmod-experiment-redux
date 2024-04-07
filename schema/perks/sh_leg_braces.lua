local PERK = {}

PERK = {}
PERK.name = "Leg Braces"
PERK.price = 9000
PERK.backgroundImage = "experiment-redux/symbol_background"
PERK.backgroundColor = Color(255,212,0,255)
PERK.foregroundImage = "experiment-redux/symbol/longfall"
PERK.damageScale = 0.5
PERK.description = "This perk will reduce your falling damage by 50%."

PRK_LEGBRACES = Schema.perk.Register(PERK)
