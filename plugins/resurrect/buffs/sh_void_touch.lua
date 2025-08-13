local BUFF = BUFF

BUFF.name = "Void Touch"
BUFF.isNegative = true
BUFF.foregroundImage = {
	spritesheet = "experiment-redux/flatmsicons32.png",
	x = 24,
	y = 5,
	size = 32,
}
BUFF.durationInSeconds = 30 * 60
BUFF.persistThroughDeath = true
BUFF.description =
"You've been recently resurrected, yet you feel a void touch. If you fall now, you'll be unable to be resurrected."

function BUFF.hooks:CanPlayerResurrectTarget(client, target, corpse)
	if (corpse and not corpse:GetNetVar("expVoidTouch", nil)) then
		return
	end

	return false
end

if (not SERVER) then
	return
end

function BUFF.hooks:OnPlayerCorpseCreated(client, corpse)
	if (not Schema.buff.GetActive(client, self.index)) then
		return
	end

	corpse:SetNetVar("expVoidTouch", true)
end

function BUFF.hooks:PlayerResurrectedTarget(client, target)
	Schema.buff.SetActive(target, self.index)
end
