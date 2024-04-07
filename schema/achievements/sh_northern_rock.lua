local ACHIEVEMENT = {}

ACHIEVEMENT.name = "Northern Rock"
ACHIEVEMENT.backgroundImage = "experiment-redux/symbol_background"
ACHIEVEMENT.backgroundColor = Color(48,93,124,255)
ACHIEVEMENT.foregroundImage = "experiment-redux/symbol/mountain"
ACHIEVEMENT.reward = 8000
ACHIEVEMENT.maximum = 1
ACHIEVEMENT.requiredMoney = 30000
ACHIEVEMENT.description = "Amass a fortune of over thirty thousand bolts."

ACH_NORTHERN_ROCK = Schema.achievement.Register(ACHIEVEMENT)
