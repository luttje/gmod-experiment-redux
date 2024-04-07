local ACHIEVEMENT = {}

ACHIEVEMENT.name = "Zip Ninja"
ACHIEVEMENT.backgroundImage = "experiment-redux/symbol_background"
ACHIEVEMENT.backgroundColor = Color(48,93,124,255)
ACHIEVEMENT.foregroundImage = "experiment-redux/symbol/ninja"
ACHIEVEMENT.reward = 500
ACHIEVEMENT.maximum = 10
ACHIEVEMENT.description = "Prove your mastery over restraint by successfully using zip ties on ten characters."

ACH_ZIP_NINJA = Schema.achievement.Register(ACHIEVEMENT)
