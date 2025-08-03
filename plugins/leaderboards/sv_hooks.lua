local PLUGIN = PLUGIN

function PLUGIN:PlayerHealed(client, target, item, healAmount)
	self:IncrementMetric(client, "Healing Done", healAmount)
	self:IncrementMetric(target, "Healing Received", healAmount)
end

function PLUGIN:PlayerGeneratorEarnedMoney(client, money, generator)
	self:IncrementMetric(client, "Bolts Generated", money)
end

function PLUGIN:OnAchievementAchieved(client, achievementTable)
	self:IncrementMetric(client, "Bolts Generated", achievementTable.reward)
end

function PLUGIN:OnBusinessItemPurchased(client, itemTable, price, entity)
	self:IncrementMetric(client, "Bolts Spent", price)
end

function PLUGIN:PlayerPerkBought(client, perkTable)
	self:IncrementMetric(client, "Bolts Spent", perkTable.price)
end

function PLUGIN:PlayerLockerRotKilled(client, attacker)
	if (not IsValid(attacker) or not attacker:IsPlayer()) then
		return
	end

	if (client == attacker) then
		return
	end

	self:IncrementMetric(attacker, "Locker Rot Kills", 1)
end

function PLUGIN:OnMonsterTakeDamage(monster, damageInfo, attacker)
	if (not IsValid(attacker) or not attacker:IsPlayer()) then
		return
	end

	self:IncrementMetric(attacker, "Monster Damage", damageInfo:GetDamage())
end

function PLUGIN:OnPlayerDefendedAttack(client)
	self:IncrementMetric(client, "Successfully Defended", 1)
end
