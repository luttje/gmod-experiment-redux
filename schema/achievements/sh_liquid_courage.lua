local ACHIEVEMENT = {}

ACHIEVEMENT.name = "Liquid Courage Connoisseur"
ACHIEVEMENT.backgroundImage = "experiment-redux/symbol_background"
ACHIEVEMENT.backgroundColor = Color(48,93,124,255)
ACHIEVEMENT.foregroundImage = "experiment-redux/symbol/drunkard"
ACHIEVEMENT.reward = 250
ACHIEVEMENT.maximum = 10
ACHIEVEMENT.description = "Drown your sorrows and steel your nerves with ten bottles of potent brews."

ACH_LIQUID_COURAGE = Schema.achievement.Register(ACHIEVEMENT)
