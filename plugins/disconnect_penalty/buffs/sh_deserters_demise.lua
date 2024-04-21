local PLUGIN = PLUGIN
local BUFF = BUFF

BUFF.name = "Deserter's Demise"
BUFF.isNegative = true
BUFF.foregroundImage = {
	spritesheet = "experiment-redux/flatmsicons32.png",
	x = 4,
	y = 20,
	size = 32,
}
BUFF.durationInSeconds = 5 * 60
BUFF.resetOnDuplicate = true
BUFF.description =
"You've recently taken or dealt damage. Disconnecting with this debuff active will cause you to drop all your belongings."

if (not SERVER) then
	return
end

function BUFF.hooks:EntityTakeDamage(victim, damageInfo)
	if (victim:IsPlayer()) then
		Schema.buff.SetActive(victim, "deserters_demise")
	end

	local attacker = damageInfo:GetAttacker()

	if (IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim) then
		Schema.buff.SetActive(attacker, "deserters_demise")
	end
end

function BUFF.hooks:OnCharacterDisconnect(client, character)
	if (not Schema.buff.GetActive(client, self.index)) then
		return
	end

	client.expDropMode = bit.bor(Schema.dropMode.ALL, Schema.dropMode.WITH_EQUIPPED)
	client.expCorpseCharacter = character
	Schema.HandlePlayerDeathCorpse(client)
end

function BUFF.hooks:PrePlayerLoadedCharacter(client, character, oldCharacter)
	if (not oldCharacter) then
		return
	end

    if (not Schema.buff.GetActive(client, self.index)) then
        return
    end

	client.expDropMode = bit.bor(Schema.dropMode.ALL, Schema.dropMode.WITH_EQUIPPED)
	client.expCorpseCharacter = oldCharacter
	Schema.HandlePlayerDeathCorpse(client)
end
