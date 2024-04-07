local PERK = {}

PERK = {}
PERK.name = "Experimentalist"
PERK.price = 5000
PERK.backgroundImage = "experiment-redux/symbol_background"
PERK.backgroundColor = Color(255,212,0,255)
PERK.foregroundImage = "experiment-redux/symbol/smoke"
PERK.description = "With this perk your flash grenades will also emit a smoke cloud."

PRK_EXPERIMENTALIST = Schema.perk.Register(PERK)
