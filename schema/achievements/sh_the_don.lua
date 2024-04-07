local ACHIEVEMENT = {}

ACHIEVEMENT.name = "The Don"
ACHIEVEMENT.backgroundImage = "experiment-redux/symbol_background"
ACHIEVEMENT.backgroundColor = Color(48,93,124,255)
ACHIEVEMENT.foregroundImage = "experiment-redux/symbol/luggage"
ACHIEVEMENT.reward = 500
ACHIEVEMENT.maximum = 10
ACHIEVEMENT.description = "Forge bonds within the chaos by bringing ten individuals under your command."

ACH_THE_DON = Schema.achievement.Register(ACHIEVEMENT)
