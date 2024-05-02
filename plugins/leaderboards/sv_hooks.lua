local PLUGIN = PLUGIN

-- TODO:
-- self:RegisterOrGetMetric("Successfully Defended", "The number of times a player has successfully defended themselves.")
-- self:RegisterOrGetMetric("Bolts Stolen", "The number of bolts stolen by a player.")

function PLUGIN:PlayerHealed(client, target, item, healAmount)
	self:IncrementMetric(client, "Healing Done", healAmount)
	self:IncrementMetric(target, "Healing Received", healAmount)
end

function PLUGIN:PlayerGeneratorEarnedMoney(client, money, generator)
    self:IncrementMetric(client, "Bolts Generated", money)
end

function PLUGIN:PlayerShipmentPurchased(client, itemSum, shipmentEntity)
    self:IncrementMetric(client, "Bolts Spent", itemSum)
end

function PLUGIN:PlayerDeath(client, inflictor, attacker)
    if (not IsValid(attacker) or not attacker:IsPlayer()) then
        return
    end

	if (client == attacker) then
		return
	end

	self:IncrementMetric(attacker, "Kills", 1)
end
