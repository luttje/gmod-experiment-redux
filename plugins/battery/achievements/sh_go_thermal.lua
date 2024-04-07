local ACHIEVEMENT = {}

ACHIEVEMENT.name = "Go Thermal"
ACHIEVEMENT.backgroundImage = "experiment-redux/symbol_background"
ACHIEVEMENT.backgroundColor = Color(48,93,124,255)
ACHIEVEMENT.foregroundImage = "experiment-redux/symbol/lightbulb"
ACHIEVEMENT.reward = 320
ACHIEVEMENT.maximum = 1
ACHIEVEMENT.description = "Turn on the thermal implant for the first time."

ACH_GOTHERMAL = Schema.achievement.Register(ACHIEVEMENT)
