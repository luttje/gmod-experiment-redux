local PLUGIN = PLUGIN

function PLUGIN:LoadBelongings()
	local belongings = self:GetData()

	for _, belongingsData in pairs(belongings) do
		local entity = ents.Create("exp_belongings")
		local inventoryID = tonumber(belongingsData.inventoryID)

		entity:SetAngles(belongingsData.angles)
		entity:SetDisplayName(belongingsData.displayName or "")
		entity:SetMoney(belongingsData.money)
		entity:SetPos(belongingsData.position)
		entity:Spawn()

		ix.inventory.Restore(inventoryID, belongingsData.invWidth, belongingsData.invHeight, function(inventory)
			if (IsValid(entity)) then
				entity:SetInventory(inventory)
			end

			inventory.vars.isBelongings = entity
		end)

		if (not belongingsData.moveable) then
			local physicsObject = entity:GetPhysicsObject()

			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false)
			end
		end
	end
end

function PLUGIN:SaveBelongings()
	local belongings = {}

	for _, entity in pairs(ents.FindByClass("exp_belongings")) do
		local inventory = entity:GetInventory()

		-- TODO: Sometimes (like when shutting the server down) inventory.GetItems is nil, why?
		-- if (entity:GetMoney() == 0 and table.Count(inventory:GetItems()) == 0) then
		-- 	local index = inventory:GetID()

		-- 	local query = mysql:Delete("ix_items")
		-- 		query:Where("inventory_id", index)
		-- 	query:Execute()

		-- 	query = mysql:Delete("ix_inventories")
		-- 		query:Where("inventory_id", index)
		-- 	query:Execute()

		-- 	continue
		-- end

		local physicsObject = entity:GetPhysicsObject()
		local moveable

        if (IsValid(physicsObject)) then
            moveable = physicsObject:IsMoveable()
        end

        if (not inventory.GetSize) then
			ErrorNoHaltWithStack("TODO: Im doing something wrong, find out why inventories are not complete\n")
			continue
		end

		local width, height = inventory:GetSize()

		belongings[#belongings + 1] = {
			money = entity:GetMoney(),
			angles = entity:GetAngles(),
			moveable = moveable,
			position = entity:GetPos(),
			inventoryID = inventory:GetID(),
			invWidth = width,
			invHeight = height,
			displayName = entity:GetDisplayName(),
		}
	end

	self:SetData(belongings)
end
