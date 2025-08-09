local PLUGIN = PLUGIN

function PLUGIN:FlashbangExploded(client, position)
	if (not client:HasTacticalGogglesActivated()) then
		return
	end

	client:AddDisplayLineFrequency(
		"Someone on your frequency was protected from a flashbang!",
		Color(255, 216, 0, 255)
	)
	client:AddDisplayLine(
		"SUPPRESSING LIGHTING! Protected from flashbang...",
		Color(255, 216, 0, 255)
	)

	return true
end

function PLUGIN:PlayerSetFrequency(client, frequency)
	if (not client:HasTacticalGogglesActivated()) then
		return
	end

	client:AddDisplayLineFrequency(
		"Somebody has connected to the network (F: " .. frequency .. ")...",
		Color(255, 100, 255, 255)
	)
	client:AddDisplayLine(
		"You have connected to the network (F: " .. frequency .. ")...",
		Color(255, 100, 255, 255)
	)
end

function PLUGIN:DoPlayerDeath(client, attacker, damageInfo)
	if (not client:HasTacticalGogglesActivated()) then
		return
	end

	local location = client:GetArea()

	if (not location or location == "") then
		location = "unknown"
	end

	client:AddDisplayLineFrequency(
		"DANGER! Vital signs terminated at location: " .. location,
		Color(255, 0, 0, 255)
	)
end

function PLUGIN:EntityTakeDamage(client, damageInfo)
	if (not client:IsPlayer() or not client:HasTacticalGogglesActivated()) then
		return
	end

	local location = client:GetArea()

	if (not location or location == "") then
		location = "unknown"
	end

	client:AddDisplayLineFrequency(
		"WARNING! Physical bodily trauma detected on network at location: " .. location,
		Color(255, 0, 0, 255)
	)
end

function PLUGIN:OnPlayerOptionSelected(target, client, option, data)
	if (option == L("searchInventory", client)) then
		PLUGIN:TrySearchTargetInventory(client, target)
		return
	end
end
