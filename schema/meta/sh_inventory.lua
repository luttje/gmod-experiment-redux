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
    local count = 0
    local stacks

    for _, item in pairs(self:GetItems(onlyMain)) do
        if (item.uniqueID == uniqueID) then
            stacks = item.data.stacks

            if (stacks and stacks >= 2) then
                count = count + stacks
            else
                count = count + 1
            end
        end
    end

    return count
end

--- Go through the items, removing them (or taking from their stack) until we have enough
---@param uniqueID string The unique ID of the item to remove.
---@param amountToRemove number The amount of items to remove.
---@param bOnlyMain boolean Whether or not to only remove items from the main inventory.
function META:RemoveStackedItem(uniqueID, amountToRemove, bOnlyMain)
    local items = self:GetItems(bOnlyMain)

    for _, item in pairs(items) do
		if (item.uniqueID ~= uniqueID) then
			continue
		end

        local stacks = item:GetData("stacks", 1)
        local toRemove = math.min(stacks, amountToRemove)

        if (toRemove == stacks) then
            item:Remove()
        else
            item:SetData("stacks", stacks - toRemove)
        end

        amountToRemove = amountToRemove - toRemove

        if (amountToRemove <= 0) then
            break
        end
    end
end

