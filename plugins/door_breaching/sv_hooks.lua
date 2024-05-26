local PLUGIN = PLUGIN

function PLUGIN:EntityBreached(entity, client, breach, noSound)
	self:OpenDoor(entity, client, noSound)

	if (not IsValid(client)) then
		return
	end

	if (Schema.util.Throttle("DoorBreached", 10, client)) then
		return
	end

	Schema.achievement.Progress("doorway_demolisher", client)
end

function PLUGIN:EntityTakeDamage(entity, damageInfo)
	if (not damageInfo:IsBulletDamage()) then
		return
	end

	local attacker = damageInfo:GetAttacker()

	if (not IsValid(attacker) or not attacker:IsPlayer()) then
		return
	end

	local weapon = attacker:GetActiveWeapon()

	if (not IsValid(weapon) or not weapon:IsWeapon()) then
		return
	end

	if (weapon.ixItem and weapon.ixItem.weaponCategory == "melee") then
		return
	end

	if (string.lower(entity:GetClass()) ~= "prop_door_rotating") then
		return
	end

	local damagePosition = damageInfo:GetDamagePosition()

	if (not self:IsDoorHitPointVulnerable(entity, damagePosition)) then
		return
	end

	-- If the door isn't locked, it'll always be vulnerable.
	if (not entity:IsLocked()) then
		Schema.ImpactEffect(damagePosition, 8, false)
		self:EntityBreached(entity, damageInfo:GetAttacker())

		return
	end

	local attacker = damageInfo:GetAttacker()

	if (not IsValid(attacker) or not attacker:IsPlayer()) then
		return
	end

	for _, entity in ipairs(ents.FindInSphere(entity:GetPos(), PLUGIN.doorProtectorRange)) do
		if (IsValid(entity.expClient) and Schema.perk.GetOwned("jinxed_door", entity.expClient)) then
			attacker:TakeDamage(damageInfo:GetDamage(), entity, entity)
		end
	end

	Schema.ImpactEffect(damagePosition, 8, false)
	self:EntityBreached(entity, attacker)
end
