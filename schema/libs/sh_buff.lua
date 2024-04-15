Schema.buff = ix.util.GetOrCreateCommonLibrary("Buff", function() return setmetatable({}, Schema.meta.buff) end)

if (SERVER) then
	util.AddNetworkString("exp_BuffUpdated")
	util.AddNetworkString("exp_BuffsLoaded")

	function Schema.buff.SetActive(client, buff, activeUntil)
		local buffTable = Schema.buff.Get(buff)

		if (not buffTable) then
			error("Buff with index " .. buff .. " does not exist.")
			return
		end

		local character = client:GetCharacter()
		local buffs = character.expBuffs or {}
		character.expBuffs = buffs

		activeUntil = activeUntil or (CurTime() + buffTable.durationInSeconds)
		buffs[buffTable.uniqueID] = activeUntil

		Schema.buff.Setup(client, buffTable, activeUntil)
		Schema.buff.Network(client, buffTable, activeUntil)
	end

	function Schema.buff.Network(client, buffTable, activeUntil)
		net.Start("exp_BuffUpdated")
		net.WriteUInt(buffTable.index, 32)
		net.WriteUInt(activeUntil, 32)
		net.Send(client)
	end

	--- Loads buffs, transforming their 'time remaining' to the time they will expire.
	---@param client Player
	---@param character any
	function Schema.buff.LoadActive(client, character)
		local storedBuffs = character:GetData("buffs", {})
		local curTime = CurTime()

		character.expBuffs = {}

		for uniqueID, activeRemaining in pairs(storedBuffs) do
			local buffTable = Schema.buff.Get(uniqueID)

			if (not buffTable) then
				continue
			end

			local activeUntil = curTime + activeRemaining
			character.expBuffs[uniqueID] = activeUntil

			Schema.buff.Setup(client, buffTable, activeUntil)
		end

		character:SetData("buffs", nil)

		net.Start("exp_BuffsLoaded")
		net.WriteTable(character.expBuffs)
		net.Send(client)
	end

	--- Sets up the buff for the client by calling the OnSetup function.
	---@param client Player
	---@param buffTable table
	---@param activeUntil number
	function Schema.buff.Setup(client, buffTable, activeUntil)
		if (buffTable.OnSetup) then
			buffTable:OnSetup(client, activeUntil)
		end
	end

	--- Calculates how long the buff has remaining, stores that in the character's data.
	---@param client Player
	---@param character any
	function Schema.buff.PrepareSaveActive(client, character)
		local buffs = character.expBuffs or {}
		local buffsToStore = {}
		local curTime = CurTime()

		for uniqueID, activeUntil in pairs(buffs) do
			local buffTable = Schema.buff.Get(uniqueID)

			if (not buffTable) then
				continue
			end

			buffsToStore[uniqueID] = activeUntil - curTime
		end

		character:SetData("buffs", buffsToStore)
	end

	--- Checks which buffs are expired, calls the OnExpire function and removes them from the character's data.
	---@param client Player
	function Schema.buff.CheckExpired(client)
		local character = client:GetCharacter()

		if (not character) then
			return
		end

		local buffs = character.expBuffs or {}
		local curTime = CurTime()

		for uniqueID, activeUntil in pairs(buffs) do
			if (activeUntil > curTime) then
				continue
			end

			local buffTable = Schema.buff.Get(uniqueID)

			if (not buffTable) then
				ErrorNoHalt("Buff with index " .. uniqueID .. " does not exist.\n")
				continue
			end

			if (buffTable.OnExpire) then
				buffTable:OnExpire(client)
			end

			buffs[uniqueID] = nil
			-- Take slight time off to account for desync
			Schema.buff.Network(client, buffTable, activeUntil - 1)
		end
	end

	--- Called on death to remove all buffs from the character. (unless persistThroughDeath is true)
	---@param client Player
	function Schema.buff.CheckRemoveOnDeath(client)
		local character = client:GetCharacter()
		local curTime = CurTime()

		if (not character) then
			return
		end

		local buffs = character.expBuffs or {}

		for uniqueID, activeUntil in pairs(buffs) do
			local buffTable = Schema.buff.Get(uniqueID)

			if (not buffTable) then
				ErrorNoHalt("Buff with index " .. uniqueID .. " does not exist.\n")
				continue
			end

			if (buffTable.persistThroughDeath) then
				continue
			end

			if (buffTable.OnExpire) then
				buffTable:OnExpire(client, true)
			end

			buffs[uniqueID] = nil
			-- Take slight time off to account for desync
			Schema.buff.Network(client, buffTable, curTime - 1)
		end
	end

	--- Called on loadout to call events on buffs that need to setup stuff on player spawn/loadout
	---@param client Player
	function Schema.buff.CallLoadout(client)
		local character = client:GetCharacter()

		if (not character) then
			return
		end

		local buffs = character.expBuffs or {}

		for uniqueID, activeUntil in pairs(buffs) do
			local buffTable = Schema.buff.Get(uniqueID)

			if (not buffTable) then
				ErrorNoHalt("Buff with index " .. uniqueID .. " does not exist.\n")
				continue
			end

			if (buffTable.OnLoadout) then
				buffTable:OnLoadout(client, activeUntil)
			end
		end
	end

	hook.Add("PostPlayerDeath", "expBuffsRemoveOnDeath", function(client)
		Schema.buff.CheckRemoveOnDeath(client)
	end)

	hook.Add("PlayerLoadout", "expBuffsCallLoadout", function(client)
		Schema.buff.CallLoadout(client)
	end)
else
	Schema.buff.localActiveUntil = Schema.buff.localActiveUntil or {}

	function Schema.buff.CreateHUDPanel()
		if (IsValid(ix.gui.buffs)) then
			ix.gui.buffs:Remove()
		end

		local panel = vgui.Create("expBuffManager")
		panel:SetTall(ScrH())
		panel:ParentToHUD()

		ix.gui.buffs = panel

		return panel
	end

	function Schema.buff.GetPanel()
		return ix.gui.buffs
	end

	function Schema.buff.RefreshPanel()
		local panel = Schema.buff.CreateHUDPanel()

		if (IsValid(panel)) then
			panel:RefreshBuffs()
		end
	end

	function Schema.buff.PopulateTooltip(tooltip, buffTable)
		local name = tooltip:AddRow("name")
		name:SetImportant()
		name:SetText(buffTable.name)
		name:SetBackgroundColor(buffTable.backgroundColor)
		name:SizeToContents()

		local description = tooltip:AddRow("description")
		description:SetText(buffTable.description)
		description:SizeToContents()

		if (buffTable.attributeBoosts) then
			for attributeKey, boostAmount in pairs(buffTable.attributeBoosts) do
				local attribute = ix.attributes.list[attributeKey]
				local panel = tooltip:AddRowAfter("description", "boost" .. attributeKey)
				panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
				panel:SetText("Boosts " .. attribute.name .. " by " .. math.Round(boostAmount, 2))
				panel:SizeToContents()
			end
		end

		tooltip:SizeToContents()
	end

	net.Receive("exp_BuffUpdated", function(msg)
		local index = net.ReadUInt(32)
		local activeUntil = net.ReadUInt(32)
		local buffTable = Schema.buff.Get(index)

		if (not buffTable) then
			error("Buff with index " .. index .. " does not exist.")
			return
		end

		Schema.buff.localActiveUntil[index] = activeUntil
		Schema.buff.RefreshPanel()
	end)

	net.Receive("exp_BuffsLoaded", function()
		local buffs = net.ReadTable()

		Schema.buff.localActiveUntil = {}

		for uniqueID, activeUntil in pairs(buffs) do
			local buffTable = Schema.buff.Get(uniqueID)

			if (not buffTable) then
				ErrorNoHalt("Buff with index " .. uniqueID .. " does not exist.\n")
				continue
			end

			Schema.buff.localActiveUntil[buffTable.index] = activeUntil
		end

		Schema.buff.RefreshPanel()
	end)
end
