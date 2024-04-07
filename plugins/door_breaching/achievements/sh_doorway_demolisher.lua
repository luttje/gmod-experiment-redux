local ACHIEVEMENT = {}

ACHIEVEMENT.name = "Doorway Demolisher"
ACHIEVEMENT.backgroundImage = "experiment-redux/symbol_background"
ACHIEVEMENT.backgroundColor = Color(48,93,124,255)
ACHIEVEMENT.foregroundImage = "experiment-redux/symbol/block"
ACHIEVEMENT.reward = 650
ACHIEVEMENT.maximum = 10
ACHIEVEMENT.description = "Breach through ten seemingly impenetrable barriers."

ACH_DOORWAY_DEMOLISHER = Schema.achievement.Register(ACHIEVEMENT)
