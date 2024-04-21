local PLUGIN = PLUGIN

PLUGIN.name = "Lockers"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Lets players store items, safely locked away from others."
PLUGIN.inventoryTypeID = "lockers"

ix.util.Include("sh_commands.lua")

ix.lang.AddTable("english", {
	lockers = "Lockers",
	lockersDesc = "Storage for your items, locked away from others.",

	openingLockers = "Opening lockers...",
})

ix.config.Add("lockersOpenDelayInSeconds", 2, "How long it takes to open lockers, in seconds.", nil, {
	data = {min = 0, max = 20},
	category = "lockers"
})

ix.inventory.Register(PLUGIN.inventoryTypeID, 6, 6)

function PLUGIN:GetLockerInventoryType()
	return ix.item.inventoryTypes[PLUGIN.inventoryTypeID], PLUGIN.inventoryTypeID
end

if (not SERVER) then
	return
end

ix.log.AddType("openLockers", function(client, ...)
	return string.format("%s opened their lockers.", client:Name())
end, FLAG_NORMAL)

ix.log.AddType("closeLockers", function(client, ...)
	return string.format("%s closed their lockers.", client:Name())
end, FLAG_NORMAL)

function PLUGIN:LoadData()
	local lockers = self:GetData()

	for _, lockerData in pairs(lockers) do
		local entity = ents.Create("exp_lockers")
		entity:SetPos(lockerData.pos)
		entity:SetAngles(lockerData.ang)
		entity:Spawn()
	end
end

function PLUGIN:SaveData()
	local lockers = {}

	for _, entity in ipairs(ents.FindByClass("exp_lockers")) do
		table.insert(lockers, {
			pos = entity:GetPos(),
			ang = entity:GetAngles()
		})
	end

	self:SetData(lockers)
end
