Schema.buff = ix.util.GetOrCreateCommonLibrary("Buff")

if (SERVER) then
	util.AddNetworkString("exp_BuffUpdated")

else
	Schema.buff.localActiveUntil = Schema.buff.localActiveUntil or {}

	net.Receive("exp_BuffUpdated", function(msg)
		local buff = net.ReadUInt(32)
		local activeUntil = net.ReadUInt(32)
		local buffTable = Schema.buff.Get(buff)

        if (not buffTable) then
            error("Buff with index " .. buff .. " does not exist.")
            return
        end

		Schema.buff.localActiveUntil[buffTable.uniqueID] = activeUntil
	end)
end
