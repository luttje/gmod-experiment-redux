DEFINE_BASECLASS("base_ai")

function ENT:InitializeInventorySystem()
	self.expInventory = {}
end

function ENT:GetInventory()
	return self.expInventory
end

function ENT:GiveItemInstance(itemInstance)
	table.insert(self.expInventory, itemInstance)
end

function ENT:TakeItemInstance(itemInstance)
	for i, item in ipairs(self.expInventory) do
		if item == itemInstance then
			table.remove(self.expInventory, i)
			break
		end
	end
end

function ENT:CountItem(itemUniqueID)
	local count = 0
	for _, item in ipairs(self.expInventory) do
		if item.uniqueID == itemUniqueID then
			count = count + 1
		end
	end
	return count
end

function ENT:HasItem(itemUniqueID)
	return self:CountItem(itemUniqueID) > 0
end
