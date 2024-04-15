Schema.buff = ix.util.GetOrCreateCommonLibrary("Buff")

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

		activeUntil = activeUntil or CurTime() + buffTable.durationInSeconds
        buffs[buffTable.uniqueID] = activeUntil

		net.Start("exp_BuffUpdated")
		net.WriteUInt(buffTable.index, 32)
		net.WriteUInt(activeUntil, 32)
		net.Send(client)
	end

	--- Loads buffs, transforming their 'time remaining' to the time they will expire.
    ---@param client any
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

            character.expBuffs[uniqueID] = curTime + activeRemaining
        end

		character:SetData("buffs", nil)

        net.Start("exp_BuffsLoaded")
        net.WriteTable(character.expBuffs)
        net.Send(client)
    end

	--- Calculates how long the buff has remaining, stores that in the character's data.
	---@param client any
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

			if (buffsToStore[uniqueID] <= 0) then
				buffsToStore[uniqueID] = nil
			end
		end

		character:SetData("buffs", buffsToStore)
	end
else
    Schema.buff.localActiveUntil = Schema.buff.localActiveUntil or {}

    function Schema.buff.GetPanel()
        return ix.gui.buffs
    end

    function Schema.buff.UpdateOnPanel(buff, activeUntil)
        local panel = Schema.buff.GetPanel()

        if (IsValid(panel)) then
            local active = activeUntil > CurTime()

			if (active) then
            	panel:AddBuff(buff, activeUntil)
			else
				panel:RemoveBuff(buff)
			end
        end
    end

	net.Receive("exp_BuffUpdated", function(msg)
		local buff = net.ReadUInt(32)
		local activeUntil = net.ReadUInt(32)
		local buffTable = Schema.buff.Get(buff)

        if (not buffTable) then
            error("Buff with index " .. buff .. " does not exist.")
            return
        end

        Schema.buff.localActiveUntil[buffTable.uniqueID] = activeUntil

        Schema.buff.UpdateOnPanel(buffTable.uniqueID, activeUntil)
    end)

	net.Receive("exp_BuffsLoaded", function()
		local buffs = net.ReadTable()
		Schema.buff.localActiveUntil = {}

		for uniqueID, activeUntil in pairs(buffs) do
			local buffTable = Schema.achievement.Get(uniqueID)

			if (not buffTable) then
				continue
			end

			Schema.buff.localActiveUntil[uniqueID] = activeUntil

			Schema.buff.UpdateOnPanel(buffTable.uniqueID, activeUntil)
		end
	end)
end
