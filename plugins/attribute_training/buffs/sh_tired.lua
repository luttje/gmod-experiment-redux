local BUFF = BUFF

BUFF.name = "Tired"
BUFF.foregroundImage = {
	spritesheet = "experiment-redux/flatmsicons32.png",
	x = 19,
	y = 11,
	size = 32,
}
BUFF.durationInSeconds = 10
BUFF.resetOnDuplicate = true
BUFF.description = "You're tired, your stamina regeneration is halted temporarily."

if (not SERVER) then
	return
end

function BUFF:OnSetup(client, buff)
	client:SetRegeneratingStamina(false)
end

function BUFF:OnExpire(client, buff)
	client:SetRegeneratingStamina(true)
end
