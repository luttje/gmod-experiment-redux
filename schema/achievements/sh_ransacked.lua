local ACHIEVEMENT = {}

ACHIEVEMENT.name = "Ransacked"
ACHIEVEMENT.backgroundImage = "experiment-redux/symbol_background"
ACHIEVEMENT.backgroundColor = Color(48,93,124,255)
ACHIEVEMENT.foregroundImage = "experiment-redux/symbol/camera"
ACHIEVEMENT.reward = 1000
ACHIEVEMENT.maximum = 1
ACHIEVEMENT.description = "Extract a fortune of $8000 from someone's remains, proving that fortune favors the bold."

ACH_RANSACKED = Schema.achievement.Register(ACHIEVEMENT)
