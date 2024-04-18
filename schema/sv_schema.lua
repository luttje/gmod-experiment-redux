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
	return amount * Schema.GetAttributeFraction(character, "medical")
end

function Schema.GetDexterityTime(character, time)
	return time * Schema.GetAttributeFraction(character, "dexterity")
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

Schema.dropMode = {
	RANDOM = 1,
	ALL = 2,
	WITH_EQUIPPED = 4
}

--- Example usage:
--- Schema.PlayerDropCharacterItems(client, client:GetCharacter(), bit.bor(Schema.dropMode.ALL, Schema.dropMode.WITH_EQUIPPED))
--- Or simply:
--- Schema.PlayerDropCharacterItems(client, client:GetCharacter(), Schema.dropMode.RANDOM)
---@param client Player The player to drop items for.
---@param character table The character to drop items for.
---@param dropMode number The drop mode to use.
function Schema.PlayerDropCharacterItems(client, character, dropMode)
	local inventory = character:GetInventory()
	local money = character:GetMoney()
	local hasConfusingPockets = Schema.perk.GetOwned("confusing_pockets", client)
	local evenEquipped = bit.band(dropMode, Schema.dropMode.WITH_EQUIPPED) == Schema.dropMode.WITH_EQUIPPED
	local dropModeIsRandom = bit.band(dropMode, Schema.dropMode.RANDOM) == Schema.dropMode.RANDOM
	local dropInfo = {
		inventory = {},
		money = money
	}

	for _, item in pairs(inventory:GetItems()) do
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
				loseItemChance = loseItemChance * Schema.perk.GetProperty("confusing_pockets", "modifyLoseChance")
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

			item.invID = 0
			inventory:Remove(item.id, false, true)
			dropInfo.inventory[#dropInfo.inventory + 1] = item
		end
	end

	if (money > 0) then
		local amountToLose = money

		if (dropModeIsRandom) then
			local fractionToLose = 0.75

			if (hasConfusingPockets) then
				fractionToLose = fractionToLose * Schema.perk.GetProperty("confusing_pockets", "modifyLoseChance")
			end

			amountToLose = math.floor(math.random(1, money * fractionToLose))
		end

		character:TakeMoney(amountToLose)
		dropInfo.money = amountToLose

		if (character:GetMoney() == 0) then
			Schema.achievement.Progress(client, "boltless_wanderer", 1)
		end
	end

	hook.Run("CreatePlayerDropItemsContainerEntity", client, character, dropInfo)
	character:Save()
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
