local BUFF = BUFF

BUFF.name = "Quantum Buffer"
BUFF.backgroundImage = "experiment-redux/symbol_background"
BUFF.backgroundColor = Color(48, 93, 124, 255)
BUFF.foregroundImage = {
	spritesheet = "experiment-redux/flatmsicons32.png",
	x = 23,
	y = 9,
	size = 32,
}
BUFF.durationInSeconds = 15 * 60
BUFF.description = "You are invulnerable for a short duration, unless you attack or speak."

if (not SERVER) then
	return
end

function BUFF:OnShouldExpire(client, buff)
	if (client.expQuantumBufferShouldExpire) then
		client.expQuantumBufferShouldExpire = nil
		return true
	end
end

function BUFF.hooks:PlayerLoadedCharacter(client, character, oldCharacter)
	Schema.buff.SetActive(client, "quantum_buffer")
end

function BUFF.hooks:PlayerShouldTakeDamage(client, attacker)
    if (Schema.buff.GetActive(client, self.index)) then
		return false
	end
end

function BUFF.hooks:PlayerSay(client, text)
	if (Schema.buff.GetActive(client, self.index)) then
		client.expQuantumBufferShouldExpire = true
	end
end

function BUFF.hooks:PlayerWeaponChanged(client, weapon)
	if (weapon:GetClass() == "ix_hands"
			or weapon:GetClass() == "ix_keys"
			or weapon:GetClass() == "gmod_tool"
			or weapon:GetClass() == "weapon_physgun") then
		return
	end

	if (Schema.buff.GetActive(client, self.index)) then
		client.expQuantumBufferShouldExpire = true
	end
end

function BUFF.hooks:PlayerOpenedBelongings(client, belongings, inventory)
	if (Schema.buff.GetActive(client, self.index)) then
		client.expQuantumBufferShouldExpire = true
	end
end

function BUFF.hooks:PlayerSecondElapsed(client)
	local weapon = client:GetActiveWeapon()

	if (not IsValid(weapon) or weapon:GetClass() ~= "ix_hands") then
		return
	end

	if (client:IsWepRaised() and Schema.buff.GetActive(client, self.index)) then
		client.expQuantumBufferShouldExpire = true
	end
end

function BUFF.hooks:CanPlayerInteractItem(client, action, item)
	if (Schema.buff.GetActive(client, self.index)) then
		client.expQuantumBufferShouldExpire = true
	end
end
