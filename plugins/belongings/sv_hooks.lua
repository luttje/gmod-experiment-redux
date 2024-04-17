local PLUGIN = PLUGIN

function PLUGIN:SaveData()
	self:SaveBelongings()
end

function PLUGIN:LoadData()
	self:LoadBelongings()
end

function PLUGIN:CanTransferItem(item, sourceInventory, targetInventory)
	if (targetInventory.vars and targetInventory.vars.isBelongings) then
		return false
	end
end

-- If there's no money or items left in the belongings, remove it.
local function removeIfEmpty(inventory)
	if (not inventory.vars or not IsValid(inventory.vars.isBelongings)) then
		return
	end

	local entity = inventory.vars.isBelongings

	if (entity:GetMoney() == 0 and table.Count(entity:GetInventory():GetItems()) == 0) then
        entity:RemoveWithEffect()

		ix.storage.Close(inventory)
	end
end

function PLUGIN:OnItemTransferred(item, sourceInventory, targetInventory)
	removeIfEmpty(sourceInventory)
end

function PLUGIN:CharacterVarChanged(character, key, oldValue, value)
	if (key ~= "money") then
		return
	end

	local client = character:GetPlayer()

	if (not IsValid(client)) then
		return
	end

	local inventory = client.ixOpenStorage

	if (not inventory or not inventory.vars.isBelongings) then
		return
	end

	-- Wait a tick until the storage has it's money set as well.
	timer.Simple(0, function()
		removeIfEmpty(inventory)
	end)
end

function PLUGIN:CreatePlayerDropItemsContainerEntity(client, character, dropInfo)
	if (table.Count(dropInfo.inventory) == 0 and dropInfo.money == 0) then
		return
	end

	local entity = ents.Create("exp_belongings")

	entity:SetAngles(Angle(0, 0, -90))
	entity:SetDisplayName(character:GetName() .. "'s Belongings")
	entity:SetMoney(dropInfo.money)
	entity:SetPos(client:GetPos() + Vector(0, 0, 48))
	entity:Spawn()

	ix.inventory.New(0, self:GetPerfectFitInventoryType(dropInfo.inventory), function(inventory)
		if (IsValid(entity)) then
			for _, item in ipairs(dropInfo.inventory) do
				inventory:Add(item.id, 1, item.data)
			end

			entity:SetInventory(inventory)
		end

		-- Set this after all the items have been added.
		inventory.vars.isBelongings = entity
	end)
end
