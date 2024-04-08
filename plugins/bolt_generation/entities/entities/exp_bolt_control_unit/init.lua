AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

DEFINE_BASECLASS("exp_generator")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self:SetUseType(SIMPLE_USE)
end

function ENT:SetupGenerator(client, item)
	BaseClass.SetupGenerator(self, client, item)

	self:SetUpgrades(item:GetData("upgrades", 0))
	self:SetOwnerName(client:Name())
end

function ENT:OnOptionSelected(client, option, data)
	BaseClass.OnOptionSelected(self, client, option, data)

	if (option == L("upgrade", client)) then
		self:Upgrade(client)
	end
end

function ENT:GetEarnings()
	local generator = self.expGenerator
	return (generator.produce + (self.extraProduce or 0)) * ix.config.Get("incomeMultiplier")
end

function ENT:Upgrade(client)
	local generator = self.expGenerator

	if (not generator or not generator.upgrades) then
		error("Generator is missing upgrades table!")
	end

	local nextType = generator.upgrades[self:GetUpgrades() + 1]

	if (not nextType) then
		client:Notify("You have reached the maximum amount of upgrades!")
		return
	end

	local price = nextType.price
	if (Schema.perk.GetOwned(PRK_MERCANTILE, client)) then
		local priceModifier = Schema.perk.GetProperty(PRK_MERCANTILE, "priceModifier")
		price = price * priceModifier
	end

	if (not client:GetCharacter():HasMoney(price)) then
		client:Notify("You can not afford this upgrade!")
		return
	end

	local canUpgrade, message

	if(nextType.condition)then
		canUpgrade, message = nextType.condition(client, self)
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
	self.extraProduce = (self.extraProduce or 0) + nextType.produce

	self:SetUpgrades(itemTable:GetData("upgrades", 0))

	self:EmitSound("items/suitchargeok1.wav", 75)

	client:Notify("You have successfully upgraded the generator!")
end
