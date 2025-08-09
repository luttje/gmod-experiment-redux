local PLUGIN = PLUGIN

util.AddNetworkString("expDisplayLine")
util.AddNetworkString("expInventorySearch")

resource.AddFile("sound/items/night_vision_on.wav")
resource.AddFile("sound/items/night_vision_off.wav")

--- Attempts to search the target inventory, requiring the client to keep staring
--- at them
--- @param client The player trying to search
--- @param target The player being searched
function PLUGIN:TrySearchTargetInventory(client, target)
	if (not client:HasTacticalGogglesActivated()) then
		client:Notify("You need tactical goggles activated to use this command.")
		return
	end

	if (not IsValid(target) or not target:IsPlayer()) then
		client:Notify("You must be looking at a player to search their inventory.")
		return
	end

	if (client:GetPos():Distance(target:GetPos()) > 90) then
		client:Notify("You are too far away to search their inventory.")
		return
	end

	local character = target:GetCharacter()
	if (not character) then
		client:Notify("Target has no character.")
		return
	end

	local searchTime = PLUGIN.searchStareSeconds

	target:SetNetVar("beingSearched", true)
	client:SetAction("@searchingInventory", searchTime)

	client:DoStaredAction(target, function()
		-- Search completed successfully
		PLUGIN:SearchTargetInventory(client, target)

		-- Clear actions
		if (IsValid(target)) then
			target:SetNetVar("beingSearched")
		end
		if (IsValid(client)) then
			client:SetAction()
		end

		client:AddDisplayLine("Inventory scan complete...", Color(0, 255, 0, 255))
	end, searchTime, function()
		-- Search was interrupted
		if (IsValid(target)) then
			target:SetNetVar("beingSearched")
		end
		if (IsValid(client)) then
			client:SetAction()
		end

		client:AddDisplayLine("Inventory scan interrupted...", Color(255, 0, 0, 255))
	end)

	client:AddDisplayLine("Scanning inventory...", Color(255, 255, 0, 255))
end

--- Executes the inventory search and networks the results to the client
--- @param client The player who initiated the search
--- @param target The player whose inventory is being searched
function PLUGIN:SearchTargetInventory(client, target)
	local character = target:GetCharacter()
	local inventory = character:GetInventory()
	local itemDescriptions = {}

	-- Get bolt count with scale
	local money = character:GetMoney() or 0
	local boltDescription = "no bolts"

	for _, scale in ipairs(self.boltScales) do
		if (money >= scale.min and money <= scale.max) then
			boltDescription = scale.text
			break
		end
	end

	table.insert(itemDescriptions, "Currency: " .. boltDescription)

	local items = inventory:GetItems()

	-- Process inventory items
	for _, item in pairs(items) do
		local description = ""

		if (item.weaponCategory) then
			description = "A " .. item.weaponCategory .. " weapon"

			local equippedWeapon = target:GetWeapon(item.class)

			if (IsValid(equippedWeapon)) then
				description = description .. " (equipped)"
			end
		elseif (item.category) then
			description = "An item of category " .. item.category
		else
			description = item.name or "Unknown item"
		end

		table.insert(itemDescriptions, description)
	end

	-- Network the results to the client
	net.Start("expInventorySearch")
	net.WriteEntity(target)
	net.WriteUInt(#itemDescriptions, 8)
	for _, itemDesc in ipairs(itemDescriptions) do
		net.WriteString(itemDesc)
	end
	net.Send(client)
end
