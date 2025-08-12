local PLUGIN = PLUGIN

local STATUS_MAP = {
	purchased = "purchased",
	expired = "expired",
	renewed = "renewed",
	refunded = "refunded",
	canceled = "canceled"
}

ix.log.AddType("premiumStatusChanged", function(client, orderId, status, steamID, itemSlug)
	return Format("Order %s status changed to %s for %s (%s)", orderId, status, steamID, itemSlug)
end, FLAG_SUCCESS)

ix.log.AddType("premiumAdminAction", function(client, action)
	return Format("%s performed admin action: %s", client:Name(), action)
end, FLAG_NORMAL)

ix.log.AddType("premiumPackageClaimed", function(client, packageKey)
	return Format("%s claimed premium package: %s", client:Name(), packageKey)
end, FLAG_SUCCESS)

function PLUGIN:OnLoaded()
	local envFile = file.Read(PLUGIN.folder .. "/.env", "LUA")

	if (not envFile) then
		ix.util.SchemaErrorNoHalt("The .env file is missing from the premium_shop plugin.")
		self.disabled = true
		return
	end

	local variables = Schema.util.EnvToTable(envFile)

	local url = Schema.util.ForceEndPath(variables.PAYNOW_STORE)

	SetNetVar("premium_shop.url", url)
end

function PLUGIN:DatabaseConnected()
	local statusses = ""

	for status, _ in pairs(STATUS_MAP) do
		if (statusses ~= "") then
			statusses = statusses .. ", "
		end

		statusses = statusses .. "'" .. status .. "'"
	end

	local query
	query = mysql:Create("exp_premium")
	query:Create("order_id", "VARCHAR(255) NOT NULL")
	query:Create("steamid64", "VARCHAR(32) NOT NULL")
	query:Create("player_name", "VARCHAR(64) NOT NULL")
	query:Create("item_slug", "VARCHAR(255) NOT NULL") -- The item as registered with RegisterPremiumPackage
	query:Create("status", "ENUM(" .. statusses .. ") NOT NULL")
	query:Create("created_at", "INT(11) UNSIGNED NOT NULL")
	query:Create("updated_at", "INT(11) UNSIGNED NOT NULL")
	query:PrimaryKey("order_id")
	query:Execute()

	-- Add indexes for faster lookups
	mysql:CreateIndexIfNotExists("exp_premium", "idx_order_id", "order_id")
	mysql:CreateIndexIfNotExists("exp_premium", "idx_steamid64", "steamid64")
end

function PLUGIN:OnWipeTables()
	local query
	query = mysql:Drop("exp_premium")
	query:Execute()
end

function PLUGIN:PrePlayerMessageSend(speaker, chatType, text, bAnonymous)
	if (speaker:HasPremiumPackage("supporter-role-lifetime")) then
		speaker.ixLastOOC = nil -- No OOC delay for supporters
	end
end

-- Network data about premium packages
function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
	local premiumPackages = character:GetData("premiumPackages", {})

	client:SetCharacterNetVar("premiumPackages", premiumPackages)
end

-- Save premium packages when they change
function PLUGIN:OnPlayerGainPackage(client, key)
	local character = client:GetCharacter()

	if (character) then
		local premiumPackages = client:GetPremiumPackages()
		character:SetData("premiumPackages", premiumPackages)
	end
end

function PLUGIN:OnPlayerLosePackage(client, key)
	local character = client:GetCharacter()

	if (character) then
		local premiumPackages = client:GetPremiumPackages()
		character:SetData("premiumPackages", premiumPackages)
	end
end

--[[
	Player Meta functions
--]]

local playerMeta = FindMetaTable("Player")

function playerMeta:GivePremiumPackage(slug)
	if (not self:GetCharacter()) then
		return false
	end

	local premiumPackages = self:GetPremiumPackages()
	premiumPackages[slug] = true
	self:SetCharacterNetVar("premiumPackages", premiumPackages)

	hook.Run("OnPlayerGainPackage", self, slug)
	return true
end

function playerMeta:RemovePremiumPackage(slug)
	if (not self:GetCharacter()) then
		return false
	end

	local premiumPackages = self:GetPremiumPackages()
	premiumPackages[slug] = nil
	self:SetCharacterNetVar("premiumPackages", premiumPackages)

	hook.Run("OnPlayerLosePackage", self, slug)
	return true
end

--[[
	Database functions for payment records
--]]

function PLUGIN:CreatePaymentRecord(orderId, steamId64, playerName, itemSlug, status, callback)
	local query = mysql:Insert("exp_premium")
	query:Insert("order_id", orderId)
	query:Insert("steamid64", steamId64)
	query:Insert("player_name", playerName)
	query:Insert("item_slug", itemSlug)
	query:Insert("status", status)
	query:Insert("created_at", os.time())
	query:Insert("updated_at", os.time())
	query:Callback(function(result, status, lastID)
		if (status == false) then
			ix.log.Add(nil, "schemaDebug", "CreatePaymentRecord",
				"Failed to create payment record with result " ..
				tostring(result) .. " and lastID " .. tostring(lastID) .. ".")

			if (callback) then
				callback(false)
			end

			return
		end

		if (callback) then
			callback(true)
		end
	end)
	query:Execute()
end

function PLUGIN:UpdatePaymentRecord(orderId, status, callback)
	local query = mysql:Update("exp_premium")
	query:Update("status", status)
	query:Update("updated_at", os.time())
	query:Where("order_id", orderId)
	query:Callback(function(result, status, lastID)
		if (status == false) then
			ix.log.Add(nil, "schemaDebug", "UpdatePaymentRecord",
				"Failed to update payment record with result " ..
				tostring(result) .. " and lastID " .. tostring(lastID) .. ".")

			if (callback) then
				callback(false)
			end
			return
		end

		if (callback) then
			callback(true)
		end
	end)
	query:Execute()
end

function PLUGIN:GetPlayerPaymentRecords(steamId64, callback)
	local query = mysql:Select("exp_premium")
	query:Where("steamid64", steamId64)
	query:OrderByDesc("created_at")
	query:Callback(function(result, status, lastID)
		if (status == false) then
			ix.log.Add(nil, "schemaDebug", "GetPlayerPaymentRecords",
				"Failed to get payment records with result " .. tostring(result) .. ".")
			callback({})
			return
		end

		callback(result or {})
	end)
	query:Execute()
end

function PLUGIN:GetAllPaymentRecords(searchQuery, callback)
	local query = "SELECT * FROM exp_premium "

	if (searchQuery and searchQuery ~= "") then
		query = query .. "WHERE (player_name LIKE '%" .. mysql:Escape(searchQuery) .. "%' OR "
			.. "steamid64 LIKE '%" .. mysql:Escape(searchQuery) .. "%' OR "
			.. "order_id LIKE '%" .. mysql:Escape(searchQuery) .. "%')"
	end

	query = query .. " ORDER BY created_at DESC LIMIT 200"

	mysql:RawQuery(query, function(result)
		callback(result)
	end)
end

--[[
	PayNow.gg Integration Commands
	(Will be sent by PayNow.gg to us through the PayNow Garry's Mod Addon)
--]]

concommand.Add("exp_premium_order", function(client, command, arguments)
	if (IsValid(client) and not client:IsSuperAdmin()) then
		return
	end

	local status = arguments[1]
	local itemSlug = arguments[2]
	local orderId = arguments[3]
	local steamId64 = arguments[4]

	if (not status or not itemSlug or not orderId or not steamId64) then
		ix.log.Add(client, "schemaDebug", "exp_premium_order",
			"Invalid command usage: " .. command .. " " .. table.concat(arguments, " "))
		return
	end

	if (not STATUS_MAP[status]) then
		ix.log.Add(client, "schemaDebug", "exp_premium_order",
			"Invalid status: " .. status .. " for command: " .. command)
		return
	end

	-- Get player name for record keeping
	local playerName = "Unknown Player"
	local player = player.GetBySteamID64(steamId64)

	if (IsValid(player)) then
		playerName = player:Name()

		-- Apply the package changes if player is online
		if (status == "purchased" or status == "renewed") then
			player:GivePremiumPackage(itemSlug)
		elseif (status == "refunded" or status == "canceled" or status == "expired") then
			player:RemovePremiumPackage(itemSlug)
		end
	end

	-- -- Create or update the payment record
	-- PLUGIN:CreatePaymentRecord(orderId, steamId64, playerName, itemSlug, status, function(success)
	-- 	if (success) then
	-- 		if (IsValid(client)) then
	-- 			client:Notify("Payment record created successfully for order ID: " .. orderId)
	-- 		end

	-- 		ix.log.Add(client, "premiumStatusChanged", orderId, status, steamId64, itemSlug)
	-- 	else
	-- 		-- Try to update existing record instead
	-- 		PLUGIN:UpdatePaymentRecord(orderId, status, function(updateSuccess)
	-- 			if (updateSuccess) then
	-- 				if (IsValid(client)) then
	-- 					client:Notify("Payment record updated successfully for order ID: " .. orderId)
	-- 				end

	-- 				ix.log.Add(client, "premiumStatusChanged", orderId, status, steamId64, itemSlug)
	-- 			else
	-- 				if (IsValid(client)) then
	-- 					client:Notify("Failed to create/update payment record for order ID: " .. orderId)
	-- 				end

	-- 				ix.log.Add(client, "schemaDebug", "exp_premium_order",
	-- 					"Failed to create/update payment record: " .. orderId)
	-- 			end
	-- 		end)
	-- 	end
	-- end)
	if (status == "purchased") then
		PLUGIN:CreatePaymentRecord(orderId, steamId64, playerName, itemSlug, status, function(success)
			if (success) then
				if (IsValid(client)) then
					client:Notify("Payment record created successfully for order ID: " .. orderId)
				end

				ix.log.Add(client, "premiumStatusChanged", orderId, status, steamId64, itemSlug)
			else
				ix.log.Add(client, "schemaDebug", "exp_premium_order",
					"Failed to create payment record: " .. orderId)
			end
		end)
	else
		PLUGIN:UpdatePaymentRecord(orderId, status, function(success)
			if (success) then
				if (IsValid(client)) then
					client:Notify("Payment record updated successfully for order ID: " .. orderId)
				end

				ix.log.Add(client, "premiumStatusChanged", orderId, status, steamId64, itemSlug)
			else
				if (IsValid(client)) then
					client:Notify("Failed to update payment record for order ID: " .. orderId)
				end

				ix.log.Add(client, "schemaDebug", "exp_premium_order",
					"Failed to update payment record: " .. orderId)
			end
		end)
	end
end)

--[[
	Network handling for claiming packages
--]]

util.AddNetworkString("expPremiumShopClaimPackage")

net.Receive("expPremiumShopClaimPackage", function(length, client)
	if (not client:GetCharacter()) then
		return
	end

	local packageKey = net.ReadString()

	if (not packageKey or packageKey == "") then
		client:Notify("Invalid package key.")
		return
	end

	if (not PLUGIN.PREMIUM_PACKAGES[packageKey]) then
		client:Notify("Unknown package: " .. packageKey)
		return
	end

	-- Check if they already have this package
	if (client:HasPremiumPackage(packageKey)) then
		client:Notify("You already have this package on this character.")
		return
	end

	-- Check if they own this package (have purchased/renewed it)
	PLUGIN:GetPlayerPaymentRecords(client:SteamID64(), function(paymentRecords)
		local hasValidPayment = false

		for _, record in ipairs(paymentRecords) do
			if (record.item_slug == packageKey and (record.status == "purchased" or record.status == "renewed")) then
				hasValidPayment = true
				break
			end
		end

		if (not hasValidPayment) then
			client:Notify("You don't own this package or it's not available for claiming.")
			return
		end

		-- Give them the package
		if (client:GivePremiumPackage(packageKey)) then
			local packageName = PLUGIN.PREMIUM_PACKAGES[packageKey].name
			client:Notify("Successfully claimed: " .. packageName)

			ix.log.Add(client, "premiumPackageClaimed", packageKey)
		else
			client:Notify("Failed to claim package. Please try again.")
		end
	end)
end)

--[[
	Network callbacks
--]]

-- Handle payment history requests
Schema.chunkedNetwork.HandleRequest("PaymentHistory", function(client, respond, requestData)
	if (not client:GetCharacter()) then
		return
	end

	-- Throttle check to prevent spam
	if (Schema.util.Throttle("premium_history", 5, client)) then
		client:Notify("Please wait before requesting payment history again.")
		return
	end

	PLUGIN:GetPlayerPaymentRecords(client:SteamID64(), function(paymentRecords)
		respond(paymentRecords)
	end)
end)

-- Handle admin payment records requests
Schema.chunkedNetwork.HandleRequest("AdminPayments", function(client, respond, requestData)
	if (not client:IsSuperAdmin()) then
		client:Notify("You don't have permission to access this feature.")
		return
	end

	local searchQuery = requestData.searchQuery or ""

	PLUGIN:GetAllPaymentRecords(searchQuery, function(paymentRecords)
		respond(paymentRecords, {
			searchQuery = searchQuery
		})
	end)
end)
