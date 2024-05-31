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

function PLUGIN:PlayerDeath(client, inflictor, attacker)
    if (not IsValid(attacker) or not attacker:IsPlayer()) then
        return
    end

    if (client == attacker) then
        return
    end

    local nemesisAiPlugin = ix.plugin.Get("nemesis_ai")
    local lockerRotEvent = nemesisAiPlugin:GetLockerRotEvent()

    if (not lockerRotEvent) then
        return
    end

	if (lockerRotEvent.targetCharacter ~= client:GetCharacter()) then
		return
	end

	self:IncrementMetric(attacker, "Locker Rot Kills", 1)
end

function PLUGIN:OnMonsterTakeDamage(monster, damage, attacker)
	if (not IsValid(attacker) or not attacker:IsPlayer()) then
		return
	end

	self:IncrementMetric(attacker, "Monster Damage", damage)
end

function PLUGIN:OnPlayerDefendedAttack(client)
	self:IncrementMetric(client, "Successfully Defended", 1)
end
