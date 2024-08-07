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

function BUFF:OnSetup(client, buff)
    if (Schema.util.Throttle("DesertersDemiseWarning", 60 * 15, client)) then
        return
    end

    client:Notify("Deserters Demise Debuff is active! Disconnecting will cause you to drop all your belongings!")
end

function BUFF:OnExpire(client, buff)
    if (client:GetNetVar("tied")) then
		buff.activeUntil = CurTime() + self.durationInSeconds
		return false
	end
end

function BUFF.hooks:PostEntityTakeDamage(victim, damageInfo, tookDamage)
    if (not tookDamage) then
        return
    end

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

	client.expDropMode = bit.bor(Schema.dropMode.ALL, Schema.dropMode.WITH_EQUIPPED_WEAPONS, Schema.dropMode.WITH_EQUIPPED_ARMOR)
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

	client.expDropMode = bit.bor(Schema.dropMode.ALL, Schema.dropMode.WITH_EQUIPPED_WEAPONS, Schema.dropMode.WITH_EQUIPPED_ARMOR)
	client.expCorpseCharacter = oldCharacter
	Schema.HandlePlayerDeathCorpse(client)
end
