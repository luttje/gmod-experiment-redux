AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:SetupGenerator(client, item)
	self.expGenerator = Schema.generator.Get(item.generator.uniqueID)

	self:SetHealth(self.expGenerator.health)
	self:SetPower(self.expGenerator.power)

	self:SetItemID(item.uniqueID)
	self.expClient = client
	self.expItemID = item.id

	if (item.OnEntityCreated) then
		item:OnEntityCreated(self)
	end

	local uniqueID = "expGenerator" .. item.id

	timer.Create(uniqueID, item.payTime, 0, function()
		if (IsValid(self) and IsValid(self.expClient)) then
			self:OnEarned(client, self:GetEarnings())
		else
			timer.Remove(uniqueID)
		end
	end)
end

function ENT:GetEarnings()
	local generator = self.expGenerator
	return generator.money * ix.config.Get("incomeMultiplier")
end

function ENT:ReleaseCharacterCount(character)
	local generators = character:GetVar("generators") or {}

	for k, generator in ipairs(generators) do
		if (generator == self) then
			table.remove(generators, k)
			break
		end
	end

	character:SetVar("generators", generators, true)
end

function ENT:OnOptionSelected(client, option, data)
	if (option == L("pickup", client)) then
		local character = client:GetCharacter()
		local inventory = character:GetInventory()
		inventory:Add(self.expItemID)

		self.ixIsSafe = true
		self:Remove()
	end
end

function ENT:OnDuplicated(entTable)
	local itemID = entTable.expItemID
	local client = entTable.expClient
	local itemTable = ix.item.instances[itemID]

	ix.item.Instance(0, itemTable.uniqueID, itemTable.data, 1, 1, function(item)
		self:SetupGenerator(client, item)
	end)
end

function ENT:Think()
	self:NextThink(CurTime() + 1)

	if (self:WaterLevel() >= 3) then
		self:SetPower(0)
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:OnTakeDamage(damageInfo)
	local generator = Schema.generator.Get(self:GetClass())
	local attacker = damageInfo:GetAttacker()

	if (not IsValid(attacker) or not attacker:IsPlayer()) then
		return
	end

	if (self.AdjustDamage) then
		self:AdjustDamage(damageInfo)
	end

	if (damageInfo:GetDamage() <= 0) then
		return
	end

	self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

	if (self:Health() > 0) then
		return
	end

	if (IsValid(attacker) and attacker:IsPlayer()) then
		self.expLastAttacker = attacker
		hook.Run("PlayerDestroyGenerator", attacker, self, generator)
	end

	if (self.OnDestroy) then
		self:OnDestroy(attacker, damageInfo)
	end

	self.expIsDestroying = true
	self:Remove()
end

function ENT:OnEarned(client, money)
	if (money > 0) then
		client:GetCharacter():GiveMoney(money)
		client:Notify("You have earned ".. ix.currency.Get(money).." from your generator.")
		ix.log.Add(client, "generatorEarn", money)
	end
end

function ENT:AdjustDamage(damageInfo)
	local owner = self.expClient

	if (IsValid(owner) and Schema.perk.GetOwned(PRK_STEELSHEETS, owner)) then
		damageInfo:ScaleDamage(0.25)
	end

	hook.Run("GeneratorAdjustDamage", self, damageInfo)
end

function ENT:OnRemove()
	if (IsValid(self.expClient) and self.expClient:GetCharacter()) then
		self:ReleaseCharacterCount(self.expClient:GetCharacter())
	end

	if (!ix.shuttingDown and !self.ixIsSafe and self.expItemID) then
		local itemTable = ix.item.instances[self.expItemID]

		if (itemTable) then
			if (self.expIsDestroying) then
				local position = self:LocalToWorld(self:OBBCenter())
				Schema.ImpactEffect(position, 3, true)

				if (itemTable.OnDestroyed) then
					itemTable:OnDestroyed(self)
				end

				ix.log.Add(self.expLastAttacker, "generatorDestroy", self.expClient)
			end

			if (itemTable.OnRemoved) then
				itemTable:OnRemoved()
			end

			local query = mysql:Delete("ix_items")
				query:Where("item_id", self.expItemID)
			query:Execute()
		end
	end
end
