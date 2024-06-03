local PLUGIN = PLUGIN

function PLUGIN:LoadBelongings()
	local belongings = self:GetData()

    for _, belongingsData in pairs(belongings) do
        if (not belongingsData.ownerID) then
			-- Legacy check that we can remove after 1 map change
            continue
        end

		local entity = ents.Create("exp_belongings")
		local inventoryID = tonumber(belongingsData.inventoryID)

		entity:SetAngles(belongingsData.angles)
		entity:SetOwnerID(belongingsData.ownerID)
		entity:SetMoney(belongingsData.money)
		entity:SetPos(belongingsData.position)
		entity:Spawn()

		ix.inventory.Restore(inventoryID, belongingsData.invWidth, belongingsData.invHeight, function(inventory)
			if (IsValid(entity)) then
				entity:SetInventory(inventory)
			end

			inventory.vars.belongingsEntity = entity
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
	local entities = ents.FindByClass("exp_belongings")
	local belongings = {}

	for _, ragdoll in pairs(ents.FindByClass("prop_ragdoll")) do
		if (not ragdoll.expIsBelongings) then
			continue
		end

		entities[#entities + 1] = ragdoll
	end

	for _, entity in pairs(entities) do
		local inventory = entity:GetInventory()

		if (self:RemoveIfEmpty(inventory)) then
			continue
		end

		local physicsObject = entity:GetPhysicsObject()
		local moveable

		if (IsValid(physicsObject)) then
			moveable = physicsObject:IsMoveable()
		end

        if (not inventory.GetSize) then
            ix.util.SchemaErrorNoHaltWithStack(
            "TODO: Im doing something wrong, find out why inventories are not complete\n")
            continue
        end

        -- Do not store monster inventories (for sake of code simplicity)
		if (entity:GetOwnerID() == 0) then
			continue
		end

		local width, height = inventory:GetSize()

		belongings[#belongings + 1] = {
			inventoryID = inventory:GetID(),
			invWidth = width,
			invHeight = height,
			money = entity:GetMoney(),

			ownerID = entity:GetOwnerID(),

			position = entity:GetPos(),
			angles = entity:GetAngles(),
			moveable = moveable,
		}
	end

	self:SetData(belongings)
end

--- If there's no money or items left in the belongings, remove it.
--- @param inventory table|nil
function PLUGIN:RemoveIfEmpty(inventory)
    if (not inventory) then
        return true
    end

	if (not inventory.vars or not IsValid(inventory.vars.belongingsEntity)) then
		return false
	end

	local entity = inventory.vars.belongingsEntity

	if (entity:GetMoney() > 0 or table.Count(entity:GetInventory():GetItems()) > 0) then
		return false
	end

	entity:RemoveWithEffect()

	ix.storage.Close(inventory)

	local index = inventory:GetID()

	local query = mysql:Delete("ix_items")
	query:Where("inventory_id", index)
	query:Execute()

	query = mysql:Delete("ix_inventories")
	query:Where("inventory_id", index)
	query:Execute()

	return true
end

function PLUGIN:CreateBelongings(client, storageEntity)
	local character = client.expCorpseCharacter or client:GetCharacter()
	local inventory = storageEntity and storageEntity.ixInventory or nil
	local entity = ents.Create("exp_belongings")

	if (not inventory) then
		local characterInventory = character:GetInventory()
		local width, height = characterInventory:GetSize()

		inventory = ix.inventory.Create(width, height, os.time())

		hook.Run("OnPlayerCorpseFillInventory", client, inventory, entity)
	elseif (storageEntity) then
		entity:SetMoney(storageEntity:GetMoney())
	end

	entity.ixInventory = inventory
	inventory.vars.belongingsEntity = entity

	entity:SetInventory(inventory)
	entity:SetAngles(storageEntity and storageEntity:GetAngles() or Angle(0, 0, -90))
	entity:SetOwnerID(character:GetID())
	entity:SetPos((storageEntity and storageEntity:GetPos() or client:GetPos()) + Vector(0, 0, 48))
	entity:Spawn()
end

function PLUGIN:CreateBelongingsForMonster(corpse)
	local inventory = corpse and corpse.ixInventory or nil
	local belongings = ents.Create("exp_belongings")

	if (not inventory) then
		ix.util.SchemaErrorNoHaltWithStack(
			"Attempted to create belongings for monster without existing corpse inventory\n")
	elseif (corpse) then
		belongings:SetMoney(corpse:GetMoney())
	end

	belongings.ixInventory = inventory
	inventory.vars.belongingsEntity = belongings

	belongings:SetInventory(inventory)
	belongings:SetAngles(corpse:GetAngles())
	belongings:SetOwnerID(0)
	belongings:SetPos(corpse:GetPos() + Vector(0, 0, 48))
	belongings:Spawn()
end

function PLUGIN:HandleCorpseEmpty(corpse)
	if (corpse:GetMoney() == 0 and table.Count(corpse.ixInventory:GetItems()) == 0) then
		local index = corpse.ixInventory:GetID()

		local query = mysql:Delete("ix_items")
		query:Where("inventory_id", index)
		query:Execute()

		query = mysql:Delete("ix_inventories")
		query:Where("inventory_id", index)
		query:Execute()

		return true
	end

	return false
end
