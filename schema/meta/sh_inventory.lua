local META = ix.meta.inventory

--- Returns a table of `Item`s by their base, also checking the base of their base.
-- @realm shared
-- @string baseID The base to search for.
-- @bool bOnlyMain Whether or not to exclude bags that are present from the search.
function META:GetItemsByNestedBase(baseID, bOnlyMain)
	local items = {}

    -- Goes through all items and for each item will recursively check their base to see if it matches the baseID
    -- If it does, the very child item will be added to the items table
	for _, item in pairs(self:GetItems(bOnlyMain)) do
		local parent = item.baseTable

		while (parent) do
			if (parent.uniqueID == baseID) then
				items[#items + 1] = item

				break
			end

			parent = parent.baseTable
		end
	end

	return items
end