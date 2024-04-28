--[[

	Organization, loading, saving and tick hooks

--]]

function Schema:GetGameDescription()
	return Schema.name
end

function Schema:PrePlayerLoadedCharacter(client, curChar, prevChar)
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

function Schema:CharacterLoaded(character)
	local client = character:GetPlayer()

	Schema.perk.LoadOwned(client, character)
	Schema.buff.LoadActive(client, character)
	Schema.achievement.LoadProgress(client, character)

	if (character.isBot) then
		-- ! Workaround. This fixes a Helix bug with bots getting a random model from the faction,
		-- ! but not having their OnAdjust called on their character vars.
		-- ! In OnAdjust skins and bodygroups are extracted from the model and applied to the player.
		local payload = character.vars

		payload.description = "A test subject, living in this city."
		payload.faction = ix.faction.GetIndex(payload.faction)

		local faction = ix.faction.indices[payload.faction]

		payload.model = math.random(#faction:GetModels(client))

		local newPayload = {}

		for varName, var in SortedPairsByMemberValue(ix.char.vars, "index") do
			local value = payload[varName]

			if (var.OnAdjust) then
				var:OnAdjust(client, payload, value, newPayload)
			end
		end

		table.Merge(payload, newPayload, true)
	end
end

function Schema:PlayerSecondElapsed(client)
	local character = client:GetCharacter()

	if (not character) then
		return
	end

	client:CheckQueuedBoostRemovals(character)
	Schema.buff.CheckExpired(client)
end

function Schema:CharacterPreSave(character)
	Schema.buff.PrepareSaveActive(character:GetPlayer(), character)
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

	if (client:SteamID() == nil or client:SteamID64() == nil) then
		--[[
		From the wiki:
		"
			NEED TO VALIDATE
			Player:SteamID, Player:SteamID64, and the like can return nil here.
		"
		https://wiki.facepunch.com/gmod/GM:PlayerDisconnected

		Let's return the favor and validate whether nil is ever returned.
		--]]
		local playerData = {
			time = os.time(),
			version = VERSION,
			versionStr = VERSIONSTR,
			jitVersion = jit.version,
			jitVersionNum = jit.version_num,
			steamID = tostring(client:SteamID()),
			steamID64 = tostring(client:SteamID64()),
			steamName = tostring(client:SteamName()),
		}
		ix.util.SchemaErrorNoHaltWithStack(
			"Player disconnected (wiki bug/issue validation): "
			.. util.TableToJSON(playerData) .. "\n"
		)
		file.Write("disconnect_validation.txt", util.TableToJSON(playerData) .. "\n")
	end
end

function Schema:CharacterVarChanged(character, key, oldValue, value)
	if (key ~= "money") then
		return
	end

	local requiredMoney = Schema.achievement.GetProperty("northern_rock", "requiredMoney")

	if (value > requiredMoney) then
		Schema.achievement.Progress("northern_rock", character:GetPlayer())
	end

	local requiredMoney = Schema.achievement.GetProperty("ransacked", "requiredMoney")

	if (value < requiredMoney) then
		return
	end

	local client = character:GetPlayer()

	if (client.ixOpenStorage and client.ixOpenStorage.storageInfo and IsValid(client.ixOpenStorage.storageInfo.entity)) then
		local target = client.ixOpenStorage.storageInfo.entity

		-- If the ragdoll is the same as the player retrieving the money, they're being resurrected and this achievement doesn't apply.
		if (target:GetNetVar("player") == client) then
			return
		end

		-- If the player is interacting with their locker, don't check for the achievement.
		if (IsValid(client.expLockersSession)) then
			return
		end

		if (client.ixOpenStorage.vars and client.ixOpenStorage.vars.isCorpse) then
			target = target
		elseif (target:IsPlayer() and target:IsRestricted()) then
			-- We're inspecting a tied up player
			target = target:GetCharacter()
		end

		local moneyBefore = target:GetMoney()

		if (moneyBefore < requiredMoney) then
			-- The money couldn't have been taken from the ragdoll, so we don't need to check if it was taken.
			return
		end

		-- TODO: This is a bit hacky, but Helix doesn't provide a hook for when money is taken from a storage.
		-- In sh_storage net.Receive("ixStorageMoneyGive") in Helix, the character money is set, right before it is taken (or given) to the storage.
		-- For this reason we will wait a frame, to check if the money has been taken from the ragdoll.
		timer.Simple(0, function()
			local isValidTarget = IsValid(target) or (target.GetPlayer and IsValid(target:GetPlayer()))

			if (not IsValid(client) or not isValidTarget) then
				return
			end

			local moneyAfter = target:GetMoney()

			if (moneyBefore - moneyAfter >= requiredMoney) then
				Schema.achievement.Progress("ransacked", client)
			end
		end)
	end
end

function Schema:CharacterAttributeUpdated(client, character, attributeKey, value)
	local attribute = ix.attributes.list[attributeKey]

	if (attribute and attribute.OnSetup) then
		-- client:GetCharacter() might be nil if the character is being created. For that reason we pass the character object.
		attribute:OnSetup(client, character:GetAttribute(attributeKey, value), character)
	end

	if (attributeKey == "strength") then
		local requiredAttribute = Schema.achievement.GetProperty("titans_strength", "requiredAttribute")

		if (value >= requiredAttribute) then
			Schema.achievement.Progress("titans_strength", client)
		end
	elseif (attributeKey == "dexterity") then
		local requiredAttribute = Schema.achievement.GetProperty("dextrous_rogue", "requiredAttribute")

		if (value >= requiredAttribute) then
			Schema.achievement.Progress("dextrous_rogue", client)
		end
	elseif (attributeKey == "acrobatics") then
		local requiredAttribute = Schema.achievement.GetProperty("natural_acrobat", "requiredAttribute")

		if (value >= requiredAttribute) then
			Schema.achievement.Progress("natural_acrobat", client)
		end
	elseif (attributeKey == "agility") then
		local requiredAttribute = Schema.achievement.GetProperty("agile_shadow", "requiredAttribute")

		if (value >= requiredAttribute) then
			Schema.achievement.Progress("agile_shadow", client)
		end
	end
end

function Schema:GetSalaryAmount(client, faction)
	local salary = faction.pay

	if (ix.config.Get("incomeMultiplier") ~= 1) then
		salary = salary * ix.config.Get("incomeMultiplier")
	end

	return salary
end

--[[

	Sandbox hooks (context/spawnmenu, spawning props, etc.)

--]]

function Schema:OnPhysgunFreeze(weapon, physObj, entity, client)
	if (not IsValid(physObj)) then
		return false
	end
end

--[[

	Spawning and Loadout hooks

--]]

function Schema:PlayerInitialSpawn(client)
	Schema.CleanupCorpses()
end

function Schema:PlayerSpawn(client)
	client:SetLocalVar("ragdoll", nil)

	-- Reset these so they don't interfere the next time the player dies
	client.expCorpseCharacter = nil
	client.expDropMode = nil
end

function Schema:PostPlayerLoadout(client)
	local character = client:GetCharacter()

	if (not character) then
		return
	end

	-- Make sure they're not still tied up (or tying or being tied) from a previous session.
	client:SetRestricted(false)
	client:SetNetVar("tying")
	client:SetNetVar("untying")
end

--[[

	Damage hooks

--]]

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

	if (damageInfo:IsDamageType(Schema.armorAffectedTypes)) then
		local damage = damageInfo:GetDamage()
		damage = Schema.armor.DamageAfterArmor(character, damage)

		damageInfo:SetDamage(damage)
	end
end

function Schema:PostEntityTakeDamage(entity, damageInfo, tookDamage)
	if (not entity:IsPlayer()) then
		return
	end

	-- Disable default viewpunch
	entity:SetViewPunchAngles(Angle(0, 0, 0))

	if (hook.Run("PlayerShouldViewPunch", entity, damageInfo) == false) then
		return
	end

	local force = damageInfo:GetDamageForce()
	local damage = damageInfo:GetDamage()

	force.z = math.max(force.z, damage) * 0.5
	force.y = math.max(force.z, damage) * 0.5
	force.x = math.max(force.z, damage) * 0.5

	-- Maximum knockback values (before it gets ridiculous):
	-- p (0 - 50)
	-- y (-45 - 45)
	-- r (-10 - 10)
	local pitch = math.Clamp(math.random(force.z * .7, force.z), 0, 50)
	local yaw = math.Clamp(math.random(-force.y * .5, force.y * .5), -45, 45)
	local roll = math.Clamp(math.random(-force.x * .1, force.x * .1), -10, 10)

	entity:ViewPunch(Angle(pitch, yaw, roll))
end

function Schema:PlayerShouldViewPunch(client, damageInfo)
	if (Schema.perk.GetOwned("concentration", client)) then
		local pitch = math.random(0, 4)
		local yaw = math.random(-2, 2)
		local roll = math.random(-1, 1)

		client:ViewPunch(Angle(pitch, yaw, roll))

		return false
	end
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

	if (not ammo or ammo:lower() ~= Schema.ammo.ConvertToAmmo("beanbag")) then
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

		if (IsValid(attacker) and attacker:IsPlayer()) then
			local weapon = attacker:GetActiveWeapon()
			local weaponIsSilenced = IsValid(weapon) and weapon.ixItem and weapon.ixItem.isSilenced
			local attackerIsStealthed = attacker:HasStealthActivated()
			local hasAssassinsCreedPerk = Schema.perk.GetOwned("assassins_creed", attacker)

			if (weaponIsSilenced and attackerIsStealthed and hasAssassinsCreedPerk) then
				local chance = Schema.perk.GetProperty("assassins_creed", "chance")

				if (math.random() < chance) then
					local bonusDamage = Schema.perk.GetProperty("assassins_creed", "bonusDamage")

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
			item:Remove()
			client:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav")
		end
	end

	-- Adjust melee damage based on perks and items.
	-- TODO: Check if ScalePlayerDamage is called for this type of melee damage
	if (damageInfo:IsDamageType(DMG_CLUB) or damageInfo:IsDamageType(DMG_SLASH)) then
		if (Schema.perk.GetOwned("blunt_defense", client)) then
			local damageScale = Schema.perk.GetProperty("blunt_defense", "damageScale")
			damageInfo:ScaleDamage(damageScale)
		end
	end

	-- Adjust fall damage based on perks and items.
	if (damageInfo:IsFallDamage()) then
		if (Schema.perk.GetOwned("leg_braces", client)) then
			local damageScale = Schema.perk.GetProperty("leg_braces", "damageScale")
			damageInfo:ScaleDamage(damageScale)
		end
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

	client:GetCharacter():GiveMoney(math.ceil(generator.price * .75))
end

--[[

	Healing hooks

--]]

function Schema:AdjustHealAmount(client, amount)
end

function Schema:PlayerHealed(client, target, item, healAmount)
	ix.log.Add(client, "playerHealed", target:Name(), healAmount)

	local buff, buffTable = Schema.buff.GetActive(client, "waning_ward")

	if (not buff) then
		Schema.buff.SetActive(client, "waning_ward")
		return
	end

	buffTable:Stack(client, buff)
end

--[[

	Death hooks

--]]

function Schema:ShouldSpawnClientRagdoll(client)
	return false
end

function Schema:ShouldRemoveRagdollOnDeath(client)
	return false
end

function Schema:OnPlayerCorpseNotCreated(client)
end

function Schema:OnPlayerCorpseCreated(client, entity)
	if (not ix.config.Get("dropItemsOnDeath", false) or not client:GetCharacter()) then
		return
	end

	local character = client.expCorpseCharacter or client:GetCharacter()
	local characterInventory = character:GetInventory()
	local width, height = characterInventory:GetSize()

	local inventory = ix.inventory.Create(width, height, os.time())
	inventory.vars.isCorpse = true
	entity.ixInventory = inventory

	entity.StartSearchCorpse = function(corpse, client)
		if (not IsValid(client)) then
			return
		end

		local baseTaskTime = ix.config.Get("corpseSearchTime", 1)
		local searchTime = Schema.GetDexterityTime(client, baseTaskTime)

		ix.storage.Open(client, entity.ixInventory, {
			entity = entity,
			name = "Corpse",
			searchText = "@searchingCorpse",
			searchTime = searchTime
		})
	end

	entity.GetDisplayName = function(corpse)
		local name = "Someone"

		if (IsValid(client)) then
			name = client:Name()
		end

		return name .. "'s Corpse"
	end

	entity.GetInventory = function(corpse)
		return corpse.ixInventory
	end

	entity.SetMoney = function(corpse, amount)
		corpse.ixMoney = amount
	end

	entity.GetMoney = function(corpse)
		return corpse.ixMoney or 0
	end

	hook.Run("OnPlayerCorpseFillInventory", client, inventory, entity)
end

function Schema:OnPlayerCorpseFillInventory(client, corpseInventory, entity)
	local character = client.expCorpseCharacter or client:GetCharacter()
	local dropMode = client.expDropMode or Schema.dropMode.RANDOM
	local characterInventory = character:GetInventory()
	local money = character:GetMoney()

	local hasConfusingPockets, confusingPocketsPerkTable = Schema.perk.GetOwned("confusing_pockets", client)
	local evenEquipped = bit.band(dropMode, Schema.dropMode.WITH_EQUIPPED) == Schema.dropMode.WITH_EQUIPPED
	local dropModeIsRandom = bit.band(dropMode, Schema.dropMode.RANDOM) == Schema.dropMode.RANDOM

	for _, slot in pairs(characterInventory.slots) do
		for _, item in pairs(slot) do
			if (item.noDrop) then
				continue
			end

			if (item:GetData("equip") and not evenEquipped) then
				continue
			end

			local shouldDropItem = false

			if (dropModeIsRandom) then
				local loseItemChance = 0.75

				if (hasConfusingPockets) then
					loseItemChance = loseItemChance * confusingPocketsPerkTable.modifyLoseChance
				end

				shouldDropItem = (math.random() > loseItemChance)
			else
				shouldDropItem = true
			end

			if (shouldDropItem) then
				if (item.hooks["drop"]) then
					item.player = client
					item.hooks["drop"](item)
					item.player = nil
				end

				item:Transfer(corpseInventory:GetID(), item.gridX, item.gridY, nil, false, true)
			end
		end
	end

	if (money > 0) then
		local amountToLose = money

		if (dropModeIsRandom) then
			local fractionToLose = 0.75

			if (hasConfusingPockets) then
				fractionToLose = fractionToLose * confusingPocketsPerkTable.modifyLoseChance
			end

			amountToLose = math.floor(math.random(1, money * fractionToLose))
		end

		character:TakeMoney(amountToLose)

		if (not entity.SetMoney) then
			error("Attempt to set money on an entity that doesn't support it: " .. tostring(entity))
		end

		entity:SetMoney(amountToLose)

		if (character:GetMoney() == 0) then
			Schema.achievement.Progress("boltless_wanderer", client)
		end
	end

	-- character:Save()
end

function Schema:DoPlayerDeath(client, attacker, damageinfo)
	Schema.HandlePlayerDeathCorpse(client)
end

function Schema:PlayerDeath(client, inflictor, attacker)
	local character = client:GetCharacter()

	if (not character) then
		return
	end

	Schema.achievement.Progress("favored_target", client)
end

--[[

	Interaction hooks

--]]

function Schema:PlayerUse(client, entity)
	if (entity:GetClass() ~= "prop_ragdoll") then
		return
	end

	if (entity.ixInventory and not ix.storage.InUse(entity.ixInventory) and entity.StartSearchCorpse) then
		local canSearch = hook.Run("CanPlayerSearchCorpse", client, entity) ~= false

		if (not canSearch) then
			return
		end

		entity:StartSearchCorpse(client)

		return false
	end
end

function Schema:PlayerInteractEntity(client, entity, option, data)
	if (entity:GetClass() ~= "prop_ragdoll") then
		return
	end

	local entityPlayer = entity:GetNetVar("player", NULL)

	if (not IsValid(entityPlayer)) then
		return
	end

	entity.OnOptionSelected = function(entity, client, option, data)
		if (client:IsRestricted()) then
			return
		end

		hook.Run("OnPlayerRagdollOptionSelected", client, entityPlayer, entity, option, data)
	end
end

function Schema:OnPlayerOptionSelected(target, client, option, data)
	if (option == L("untie", client)) then
		if (not client:IsRestricted() and target:IsPlayer() and target:IsRestricted() and not target:GetNetVar("untying")) then
			Schema.PlayerTryUntieTarget(client, target)
		end
	end
end

function Schema:OnPlayerRagdollOptionSelected(client, ragdollPlayer, ragdoll, option, data)
	if (ragdollPlayer:Alive()) then
		if (ragdollPlayer:IsRestricted() and not ragdollPlayer:GetNetVar("untying")) then
			if (option == L("untie", client)) then
				Schema.PlayerTryUntieTarget(client, ragdoll)
			elseif (option == L("searchTied", client)) then
				Schema.SearchPlayer(client, ragdollPlayer)
			end
		end

		return
	end

	if (option == L("searchCorpse", client) and ragdoll.StartSearchCorpse) then
		ragdoll:StartSearchCorpse(client)
		return
	end

	if (option == L("mutilateCorpse", client)) then
		local hasMutilatorPerk, mutilatorPerkTable = Schema.perk.GetOwned("mutilator", client)

		if (not hasMutilatorPerk) then
			return
		end

		if (hook.Run("CanPlayerMutilate", client, target, ragdoll) == false) then
			return
		end

		if (ragdoll:GetNetVar("mutilated", 0) >= mutilatorPerkTable.maximumMutilations) then
			return
		end

		local baseTaskTime = mutilatorPerkTable.mutilateTime
		local mutilateTime = Schema.GetDexterityTime(client, baseTaskTime)
		local healthIncrease = mutilatorPerkTable.healthIncrease

		client:SetAction("@mutilatingCorpse", mutilateTime)
		client:DoStaredAction(ragdoll, function()
			-- Double check, so players cant mutilate the same corpse at once.
			if (ragdoll:GetNetVar("mutilated", 0) >= mutilatorPerkTable.maximumMutilations) then
				return
			end

			local trace = client:GetEyeTraceNoCursor()

			Schema.BloodEffect(ragdoll, ragdoll:NearestPoint(trace.HitPos))
			client:EmitSound("npc/barnacle/barnacle_crunch" .. math.random(2, 3) .. ".wav")

			client:SetHealth(math.min(client:Health() + healthIncrease, client:GetMaxHealth()))
			ragdoll:SetNetVar("mutilated", ragdoll:GetNetVar("mutilated", 0) + 1)
		end, mutilateTime, function()
			if (IsValid(client)) then
				client:SetAction()
			end
		end)

		return
	end
end

function Schema:PlayerPerkBought(client, perk)
	Schema.achievement.Progress("perk_purveyor", client)
end

function Schema:CreateShipment(client, shipmentEntity)
	local itemCount = 0
	local itemSum = 0

	for uniqueID, amount in pairs(shipmentEntity.items) do
		local itemTable = ix.item.list[uniqueID]

		itemCount = itemCount + math.max(amount, 0)
		itemSum = itemSum + math.max(amount, 0) * (itemTable.price or 0)
	end

	local atLeast = Schema.achievement.GetProperty("master_trader", "atLeast")

	if (itemCount >= atLeast) then
		Schema.achievement.Progress("master_trader", client)
	end

	local hasMercantilePerk, mercantilePerkTable = Schema.perk.GetOwned("mercantile", client)

	if (hasMercantilePerk) then
		local rebate = itemSum * mercantilePerkTable.sumRebate

		if (rebate > 0) then
			client:GetCharacter():GiveMoney(rebate)
		end
	end
end

function Schema:InventoryItemAdded(sourceInventory, targetInventory, item)
	-- If the item has base_stackable and we find existing base_stackable items in the target inventory
	-- Check if the existing item can stack with the new item, if so, stack them.
	if (not item:IsBasedOn("base_stackable")) then
		return
	end

	local client = targetInventory:GetOwner()

	if (not client) then
		return
	end

	if (client.expLastSplit and client.expLastSplit + 0.1 > CurTime()) then
		-- Don't stack items if the player just tried to split them.
		return
	end

	local tallestStackItem = nil
	local tallestStack = 0

	for _, otherItem in pairs(targetInventory:GetItems()) do
		if (otherItem:IsBasedOn("base_stackable") and otherItem:CanStackWith(item)) then
			local otherStacks = otherItem:GetData("stacks", 1)

			if (otherStacks > tallestStack) then
				tallestStack = otherStacks
				tallestStackItem = otherItem
			end
		end
	end

	if (tallestStackItem) then
		tallestStackItem:Stack(item)
		return
	end
end

function Schema:GeneratorAdjustEarnings(generator, earningsData)
	local client = generator:GetItemOwner()

	if (not IsValid(client)) then
		return
	end

	local hasThievingPerk, thievingPerkTable = Schema.perk.GetOwned("thieving", client)

	if (hasThievingPerk) then
		earningsData.earnings = earningsData.earnings * thievingPerkTable.generatorEarningsMultiplier
	end

	local hasMetalshipPerk, metalshipPerkTable = Schema.perk.GetOwned("metalship", client)

	if (hasMetalshipPerk) then
		earningsData.earnings = earningsData.earnings * metalshipPerkTable.generatorEarningsMultiplier
	end
end

-- Fix Nexus doors not opening when using them
function Schema:PlayerUseDoor(client, door)
	if (game.GetMap() ~= "rp_c18_v2" or door:GetClass() ~= "func_door") then
		return
	end

	if (door:IsLocked() or door:GetNetVar("disabled")) then
		return
	end

	if (client:IsRestricted()) then
		return
	end

	door:Fire("open")
end
