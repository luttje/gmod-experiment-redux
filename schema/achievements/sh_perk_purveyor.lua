local ACHIEVEMENT = {}

ACHIEVEMENT.name = "Perk Purveyor"
ACHIEVEMENT.backgroundImage = "experiment-redux/symbol_background"
ACHIEVEMENT.backgroundColor = Color(48,93,124,255)
ACHIEVEMENT.foregroundImage = "experiment-redux/symbol/yy"
ACHIEVEMENT.reward = 1000
ACHIEVEMENT.maximum = 5
ACHIEVEMENT.description = "Diversify your arsenal by acquiring five unique perks."

ACH_PERK_PURVEYOR = Schema.achievement.Register(ACHIEVEMENT)
