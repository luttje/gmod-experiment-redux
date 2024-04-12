local PLUGIN = PLUGIN

PLUGIN.name = "Scavenging"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Scatter items around the map for players to find."

ix.util.Include("sh_commands.lua")

ix.config.Add("scavengeSourceOpenTime", 3, "How long it takes to search a scavenging source.", nil, {
	data = {min = 0, max = 100, decimals = 0},
	category = "scavenging"
})

ix.config.Add("scavengeSourceRefillInterval", 300, "What interval to refill the scavenging source with a new item.",
    function(oldValue, value)
		if (timer.Exists("ixScavengingSourceSpawner")) then
			timer.Adjust("ixScavengingSourceSpawner", value, 0)
		end
	end, {
		data = {min = 0, max = 1000, decimals = 0},
		category = "scavenging"
	})

ix.config.Add("scavengeSourceMaxFillPercentage", 30, "What percentage of the scavenge source may be filled with items, to get a new random item.", nil, {
	data = {min = 0, max = 100, decimals = 0},
	category = "scavenging"
})

ix.config.Add("scrapAmalgamAmount", 5, "How much scrap it takes to make a scrap amalgam.", nil, {
	data = {min = 0, max = 100, decimals = 0},
	category = "scavenging"
})

ix.inventory.Register("scavenging:base", 5, 1)

if (SERVER) then
	PLUGIN.defaultJunkChances = {
		{
			item = "junk_can",
			chance = 50
		},
		{
			item = "junk_can2",
			chance = 45
		},
		{
			item = "junk_pot",
			chance = 10
		},
		{
			item = "sawblade",
			chance = 8
		}
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
        local maxFillPercentage = ix.config.Get("scavengeSourceMaxFillPercentage") / 100
		local inventorySlotCount = inventory:GetFilledSlotCount()

		if (inventorySlotCount >= math.ceil(inventory:GetSize() * maxFillPercentage)) then
			return
		end

        local roll = math.random(1, 100)
		local junkChances = self.defaultJunkChances

		table.SortByMember(junkChances, "chance", true)

        for _, junkChance in ipairs(junkChances) do
			if (roll <= junkChance.chance) then
				local itemTable = ix.item.list[junkChance.item]

				if (itemTable) then
					inventory:Add(junkChance.item)
					break
				end
			end
		end
	end

	function PLUGIN:OnLoaded()
        local refillInterval = ix.config.Get("scavengeSourceRefillInterval")

		timer.Create("ixScavengingSourceSpawner", refillInterval, 0, function()
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
