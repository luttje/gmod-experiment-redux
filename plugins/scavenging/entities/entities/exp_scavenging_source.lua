local PLUGIN = PLUGIN

if (SERVER) then
	AddCSLuaFile()
end

ENT.Type = "anim"

ENT.PrintName = "Scavenging Source"
ENT.Author = "Experiment Redux"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.Model = Model("models/props_junk/trashcluster01a.mdl")

function ENT:SetupDataTables()
	self:NetworkVar("Int", "ID")
	self:NetworkVar("String", "InventoryType")
	self:NetworkVar("String", "SourceName")
end

function ENT:GetInventory()
	local inventoryID = self:GetID()

	if (inventoryID == 0) then
		return nil
	end

	return ix.item.inventories[inventoryID]
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel(self.Model)

		-- self:SetSolid(SOLID_BBOX)
		-- self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:EnableMotion(false)
		end
	end

	function ENT:Think()
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject) and physicsObject:IsMotionEnabled() and not IsValid(self.expPhysgunnedBy)) then
			-- Prevent admins from accidentally moving the entity too much
			physicsObject:EnableMotion(false)
		end

		self:NextThink(CurTime() + 1)
		return true
	end

	function ENT:SetInvisible(invisible)
		self:SetNoDraw(invisible)
		self:DrawShadow(not invisible)

		if (invisible) then
			self:SetModel("models/props_wasteland/laundry_dryer001.mdl")
			self:SetSolid(SOLID_BBOX)
			self:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self:SetRenderMode(RENDERMODE_TRANSALPHA)
			self:SetColor(Color(0, 0, 0, 0))
		else
			self:SetModel(self.Model)
			self:SetSolid(SOLID_VPHYSICS)
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetRenderMode(RENDERMODE_NORMAL)
			self:SetColor(Color(255, 255, 255, 255))
		end
	end

	function ENT:SetInventory(inventory)
		if (inventory) then
			self:SetID(inventory:GetID())
		end
	end

	function ENT:MakeInventory(inventoryType)
		local entity = self

		inventoryType = inventoryType or "scavenging:base"

		self:SetInventoryType(inventoryType)

		ix.inventory.New(0, inventoryType, function(inventory)
			inventory.vars.isScavengingSource = entity

			if (IsValid(entity)) then
				entity:SetInventory(inventory)

				PLUGIN:AddItemsToScavengingSource(entity, inventory)
			end
		end)
	end

	function ENT:OpenInventory(activator)
		local inventory = self:GetInventory()

		if (not inventory) then
			ix.util.SchemaErrorNoHalt("Attempt to open a scavenging source with no inventory!\n")
			return
		end

		local name = self:GetSourceName()

		if (name == "") then
			name = "A bunch of junk"
		end

		local baseTaskTime = ix.config.Get("scavengeSourceOpenTime", 4)
		local searchTime = Schema.GetDexterityTime(activator, baseTaskTime)

		ix.storage.Open(activator, inventory, {
			name = name,
			entity = self,
			searchTime = searchTime,
			searchText = "Scavenging...",
			bMultipleUsers = true,
			OnPlayerOpen = function()
			end,
			OnPlayerClose = function()
				ix.log.Add(activator, "closeContainer", name, inventory:GetID())
			end
		})

		ix.log.Add(activator, "openContainer", name, inventory:GetID())
	end

	function ENT:Use(activator)
		self:OpenInventory(activator)
	end

	function ENT:OnRemove()
		local index = self:GetID()

		if (! ix.shuttingDown and ! self.ixIsSafe and ix.entityDataLoaded and index) then
			local inventory = ix.item.inventories[index]

			if (inventory) then
				ix.item.inventories[index] = nil

				local query = mysql:Delete("ix_items")
				query:Where("inventory_id", index)
				query:Execute()

				query = mysql:Delete("ix_inventories")
				query:Where("inventory_id", index)
				query:Execute()

				hook.Run("ContainerRemoved", self, inventory)
			end
		end
	end

	-- Let the map spawn scavenging sources
	function ENT:KeyValue(key, value)
		key = key:lower()

		if (key == "inventorytype") then
			self:SetInventoryType(value)
		elseif (key == "sourcename") then
			self:SetSourceName(value)
		elseif (key == "model") then
			self.Model = value
		elseif (key == "invisible") then
			self:SetInvisible(tobool(value))
		end
	end
end

if (not CLIENT) then
	return
end

ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(tooltip)
	local sourceName = self:GetSourceName()

	if (sourceName == "") then
		sourceName = "A pile of junk"
	end

	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText(sourceName)
	name:SizeToContents()

	local description = tooltip:AddRow("description")
	description:SetText("It might contain something useful...")
	description:SizeToContents()
end
