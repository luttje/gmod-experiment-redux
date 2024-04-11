local PLUGIN = PLUGIN

PLUGIN.name = "Scavenging"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Scatter items around the map for players to find."

ix.util.Include("sh_commands.lua")

ix.config.Add("scavengeSourceOpenTime", 3, "How long it takes to search a scavenging source.", nil, {
	data = {min = 0, max = 100, decimals = 0}
})

ix.config.Add("scrapAmalgamAmount", 5, "How much scrap it takes to make a scrap amalgam.", nil, {
	data = {min = 0, max = 100, decimals = 0}
})

ix.inventory.Register("scavenging:base", 5, 1)

if (SERVER) then
	PLUGIN.defaultJunkChances = {
		["junk_can"] = 70,
		["junk_can2"] = 70,
		["junk_pot"] = 89,
		["sawblade"] = 93
	}

	-- Let's allow players to store items in scavenging sources (might result in fun where players can hide items for others to find)
	-- function PLUGIN:CanTransferItem(item, sourceInventory, targetInventory)
	-- 	if (targetInventory.vars and targetInventory.vars.isScavengingSource) then
	-- 		return false
	-- 	end
	-- end

	local function closeIfEmpty(inventory)
		if (not inventory.vars or not IsValid(inventory.vars.isScavengingSource)) then
			return
		end

		local entity = inventory.vars.isScavengingSource

		if (table.Count(entity:GetInventory():GetItems()) == 0) then
			ix.storage.Close(inventory)
		end
	end

	function PLUGIN:AddItemsToScavengingSource(entity, inventory)
		for itemUniqueID, chance in pairs(self.defaultJunkChances) do
			if (math.random(1, 100) >= chance) then
				inventory:Add(itemUniqueID, 1) -- will quietly fail if the item doesn't fit
			end
		end
	end

	function PLUGIN:OnLoaded()
		timer.Create("ixScavengingSourceSpawner", 300, 0, function()
			for _, entity in ipairs(ents.FindByClass("exp_scavenging_source")) do
				local inventory = entity:GetInventory()

				if (not inventory) then
					ErrorNoHalt("Attempt to spawn items in a scavenging source with no inventory!\n")
					continue
				end

				hook.Run("AddItemsToScavengingSource", entity, inventory)
			end
		end)
	end

	function PLUGIN:OnUnload()
		timer.Remove("ixScavengingSourceSpawner")
	end

	function PLUGIN:OnItemTransferred(item, sourceInventory, targetInventory)
		closeIfEmpty(sourceInventory)
	end

	function PLUGIN:SaveData()
		local scavengingSources = {}

		for _, entity in ipairs(ents.FindByClass("exp_scavenging_source")) do
			local inventory = entity:GetInventory()

			if (not inventory) then
				ErrorNoHalt("Attempt to save a scavenging source with no inventory!\n")
				continue
			end

			scavengingSources[#scavengingSources + 1] = {
				name = entity:GetSourceName(),
				position = entity:GetPos(),
				angles = entity:GetAngles(),
				model = entity:GetModel(),
				inventoryID = inventory:GetID(),
				inventoryType = entity:GetInventoryType()
			}
		end

		self:SetData(scavengingSources)
	end

	function PLUGIN:LoadData()
		local scavengingSources = self:GetData()

		if (scavengingSources) then
			for _, scavengingSourceData in pairs(scavengingSources) do
				local entity = ents.Create("exp_scavenging_source")

				entity:SetPos(scavengingSourceData.position)
				entity:SetAngles(scavengingSourceData.angles)
				entity:SetModel(scavengingSourceData.model)
				entity:SetSourceName(scavengingSourceData.name)
				entity:SetInventoryType(scavengingSourceData.inventoryType)
				entity:Spawn()
				entity:Activate()

				local inventoryType = ix.item.inventoryTypes[scavengingSourceData.inventoryType]

				ix.inventory.Restore(scavengingSourceData.inventoryID, inventoryType.w, inventoryType.h, function(inventory)
					if (IsValid(entity)) then
						entity:SetInventory(inventory)
					end

					inventory.vars.isScavengingSource = entity
				end)
			end
		end
	end
end
