local PERK = {}

PERK = {}
PERK.name = "Jinxed Door"
PERK.price = 10000
PERK.backgroundImage = "experiment-redux/symbol_background"
PERK.backgroundColor = Color(204,0,0,255)
PERK.foregroundImage = "experiment-redux/symbol/reverse"
PERK.description = "Your door protectors will damage characters that try to shoot your doors open."

PRK_JINXED_DOOR = Schema.perk.Register(PERK)
