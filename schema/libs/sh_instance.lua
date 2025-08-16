--[[
	An instancing system that allows entities to be visible only to specific players.
	By default, all players are in the global instance (nil).
	When a player is moved to a specific instance, they can only see entities that belong to that instance.

	Instances are identified by unique strings (typically SteamID64).
	Entities can belong to one instance at a time.
	Players can be in one instance at a time.

	Each instance can have an owner. When the owner disconnects, the instance is automatically destroyed.

	TODO: Prevent in-character chat
	TODO: Prevent server-side only EmitSounds from playing (only shared calls to EmitSound can be stopped by EntityEmitSound)
]]

--- @class InstanceData
--- @field entities table<Entity, boolean> Entities belonging to this instance
--- @field players table<Player, boolean> Players in this instance
--- @field owner Player|nil The client that owns this instance

Schema.instance = ix.util.GetOrCreateLibrary("instance", {
	instances = {},    -- instanceID -> InstanceData
	playerInstances = {}, -- Player -> instanceID
	entityInstances = {}, -- Entity -> instanceID
	instanceOwners = {} -- instanceID -> Player (for quick lookup)
})

if (SERVER) then
	--- Creates a new instance or returns existing one
	--- @param instanceID string
	--- @param owner Player|nil Optional owner of the instance
	--- @return InstanceData
	function Schema.instance.CreateInstance(instanceID, owner)
		if (not Schema.instance.instances[instanceID]) then
			Schema.instance.instances[instanceID] = {
				entities = {},
				players = {},
				owner = owner
			}

			-- Track ownership for quick lookup
			if (IsValid(owner)) then
				Schema.instance.instanceOwners[instanceID] = owner
			end
		end

		return Schema.instance.instances[instanceID]
	end

	--- Sets the owner of an instance
	--- @param instanceID string
	--- @param owner Player The new owner
	function Schema.instance.SetInstanceOwner(instanceID, owner)
		if (not IsValid(owner)) then
			ix.util.SchemaErrorNoHalt("Attempted to set invalid owner for instance '" .. tostring(instanceID) .. "'\n")
			return
		end

		local instance = Schema.instance.instances[instanceID]
		if (not instance) then
			ix.util.SchemaErrorNoHalt("Attempted to set owner for non-existent instance '" ..
				tostring(instanceID) .. "'\n")
			return
		end

		local oldOwner = instance.owner
		instance.owner = owner
		Schema.instance.instanceOwners[instanceID] = owner

		hook.Run("InstanceOwnerChanged", instanceID, owner, oldOwner)
	end

	--- Gets the owner of an instance
	--- @param instanceID string
	--- @return Player|nil
	function Schema.instance.GetInstanceOwner(instanceID)
		local instance = Schema.instance.instances[instanceID]
		return instance and instance.owner or nil
	end

	--- Checks if a player owns an instance
	--- @param client Player
	--- @param instanceID string
	--- @return boolean
	function Schema.instance.IsInstanceOwner(client, instanceID)
		local instance = Schema.instance.instances[instanceID]
		return instance and instance.owner == client or false
	end

	--- Gets all instances owned by a player
	--- @param client Player
	--- @return table<string, InstanceData>
	function Schema.instance.GetPlayerOwnedInstances(client)
		local ownedInstances = {}

		for instanceID, owner in pairs(Schema.instance.instanceOwners) do
			if (owner == client) then
				ownedInstances[instanceID] = Schema.instance.instances[instanceID]
			end
		end

		return ownedInstances
	end

	--- Adds an entity to an instance
	--- @param entity Entity
	--- @param instanceID string
	function Schema.instance.AddEntity(entity, instanceID)
		if (not IsValid(entity)) then
			ix.util.SchemaErrorNoHalt("Attempted to add invalid entity to instance '" .. tostring(instanceID) .. "'\n")
			return
		end

		-- Remove from previous instance if it exists
		local oldInstanceID = Schema.instance.entityInstances[entity]
		if (oldInstanceID) then
			Schema.instance.RemoveEntity(entity)
		end

		-- Create instance if it doesn't exist
		local instance = Schema.instance.CreateInstance(instanceID)

		-- Add entity to instance
		instance.entities[entity] = true
		Schema.instance.entityInstances[entity] = instanceID

		-- Network the entity's instance ID
		entity:SetNWString("InstanceID", instanceID)

		-- Needed for ShouldCollide to work
		entity.expInstanceOldCustomCollisionCheck = entity:GetCustomCollisionCheck()
		entity:SetCustomCollisionCheck(true)

		-- Update transmission for all players
		Schema.instance.UpdateEntityTransmission(entity)

		hook.Run("EntityAddedToInstance", entity, instanceID)
	end

	--- Removes an entity from its instance
	--- @param entity Entity
	function Schema.instance.RemoveEntity(entity)
		if (not IsValid(entity)) then
			return
		end

		local instanceID = Schema.instance.entityInstances[entity]
		if (not instanceID) then
			return
		end

		local instance = Schema.instance.instances[instanceID]
		if (instance) then
			instance.entities[entity] = nil
		end

		Schema.instance.entityInstances[entity] = nil

		-- Clear networked instance ID
		entity:SetNWString("InstanceID", "")

		entity:SetCustomCollisionCheck(entity.expInstanceOldCustomCollisionCheck or false)

		-- Update transmission for all players (entity becomes visible to everyone)
		Schema.instance.UpdateEntityTransmission(entity)

		hook.Run("EntityRemovedFromInstance", entity, instanceID)
	end

	--- Adds a player to an instance
	--- @param client Player
	--- @param instanceID? string Optional ID to identify the instance by, defaults to SteamID64
	function Schema.instance.AddPlayer(client, instanceID)
		if (not IsValid(client)) then
			ix.util.SchemaErrorNoHalt("Attempted to add invalid player to instance '" .. tostring(instanceID) .. "'\n")
			return
		end

		-- Remove from previous instance
		local oldInstanceID = Schema.instance.playerInstances[client]
		if (oldInstanceID) then
			Schema.instance.RemovePlayer(client)
		end

		instanceID = instanceID or client:SteamID64()

		-- Create instance if it doesn't exist
		local instance = Schema.instance.CreateInstance(instanceID)

		-- Add player to instance
		instance.players[client] = true
		Schema.instance.playerInstances[client] = instanceID

		-- Network the player's instance to all clients
		client:SetNWString("InstanceID", instanceID)

		-- Needed for ShouldCollide to work
		client.expInstanceOldCustomCollisionCheck = client:GetCustomCollisionCheck()
		client:SetCustomCollisionCheck(true)

		-- Update transmission for all entities
		Schema.instance.UpdatePlayerTransmission(client)

		hook.Run("PlayerAddedToInstance", client, instanceID)
	end

	--- Removes a player from their instance (returns them to global)
	--- @param client Player
	function Schema.instance.RemovePlayer(client)
		if (not IsValid(client)) then
			return
		end

		local instanceID = Schema.instance.playerInstances[client]
		if (not instanceID) then
			return
		end

		local instance = Schema.instance.instances[instanceID]
		if (instance) then
			instance.players[client] = nil
		end

		Schema.instance.playerInstances[client] = nil

		-- Clear networked instance ID
		client:SetNWString("InstanceID", "")

		client:SetCustomCollisionCheck(client.expInstanceOldCustomCollisionCheck or false)

		-- Update transmission for all entities
		Schema.instance.UpdatePlayerTransmission(client)

		hook.Run("PlayerRemovedFromInstance", client, instanceID)
	end

	--- Gets the instance ID a player is in
	--- @param client Player
	--- @return string|nil
	function Schema.instance.GetPlayerInstance(client)
		return Schema.instance.playerInstances[client]
	end

	--- Gets the instance ID an entity belongs to
	--- @param entity Entity
	--- @return string|nil
	function Schema.instance.GetEntityInstance(entity)
		return Schema.instance.entityInstances[entity]
	end

	--- Checks if a player can see an entity based on instancing
	--- @param client Player
	--- @param entity Entity
	--- @return boolean
	function Schema.instance.CanPlayerSeeEntity(client, entity)
		local playerInstance = Schema.instance.playerInstances[client]
		local entityInstance = Schema.instance.entityInstances[entity]

		-- If neither are in an instance, they can see each other
		if (not playerInstance and not entityInstance) then
			return true
		end

		-- If they're in the same instance, they can see each other
		return playerInstance == entityInstance
	end

	--- Checks if a player can see another player based on instancing
	--- @param viewer Player
	--- @param target Player
	--- @return boolean
	function Schema.instance.CanPlayerSeePlayer(viewer, target)
		local viewerInstance = Schema.instance.playerInstances[viewer]
		local targetInstance = Schema.instance.playerInstances[target]

		-- If neither are in an instance, they can see each other
		if (not viewerInstance and not targetInstance) then
			return true
		end

		-- If they're in the same instance, they can see each other
		return viewerInstance == targetInstance
	end

	--- Updates transmission for a specific entity to all players
	--- @param entity Entity
	function Schema.instance.UpdateEntityTransmission(entity)
		if (not IsValid(entity)) then
			return
		end

		for _, client in ipairs(player.GetAll()) do
			if (Schema.instance.CanPlayerSeeEntity(client, entity)) then
				entity:SetPreventTransmit(client, false)
			else
				entity:SetPreventTransmit(client, true)
			end
		end
	end

	--- Updates transmission for a specific player to all entities
	--- @param client Player
	function Schema.instance.UpdatePlayerTransmission(client)
		if (not IsValid(client)) then
			return
		end

		-- Update transmission for all instanced entities
		for entity, _ in pairs(Schema.instance.entityInstances) do
			if (IsValid(entity)) then
				if (Schema.instance.CanPlayerSeeEntity(client, entity)) then
					entity:SetPreventTransmit(client, false)
				else
					entity:SetPreventTransmit(client, true)
				end
			end
		end
	end

	--- Destroys an instance and removes all its entities and players
	--- @param instanceID string
	--- @param reason string|nil Optional reason for destruction
	function Schema.instance.DestroyInstance(instanceID, reason)
		local instance = Schema.instance.instances[instanceID]
		if (not instance) then
			return
		end

		hook.Run("InstancePreDestroy", instanceID, reason or "manual")

		-- Remove all players from instance
		for client, _ in pairs(instance.players) do
			if (IsValid(client)) then
				Schema.instance.RemovePlayer(client)
			end
		end

		-- Remove all entities (this will also remove them from the world)
		for entity, _ in pairs(instance.entities) do
			if (IsValid(entity)) then
				Schema.instance.RemoveEntity(entity)
				entity:Remove()
			end
		end

		-- Clear ownership tracking
		Schema.instance.instanceOwners[instanceID] = nil

		-- Clear the instance
		Schema.instance.instances[instanceID] = nil

		hook.Run("InstanceDestroyed", instanceID, reason or "manual")
	end

	--- Gets all players in an instance
	--- @param instanceID string
	--- @return table<Player, boolean>
	function Schema.instance.GetPlayersInInstance(instanceID)
		local instance = Schema.instance.instances[instanceID]
		return instance and instance.players or {}
	end

	--- Gets all entities in an instance
	--- @param instanceID string
	--- @return table<Entity, boolean>
	function Schema.instance.GetEntitiesInInstance(instanceID)
		local instance = Schema.instance.instances[instanceID]
		return instance and instance.entities or {}
	end

	--- Gets all active instances
	--- @return table<string, InstanceData>
	function Schema.instance.GetAllInstances()
		return Schema.instance.instances
	end

	--- Transfers ownership of an instance to another player
	--- @param instanceID string
	--- @param newOwner Player
	--- @param oldOwner Player|nil Optional verification of current owner
	function Schema.instance.TransferInstanceOwnership(instanceID, newOwner, oldOwner)
		if (not IsValid(newOwner)) then
			ix.util.SchemaErrorNoHalt("Attempted to transfer instance ownership to invalid player\n")
			return false
		end

		local instance = Schema.instance.instances[instanceID]
		if (not instance) then
			ix.util.SchemaErrorNoHalt("Attempted to transfer ownership of non-existent instance '" ..
				tostring(instanceID) .. "'\n")
			return false
		end

		-- Verify current ownership if specified
		if (oldOwner and instance.owner ~= oldOwner) then
			ix.util.SchemaErrorNoHalt("Instance ownership verification failed for '" .. tostring(instanceID) .. "'\n")
			return false
		end

		local previousOwner = instance.owner
		instance.owner = newOwner
		Schema.instance.instanceOwners[instanceID] = newOwner

		hook.Run("InstanceOwnershipTransferred", instanceID, newOwner, previousOwner)
		return true
	end

	-- Clean up when entities are removed
	hook.Add("EntityRemoved", "expInstanceCleanup", function(entity)
		Schema.instance.RemoveEntity(entity)
	end)

	-- Clean up when players disconnect - destroy owned instances
	hook.Add("PlayerDisconnected", "expInstanceCleanup", function(client)
		-- Remove player from their current instance
		Schema.instance.RemovePlayer(client)

		-- Destroy all instances owned by this player
		local ownedInstances = Schema.instance.GetPlayerOwnedInstances(client)

		for instanceID, _ in pairs(ownedInstances) do
			Schema.instance.DestroyInstance(instanceID, "owner_disconnect")
		end
	end)

	-- Handle new players connecting
	hook.Add("PlayerSpawn", "expInstanceTransmission", function(client)
		Schema.instance.UpdatePlayerTransmission(client)
	end)

	-- Handle entity spawning - ensure proper transmission
	hook.Add("OnEntityCreated", "expInstanceTransmission", function(entity)
		Schema.instance.UpdateEntityTransmission(entity)
	end)

	-- Prevent players from hearing voice chat across instances
	hook.Add("PlayerCanHearPlayersVoice", "expPreventHearingOtherInstancePlayers", function(listener, speaker)
		return Schema.instance.CanPlayerSeePlayer(listener, speaker)
	end)

	-- Prevent physgun interactions across instances
	hook.Add("PhysgunPickup", "expInstancePhysgunPickup", function(client, entity)
		if (not Schema.instance.CanPlayerSeeEntity(client, entity)) then
			return false
		end
	end)

	-- Prevent gravgun interactions across instances
	hook.Add("GravGunOnPickedUp", "expInstanceGravgunPickup", function(client, entity)
		if (not Schema.instance.CanPlayerSeeEntity(client, entity)) then
			return false
		end
	end)

	hook.Add("GravGunPunt", "expInstanceGravgunPunt", function(client, entity)
		if (not Schema.instance.CanPlayerSeeEntity(client, entity)) then
			return false
		end
	end)

	-- Prevent damage across instances
	hook.Add("EntityTakeDamage", "expInstanceDamage", function(target, dmgInfo)
		local attacker = dmgInfo:GetAttacker()

		if (IsValid(attacker) and attacker:IsPlayer()) then
			-- Prevent player damage across instances
			if (target:IsPlayer()) then
				if (not Schema.instance.CanPlayerSeePlayer(attacker, target)) then
					return true -- Block damage
				end
			else
				-- Prevent entity damage across instances
				if (not Schema.instance.CanPlayerSeeEntity(attacker, target)) then
					return true -- Block damage
				end
			end
		end
	end)

	-- Prevent use interactions across instances
	hook.Add("PlayerUse", "expInstancePlayerUse", function(client, entity)
		if (not Schema.instance.CanPlayerSeeEntity(client, entity)) then
			return false
		end
	end)

	-- Prevent tool gun usage across instances
	hook.Add("CanTool", "expInstanceCanTool", function(client, trace, tool)
		local entity = trace.Entity
		if (IsValid(entity) and not Schema.instance.CanPlayerSeeEntity(client, entity)) then
			return false
		end
	end)

	-- Prevent duplicator interactions across instances
	hook.Add("CanDrive", "expInstanceCanDrive", function(client, entity)
		if (not Schema.instance.CanPlayerSeeEntity(client, entity)) then
			return false
		end
	end)

	-- Prevent property interactions across instances
	hook.Add("CanProperty", "expInstanceCanProperty", function(client, property, entity)
		if (not Schema.instance.CanPlayerSeeEntity(client, entity)) then
			return false
		end
	end)

	-- Prevent right-click context menu interactions across instances
	hook.Add("PlayerCanPickupWeapon", "expInstancePickupWeapon", function(client, weapon)
		if (not Schema.instance.CanPlayerSeeEntity(client, weapon)) then
			return false
		end
	end)

	-- Prevent item pickup across instances (for dropped items)
	hook.Add("PlayerCanPickupItem", "expInstancePickupItem", function(client, item)
		if (not Schema.instance.CanPlayerSeeEntity(client, item)) then
			return false
		end
	end)

	-- Prevent vehicles from being entered across instances
	hook.Add("CanPlayerEnterVehicle", "expInstanceEnterVehicle", function(client, vehicle, role)
		if (not Schema.instance.CanPlayerSeeEntity(client, vehicle)) then
			return false
		end
	end)

	-- Prevent spawning entities in other instances
	hook.Add("PlayerSpawnedSENT", "expInstanceSpawnedSENT", function(client, entity)
		-- Automatically add spawned entities to the player's instance
		local playerInstance = Schema.instance.GetPlayerInstance(client)
		if (playerInstance) then
			Schema.instance.AddEntity(entity, playerInstance)
		end
	end)

	hook.Add("PlayerSpawnedProp", "expInstanceSpawnedProp", function(client, model, entity)
		-- Automatically add spawned props to the player's instance
		local playerInstance = Schema.instance.GetPlayerInstance(client)
		if (playerInstance) then
			Schema.instance.AddEntity(entity, playerInstance)
		end
	end)

	hook.Add("PlayerSpawnedNPC", "expInstanceSpawnedNPC", function(client, entity)
		-- Automatically add spawned NPCs to the player's instance
		local playerInstance = Schema.instance.GetPlayerInstance(client)
		if (playerInstance) then
			Schema.instance.AddEntity(entity, playerInstance)
		end
	end)

	hook.Add("PlayerSpawnedVehicle", "expInstanceSpawnedVehicle", function(client, entity)
		-- Automatically add spawned vehicles to the player's instance
		local playerInstance = Schema.instance.GetPlayerInstance(client)
		if (playerInstance) then
			Schema.instance.AddEntity(entity, playerInstance)
		end
	end)

	-- Prevent doors from being used across instances
	hook.Add("PlayerUseDoor", "expInstanceUseDoor", function(client, door)
		if (not Schema.instance.CanPlayerSeeEntity(client, door)) then
			return false
		end
	end)

	-- Prevent doors from being knocked across instances
	hook.Add("CanPlayerKnock", "expInstanceKnockDoor", function(client, door)
		if (not Schema.instance.CanPlayerSeeEntity(client, door)) then
			return false
		end
	end)

	-- Prevent picking up objects with hands across instances.
	hook.Add("CanPlayerHoldObject", "expInstanceHoldObject", function(client, object)
		if (not Schema.instance.CanPlayerSeeEntity(client, object)) then
			return false
		end
	end)

	-- Ensure dropped items from a player get moved to the same instance.
	hook.Add("OnItemSpawned", "expInstanceItemSpawned", function(item)
		if (not item.ixSteamID) then
			return
		end

		local client = player.GetBySteamID(item.ixSteamID)

		if (client) then
			local playerInstance = Schema.instance.GetPlayerInstance(client)

			if (playerInstance) then
				Schema.instance.AddEntity(item, playerInstance)
			end
		end
	end)

	-- Prevent in-character chat from working across instances
	hook.Add("PlayerMessageSend", "expInstanceChatFilter",
		function(speaker, chatType, text, anonymous, receivers, rawText)
			if (chatType == "ic") then
				local playerInstance = Schema.instance.GetPlayerInstance(speaker)

				-- If the player is in an instance, remove receivers not in the same instance
				if (playerInstance) then
					for i = #receivers, 1, -1 do
						local receiver = receivers[i]

						if (not Schema.instance.CanPlayerSeePlayer(speaker, receiver)) then
							table.remove(receivers, i)
						end
					end
				end
			end

			return text -- Allow the message to be sent normally
		end)
end

-- Shared functions for client-side prediction
--- Client-side function to get a player's instance using networked data
--- @param client Player
--- @return string|nil
function Schema.instance.GetPlayerInstance(client)
	if (not IsValid(client)) then
		return nil
	end

	local instanceID = client:GetNWString("InstanceID", "")
	return instanceID ~= "" and instanceID or nil
end

--- Client-side function to get an entity's instance using networked data
--- @param entity Entity
--- @return string|nil
function Schema.instance.GetEntityInstance(entity)
	if (not IsValid(entity)) then
		return nil
	end

	local instanceID = entity:GetNWString("InstanceID", "")
	return instanceID ~= "" and instanceID or nil
end

--- Shared function to check if a player can see an entity based on instancing
--- @param client Player
--- @param entity Entity
--- @return boolean
function Schema.instance.CanPlayerSeeEntity(client, entity)
	local playerInstance = Schema.instance.GetPlayerInstance(client)
	local entityInstance = Schema.instance.GetEntityInstance(entity)

	-- If neither are in an instance, they can see each other
	if (not playerInstance and not entityInstance) then
		return true
	end

	-- If they're in the same instance, they can see each other
	return playerInstance == entityInstance
end

--- Shared function to check if a player can see another player based on instancing
--- @param viewer Player
--- @param target Player
--- @return boolean
function Schema.instance.CanPlayerSeePlayer(viewer, target)
	local viewerInstance = Schema.instance.GetPlayerInstance(viewer)
	local targetInstance = Schema.instance.GetPlayerInstance(target)

	-- If neither are in an instance, they can see each other
	if (not viewerInstance and not targetInstance) then
		return true
	end

	-- If they're in the same instance, they can see each other
	return viewerInstance == targetInstance
end

if (CLIENT) then
	--- Client-side function to check if the local player can see another player
	--- @param target Player
	--- @return boolean
	function Schema.instance.CanSeePlayer(target)
		local localPlayer = LocalPlayer()
		if (not IsValid(localPlayer) or not IsValid(target)) then
			return true
		end

		return Schema.instance.CanPlayerSeePlayer(localPlayer, target)
	end

	--- Client-side function to check if the local player can see an entity
	--- @param entity Entity
	--- @return boolean
	function Schema.instance.CanSeeEntity(entity)
		local localPlayer = LocalPlayer()
		if (not IsValid(localPlayer) or not IsValid(entity)) then
			return true
		end

		return Schema.instance.CanPlayerSeeEntity(localPlayer, entity)
	end

	-- Hide players that are in different instances
	hook.Add("PrePlayerDraw", "expInstancePlayerVisibility", function(client)
		if (not Schema.instance.CanSeePlayer(client)) then
			return true -- Prevent drawing
		end
	end)

	-- Hide player names/overlays for players in different instances
	hook.Add("HUDDrawTargetID", "expInstanceTargetID", function()
		local trace = LocalPlayer():GetEyeTrace()
		local target = trace.Entity

		if (IsValid(target) and target:IsPlayer()) then
			if (not Schema.instance.CanSeePlayer(target)) then
				return true -- Prevent drawing target ID
			end
		end
	end)

	-- Prevent sound from playing across instances
	hook.Add("EntityEmitSound", "expInstanceEntitySound", function(data)
		local entity = data.Entity

		if (IsValid(entity)) then
			local localPlayer = LocalPlayer()

			if (IsValid(localPlayer)) then
				-- If it's a player sound
				if (entity:IsPlayer()) then
					if (not Schema.instance.CanSeePlayer(entity)) then
						return false
					end
				else
					-- For entity sounds, check if we can see the entity
					if (not Schema.instance.CanSeeEntity(entity)) then
						return false
					end
				end
			end
		end
	end)

	-- Prevent client-side prediction errors for interactions
	hook.Add("CreateMove", "expInstanceCreateMove", function(cmd)
		if (cmd:KeyDown(IN_USE)) then
			local trace = LocalPlayer():GetEyeTrace()
			local entity = trace.Entity

			if (IsValid(entity) and not Schema.instance.CanSeeEntity(entity)) then
				cmd:RemoveKey(IN_USE)
			end
		end
	end)

	-- Prevent tooltip info for entities in other instances
	hook.Add("ShouldPopulateEntityInfo", "expInstanceEntityInfo", function(entity)
		local localPlayer = LocalPlayer()
		if (IsValid(localPlayer)) then
			if (not Schema.instance.CanSeeEntity(entity)) then
				return false
			end
		end
	end)
end

-- Shared collision prevention across instances
hook.Add("ShouldCollide", "expInstanceShouldCollide", function(ent1, ent2)
	local inst1 = Schema.instance.GetEntityInstance(ent1)
	local inst2 = Schema.instance.GetEntityInstance(ent2)

	-- If one is the world, return to have default behaviour
	if (not IsValid(ent1) or not IsValid(ent2)) then
		return
	end

	-- If one is instanced and the other isn't, or they're in different instances
	if ((inst1 and not inst2) or (not inst1 and inst2) or (inst1 ~= inst2)) then
		return false
	end
end)

-- Shared trace filtering
hook.Add("PlayerTraceAttack", "expInstanceTraceAttack", function(client, damageinfo, dir, trace)
	local attacker = damageinfo:GetAttacker()

	if (IsValid(attacker) and attacker:IsPlayer()) then
		if (attacker:IsPlayer()) then
			if (not Schema.instance.CanPlayerSeePlayer(client, attacker)) then
				return true -- Block trace
			end
		else
			if (not Schema.instance.CanPlayerSeeEntity(client, attacker)) then
				return true -- Block trace
			end
		end
	end
end)

do
	local COMMAND = {}

	COMMAND.description = "Get the instance ID of a player."
	COMMAND.arguments = {
		ix.type.player
	}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, target)
		if (not IsValid(target)) then
			client:Notify("Invalid player.")
			return
		end

		local instanceID = Schema.instance.GetEntityInstance(target)

		if (not instanceID) then
			client:Notify("Player is not in an instance.")
			return
		end

		client:Notify("Player's instance ID: " .. instanceID)
	end

	ix.command.Add("InstanceGetID", COMMAND)
end
