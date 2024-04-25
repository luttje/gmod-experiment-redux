local PLUGIN = PLUGIN

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/weapons/w_suitcase_passenger.mdl")

	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetHealth(50)

	local physicsObject = self:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		physicsObject:Wake()
		physicsObject:EnableMotion(true)
	end
end

-- Transmit information only when this entity is in the player's PVS.
function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:OnTakeDamage(damageInfo)
	self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

	if (self:Health() <= 0) then
        self:RemoveWithEffect()
	end
end

function ENT:SetInventory(inventory)
	if (inventory) then
		self:SetID(inventory:GetID())
	end
end

function ENT:SetMoney(amount)
	self.money = math.max(0, math.Round(tonumber(amount) or 0))
	PLUGIN:RemoveIfEmpty(self:GetInventory())
end

function ENT:GetMoney()
	return self.money or 0
end

function ENT:OnRemove()
	local index = self:GetID()

	if (!ix.shuttingDown and !self.ixIsSafe and ix.entityDataLoaded and index) then
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

function ENT:OpenInventory(activator)
	local inventory = self:GetInventory()

	if (not inventory) then
		ErrorNoHalt("Attempt to open belongings with no inventory!\n")
		return
	end

	local name = self:GetDisplayName()
	local baseTaskTime = ix.config.Get("containerOpenTime", 0.7)
	local searchTime = Schema.GetDexterityTime(activator, baseTaskTime)

	ix.storage.Open(activator, inventory, {
		name = name,
		entity = self,
		searchTime = searchTime,
		data = { money = self:GetMoney() },
		OnPlayerOpen = function()
			hook.Run("PlayerOpenedBelongings", activator, self, inventory)
			PLUGIN:RemoveIfEmpty(inventory)
		end,
		OnPlayerClose = function()
			hook.Run("PlayerClosedBelongings", activator, self, inventory)
			PLUGIN:RemoveIfEmpty(inventory)
			ix.log.Add(activator, "closeContainer", name, inventory:GetID())
		end
	})

	ix.log.Add(activator, "openContainer", name, inventory:GetID())
end

function ENT:Use(activator)
	local inventory = self:GetInventory()

	if (inventory and (activator.expNextOpen or 0) < CurTime()) then
		local character = activator:GetCharacter()

		if (character) then
			self:OpenInventory(activator)
		end

		activator.expNextOpen = CurTime() + 1
	end
end
