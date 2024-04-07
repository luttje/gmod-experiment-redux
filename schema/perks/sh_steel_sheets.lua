local PERK = {}

PERK = {}
PERK.name = "Steel Sheets"
PERK.price = 7000
PERK.backgroundImage = "experiment-redux/symbol_background"
PERK.backgroundColor = Color(0,145,255,255)
PERK.foregroundImage = "experiment-redux/symbol/molecule"
PERK.description = "With this perk your generators will be harder to destroy."

PRK_STEELSHEETS = Schema.perk.Register(PERK)
