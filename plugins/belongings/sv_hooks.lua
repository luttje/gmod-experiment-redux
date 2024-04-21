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
function PLUGIN:RemoveIfEmpty(inventory)
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
	self:RemoveIfEmpty(sourceInventory)
end

function PLUGIN:OnPlayerCorpseNotCreated(client)
	self:CreateBelongings(client)
end

function PLUGIN:OnPlayerCorpseRemoved(client, corpse)
	if (not corpse.ixInventory and (not corpse.GetMoney or corpse:GetMoney() == 0)) then
		return
	end

	self:CreateBelongings(client, corpse)
end

function PLUGIN:OnPlayerCorpseCreated(client, corpse)
	corpse.expIsBelongings = true
end
