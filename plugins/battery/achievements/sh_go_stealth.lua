local ACHIEVEMENT = {}

ACHIEVEMENT.name = "Go Stealth"
ACHIEVEMENT.backgroundImage = "experiment-redux/symbol_background"
ACHIEVEMENT.backgroundColor = Color(48,93,124,255)
ACHIEVEMENT.foregroundImage = "experiment-redux/symbol/xray"
ACHIEVEMENT.reward = 1500
ACHIEVEMENT.maximum = 1
ACHIEVEMENT.description = "Turn on the stealth implant for the first time."

ACH_GOSTEALTH = Schema.achievement.Register(ACHIEVEMENT)
