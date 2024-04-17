function Schema:GetGameDescription()
	return Schema.name
end

function Schema:OnPhysgunFreeze(weapon, physObj, entity, client)
	if (not IsValid(physObj)) then
		return false
	end
end

function Schema:CharacterLoaded(character)
	local client = character:GetPlayer()

	Schema.perk.LoadOwned(client, character)
	Schema.buff.LoadActive(client, character)
	Schema.achievement.LoadProgress(client, character)
end

function Schema:CharacterPreSave(character)
	Schema.buff.PrepareSaveActive(character:GetPlayer(), character)
end

function Schema:PlayerSecondElapsed(client)
	local character = client:GetCharacter()

	if (not character) then
		return
	end

	client:CheckQueuedBoostRemovals(character)
	Schema.buff.CheckExpired(client)
end

function Schema:GetPlayerPunchDamage(client, damage, context)
	if (not client:GetCharacter()) then
		return
	end

	context.damage = context.damage
		+ (client:GetCharacter():GetAttribute("strength", 0) * ix.config.Get("strengthMultiplier"))
end

function Schema:EntityTakeDamage(entity, damageInfo)
	if (not entity:IsPlayer()) then
		return
	end

	local character = entity:GetCharacter()

	if (not character) then
		return
	end

	entity.expLastDamage = CurTime()

	local damage = damageInfo:GetDamage()
	damage = Schema.armor.DamageAfterArmor(character, damage)

	damageInfo:SetDamage(damage)
end

function Schema:PlayerHurt(client, attacker, health, damage)
	if ((client.ixNextPain or 0) < CurTime() and health > 0) then
		local painSound, delay = hook.Run("GetPlayerPainSound", client)

		if (painSound) then
			if (not client:IsBot() and client:IsFemale() and ! painSound:find("female")) then
				painSound = painSound:gsub("male", "female")
			end

			client:EmitSound(painSound)
			client.ixNextPain = CurTime() + (delay or 0.4)
		end
	end

	ix.log.Add(client, "playerHurt", damage, attacker:GetName() ~= "" and attacker:GetName() or attacker:GetClass())

	-- We override this function to prevent the default damage sound handling
	return true
end

function Schema:GetPlayerPainSound(client)
	if (Schema.perk.GetOwned("hit_in_the_gut", client) and math.random() <= 0.5) then
		local delay = 2
		return "vo/npc/male01/hitingut0" .. math.random(1, 2) .. ".wav", delay
	end

	local hitGroup = client.expLastBulletDamageHitGroup

	if (hitGroup and math.random() <= 0.4) then
		local delay = 2
		if (hitGroup == HITGROUP_HEAD) then
			return "vo/npc/male01/ow0" .. math.random(1, 2) .. ".wav", delay
		elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC) then
			return "vo/npc/male01/hitingut0" .. math.random(1, 2) .. ".wav", delay
		elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
			return "vo/npc/male01/myleg0" .. math.random(1, 2) .. ".wav", delay
		elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
			return "vo/npc/male01/myarm0" .. math.random(1, 2) .. ".wav", delay
		elseif (hitGroup == HITGROUP_GEAR) then
			return "vo/npc/male01/startle0" .. math.random(1, 2) .. ".wav", delay
		end
	end

	return "vo/npc/male01/pain0" .. math.random(1, 9) .. ".wav"
end

local function handleBeanbagWeaponDamage(client, attacker, damageInfo)
	local weapon = attacker:GetActiveWeapon()

	if (not IsValid(weapon)) then
		return
	end

	local ammo = game.GetAmmoName(weapon:GetPrimaryAmmoType())

	if (ammo:lower() ~= Schema.ammo.ConvertToAmmo("beanbag")) then
		return
	end

	-- Do a bit of damage if they're already ragdolled and override to not proceed with the regular damage.
	if (client:GetLocalVar("ragdoll")) then
		damageInfo:SetDamage(5)
		return true
	end

	local luck = 0.9

	if (Schema.perk.GetOwned("thick_skin", client)) then
		luck = luck * Schema.perk.GetProperty("thick_skin", "chance")
	end

	local gotLucky = math.random() < luck
	local position = damageInfo:GetDamagePosition()

	Schema.ImpactEffect(position, 8, true)

	if (gotLucky) then
		damageInfo:SetDamage(25)
	else
		damageInfo:SetDamage(5)

		local duration = ix.config.Get("beanbagRagdollDuration")

		client:SetRagdolled(true, duration)

		hook.Run("PlayerBeanbagged", client, attacker, duration, damageInfo)
	end

	-- Override, do not proceed with regular damage, because the beanbag doesnt hurt more.
	return true
end

-- Note: This is called only for bullet damage a player receives, you should use GM:EntityTakeDamage instead if you need to detect ALL damage.
function Schema:ScalePlayerDamage(client, hitGroup, damageInfo)
	local character = client:GetCharacter()

	if (not character) then
		return
	end

	client.expLastBulletDamageHitGroup = hitGroup

	local attacker = damageInfo:GetAttacker()
	local weapon = attacker:GetActiveWeapon()

	if (IsValid(attacker) and attacker:IsPlayer()) then
		if (handleBeanbagWeaponDamage(client, attacker, damageInfo) == true) then
			return
		end
	end

	-- Adjust head damage based on perks and items.
	if (hitGroup == HITGROUP_HEAD) then
		if (Schema.perk.GetOwned("headplate", client)) then
			local chance = Schema.perk.GetProperty("headplate", "chance")

			if (math.random() < chance) then
				damageInfo:ScaleDamage(0)
				return
			end
		end

		if (attacker:IsPlayer()) then
			local weaponIsSilenced = IsValid(weapon) and weapon.ixItem and weapon.ixItem.isSilenced
			local attackerIsStealthed = attacker:HasStealthActivated()
			local hasAssassinsCreedPerk = Schema.perk.GetOwned("assassinscreed", attacker)

			if (weaponIsSilenced and attackerIsStealthed and hasAssassinsCreedPerk) then
				local chance = Schema.perk.GetProperty("assassinscreed", "chance")

				if (math.random() < chance) then
					local bonusDamage = Schema.perk.GetProperty("assassinscreed", "bonusDamage")

					damageInfo:ScaleDamage(bonusDamage)
				end
			end
		end

		local helmetItemId = character:GetData("helmet")
		if (helmetItemId ~= nil) then
			local item = ix.item.instances[helmetItemId]

			if (not item) then
				ix.log.Add(client, "schemaDebug", "Schema:ScalePlayerDamage",
					"Attempt to get invalid helmet item instance: " ..
					tostring(helmetItemId))
				return
			end

			damageInfo:ScaleDamage(item.damageScale)
			character:SetData("helmet", nil)
			local inventory = ix.item.inventories[item.invID]
			inventory:Remove(helmetItemId, false, true)
			client:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav")
		end
	end

	-- Adjust melee damage based on perks and items.
	-- TODO: Check if ScalePlayerDamage is called for this type of melee damage
	if (damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH)) then
		if (Schema.perk.GetOwned("bluntdefense", client)) then
			local damageScale = Schema.perk.GetProperty("bluntdefense", "damageScale")
			damageInfo:ScaleDamage(damageScale)
		end
	end

	-- Adjust fall damage based on perks and items.
	if (damageInfo:IsFallDamage()) then
		if (Schema.perk.GetOwned("legbraces", client)) then
			local damageScale = Schema.perk.GetProperty("legbraces", "damageScale")
			damageInfo:ScaleDamage(damageScale)
		end
	end
end

function Schema:PlayerDeath(client, inflictor, attacker)
	Schema.achievement.Progress(client, "favored_target")

	Schema.PlayerDropRandomItems(client)
end

function Schema:PlayerUse(client, entity)
	if (! client:IsRestricted() and entity:IsPlayer() and entity:IsRestricted() and ! entity:GetNetVar("untying")) then
		entity:SetAction("@beingUntied", 5)
		entity:SetNetVar("untying", true)

		client:SetAction("@unTying", 5)

		client:DoStaredAction(entity, function()
			Scema:UntiePlayer(entity)
		end, 5, function()
			if (IsValid(entity)) then
				entity:SetNetVar("untying")
				entity:SetAction()
			end

			if (IsValid(client)) then
				client:SetAction()
			end
		end)
	end
end

function Schema:PlayerLoadedCharacter(client, curChar, prevChar)
	if (prevChar) then
		local informers = prevChar:GetVar("boltInformers") or {}
		local inventory = prevChar:GetInventory()

		for _, v in ipairs(informers) do
			if (IsValid(v)) then
				v:Remove()
			end
		end

		prevChar:SetVar("boltInformers", nil)
	end
end

function Schema:PlayerDisconnected(client)
	local character = client:GetCharacter()

	if (character) then
		local doors = character:GetVar("doors") or {}

		for _, v in ipairs(doors) do
			if (IsValid(v) and v:IsDoor() and v:GetDTEntity(0) == client) then
				v:RemoveDoorAccessData()
			end
		end

		character:SetVar("doors", nil)
	end
end

function Schema:PlayerDestroyGenerator(client, entity, generator)
	if (entity.PlayerDestroyGenerator and entity:PlayerDestroyGenerator(client, generator) ~= nil) then
		return
	end

	if (Schema.perk.GetOwned("payback", client)) then
		client:GetCharacter():GiveMoney(generator.price)

		return
	end

	client:GetCharacter():GiveMoney((generator.price * .75))
end

function Schema:PlayerPerkBought(client, perk)
	Schema.achievement.Progress(client, "perk_purveyor")
end

function Schema:CreateShipment(client, shipmentEntity)
	local atLeast = Schema.achievement.GetProperty("master_trader", "atLeast")
	if (shipmentEntity:GetItemCount() >= atLeast) then
		Schema.achievement.Progress(client, "master_trader")
	end

	for uniqueID, amount in ipairs(shipmentEntity.items) do
		local itemTable = ix.item.list[uniqueID]

		local targetItemId = Schema.achievement.GetProperty("freeman", "targetItemId")
		if (itemTable.uniqueID == targetItemId) then
			Schema.achievement.Progress(client, "freeman")
			break
		end
	end
end

function Schema:CharacterVarChanged(character, key, oldValue, value)
	if (key == "money") then
		local requiredMoney = Schema.achievement.GetProperty("northern_rock", "requiredMoney")

		if (value > requiredMoney) then
			Schema.achievement.Progress(character:GetPlayer(), "northern_rock")
		end
	end
end

function Schema:CharacterAttributeUpdated(client, character, attributeKey, value)
	if (attributeKey == "strength") then
		local requiredAttribute = Schema.achievement.GetProperty("titans_strength", "requiredAttribute")

		if (value >= requiredAttribute) then
			Schema.achievement.Progress(client, "titans_strength")
		end
	elseif (attributeKey == "dexterity") then
		local requiredAttribute = Schema.achievement.GetProperty("dextrous_rogue", "requiredAttribute")

		if (value >= requiredAttribute) then
			Schema.achievement.Progress(client, "dextrous_rogue")
		end
	elseif (attributeKey == "acrobatics") then
		local requiredAttribute = Schema.achievement.GetProperty("natural_acrobat", "requiredAttribute")

		if (value >= requiredAttribute) then
			Schema.achievement.Progress(client, "natural_acrobat")
		end
	elseif (attributeKey == "agility") then
		local requiredAttribute = Schema.achievement.GetProperty("agile_shadow", "requiredAttribute")

		if (value >= requiredAttribute) then
			Schema.achievement.Progress(client, "agile_shadow")
		end
	end
end

function Schema:OnCharacterDisconnect(client, character)
	Schema.CheckCharacterDisconnectPenalty(client, character)
end

function Schema:PlayerLoadedCharacter(client, character, oldCharacter)
	if (not oldCharacter) then
		return
	end

	Schema.CheckCharacterDisconnectPenalty(client, oldCharacter)
end

function Schema:GetSalaryAmount(client, faction)
	local salary = faction.pay

	if (ix.config.Get("incomeMultiplier") ~= 1) then
		salary = salary * ix.config.Get("incomeMultiplier")
	end

	return salary
end
