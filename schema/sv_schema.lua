util.AddNetworkString("exp_Flashed")
util.AddNetworkString("exp_TearGassed")

local L = Format

ix.log.AddType("perkBought", function(client, ...)
	local arg = { ... }
	return L("%s bought the perk '%s'", client:Name(), arg[1])
end, FLAG_WARNING)

ix.log.AddType("generatorEarn", function(client, ...)
	local arg = { ... }
	return L("%s earned %s from their generator", client:Name(), ix.currency.Get(arg[1]))
end, FLAG_SUCCESS)

ix.log.AddType("generatorDestroy", function(client, ...)
	local arg = { ... }
	return L("%s destroyed a generator belonging to %s", IsValid(client) and client:Name() or "an unknown player", IsValid(arg[1]) and arg[1]:Name() or "an unknown player")
end, FLAG_WARNING)

ix.log.AddType("achievementAchieved", function(client, ...)
	local arg = { ... }
	return L("%s achieved the achievement '%s' and earned %d", client:Name(), arg[1], arg[2])
end, FLAG_WARNING)

ix.log.AddType("allianceCreated", function(client, ...)
	local arg = { ... }
	return L("%s created the alliance '%s'", client:Name(), arg[1])
end, FLAG_WARNING)

ix.log.AddType("allianceDeleted", function(client, ...)
	local arg = { ... }
	return L("%s deleted the alliance '%s'", client:Name(), arg[1])
end, FLAG_WARNING)

ix.log.AddType("allianceInvited", function(client, ...)
	local arg = { ... }
	return L("%s invited %s to the alliance '%s'", client:Name(), arg[1]:Name(), arg[2])
end, FLAG_WARNING)

ix.log.AddType("allianceKicked", function(client, ...)
	local arg = { ... }
	return L("%s kicked %s from the alliance '%s'", client:Name(), arg[1]:Name(), arg[2])
end, FLAG_WARNING)

ix.log.AddType("allianceLeft", function(client, ...)
	local arg = { ... }
	return L("%s left the alliance '%s'", client:Name(), arg[1])
end, FLAG_WARNING)

ix.log.AddType("allianceRankSet", function(client, ...)
	local arg = { ... }
	return L("%s set %s's rank to %s in the alliance '%s'", client:Name(), arg[1]:Name(), arg[2], arg[3])
end, FLAG_WARNING)

ix.log.AddType("schemaDebug", function(client, ...)
	local arg = {...}
	return L("(%s) function: %s, debug log: %s", client:Name(), arg[1], arg[2])
end, FLAG_DANGER)

function Schema.ImpactEffect(position, scale, withSound)
	local effectData = EffectData()

	effectData:SetStart(position)
	effectData:SetOrigin(position)
	effectData:SetScale(scale)

	util.Effect("GlassImpact", effectData, true, true)

	if (withSound) then
		sound.Play("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", position)
	end
end

function Schema.TiePlayer(client)
	client:SetRestricted(true)
	client:SetNetVar("tying")
	client:NotifyLocalized("fTiedUp")
	client:Flashlight(false)
end

function Schema.UntiePlayer(client)
	client:SetRestricted(false)
	client:SetNetVar("untying")
	client:NotifyLocalized("fUntied")
end

function Schema.ChloroformPlayer(client)
	client:SetNetVar("beingChloroformed")
	client:SetRagdolled(true, 0, 5)
end

function Schema.MakeExplosion(position, scale)
	local effectData = EffectData()

	effectData:SetOrigin(position)
	effectData:SetScale(scale)

	util.Effect("explosion", effectData, true, true)
end

function Schema.GetHealAmount(character, amount)
	return amount * Schema.GetAttributeFraction(character, "med")
end

function Schema.GetDexterityTime(character, time)
	return time * Schema.GetAttributeFraction(character, "dex")
end

function Schema.BustDownDoor(client, door, force)
	door.bustedDown = true
	door:SetNotSolid(true)
	door:DrawShadow(false)
	door:SetNoDraw(true)
	door:EmitSound("physics/wood/wood_box_impact_hard3.wav")
	door:Fire("Unlock", "", 0)

	local detachedDoor = ents.Create("prop_physics")

	detachedDoor:SetCollisionGroup(COLLISION_GROUP_WORLD)
	detachedDoor:SetAngles(door:GetAngles())
	detachedDoor:SetModel(door:GetModel())
	detachedDoor:SetSkin(door:GetSkin())
	detachedDoor:SetPos(door:GetPos())
	detachedDoor:Spawn()

	local physicsObject = detachedDoor:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		if (not force) then
			if (IsValid(client)) then
				physicsObject:ApplyForceCenter((door:GetPos() - client:GetPos()):Normalize() * 10000)
			end
		else
			physicsObject:ApplyForceCenter(force)
		end
	end

	Schema.DecayEntity(detachedDoor, 300)

	timer.Create("Reset Door: " .. door:EntIndex(), 300, 1, function()
		if (IsValid(door)) then
			door:SetNotSolid(false)
			door:DrawShadow(true)
			door:SetNoDraw(false)
			door.bustedDown = nil
		end
	end)
end

-- TODO: Move this logic to the items
function Schema.DropWearableItems(client)
	local spawnPos = client:GetPos() + Vector(0, 0, math.random(1, 48))
	local character = client:GetCharacter()

	if (character:GetData("shoes")) then
		ix.item.Spawn("running_shoes", spawnPos)
	end

	if (character:GetData("helmet")) then
		ix.item.Spawn("helmet", spawnPos)
	end

	if (character:GetData("knuckles")) then
		ix.item.Spawn("brass_knuckles", spawnPos)
	end

	character:SetData("knuckles", false)
	character:SetData("helmet", false)
	character:SetData("shoes", false)
end

function Schema.PlayerDropRandomItems(client, evenEquipped)
	local confusingPockets = Schema.perk.GetOwned(PRK_CONFUSINGPOCKETS, client)
	local character = client:GetCharacter()
	local inventory = character:GetInventory()
	local cash = character:GetMoney()
	local dropInfo = {
		inventory = {},
		cash = cash
	}

	Schema.DropWearableItems(client)

	for _, item in pairs(inventory:GetItems(false)) do
		local losesItem = (confusingPockets and math.random() <= 0.5) or (not confusingPockets and math.random() <= 0.75)

		if (not losesItem) then
			continue
		end

		if (item:GetData("equip") and not evenEquipped) then
			continue
		end

		item.invID = 0
		inventory:Remove(item.id, false, true)
		dropInfo.inventory[#dropInfo.inventory + 1] = item
	end

	if (cash > 0) then
		local amount = math.ceil(math.max(math.random(1, cash), cash / 8))

		if (confusingPockets) then
			amount = math.ceil(math.max(math.random(1, cash * 0.75), cash / 8))
		end

		character:TakeMoney(amount, "Death")
		dropInfo.money = amount

		if (character:GetMoney() == 0) then
			Schema.achievement.Progress(client, ACH_BOLTLESS_WANDERER, 1)
		end
	end

	hook.Run("CreatePlayerDropItemsContainerEntity", client, character, dropInfo)
	client:GetCharacter():Save()
end

function Schema.PlayerDropAllItems(client, evenEquipped, disconnectPenalty)
	local character = client:GetCharacter()
	local inventory = character:GetInventory()
	local cash = character:GetMoney()
	local dropInfo = {
		inventory = {},
		cash = cash
	}

	Schema.DropWearableItems(client)

	for _, item in pairs(inventory:GetItems(false)) do
		if (item:GetData("equip") and not evenEquipped) then
			continue
		end

		item.invID = 0
		inventory:Remove(item.id, false, true)
		dropInfo.inventory[#dropInfo.inventory + 1] = item
	end

	if (cash > 0) then
		local amount = cash

		character:TakeMoney(amount, "Death")
		dropInfo.money = amount

		Schema.achievement.Progress(client, ACH_BOLTLESS_WANDERER, 1)
	end

	hook.Run("CreatePlayerDropItemsContainerEntity", client, character, dropInfo)
	client:GetCharacter():Save()
end

function Schema.SearchPlayer(client, target)
	if (! target:GetCharacter() or ! target:GetCharacter():GetInventory()) then
		return false
	end

	local name = hook.Run("GetDisplayedName", target) or target:Name()
	local inventory = target:GetCharacter():GetInventory()

	ix.storage.Open(client, inventory, {
		entity = target,
		name = name
	})

	return true
end

function Schema.MakeFlushToGround(entity, position, normal)
	local lowestPoint = entity:NearestPoint(position - (normal * 512))
	entity:SetPos(position + (entity:GetPos() - lowestPoint))
end

function Schema.CanSeePosition(client, position, allowance, ignoreEnts)
	local trace = {}

	trace.mask = CONTENTS_SOLID
		+ CONTENTS_MOVEABLE
		+ CONTENTS_OPAQUE
		+ CONTENTS_DEBRIS
		+ CONTENTS_HITBOX
		+ CONTENTS_MONSTER
	trace.start = client:GetShootPos()
	trace.endpos = position
	trace.filter = { client }

	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts)
		else
			table.Add(trace.filter, ents.GetAll())
		end
	end

	trace = util.TraceLine(trace)

	if (trace.Fraction >= (allowance or 0.75)) then
		return true
	end
end

function Schema.DecayEntity(entity, seconds, callback)
	local color = entity:GetColor()
	local alpha = color.a
	local subtract = math.ceil(alpha / seconds)
	local index

	if (entity.decaying) then
		index = entity.decaying
	else
		index = tostring({}) -- will be unique
		entity.decaying = index
	end

	local name = "Decay: " .. index

	timer.Create(name, 1, 0, function()
		alpha = alpha - subtract

		if (not IsValid(entity)) then
			timer.Remove(name)
			return
		end

		local color = entity:GetColor()
		local decayed = math.Clamp(math.ceil(alpha), 0, 255)

		if (color.a > 0) then
			entity:SetColor(Color(color.r, color.g, color.b, decayed))
			return
		end

		if (callback) then
			callback()
		end

		entity:Remove()
		timer.Remove(name)
	end)
end

function Schema.CheckCharacterDisconnectPenalty(client, character)
	local requiredGraceAfterDamage = ix.config.Get("requiredGraceAfterDamage")
	local lastTakeDamage = client.expLastDamage
	local curTime = CurTime()

	if (not lastTakeDamage or curTime - lastTakeDamage > requiredGraceAfterDamage) then
		return
	end

	Schema.PlayerDropAllItems(client, nil, nil, true)
end
