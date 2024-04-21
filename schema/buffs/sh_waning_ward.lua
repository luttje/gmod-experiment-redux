local BUFF = BUFF

BUFF.name = "Waning Ward"
BUFF.isNegative = true
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

if (not SERVER) then
	return
end

function BUFF.hooks:AdjustHealAmount(client, amount)
	local buff = Schema.buff.GetActive(client, self.index)

	if (not buff) then
		return
	end

	local stacks = self:GetStacks(client, buff)
	local totalHealModify = math.pow(self.healModifyPerStack, stacks)

	return amount * totalHealModify
end
