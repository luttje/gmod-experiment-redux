local PLUGIN = PLUGIN

PLUGIN.name = "Attack Event Tracker"
PLUGIN.author = "Experiment Redux"
PLUGIN.description =
"Tracks attacks and calls hooks to mark which player first attacked another player, and which player successfully defended themselves."

ix.config.Add("attackEventResetSeconds", 60, "After how many seconds should the attack event be reset?", nil, {
	data = { min = 1, max = 3600 },
	category = PLUGIN.name
})

if (not SERVER) then
	return
end

-- Set this to true to test the attack event tracker with NPCs (useful for testing)
-- local DEBUG_FAKE_NPC_AS_PLAYERS = false

function PLUGIN:HasPlayerAttacked(client, victim)
	local curTime = CurTime()

	for _, attack in ipairs(client.expInitiatedAttacks or {}) do
		if (attack.victim == victim
			and curTime < attack.expireAt) then
			return true
		end
	end

	return false
end

-- Expire all attack events that have expired and return if any attack events are still active
function PLUGIN:HasClientAttackedAnyone(victim)
	local curTime = CurTime()
	victim.expInitiatedAttacks = victim.expInitiatedAttacks or {}

	for i = #victim.expInitiatedAttacks, 1, -1 do
		local attack = victim.expInitiatedAttacks[i]

		if (curTime >= attack.expireAt) then
			table.remove(victim.expInitiatedAttacks, i)
		end
	end

	return #victim.expInitiatedAttacks > 0
end

function PLUGIN:EntityTakeDamage(victim, damageInfo)
	if (not victim:IsPlayer()) then
		if (not DEBUG_FAKE_NPC_AS_PLAYERS) then
			return
		end

		if (not victim:IsNPC()) then
			return
		end
	end

	local attacker = damageInfo:GetAttacker()

	if (not attacker:IsPlayer()) then
		if (not DEBUG_FAKE_NPC_AS_PLAYERS) then
			return
		end

		if (not attacker:IsNPC()) then
			return
		end
	end

	attacker.expInitiatedAttacks = attacker.expInitiatedAttacks or {}

	if (self:HasClientAttackedAnyone(victim)) then
		return
	end

	if (self:HasPlayerAttacked(attacker, victim)) then
		-- Update the expireAt time for the attack event, so that we don't call the OnPlayerFirstAttacked hook again
		for _, attack in ipairs(attacker.expInitiatedAttacks) do
			if (attack.victim == victim) then
				attack.expireAt = CurTime() + ix.config.Get("attackEventResetSeconds")
				break
			end
		end

		return
	end

	attacker.expInitiatedAttacks[#attacker.expInitiatedAttacks + 1] = {
		expireAt = CurTime() + ix.config.Get("attackEventResetSeconds"),
		victim = victim
	}

	hook.Run("OnPlayerInitiatedAttack", attacker, victim)
end

function PLUGIN:PlayerDeath(victim, inflictor, attacker)
	if (not attacker:IsPlayer()) then
		if (not DEBUG_FAKE_NPC_AS_PLAYERS) then
			return
		end

		if (not attacker:IsNPC()) then
			return
		end
	end

	if (self:HasPlayerAttacked(victim, attacker)) then
		hook.Run("OnPlayerDefendedAttack", attacker, victim)
	end
end

function PLUGIN:OnNPCKilled(npc, attacker, inflictor)
	if (not DEBUG_FAKE_NPC_AS_PLAYERS) then
		return
	end

	if (not attacker:IsPlayer()) then
		return
	end

	if (self:HasPlayerAttacked(npc, attacker)) then
		hook.Run("OnPlayerDefendedAttack", attacker, npc)
	end
end
