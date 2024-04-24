local META = ix.meta.item

--- Returns whether or not the item is based on the provided base.
---This will also check the base of the base, and so on.
---@param baseID string The base to search for.
---@return boolean
function META:IsBasedOn(baseID)
    if (self.uniqueID == baseID) then
        return true
    end

    local baseTable = self.baseTable

    while (baseTable) do
        if (baseTable.uniqueID == baseID) then
            return true
        end

        baseTable = baseTable.baseTable
    end

	return false
end
