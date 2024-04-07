local PERK = {}

PERK = {}
PERK.name = "Army Training"
PERK.price = 5000
PERK.backgroundImage = "experiment-redux/symbol_background"
PERK.backgroundColor = Color(170,85,64,255)
PERK.foregroundImage = "experiment-redux/symbol/troop"
PERK.description = "Increases your max inventory weight, based on your strength."

PRK_ARMYTRAINING = Schema.perk.Register(PERK)
