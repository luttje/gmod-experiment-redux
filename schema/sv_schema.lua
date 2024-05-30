util.AddNetworkString("expFlashed")
util.AddNetworkString("expTearGassed")
util.AddNetworkString("expClearEntityInfoTooltip")

resource.AddFile("materials/experiment-redux/symbol_background.vmt")
resource.AddFile("materials/experiment-redux/logo.png")
resource.AddFile("materials/experiment-redux/arrow-down.png")
resource.AddFile("materials/experiment-redux/check.png")
resource.AddFile("materials/experiment-redux/close.png")

resource.AddFile("materials/experiment-redux/mission_available.png")
resource.AddFile("materials/experiment-redux/mission_unavailable.png")

-- JersonGaming's Model/Real RNG Ammo Boxes (https://steamcommunity.com/sharedfiles/filedetails/?id=1741790902)
-- Higher quality ammo boxes, they replace the default ones.
resource.AddWorkshop("1741790902")

-- Aperture Scientists Players (https://steamcommunity.com/sharedfiles/filedetails/?id=634829400)
-- Scientists for citizens, they can be used to create scientist monsters.
resource.AddWorkshop("634829400")
resource.AddFile("materials/models/experiment-redux/characters/guardian_scientist_sheet.vmt")
resource.AddFile("materials/models/experiment-redux/characters/guardian_scientist_sheet_bloody1.vmt")
resource.AddFile("materials/models/experiment-redux/characters/guardian_scientist_sheet_bloody2.vmt")
resource.AddFile("materials/models/experiment-redux/characters/guardian_scientist_sheet_bloody3.vmt")

-- We send the generated HTML and random content to the client so it can be loaded only when its needed.
AddCSLuaFile("content/cl_html.generated.lua")
AddCSLuaFile("content/sh_names.lua")
AddCSLuaFile("content/sh_descriptions.lua")

Schema.corpses = Schema.corpses or {}
Schema.dropMode = {
	RANDOM = 1,
	ALL = 2,
	WITH_EQUIPPED_WEAPONS = 4,
	WITH_EQUIPPED_ARMOR = 8,
}

ix.log.AddType("playerHealed", function(client, ...)
	local arg = {...}
	return Format("%s has healed %s for %d hp", client:Name(), arg[1], arg[2])
end, FLAG_WARNING)

ix.log.AddType("perkBought", function(client, ...)
	local arg = { ... }
	return Format("%s bought the perk '%s'", client:Name(), arg[1])
end, FLAG_WARNING)

ix.log.AddType("perkTaken", function(client, ...)
	local arg = { ... }
	return Format("%s lost the perk '%s'", client:Name(), arg[1])
end, FLAG_WARNING)

ix.log.AddType("generatorEarn", function(client, ...)
	local arg = { ... }
	return Format("%s earned %s from their generator", client:Name(), ix.currency.Get(arg[1]))
end, FLAG_SUCCESS)

ix.log.AddType("generatorDestroy", function(client, ...)
	local arg = { ... }
	return Format("%s destroyed a generator belonging to %s", IsValid(client) and client:Name() or "an unknown player",
		IsValid(arg[1]) and arg[1]:Name() or "an unknown player")
end, FLAG_WARNING)

ix.log.AddType("achievementAchieved", function(client, ...)
	local arg = { ... }
	return Format("%s achieved the achievement '%s' and earned %d", client:Name(), arg[1], arg[2])
end, FLAG_WARNING)

ix.log.AddType("allianceCreated", function(client, ...)
	local arg = { ... }
	return Format("%s created the alliance '%s'", client:Name(), arg[1])
end, FLAG_WARNING)

ix.log.AddType("allianceDeleted", function(client, ...)
	local arg = { ... }
	return Format("%s deleted the alliance '%s'", client:Name(), arg[1])
end, FLAG_WARNING)

ix.log.AddType("allianceInvited", function(client, ...)
	local arg = { ... }
	return Format("%s invited %s to the alliance '%s'", client:Name(), arg[1]:Name(), arg[2])
end, FLAG_WARNING)

ix.log.AddType("allianceJoined", function(client, ...)
	local arg = { ... }
	return Format("%s joined the alliance '%s'", client:Name(), arg[1])
end, FLAG_WARNING)

ix.log.AddType("allianceKicked", function(client, ...)
	local arg = { ... }
	return Format("%s kicked %s from the alliance '%s'", client:Name(), arg[1]:Name(), arg[2])
end, FLAG_WARNING)

ix.log.AddType("allianceLeft", function(client, ...)
	local arg = { ... }
	return Format("%s left the alliance '%s'", client:Name(), arg[1])
end, FLAG_WARNING)

ix.log.AddType("allianceRankSet", function(client, ...)
	local arg = { ... }
	return Format("%s set %s's rank to %s in the alliance '%s'", client:Name(), arg[1]:Name(), arg[2], arg[3])
end, FLAG_WARNING)

ix.log.AddType("schemaDebug", function(client, ...)
	local arg = { ... }
	return Format("(%s) function: %s, debug log: %s", client:Name(), arg[1], arg[2])
end, FLAG_DANGER)

--- ! WORKAROUND for helix bug where inventory that is closed doesn't remove receivers.
--- @param inventory Inv
function Schema.CloseInventory(inventory)
	if (not inventory.storageInfo) then
		-- Can happen for a character's inventory, while nobody is searching them
		return
	end

	ix.storage.Close(inventory)

	-- TODO: Shouldn't this happen automatically? Helix bug?
	for receiver, _ in pairs(inventory.receivers) do
		-- Remove all receivers, except the owner (or they wont be able to interact in their own inventory)
		if (receiver == inventory:GetOwner()) then
			continue
		end

		inventory.receivers[receiver] = nil
	end
end

--- Use this to force an entity info tooltip to update.
--- For example when a player is being tied up, you will want to update the tooltip to show its done.
--- @param client Player
--- @param targetEntity? Entity
function Schema.PlayerClearEntityInfoTooltip(client, targetEntity)
	net.Start("expClearEntityInfoTooltip")
	net.WriteEntity(targetEntity or Entity(0))
	net.Send(client)
end

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

function Schema.BloodEffect(entity, position, scale, force)
	if (not scale) then
		scale = 0.5
	end

	if (not force) then
		force = VectorRand() * 80
	end

	local effectData = EffectData()
	effectData:SetOrigin(position)
	effectData:SetNormal(force)
	effectData:SetScale(scale)
	util.Effect("exp_blood_smoke", effectData, true, true)

	local effectData = EffectData()
	effectData:SetOrigin(position)
	effectData:SetEntity(entity)
	effectData:SetStart(position)
	effectData:SetScale(scale)
	util.Effect("BloodImpact", effectData, true, true)

	local trace = {}
	trace.start = position
	trace.endpos = trace.start
	trace.filter = entity
	trace = util.TraceLine(trace)

	util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
end

local newTiedBoneAngles = {
	["ValveBiped.Bip01_L_UpperArm"] = Angle(20, 8.8, 0),
	["ValveBiped.Bip01_L_Forearm"] = Angle(15, 0, 0),
	["ValveBiped.Bip01_L_Hand"] = Angle(0, 0, 75),
	["ValveBiped.Bip01_R_Forearm"] = Angle(-15, 0, 0),
	["ValveBiped.Bip01_R_Hand"] = Angle(0, 0, -75),
	["ValveBiped.Bip01_R_UpperArm"] = Angle(-20, 16.6, 0),
}
function Schema.SetPlayerTiedBones(client, enabled)
	if (enabled) then
		client.expIgnoreBoneManipulation = {}
	else
		client.expIgnoreBoneManipulation = nil
	end

	for boneName, angles in pairs(newTiedBoneAngles) do
		local boneIndex = client:LookupBone(boneName)

		if (boneIndex) then
			client:ManipulateBoneAngles(boneIndex, enabled and angles or Angle(0, 0, 0))

			if (enabled) then
				client.expIgnoreBoneManipulation[boneIndex] = true
			end
		end
	end
end

function Schema.TiePlayer(client)
	local ragdollIndex = client:GetLocalVar("ragdoll")
	local ragdoll = ragdollIndex and Entity(ragdollIndex) or nil

	if (IsValid(ragdoll)) then
		local hasBadDreamer = Schema.perk.GetOwned("bad_dreamer", client)

		if (hasBadDreamer) then
			return false
		end

		-- When the player is tied up while fallen over, move their stored weapon information.
		-- Otherwise, when they get up their weapons will be returned to them.
		if (ragdoll.ixActiveWeapon) then
			client.expTiedActiveWeapon = ragdoll.ixActiveWeapon
			ragdoll.ixActiveWeapon = nil
		end

		if (ragdoll.ixWeapons) then
			client.expTiedWeapons = ragdoll.ixWeapons
			ragdoll.ixWeapons = {}
		end
	end

	Schema.SetPlayerTiedBones(client, true)
	client:SetNetVar("tied", true)
	client:SetRestricted(true, true)
	client:SetNetVar("beingTied")
	client:NotifyLocalized("fTiedUp")
	client:Flashlight(false)

	client.expRunSpeedBeforeTied = client:GetRunSpeed()
	client:SetRunSpeed(client:GetWalkSpeed())

	-- Allow them to break free, if they react fast enough to a key press.
	local breakFreeTimerName = "expBreakFree" .. client:SteamID64()
	local breakFreeMaxReactDuration = ix.config.Get("breakFreeMaxReactDuration")

	Schema.TiedPlayerResetBreakFree(client)

	timer.Create(breakFreeTimerName, breakFreeMaxReactDuration, 0, function()
		if (not IsValid(client)) then
			timer.Remove(breakFreeTimerName)
			return
		end

		if (client.expNextBreakFreeTime > CurTime()) then
			return
		end

		if (client.expCanBreakFree) then
			if (client.expCanBreakFree.untilTime < CurTime()) then
				Schema.TiedPlayerResetBreakFree(client)
			end

			return
		end

		-- Random check to see if player can break free, agility only increases how often the chance is checked.
		local breakFreeChancePercent = ix.config.Get("breakFreeChancePercent")
		local canBreakFree = math.random(1, 100) <= breakFreeChancePercent

		if (not canBreakFree) then
			return
		end

		-- Send a message to the client to show a break free prompt.
		client.expCanBreakFree = {
			untilTime = CurTime() + breakFreeMaxReactDuration,
			randomKey = math.random(KEY_1, KEY_9), -- TODO: Let's hope nobody rebound these keys, we should make this configurable.
		}
		client:SetNetVar("canBreakFreeKey", client.expCanBreakFree.randomKey)
	end)
end

function Schema.TiedPlayerResetBreakFree(client, additionalTime)
	local breakFreeMaxReactDuration = ix.config.Get("breakFreeMaxReactDuration")
	local baseBreakFreeInterval = ix.config.Get("breakFreeIntervalSeconds")
	local agilityFraction = Schema.GetAttributeFraction(client:GetCharacter(), "agility")

	client.expCanBreakFree = nil
	client:SetNetVar("canBreakFreeKey")

	baseBreakFreeInterval = math.max(baseBreakFreeInterval - (baseBreakFreeInterval * agilityFraction), breakFreeMaxReactDuration + (baseBreakFreeInterval * .05))
	client.expNextBreakFreeTime = CurTime() + baseBreakFreeInterval + (additionalTime or 0)
end

function Schema.TiedPlayerPressedBreakFree(client, key)
	local canBreakFreeKey = client:GetNetVar("canBreakFreeKey")

	if (not canBreakFreeKey) then
		return
	end

	-- Wrong button, remove their chance to break free (or they'd just spam all buttons)
	if (canBreakFreeKey ~= key) then
		Schema.TiedPlayerResetBreakFree(client)
		return
	end

	client.expCanBreakFree = nil
	client:SetNetVar("canBreakFreeKey")

	local baseTaskTime = 15
	local taskTime = Schema.GetDexterityTime(client, baseTaskTime)

	local hasQuickHands, quickHandsPerkTable = Schema.perk.GetOwned("quick_hands", client)

	if (hasQuickHands) then
		taskTime = taskTime * quickHandsPerkTable.tieTimeMultiplier
	end

	taskTime = math.Clamp(taskTime, 2, baseTaskTime)

	client:SetNetVar("tiedBreakingFree", true)
	client:SetAction("@tiedBreakingFree", taskTime)

	ix.chat.Send(client, "me", L("tiedBreakingFreeMe", client))

	Schema.TiedPlayerResetBreakFree(client, taskTime)

	client:DoStandStillAction(function()
		client:SetNetVar("tiedBreakingFree")

		Schema.UntiePlayer(client)

		hook.Run("OnPlayerBecameUntied", client, client)
	end, taskTime, function()
		if (IsValid(client)) then
			client:SetAction()
			client:SetNetVar("tiedBreakingFree")
		end
	end)
end

function Schema.UntiePlayer(client)
	local ragdollIndex = client:GetLocalVar("ragdoll")
	local ragdoll = ragdollIndex and Entity(ragdollIndex) or nil

	local breakFreeTimerName = "expBreakFree" .. client:SteamID64()
	timer.Remove(breakFreeTimerName)

	client:SetNetVar("canBreakFreeKey")
	client:SetNetVar("tied")
	client:SetRestricted(false)
	client:SetNetVar("beingUntied")
	client:NotifyLocalized("fUntied")
	Schema.SetPlayerTiedBones(client, false)

	if (client.expRunSpeedBeforeTied) then
		client:SetRunSpeed(client.expRunSpeedBeforeTied)
		client.expRunSpeedBeforeTied = nil
	end

	-- If they have weapon information stored, give it back to their ragdoll.
	if (IsValid(ragdoll)) then
		if (client.expTiedActiveWeapon) then
			ragdoll.ixActiveWeapon = client.expTiedActiveWeapon
		end

		if (client.expTiedWeapons) then
			ragdoll.ixWeapons = client.expTiedWeapons
		end
	else
		-- If they don't have a ragdoll, return their weapons to them.
		if (client.expTiedWeapons) then
			for _, v in ipairs(client.expTiedWeapons) do
				if (v.class) then
					local weapon = client:Give(v.class, true)

					if (v.item) then
						weapon.ixItem = v.item
					end

					client:SetAmmo(v.ammo, weapon:GetPrimaryAmmoType())
					weapon:SetClip1(v.clip)
				elseif (v.item and v.invID == v.item.invID) then
					v.item:Equip(client, true, true)
					client:SetAmmo(v.ammo, client.carryWeapons[v.item.weaponCategory]:GetPrimaryAmmoType())
				end
			end
		end

		if (client.expTiedActiveWeapon) then
			if (client:HasWeapon(client.expTiedActiveWeapon)) then
				client:SetActiveWeapon(client:GetWeapon(client.expTiedActiveWeapon))
			else
				local weapons = client:GetWeapons()
				if (#weapons > 0) then
					client:SetActiveWeapon(weapons[1])
				end
			end
		end
	end

	client.expTiedActiveWeapon = nil
	client.expTiedWeapons = nil
end

function Schema.PlayerTryUntieTarget(client, target)
	local lookTarget = target

	if (IsValid(target:GetNetVar("player"))) then
		target = target:GetNetVar("player")
	end

	local canPerform, speedMultiplier = hook.Run("CanPlayerUntie", client, target)

	if (canPerform == false) then
		return false
	end

	local hasHurrymanPerk, hurrymanPerkTable = Schema.perk.GetOwned("hurryman", client)
	local baseTaskTime = 5
	local untieSpeed = Schema.GetDexterityTime(client, baseTaskTime)

	if (speedMultiplier) then
		untieSpeed = untieSpeed * speedMultiplier
	end

	if (hasHurrymanPerk) then
		untieSpeed = untieSpeed * hurrymanPerkTable.untieTimeMultiplier
	end

	target:SetAction("@beingUntied", untieSpeed)
	target:SetNetVar("beingUntied", true)

	client:SetAction("@unTying", untieSpeed)

	client:DoStaredAction(lookTarget, function()
		Schema.UntiePlayer(target)
		Schema.PlayerClearEntityInfoTooltip(client)

		hook.Run("OnPlayerBecameUntied", target, client)
	end, untieSpeed, function()
		if (IsValid(target)) then
			target:SetNetVar("beingUntied")
			target:SetAction()
		end

		if (IsValid(client)) then
			client:SetAction()
			Schema.PlayerClearEntityInfoTooltip(client)
		end
	end)
end

--- Knock out a player with chloroform.
--- @param client Player
--- @param duration? number
function Schema.ChloroformPlayer(client, duration)
	duration = duration or 20

	client:SetNetVar("beingChloroformed")
	client:NotifyLocalized("fChloroformed")
	client:SetRagdolled(true, duration)
end

function Schema.MakeExplosion(position, scale)
	local effectData = EffectData()

	effectData:SetOrigin(position)
	effectData:SetScale(scale)

	util.Effect("explosion", effectData, true, true)
end

function Schema.GetHealAmount(client, healAmount)
	local attributeIncrement = 1 + (Schema.GetAttributeFraction(client:GetCharacter(), "medical") * 1.5)

	healAmount = healAmount * attributeIncrement

	healAmount = hook.Run("AdjustHealAmount", client, healAmount) or healAmount

	return healAmount
end

function Schema.GetDexterityTime(client, time)
	local attributeFraction = math.max(1, (1 + Schema.GetAttributeFraction(client:GetCharacter(), "dexterity")) * 1.5)

	return time / attributeFraction
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

function Schema.CleanupCorpses(maxCorpses)
	maxCorpses = maxCorpses or ix.config.Get("corpseMax", 8)
	local toRemove = {}

	if (#Schema.corpses > maxCorpses) then
		for k, corpse in ipairs(Schema.corpses) do
			if (! IsValid(corpse)) then
				toRemove[#toRemove + 1] = k
			elseif (#Schema.corpses - #toRemove > maxCorpses) then
				corpse:Remove()
				toRemove[#toRemove + 1] = k
			end
		end
	end

	for k, _ in ipairs(toRemove) do
		table.remove(Schema.corpses, k)
	end
end

function Schema.HandlePlayerDeathCorpse(client)
	if (hook.Run("ShouldSpawnPlayerCorpse") == false) then
		return
	end

	local maxCorpses = ix.config.Get("corpseMax", 8)

	if (maxCorpses == 0) then
		hook.Run("OnPlayerCorpseNotCreated", client)
		return
	end

	local entity = IsValid(client.ixRagdoll) and client.ixRagdoll or client:CreateServerRagdoll()
	local decayTime = ix.config.Get("corpseDecayTime", 60)
	local uniqueID = "ixCorpseDecay" .. entity:EntIndex()

	entity:SetNetVar("corpseOwnerID", client:GetCharacter():GetID())

	entity:RemoveCallOnRemove("fixer")
	entity:CallOnRemove("expPersistentCorpse", function(ragdoll)
		if (IsValid(client) and not client:Alive()) then
			client:SetLocalVar("ragdoll", nil)
		end

		local index

		for k, v in ipairs(Schema.corpses) do
			if (v == ragdoll) then
				index = k
				break
			end
		end

		if (index) then
			table.remove(Schema.corpses, index)
		end

		if (timer.Exists(uniqueID)) then
			timer.Remove(uniqueID)
		end

		if (not client.expCorpseCharacter and not client:GetCharacter()) then
			-- Can happen when the server is shutting down, removing all ents
			return
		end

		hook.Run("OnPlayerCorpseRemoved", client, ragdoll)
	end)

	if (decayTime > 0) then
		local visualDecayTime = math.max(decayTime * .1, math.min(10, decayTime))

		timer.Create(uniqueID, decayTime - visualDecayTime, 1, function()
			if (IsValid(entity)) then
				Schema.DecayEntity(entity, visualDecayTime)
			else
				timer.Remove(uniqueID)
			end
		end)
	end

	-- Remove reference to ragdoll so it isn't removed on spawn when SetRagdolled is called
	client.ixRagdoll = nil
	-- Remove reference to the player so no more damage can be dealt
	entity.ixPlayer = nil

	Schema.corpses[#Schema.corpses + 1] = entity

	if (#Schema.corpses >= maxCorpses) then
		Schema.CleanupCorpses(maxCorpses)
	end

	client:SetLocalVar("ragdoll", entity:EntIndex())

	hook.Run("OnPlayerCorpseCreated", client, entity)
end

function Schema.SearchPlayer(client, target)
	if (not target:GetCharacter() or not target:GetCharacter():GetInventory()) then
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

	entity:SetRenderMode(RENDERMODE_TRANSALPHA)

	local name = "Decay: " .. index

	timer.Create(name, 1, 0, function()
		alpha = alpha - subtract

		if (not IsValid(entity)) then
			timer.Remove(name)
			return
		end

		local color = entity:GetColor()
		local decayed = math.Clamp(math.ceil(alpha), 0, 255)

		if (decayed > 0) then
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
