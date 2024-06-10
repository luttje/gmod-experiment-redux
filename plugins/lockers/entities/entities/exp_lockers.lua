if SERVER then
	AddCSLuaFile()
end

local PLUGIN = PLUGIN

ENT.Type = "anim"
ENT.Model = "models/props_c17/lockers001a.mdl"
ENT.PrintName = "Lockers"
ENT.Author = "Experiment Redux"
ENT.Category = "Experiment Redux"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.IsLockers = true

if (CLIENT) then
	ENT.PopulateEntityInfo = true

	function ENT:OnPopulateEntityInfo(tooltip)
		local name = tooltip:AddRow("name")
		name:SetImportant()
		name:SetText(L("lockers"))
		name:SizeToContents()

		local description = tooltip:AddRow("description")
		description:SetText(L("lockersDesc"))
		description:SizeToContents()
	end
end

if (not SERVER) then
	return
end

function ENT:Initialize()
	self:SetModel(self.expModelReplacement or self.Model)

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)

	local physicsObject = self:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		physicsObject:EnableMotion(false)
	end

	self:SetUseType(SIMPLE_USE)
end

function ENT:KeyValue(key, value)
	if (key == "model") then
		self.expModelReplacement = value
	end
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
				if (IsValid(session)) then
					session:Remove()
				end

				return
			end

			ix.storage.Open(client, inventory, {
				name = L("lockers", client),
				entity = session,
                bMultipleUsers = true,
				isLockersInventory = true,
				data = {
					money = character:GetData("lockersMoney", 0)
				},
				OnPlayerOpen = function(client)
					hook.Run("OnPlayerLockerOpened", client, self)
				end,
				OnPlayerClose = function(client)
                    hook.Run("OnPlayerLockerClosed", client, self)

                    if (IsValid(session)) then
                        session:Remove()
                    end

					client.expLockersSession = nil
				end
			})
		end, searchTime, function()
			if (IsValid(client)) then
				client:SetAction()
			end

			if (IsValid(session)) then
				session:Remove()
			end
		end)
	end)
end

--- Each client gets a single unique locker inventory.
--- @param client Player
--- @param callback fun(table) # The function to call when the locker inventory is ready.
function ENT:GetOrCreateLockerInventory(client, callback)
    if (client.expIsCreatingLockerInventory) then
        return
    end

	local character = client:GetCharacter()
	local lockerInventory = character:GetLockerInventory()
	local inventoryType, inventoryTypeID = PLUGIN:GetLockerInventoryType()

    if (lockerInventory) then
        callback(lockerInventory)
        return
    end

	client.expIsCreatingLockerInventory = true

	ix.inventory.New(character:GetID(), inventoryTypeID, function(inventory)
		if (IsValid(client)) then
			client.expIsCreatingLockerInventory = false
			character:SetData("lockerID", inventory:GetID())
			callback(inventory)
		end
	end)
end
