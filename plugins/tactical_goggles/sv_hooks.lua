local PLUGIN = PLUGIN

function PLUGIN:FlashbangExploded(client, position)
	if (not client:HasTacticalGogglesActivated()) then
		return
	end

	client:AddDisplayLineFrequency(frequency,
		"Someone on your frequency was protected from a flashbang!", Color(255, 255, 255, 255))
		client:AddDisplayLine("SUPPRESSING LIGHTING! Protected from flashbang...",
		Color(255, 255, 255, 255))

	return true
end

function PLUGIN:PlayerSetFrequency(client, frequency)
	if (not client:HasTacticalGogglesActivated()) then
		return
	end

	client:AddDisplayLineFrequency(frequency, "Somebody has connected to the network...", Color(255, 100, 255, 255))
	client:AddDisplayLine("You have connected to the network...", Color(255, 100, 255, 255))
end

function PLUGIN:DoPlayerDeath(client, attacker, damageInfo)
	if (not client:HasTacticalGogglesActivated()) then
		return
	end

	local frequency = client:GetCharacterData("frequency")
	local location = client:GetArea()

	if (not location) then
		location = "unknown location"
	end

	client:AddDisplayLineFrequency(frequency, "DANGER! Vital signs terminated at location: " .. location,
		Color(255, 0, 0, 255))
	client:AddDisplayLineFrequency(frequency, "Downloading physical body system data...", Color(255, 255, 255, 255))
end

function PLUGIN:EntityTakeDamage(client, damageInfo)
	if (not client:HasTacticalGogglesActivated()) then
		return
	end

	client:AddDisplayLineFrequency(frequency, "WARNING! Physical bodily trauma detected...", Color(255, 0, 0, 255))
	client:AddDisplayLineFrequency(frequency, "Downloading physical body system data...", Color(255, 255, 255, 255))
end
