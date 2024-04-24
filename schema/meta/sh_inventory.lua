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
		if (item:IsBasedOn(baseID)) then
			items[#items + 1] = item

			break
		end
    end

    return items
end

-- Overrides GetItemCount in gamemode/core/meta/sh_inventory.lua
-- Source: https://github.com/Bilwin/helix-plugins/blob/main/stacks/sh_meta.lua
function META:GetItemCount(uniqueID, onlyMain)
	local i = 0
    local stacks

	for _, v in pairs(self:GetItems(onlyMain)) do
		if (v.uniqueID == uniqueID) then
            stacks = v.data.stacks

            if (stacks and stacks >= 2) then
                i = i + stacks
            else
                i = i + 1
            end
		end
	end

	return i
end
