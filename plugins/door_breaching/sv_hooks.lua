local PLUGIN = PLUGIN

function PLUGIN:EntityBreached(entity, client, breach, noSound)
	self:OpenDoor(entity, client, noSound)

	if (IsValid(client)) then
		Schema.achievement.Progress(client, "doorway_demolisher")
	end
end

function PLUGIN:EntityIsDoor(entity)
	if (entity:GetClass() == "exp_door_protector") then
		return false
	end
end

function PLUGIN:CanPlayerHoldObject(client, entity)
	if (entity:GetClass() == "exp_door_protector") then
		return true
	end
end

function PLUGIN:EntityTakeDamage(entity, damageInfo)
	if (not damageInfo:IsBulletDamage()) then
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
		if (entity:GetClass() ~= "exp_door_protector") then
			continue
		end

		if (IsValid(entity.expClient) and Schema.perk.GetOwned("jinxed_door", entity.expClient)) then
			attacker:TakeDamage(damageInfo:GetDamage(), entity, entity)
		end

		-- The door protector prevented the door from being shot open.
		return
	end

	Schema.ImpactEffect(damagePosition, 8, false)
	self:EntityBreached(entity, attacker)
end
