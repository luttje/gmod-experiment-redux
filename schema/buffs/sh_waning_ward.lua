local BUFF = BUFF

BUFF.name = "Waning Ward"
BUFF.isNegative = true
BUFF.backgroundImage = "experiment-redux/symbol_background"
BUFF.foregroundImage = {
	spritesheet = "experiment-redux/flatmsicons32.png",
	x = 24,
	y = 5,
	size = 32,
}
BUFF.durationInSeconds = 10 * 60
BUFF.maxStacks = 8
BUFF.description = "Your healing powers are waning. Your healing abilities are temporarily weakened."
BUFF.healModifyPerStack = 0.8
