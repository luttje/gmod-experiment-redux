local BUFF = BUFF

--- When a Locker Rot Virus player attacks someone this many seconds after being attacked by them, we consider it unprovoked aggression again.
local PROVOKE_TIME_IN_SECONDS = 60 -- 1 minute must be enough

BUFF.name = "Rotbrand"
BUFF.isNegative = true
BUFF.foregroundImage = {
	spritesheet = "experiment-redux/flatmsicons32.png",
	x = 27,
	y = 11,
	size = 32,
}
BUFF.durationInSeconds = 10 * 60 -- 10 minutes stacking for each time damage is done.
BUFF.persistThroughDeath = true
BUFF.stackOnDuplicate = true
BUFF.description =
"You're next in line for the Locker Rot Virus. Unprovoked aggression during the Locker Rot Virus causes this to happen."

if (not SERVER) then
	return
end

--- Cap the stack to at most 4 hours
--- @param client Player
--- @param buff ActiveBuff
function BUFF:OnStacked(client, buff)
	if (buff.activeUntil < CurTime() + (60 * 60 * 4)) then
		-- The buff is already set to expire in less than 4 hours, so we don't need to do anything.
		return
	end

	buff.activeUntil = CurTime() + (60 * 60 * 4) -- Set the buff to expire in 4 hours.
end

-- When a player is attacked, if infected with the locker rot virus, we will mark the time they were attacked.
-- A Locker Rot Virus infected player can only attack someone unprovoked if they were attacked by them within the last PROVOKE_TIME_IN_SECONDS seconds.
-- If they attack someone unprovoked, they will get the Rotbrand buff applied to them.
function BUFF.hooks:EntityTakeDamage(client, damageInfo)
	local attacker = damageInfo:GetAttacker()

	if (not IsValid(attacker) or not attacker:IsPlayer() or not client:IsPlayer()) then
		return
	end

	local nemesisPlugin = ix.plugin.Get("nemesis_ai")

	-- If this player is not the Locker Rot Virus infected player, check if their attacker was.
	if (not nemesisPlugin:IsLockerRotEventPlayer(client)) then
		if (not nemesisPlugin:IsLockerRotEventPlayer(attacker)) then
			return
		end

		-- The attacker is the Locker Rot Virus infected player, let's check if they were provoked.
		if (not attacker.expLockerRotAttacks) then
			-- The player wasn't attacked before, so they weren't provoked. We punish this by applying the
			-- Rotbrand buff to them.
			Schema.buff.SetActive(attacker, self.index)

			return
		end

		-- The player was attacked before, so we check if this attack was provoked.
		for _, attack in ipairs(attacker.expLockerRotAttacks) do
			if (attack.attacker == client and attack.time + PROVOKE_TIME_IN_SECONDS > CurTime()) then
				-- The attack was provoked, so we don't apply the Rotbrand buff.
				return
			end
		end

		-- The attack was not provoked, so we apply the Rotbrand buff.
		Schema.buff.SetActive(attacker, self.index)

		return
	end

	-- Mark this time of the attack, so we can check later if the locker rot player was provoked or not.
	client.expLockerRotAttacks = client.expLockerRotAttacks or {}
	table.insert(client.expLockerRotAttacks, {
		time = CurTime(),
		attacker = attacker,
	})
end

function BUFF.hooks:OnCharacterDisconnect(client, character)
	client.expLockerRotAttacks = nil
end

function BUFF.hooks:PlayerLockerRotEnded(client, isSuccessful)
	-- When the Locker Rot Virus ends, we clear the attacks table.
	client.expLockerRotAttacks = nil
end
