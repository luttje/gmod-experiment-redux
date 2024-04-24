AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)

	-- self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	self:SetUseType(SIMPLE_USE)
end

function ENT:Upgrade(client, nextUpgrade)
	local generator = self.expGenerator

    if (not generator or not generator.upgrades) then
        error("Generator is missing upgrades table!")
    end

    local price = nextUpgrade.price

	if (Schema.perk.GetOwned("mercantile", client)) then
		local priceModifier = Schema.perk.GetProperty("mercantile", "priceModifier")
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

	client:Notify("You have successfully upgraded the generator.")
end

function ENT:SetupGenerator(client, item)
	self.expGenerator = Schema.generator.Get(item.generator.uniqueID)

	self:SetHealth(self.expGenerator.health)
	self:SetPower(item:GetData("power", self.expGenerator.power))

	self:SetItemID(item.uniqueID)
	self:SetUpgrades(item:GetData("upgrades", 0))

	self:SetItemOwner(client)
	self:SetOwnerName(L("generatorOwnerName", client, client:Name()))
	self.expItemID = item.id

	if (item.OnEntityCreated) then
		item:OnEntityCreated(self)
	end

	local uniqueID = "expGenerator" .. item.id

	timer.Create(uniqueID, item.payTimeInSeconds, 0, function()
		if (IsValid(self) and IsValid(self:GetItemOwner())) then
			if (self:GetCanEarn()) then
				self:OnEarned(self:GetEarnings())
			end
		else
			timer.Remove(uniqueID)
		end
	end)
end

function ENT:GetCanEarn()
	local canEarn = self:GetPower() > 0

	if (hook.Run("GeneratorCanEarn", self) == false) then
		canEarn = false
	end

	return canEarn
end

function ENT:GetEarnings()
	local generator = self.expGenerator

	return math.ceil((generator.produce + (self.extraProduce or 0)) * ix.config.Get("incomeMultiplier"))
end

function ENT:OnEarned(money)
	self:SetPower(math.max(self:GetPower() - 1, 0))

	local itemID = self.expItemID
    local itemTable = ix.item.instances[itemID]

	if (itemTable.OnEarned) then
		itemTable:OnEarned(self, money)
	end

	if (money <= 0) then
		return
	end

	local client = self:GetItemOwner()

	local teleportEarnings = ix.config.Get("teleportGeneratorEarnings")

	if (teleportEarnings) then
		client:GetCharacter():GiveMoney(money)
		client:Notify("You have earned ".. ix.currency.Get(money).." from your generator.")
	else
		local heldBolts = self:GetHeldBolts() or 0

		self:SetHeldBolts(heldBolts + money)
	end

	self:EmitSound("ambient/levels/labs/coinslot1.wav", 75)

	ix.log.Add(client, "generatorEarn", money)
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

	local heldBolts = self:GetHeldBolts() or 0

	if (option == L("pickup", client) and client == self:GetItemOwner()) then
		if (heldBolts > 0) then
			client:GetCharacter():GiveMoney(heldBolts)
			client:Notify("You have withdrawn ".. ix.currency.Get(heldBolts) .." from the generator.")
		end

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

	if (option == L("withdraw", client, heldBolts)) then
		if (heldBolts <= 0) then
			client:Notify("There are no bolts to withdraw!")
			return
		end

		self:SetHeldBolts(0)
		client:GetCharacter():GiveMoney(heldBolts)

		client:Notify("You have withdrawn ".. ix.currency.Get(heldBolts) .." from the generator.")
	end

	if (option == L("generatorRecharge", client)) then
		local power = self:GetPower()

		if (power >= itemTable.generator.power) then
			client:Notify("The generator is already fully charged!")
			return
		end

		-- Take scrap from the player to recharge the generator (1 scrap = 1 power)
		local scrap = client:GetCharacter():GetInventory():GetItemsByUniqueID("scrap")

		if (#scrap <= 0) then
			client:Notify("You do not have any scrap to recharge the generator with!")
			return
		end

		local chargeAmount = itemTable.generator.power - power
		local scrapAmount = 0

		for _, scrapItem in ipairs(scrap) do
			scrapItem:Remove()

			scrapAmount = scrapAmount + 1

			if (scrapAmount >= chargeAmount) then
				break
			end
		end

		self:SetPower(math.min(power + scrapAmount, itemTable.generator.power))

		client:NotifyLocalized("generatorRecharged", scrapAmount)
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

function ENT:AdjustDamage(damageInfo)
	local owner = self:GetItemOwner()

	if (IsValid(owner) and Schema.perk.GetOwned("steel_sheets", owner)) then
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
