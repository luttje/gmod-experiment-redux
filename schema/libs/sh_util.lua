if (Schema.util == nil) then
	Schema.util = {}
	Schema.util.transactions = {}
	Schema.util.throttles = {}
end

--- Converts Source Engine units (1 unit = 1 inch) to centimeters (1 unit = 2.54 cm)
---@param unit any
---@return unknown
function Schema.util.UnitToCentimeters(unit)
    return unit * 2.54
end

--- Converts a time in seconds to a short nice time format (e.g: 2s, 1m, 1h)
---@param time number The time in seconds.
---@return string
function Schema.util.GetNiceShortTime(time)
    local text = string.NiceTime(time)

    local parts = text:Split(" ")
    local last = parts[#parts]

	return parts[1] .. last:sub(1, 1):lower()
end

--- Creates a scope that allows only a single transaction to be active at a time.
---@param scope string
---@param callback fun(release: fun())
---@param client? any If provided, the scope will be unique to the client.
---@return boolean
function Schema.util.RunSingleWithinScope(scope, callback, client)
	if (client) then
		scope = scope .. "_" .. client:SteamID64()
	end

	if (Schema.util.transactions[scope] ~= nil) then
		return false
	end

	Schema.util.transactions[scope] = true

	local release = function()
		Schema.util.transactions[scope] = nil
	end

	local success, err = pcall(callback, release)

	if (not success) then
		ErrorNoHalt("Schema.util.RunSingleWithinScope: " .. err .. "\n")
		release()
	end

	return true
end

--- Returns true if the throttle is active, otherwise false.
---@param scope string
---@param delay number
---@param entity any? If provided, the throttle will be unique to the entity.
---@return boolean
function Schema.util.Throttle(scope, delay, entity)
	local scopeTable = Schema.util.throttles

	if (entity) then
		scopeTable = entity.expThrottles or {}
		entity.expThrottles = scopeTable
	end

	if (scopeTable[scope] == nil) then
		scopeTable[scope] = CurTime() + delay

		return false
	end

	local throttled = scopeTable[scope] > CurTime()

	if (not throttled) then
		scopeTable[scope] = CurTime() + delay
	end

	return throttled
end

if (CLIENT) then
	function Schema.util.RunInventoryAction(itemID, inventoryID, action, data)
		net.Start("ixInventoryAction")
		net.WriteString(action)
		net.WriteUInt(itemID, 32)
		net.WriteUInt(inventoryID, 32)
		net.WriteTable(data or {})
		net.SendToServer()
	end
end
