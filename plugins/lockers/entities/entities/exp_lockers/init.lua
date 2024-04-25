local PLUGIN = PLUGIN

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)

	local physicsObject = self:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		physicsObject:EnableMotion(false)
	end

	self:SetUseType(SIMPLE_USE)
end

function ENT:OnTakeDamage(damageInfo)
	damageInfo:ScaleDamage(0)
end

function ENT:Use(client)
	if (not IsValid(client) or not client:IsPlayer()) then
		return
	end

	if (Schema.util.Throttle("lockersUse", 0.5, client)) then
		return
	end

	self:GetOrCreateLockerInventory(client, function(inventory)
		if (not IsValid(client) or not IsValid(self)) then
			return
		end

		local character = client:GetCharacter()
		character:SetData("lockerID", inventory:GetID())

		if (IsValid(client.expLockersSession)) then
			client.expLockersSession:Remove()
		end

		-- Create a session entity for the client to interact with, so we can add money to the locker.
		local session = ents.Create("exp_lockers_session")
		session:SetPos(self:GetPos())
		session:SetAngles(self:GetAngles())
		session:SetCharacter(character)
		session:Spawn()
		client.expLockersSession = session

		local baseTaskTime = ix.config.Get("lockersOpenDelayInSeconds")
        local searchTime = Schema.GetDexterityTime(client, baseTaskTime)

		client:SetAction("@openingLockers", searchTime)
		client:DoStaredAction(self, function()
			if (not IsValid(client) or not IsValid(self)) then
				return
			end

			ix.storage.Open(client, inventory, {
				name = L("lockers", client),
				entity = session,
				bMultipleUsers = true,
				data = {
					money = character:GetData("lockersMoney", 0)
				},
				OnPlayerOpen = function()
					ix.log.Add(client, "openLockers")
				end,
				OnPlayerClose = function()
					ix.log.Add(client, "closeLockers")

					if (IsValid(session)) then
						session:Remove()
					end
				end
			})
		end, searchTime, function()
			if (IsValid(client)) then
				client:SetAction()
			end
		end)
	end)
end

--- Each client gets a single unique locker inventory.
---@param client Player
---@param callback fun(table) # The function to call when the locker inventory is ready.
function ENT:GetOrCreateLockerInventory(client, callback)
	local character = client:GetCharacter()
	local lockerInventoryID = character:GetData("lockerID")
	local inventoryType, inventoryTypeID = PLUGIN:GetLockerInventoryType()

	if (lockerInventoryID) then
		if (ix.item.inventories[lockerInventoryID]) then
			callback(ix.item.inventories[lockerInventoryID])
			return
		end

		error("Locker inventory ID exists, but the inventory does not. I'm convinced this shouldn't happen.")
		-- Shouldn't be necessary, because ix.char.Restore will restore all inventories belonging to the character.
		ix.inventory.Restore(invID, inventoryType.w, inventoryType.h, callback)
		return
	end

	ix.inventory.New(character:GetID(), inventoryTypeID, callback)
end
