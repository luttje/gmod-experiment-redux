local PLUGIN = PLUGIN
local BUFF = BUFF

BUFF.name = "Deserter's Demise"
BUFF.isNegative = true
BUFF.foregroundImage = {
	spritesheet = "experiment-redux/flatmsicons32.png",
	x = 18,
	y = 8,
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
		Schema.buff.SetActive(victim, self.index)
	end

	local attacker = damageInfo:GetAttacker()

	if (IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim) then
		Schema.buff.SetActive(attacker, self.index)
	end
end

function BUFF.hooks:CanPlayerTie(client, target)
    Schema.buff.SetActive(client, self.index)
    Schema.buff.SetActive(target, self.index)
end

function BUFF.hooks:OnPlayerBecameTied(client, tiedBy)
    Schema.buff.SetActive(client, self.index)
    Schema.buff.SetActive(tiedBy, self.index)
end

function BUFF.hooks:CanPlayerUntie(client, target)
    Schema.buff.SetActive(client, self.index)
end

function BUFF.hooks:OnPlayerBecameUntied(client, untiedBy)
	Schema.buff.SetActive(untiedBy, self.index)
end

function BUFF.hooks:CanPlayerChloroform(client, target)
	Schema.buff.SetActive(client, self.index)
	Schema.buff.SetActive(target, self.index)
end

function BUFF.hooks:OnPlayerBecameChloroformed(client, chloroformedBy)
	Schema.buff.SetActive(client, self.index)
	Schema.buff.SetActive(chloroformedBy, self.index)
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
