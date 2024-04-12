AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetUseType(SIMPLE_USE)
end

function ENT:GetEarnings()
	local generator = self.expGenerator
	return (generator.produce + (self.extraProduce or 0)) * ix.config.Get("incomeMultiplier")
end

function ENT:Upgrade(client, nextUpgrade)
	local generator = self.expGenerator

    if (not generator or not generator.upgrades) then
        error("Generator is missing upgrades table!")
    end

    local price = nextUpgrade.price

	if (Schema.perk.GetOwned(PRK_MERCANTILE, client)) then
		local priceModifier = Schema.perk.GetProperty(PRK_MERCANTILE, "priceModifier")
		price = price * priceModifier
	end

	if (not client:GetCharacter():HasMoney(price)) then
		client:Notify("You can not afford this upgrade!")
		return
	end

	local canUpgrade, message

	if(nextUpgrade.condition)then
		canUpgrade, message = nextUpgrade.condition(client, self)
	else
		canUpgrade = true
	end

	if (not canUpgrade) then
		client:Notify(message or "An unknown error occured!")
		return
	end

	client:GetCharacter():TakeMoney(price)

	local itemID = self.expItemID
	local itemTable = ix.item.instances[itemID]

	itemTable:SetData("upgrades", itemTable:GetData("upgrades", 0) + 1)
	self.extraProduce = (self.extraProduce or 0) + nextUpgrade.produce

	self:SetUpgrades(itemTable:GetData("upgrades", 0))

	self:EmitSound("items/suitchargeok1.wav", 75)

	client:Notify("You have successfully upgraded the generator!")
end

function ENT:SetupGenerator(client, item)
	self.expGenerator = Schema.generator.Get(item.generator.uniqueID)

	self:SetHealth(self.expGenerator.health)
	self:SetPower(self.expGenerator.power)

	self:SetItemID(item.uniqueID)
	self:SetUpgrades(item:GetData("upgrades", 0))

	self:SetItemOwner(client)
	self:SetOwnerName(client:Name())
	self.expItemID = item.id

	if (item.OnEntityCreated) then
		item:OnEntityCreated(self)
	end

	local uniqueID = "expGenerator" .. item.id

	timer.Create(uniqueID, item.payTime, 0, function()
		if (IsValid(self) and IsValid(self:GetItemOwner())) then
			self:OnEarned(client, self:GetEarnings())
		else
			timer.Remove(uniqueID)
		end
	end)
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
	local itemID = self.expItemID
    local itemTable = ix.item.instances[itemID]

	if (not itemTable) then
		client:Notify("This generator is broken!")
		ErrorNoHalt("Generator with item ID " .. itemID .. " is missing item table!\n")
		return
	end

	if (option == L("pickup", client) and client == self:GetItemOwner()) then
		self.ixIsSafe = true
		self:Remove()

		if (itemTable.OnRemoved) then
			itemTable:OnRemoved()
		end
	end

    local nextUpgrade, upgradeLabel = self:GetNextUpgrade(client)

	if (option == upgradeLabel) then
		if (not nextUpgrade) then
			client:Notify("You have reached the maximum amount of upgrades!")
			return
		end

        self:Upgrade(client, nextUpgrade)
	end
end

function ENT:OnDuplicated(entTable)
	local itemID = entTable.expItemID
	local client = self:GetItemOwner()
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
	local owner = self:GetItemOwner()

	if (IsValid(owner) and Schema.perk.GetOwned(PRK_STEELSHEETS, owner)) then
		damageInfo:ScaleDamage(0.25)
	end

	hook.Run("GeneratorAdjustDamage", self, damageInfo)
end

function ENT:OnRemove()
	local owner = self:GetItemOwner()

	if (IsValid(owner) and owner:GetCharacter()) then
		self:ReleaseCharacterCount(owner:GetCharacter())
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

				ix.log.Add(self.expLastAttacker, "generatorDestroy", owner)
			end

			if (itemTable.OnRemoved) then
				itemTable:OnRemoved()
			end

			if (itemTable.removeCompletely) then
				local query = mysql:Delete("ix_items")
					query:Where("item_id", self.expItemID)
				query:Execute()
			end
		end
	end
end
