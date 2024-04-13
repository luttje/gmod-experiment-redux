if (Schema.util == nil) then
	Schema.util = {}
	Schema.util.transactions = {}
	Schema.util.throttles = {}
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

	return scopeTable[scope] > CurTime()
end

local playerMeta = FindMetaTable("Player")

-- Helpers to ensure NWVars are only set for the specified character.
-- The networked vars will be set to their default values when the character changes
local networkedTypes = {
    "Angle",
    "Bool",
    "Entity",
    "Float",
    "Int",
    "String",
    "Vector",
}

for _, type in ipairs(networkedTypes) do
	local funcName = "SetCharacterNW" .. type

    playerMeta[funcName] = function(self, key, value)
        local character = self:GetCharacter()

        if (not character) then
            error("Attempted to set networked var for player without a character.")
            return
        end

        local cleanupList = self.expCleanupList or {}
        self.expCleanupList = cleanupList

        cleanupList[type] = cleanupList[type] or {}

        if (not cleanupList[type][key]) then
            cleanupList[type][key] = self["GetNW" .. type](self, key)
        end

        self["SetNW" .. type](self, key, value)
    end

    local funcName = "GetCharacterNW" .. type

	playerMeta[funcName] = function(self, key, default)
        local character = self:GetCharacter()

		if (not character) then
			return
		end

		return self["GetNW" .. type](self, key, default)
	end
end

hook.Add("PlayerLoadedCharacter", "expCleanupNWVars", function(client, character, currentChar)
    local cleanupList = client.expCleanupList

	if (cleanupList) then
		for type, vars in pairs(cleanupList) do
            for key, value in pairs(vars) do
				client["SetNW" .. type](client, key, value)
			end
		end
	end

	client.expCleanupList = {}
end)

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
