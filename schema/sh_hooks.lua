function Schema:PostGamemodeLoaded()
	baseclass.Set("exp_npc_meta", Schema.meta.npc)
end

function Schema:DoPluginIncludes(path, plugin)
	Schema.achievement.LoadFromDir(path .. "/achievements")
	Schema.buff.LoadFromDir(path .. "/buffs")
	Schema.perk.LoadFromDir(path .. "/perks")
	Schema.npc.LoadFromDir(path .. "/npcs")
end

function Schema:PlayerTick(client, moveData)
	if (self.nextPlayerTick and CurTime() < self.nextPlayerTick) then
		return
	end

	self.nextPlayerTick = CurTime() + 1

	hook.Run("PlayerSecondElapsed", client)
end

function Schema:CanPlayerUseBusiness(client, uniqueID)
	local itemTable = ix.item.list[uniqueID]

	if (itemTable.OnCanOrder) then
		return itemTable:OnCanOrder(client)
	end
end

function Schema:InitializedPlugins()
	local ammoItems = {}
    local items = ix.item.list

	for _, item in pairs(items) do
		if (item.isAttachment and item.class ~= nil) then
			Schema.RegisterWeaponAttachment(item)
		end

		if (item.base == "base_ammo" and item.calibre) then
			ammoItems[item.calibre] = item
		end

		if (item.forcedWeaponCalibre) then
			if (not item.class) then
				ErrorNoHalt("Item " .. item.uniqueID .. " does not have a class, can't force bullet calibre.")
				continue
			end

			Schema.ammo.ForceWeaponCalibre(item.class, item.forcedWeaponCalibre)
		end
	end

	local calibres = Schema.ammo.GetAllCalibres()

	-- Check if the calibre has a matching ammo item
	for _, calibre in ipairs(calibres) do
		if (not ammoItems[calibre]) then
			ErrorNoHalt("No ammo item found for calibre '" ..
				calibre .. "'. You should create an ammo item for this calibre.\n")
		end
	end

	if (SERVER) then
		local anyNewUnloaded = false

		for _, pluginID in ipairs(Schema.disabledPlugins) do
			local pluginUnloaded = ix.plugin.unloaded[pluginID] == true

			if (not pluginUnloaded) then
				anyNewUnloaded = true
				ix.plugin.SetUnloaded(pluginID, true)
				ErrorNoHalt("Helix Plugin Notice: The plugin '" .. pluginID .. "' is marked as disabled in the schema.\n")
			end
		end

		if (anyNewUnloaded) then
			ErrorNoHalt("Helix Plugin Notice: Some plugins were disabled by the schema. You should most definitely restart the server to apply these changes!\n")
		end
	end
end

function Schema:PlayerFootstep(client, position, foot, soundName, volume, filter)
	local character = client:GetCharacter()

	if (not character) then
		return true
	end

	local mode = client:IsRunning() and "run" or "walk"

	if (mode == "walk" and Schema.perk.GetOwned("lightstep", client)) then
		return true
	end

	if (client:IsBot()) then
		-- Bots wont have an inventory
		return
	end

	local inventory = character:GetInventory()
	local soundOverride

	for _, item in pairs(inventory:GetItems()) do
		if (not item:GetData("equip") or not item.footstepSounds) then
			continue
		end

		local footstepSounds = item.footstepSounds[mode]

		if (not footstepSounds) then
			continue
		end

		soundOverride = footstepSounds[math.random(#footstepSounds)]
	end

	if (soundOverride) then
		EmitSound(soundOverride, position, 0, CHAN_BODY, volume, 75, 0, 100, 0, filter)
		return true
	end
end
