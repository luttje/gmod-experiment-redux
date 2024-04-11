local PLUGIN = PLUGIN

function PLUGIN:LoadBelongings()
	local belongings = self:GetData()

	for _, belongingsData in pairs(belongings) do
		local entity = ents.Create("exp_belongings")
		local inventoryID = tonumber(belongingsData.inventoryID)

		entity:SetAngles(belongingsData.angles)
		entity:SetDisplayName(belongingsData.displayName)
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

	-- TODO: Test this, I don't think I implemented it (nor is it implemented by Helix?)
	for _, ragdoll in pairs(ents.FindByClass("prop_ragdoll")) do
		if (ragdoll.areBelongings) then
			if (ragdoll.money > 0 or table.Count(ragdoll.inventory) > 0) then
				belongings[#belongings + 1] = {
					cash = ragdoll.money,
					angles = Angle(0, 0, -90),
					moveable = true,
					position = ragdoll:GetPos() + Vector(0, 0, 32),
					inventory = ragdoll.inventory,
					displayName = ragdoll:GetDisplayName(),
				}
			end
		end
	end

	for _, entity in pairs(ents.FindByClass("exp_belongings")) do
		local inventory = entity:GetInventory()

		-- TODO: Sometimes (like when shutting the server down) inventory.GetItems is nil
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
			-- TODO: Im doing something wrong, find out why inventories are not complete
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
		}
	end

	self:SetData(belongings)
end
