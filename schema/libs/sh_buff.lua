Schema.buff = ix.util.GetOrCreateCommonLibrary("Buff", function() return setmetatable({}, Schema.meta.buff) end)

--[[
	A buff is a temporary effect that can be applied to a player.
	Buffs can have a duration, a background image, a foreground image, a description, and can boost attributes.

	Buffs can optionally contain additional data, which can be used to store additional information about the buff.
	For example a 'Siege Surge (VICTIM)' buff that stores the victim who's props were destroyed. Causing the player
	who destroyed the props to deal more damage to the victim's props.
--]]

---@class ActiveBuff
---@field index string|number The index of the buff, pointing to a type of buff.
---@field activeUntil number The time the buff will expire (server time, CurTime()).
---@field data? table Optional data that can be stored in the buff.

--- Creates information about an active buff.
---@param buffIndex string|number
---@param activeUntil number
---@param buffData? table
---@return ActiveBuff
function Schema.buff.MakeActive(buffIndex, activeUntil, buffData)
	return {
		index = buffIndex,
		activeUntil = activeUntil,
		data = buffData
	}
end

if (SERVER) then
	util.AddNetworkString("exp_BuffUpdated")
	util.AddNetworkString("exp_BuffsLoaded")

	--- Set a buff active for a client, optionally with custom duration and data.
	---@param client Player
	---@param buffIndex string|number
	---@param activeUntil? number
	---@param buffData? table
	function Schema.buff.SetActive(client, buffIndex, activeUntil, buffData)
		local buffTable = Schema.buff.Get(buffIndex)

		if (not buffTable) then
			error("Buff with index " .. buffIndex .. " does not exist.")
			return
		end

		local character = client:GetCharacter()
		local buffs = character.expBuffs or {}
		character.expBuffs = buffs

		activeUntil = activeUntil or (CurTime() + buffTable:GetDurationInSeconds(client))
		local buff = Schema.buff.MakeActive(buffIndex, activeUntil, buffData)
		local buffKey = #buffs + 1
		buffs[buffKey] = buff

		hook.Run("PlayerBuffActivated", client, buffTable, buff)

		Schema.buff.Setup(client, buffTable, buff)
		Schema.buff.Network(client, buffTable, buff)
	end

	--- Network the buff to the client.
	---@param client Player
	---@param buffTable Buff
	---@param buff ActiveBuff
	function Schema.buff.Network(client, buffTable, buff)
		net.Start("exp_BuffUpdated")
		net.WriteUInt(buffTable.index, 32)
		net.WriteUInt(buff.activeUntil, 32)
		net.WriteBool(buff.data and true or false)
		if (buff.data) then
			net.WriteTable(buff.data)
		end
		net.Send(client)
	end

	--- Loads buffs, transforming their 'time remaining' to the time they will expire.
	---@param client Player
	---@param character any
	function Schema.buff.LoadActive(client, character)
		local storedBuffs = character:GetData("buffs", {})
		local curTime = CurTime()

		character.expBuffs = {}

		for k, storedBuff in ipairs(storedBuffs) do
			local buffTable = Schema.buff.Get(storedBuff.index)

			if (not buffTable) then
				ErrorNoHalt("Buff with index " ..
				storedBuff.index .. " does not exist (player: " .. client:Name() .. ")\n")
				continue
			end

			local activeUntil = curTime + storedBuff.activeRemaining
			local buff = Schema.buff.MakeActive(storedBuff.index, activeUntil, storedBuff.data)
			local buffKey = #character.expBuffs + 1
			character.expBuffs[buffKey] = buff

			Schema.buff.Setup(client, buffTable, buff)
		end

		character:SetData("buffs", nil)

		net.Start("exp_BuffsLoaded")
		net.WriteTable(character.expBuffs)
		net.Send(client)
	end

	--- Sets up the buff for the client by calling the OnSetup function.
	---@param client Player
	---@param buffTable Buff
	---@param buff ActiveBuff
	function Schema.buff.Setup(client, buffTable, buff)
		if (buffTable.OnSetup) then
			buffTable:OnSetup(client, buff)
		end
	end

	function Schema.buff.MakeStored(client, buffIndex, activeRemaining, data)
		if (not activeRemaining) then
			local buffTable = Schema.buff.Get(buffIndex)
			activeRemaining = buffTable:GetDurationInSeconds(client)
		end

		return {
			index = buffIndex,
			activeRemaining = activeRemaining,
			data = data
		}
	end

	--- Calculates how long the buff has remaining, stores that in the character's data.
	---@param client Player
	---@param character any
	function Schema.buff.PrepareSaveActive(client, character)
		local buffs = character.expBuffs or {}
		local buffsToStore = {}
		local curTime = CurTime()

		for buffKey, buff in ipairs(buffs) do
			local buffTable = Schema.buff.Get(buff.index)

			if (not buffTable) then
				ErrorNoHalt("Buff with index " .. buff.index .. " does not exist (player: " .. client:Name() .. ")\n")
				continue
			end

			local storeKey = #buffsToStore + 1
			buffsToStore[storeKey] = Schema.buff.MakeStored(client, buff.index, buff.activeUntil - curTime, buff.data)

			hook.Run("PlayerBuffSaving", client, buffTable, buffsToStore[storeKey], buff)
		end

		character:SetData("buffs", buffsToStore)
	end

	--- Checks which buffs are expired, calls the OnExpire function and removes them from the character's data.
	--- Optionally uses a custom expiry callback.
	---@param client Player
	---@param expireChecker? fun(client: Player, buffTable: Buff, buff: ActiveBuff): boolean
	---@return number # The amount of expired buffs.
	function Schema.buff.CheckExpired(client, expireChecker)
		local character = client:GetCharacter()

		if (not character) then
			return 0
		end

		local buffs = character.expBuffs or {}

		if (not expireChecker) then
			local curTime = CurTime()

			expireChecker = function(client, buffTable, buff)
				return buff.activeUntil <= curTime
			end
		end

		local expiredCount = 0

		-- for buffKey, buff in ipairs(buffs) do
		-- We traverse in reverse order, so that we can remove elements without affecting the loop, whilst also shifting the indexes.
		for buffKey = #buffs, 1, -1 do
			local buff = buffs[buffKey]
			local buffTable = Schema.buff.Get(buff.index)

			if (not buffTable) then
				ErrorNoHalt("Buff with index " .. buff.index .. " does not exist.\n")
				continue
			end

			local expired = expireChecker(client, buffTable, buff)

			if (not expired) then
				continue
			end

			-- Correct the time so it's always in the past, even if they client is behind (should only ever be slightly if at all)
			buff.activeUntil = curTime - 1

			if (buffTable.OnExpire) then
				buffTable:OnExpire(client, buff, false)
			end

			table.remove(buffs, buffKey)
			Schema.buff.Network(client, buffTable, buff)
			expiredCount = expiredCount + 1
		end

		return expiredCount
	end

	--- Called on loadout to call events on buffs that need to setup stuff on player spawn/loadout
	---@param client Player
	function Schema.buff.CallLoadout(client)
		local character = client:GetCharacter()

		if (not character) then
			return
		end

		local buffs = character.expBuffs or {}

		for buffKey, buff in pairs(buffs) do
			local buffTable = Schema.buff.Get(buff.index)

			if (not buffTable) then
				ErrorNoHalt("Buff with index " .. buff.index .. " does not exist.\n")
				continue
			end

			if (buffTable.OnLoadout) then
				buffTable:OnLoadout(client, buff)
			end
		end
	end

	hook.Add("PostPlayerDeath", "expBuffsRemoveOnDeath", function(client)
		Schema.buff.CheckExpired(client, function(client, buffTable, buff)
			return not buffTable:ShouldPersistThroughDeath(client, buff)
		end)
	end)

	hook.Add("PlayerLoadout", "expBuffsCallLoadout", function(client)
		Schema.buff.CallLoadout(client)
	end)
else
	Schema.buff.localActive = Schema.buff.localActive or {}

	function Schema.buff.CreateHUDPanel()
		if (IsValid(ix.gui.buffs)) then
			ix.gui.buffs:Remove()
		end

		local panel = vgui.Create("expBuffManager")
		panel:SetTall(ScrH())
		panel:ParentToHUD()

		ix.gui.buffs = panel
		panel:RefreshBuffs()

		return panel
	end

	function Schema.buff.GetPanel()
		return ix.gui.buffs
	end

	function Schema.buff.RefreshPanel()
		local panel = Schema.buff.GetPanel()

		if (IsValid(panel)) then
			panel:RefreshBuffs()
		end
	end

	function Schema.buff.AddLocalActive(index, activeUntil, data)
		local newLocalKey = #Schema.buff.localActive + 1

		Schema.buff.localActive[newLocalKey] = {
			index = index,
			activeUntil = activeUntil,
			data = data
		}
	end

	function Schema.buff.RemoveLocalActive(localKey)
		Schema.buff.localActive[localKey] = nil
	end

	function Schema.buff.GetAllLocalActive()
		return Schema.buff.localActive
	end

	function Schema.buff.PopulateTooltip(tooltip, buffTable, buffData)
		local name = tooltip:AddRow("name")
		name:SetImportant()
		name:SetText(buffTable:GetName(LocalPlayer(), buffData))
		name:SetBackgroundColor(buffTable:GetBackgroundColor(LocalPlayer(), buffData))
		name:SizeToContents()

		local description = tooltip:AddRow("description")
		description:SetText(buffTable:GetDescription(LocalPlayer(), buffData))
		description:SizeToContents()
		local attributeBoosts = buffTable:GetAttributeBoosts(LocalPlayer(), buffData)

		if (attributeBoosts) then
			for attributeKey, boostAmount in pairs(attributeBoosts) do
				local attribute = ix.attributes.list[attributeKey]
				local panel = tooltip:AddRowAfter("description", "boost" .. attributeKey)
				panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
				panel:SetText("Boosts " .. attribute.name .. " by " .. math.Round(boostAmount, 2))
				panel:SizeToContents()
			end
		end

		tooltip:SizeToContents()
	end

	net.Receive("exp_BuffUpdated", function()
		local index = net.ReadUInt(32)
		local activeUntil = net.ReadUInt(32)
		local hasData = net.ReadBool()
		local data = hasData and net.ReadTable() or nil
		local buffTable = Schema.buff.Get(index)

		if (not buffTable) then
			error("Buff with index " .. index .. " does not exist.")
			return
		end

		Schema.buff.AddLocalActive(index, activeUntil, data)

		Schema.buff.RefreshPanel()
	end)

	net.Receive("exp_BuffsLoaded", function()
		local buffs = net.ReadTable()

		Schema.buff.localActive = {}

		for _, buff in ipairs(buffs) do
			Schema.buff.AddLocalActive(
				buff.index,
				buff.activeUntil,
				buff.data
			)
		end

		Schema.buff.RefreshPanel()
	end)
end
