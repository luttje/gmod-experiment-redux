-- Source: https://github.com/Bilwin/helix-plugins/blob/main/stacks/items/base/sh_stackable.lua
local ITEM = ITEM

ITEM.name = "Stackable Items Base"
ITEM.description = "Stackable Item"
ITEM.category = "Stackable"
ITEM.model = "models/props_c17/TrapPropeller_Lever.mdl"
ITEM.maxStacks = 16

if (CLIENT) then
    function ITEM:PaintOver(item, w, h)
        local isMax = item:GetData("stacks", 1) == item.maxStacks

		draw.SimpleTextOutlined(
			item:GetData("stacks", 1),
			"DermaDefault",
			w - 5,
			h - 5,
			isMax and Color(120, 120, 120, 200) or Color(255, 255, 255, 200),
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_BOTTOM,
			1,
			color_black
		)
	end
end

ITEM.functions.combine = {
	name = "Combine",
	icon = "icon16/arrow_in.png",
	OnRun = function(item, data)
        local currentItemStacks = item:GetData("stacks", 1)
        local otherItem = ix.item.instances[data[1]]
        local otherItemStacks = otherItem:GetData("stacks", 1)
		local totalStacks = otherItemStacks + currentItemStacks
        local client = item.player

        if (item.uniqueID ~= otherItem.uniqueID) then
			client:Notify("You can't stack these items.")

			return false
		end

        if (totalStacks > item.maxStacks) then
			client:Notify("These items can't be stacked any further.")

			return false
		end

		item:SetData(
			"stacks",
			totalStacks,
			ix.inventory.Get(item.invID):GetReceivers()
		)
		otherItem:Remove()

		return false
	end,

	OnCanRun = function(firstItem, data)
		return true
	end
}

ITEM.functions.split = {
	name = "Split",
	icon = "icon16/arrow_divide.png",
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local itemUniqueID = item.uniqueID
		local stacks = item:GetData("stacks", 1)

		client:RequestString(
			"Split",
			"Please enter how many items you want to split",
			function(splitStack)
				if (not isnumber(tonumber(splitStack))) then
					client:Notify("Please enter a `number`")
					return false
				end

				local cleanSplitStack = math.Round(math.abs(tonumber(splitStack)))

				if (cleanSplitStack >= stacks) then
					return false
				end

                local stackedCount = (stacks - cleanSplitStack)
				local stackData = {stacks = cleanSplitStack}

				if (not character:GetInventory():Add(itemUniqueID, 1, stackData)) then
					ix.item.Spawn(itemUniqueID, client, nil, angle_zero, stackData)
				end

				item:SetData("stacks", stackedCount, ix.inventory.Get(item.invID):GetReceivers())
			end,
            "1"
		)

		return false
    end,

	OnCanRun = function(item)
		return (item:GetData("stacks", 1) ~= 1)
	end
}
