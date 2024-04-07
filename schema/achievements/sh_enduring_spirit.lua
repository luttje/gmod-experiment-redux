local ACHIEVEMENT = {}

ACHIEVEMENT.name = "Enduring Spirit"
ACHIEVEMENT.backgroundImage = "experiment-redux/symbol_background"
ACHIEVEMENT.backgroundColor = Color(48,93,124,255)
ACHIEVEMENT.foregroundImage = "experiment-redux/symbol/arrow_squiggly"
ACHIEVEMENT.reward = 960
ACHIEVEMENT.maximum = 1
ACHIEVEMENT.requiredAttribute = 100
ACHIEVEMENT.description = "Embolden yourself to withstand any trial, achieving 100% endurance through relentless perseverance."

ACH_ENDURING_SPIRIT = Schema.achievement.Register(ACHIEVEMENT)
