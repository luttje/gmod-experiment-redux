local ACHIEVEMENT = {}

ACHIEVEMENT.name = "Agile Shadow"
ACHIEVEMENT.backgroundImage = "experiment-redux/symbol_background"
ACHIEVEMENT.backgroundColor = Color(48,93,124,255)
ACHIEVEMENT.foregroundImage = "experiment-redux/symbol/gonzales"
ACHIEVEMENT.reward = 960
ACHIEVEMENT.maximum = 1
ACHIEVEMENT.requiredAttribute = 100
ACHIEVEMENT.description = "Navigate the chaos with unparalleled grace, achieving 100% agility solely through your own relentless training."

ACH_AGILE_SHADOW = Schema.achievement.Register(ACHIEVEMENT)
