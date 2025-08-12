local PLUGIN = PLUGIN

util.AddNetworkString("expPremiumShopPurchase")
util.AddNetworkString("expPremiumShopRefreshPayment")
util.AddNetworkString("expPremiumShopClaimPackage")
util.AddNetworkString("expPremiumShopAdminForceCheck")

ix.log.AddType("premiumPurchase", function(client, packageKey)
	return Format("%s purchased premium package: %s", client:Name(), packageKey)
end, FLAG_SUCCESS)

ix.log.AddType("premiumPurchaseFailed", function(client, packageKey)
	return Format("%s failed to purchase premium package: %s", client:Name(), packageKey)
end, FLAG_ERROR)

ix.log.AddType("premiumAdminAction", function(client, action)
	return Format("%s performed admin action: %s", client:Name(), action)
end, FLAG_NORMAL)

ix.log.AddType("premiumPackageClaimed", function(client, packageKey)
	return Format("%s claimed premium package: %s", client:Name(), packageKey)
end, FLAG_SUCCESS)

function PLUGIN:DatabaseConnected()
	local query
	query = mysql:Create("exp_premium")
	query:Create("payment_id", "INT(11) UNSIGNED NOT NULL AUTO_INCREMENT")
	query:Create("session_id", "VARCHAR(255) NOT NULL")
	query:Create("steamid64", "VARCHAR(32) NOT NULL")
	query:Create("player_name", "VARCHAR(64) NOT NULL")
	query:Create("cart_items", "TEXT NOT NULL") -- JSON encoded single item
	query:Create("total_price", "DECIMAL(10,2) NOT NULL")
	query:Create("currency", "VARCHAR(3) NOT NULL")
	query:Create("payment_url", "TEXT NOT NULL")
	query:Create("status", "ENUM('pending', 'completed', 'failed', 'expired', 'refunded') NOT NULL DEFAULT 'pending'")
	query:Create("created_at", "INT(11) UNSIGNED NOT NULL")
	query:Create("updated_at", "INT(11) UNSIGNED NOT NULL")
	query:Create("lemonsqueezy_order_id", "VARCHAR(255)")
	query:Create("needs_processing", "TINYINT(1) DEFAULT 0")
	query:PrimaryKey("payment_id")
	query:Execute()

	-- Add indexes for faster lookups
	mysql:CreateIndexIfNotExists("exp_premium", "idx_session_id", "session_id")
	mysql:CreateIndexIfNotExists("exp_premium", "idx_steamid64", "steamid64")
	mysql:CreateIndexIfNotExists("exp_premium", "idx_lemonsqueezy_order_id", "lemonsqueezy_order_id")
	mysql:CreateIndexIfNotExists("exp_premium", "idx_needs_processing", "needs_processing")
end

function PLUGIN:OnWipeTables()
	local query
	query = mysql:Drop("exp_premium")
	query:Execute()
end

function PLUGIN:PrePlayerMessageSend(speaker, chatType, text, bAnonymous)
	if (speaker:HasPremiumKey("supporter_role")) then
		speaker.ixLastOOC = nil -- No OOC delay for supporters
	end
end

-- Hook to determine if a player can purchase a premium package
function PLUGIN:OnPremiumPurchaseAttempt(client, package, itemUniqueID)
	if (not client:GetCharacter()) then
		return false
	end

	-- Check cooldown to prevent spam purchases
	local lastPurchase = client:GetData("lastPremiumPurchase", 0)

	if (CurTime() - lastPurchase < 5) then
		client:Notify("Please wait before making another purchase.")
		return false
	end

	client:SetData("lastPremiumPurchase", CurTime())

	return true
end

-- Data persistence for premium packages
function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
	local premiumPackages = character:GetData("premiumPackages", {})
	client:SetCharacterNetVar("premiumPackages", premiumPackages)

	-- Process any offline payments for this player
	timer.Simple(2, function()
		if (IsValid(client) and client:GetCharacter()) then
			PLUGIN:ProcessOfflinePayments(client)
		end
	end)
end

-- Save premium packages when they change
function PLUGIN:OnPlayerGainPremiumKey(client, key)
	local character = client:GetCharacter()

	if (character) then
		local premiumPackages = client:GetPremiumPackages()
		character:SetData("premiumPackages", premiumPackages)
	end
end

function PLUGIN:OnPlayerLosePremiumKey(client, key)
	local character = client:GetCharacter()

	if (character) then
		local premiumPackages = client:GetPremiumPackages()
		character:SetData("premiumPackages", premiumPackages)
	end
end

function PLUGIN:GetAdminPayments(searchQuery, statusFilter, callback)
	local query = "SELECT * FROM exp_premium WHERE "

	if (statusFilter and statusFilter ~= "all" and statusFilter ~= "") then
		query = query .. "status = '" .. mysql:Escape(statusFilter) .. "' AND "
	end

	if (searchQuery and searchQuery ~= "") then
		local escapedQuery = mysql:Escape(searchQuery)
		query = query ..
			"(player_name LIKE '%" ..
			escapedQuery ..
			"%' OR steamid64 LIKE '%" .. escapedQuery .. "%' OR session_id LIKE '%" .. escapedQuery .. "%') AND "
	end

	-- Remove the trailing " AND "
	query = query:sub(1, -5)

	query = query .. " ORDER BY created_at DESC LIMIT 200"

	mysql:RawQuery(query, function(result)
		for _, payment in ipairs(result) do
			payment.cart_items = util.JSONToTable(payment.cart_items)
		end

		callback(result)
	end)
end

function PLUGIN:GetPaymentStatistics(callback)
	local query = mysql:Select("exp_premium")
	query:Select("status")
	query:Select("COUNT(*)", "count")
	query:Select("SUM(total_price)", "total_revenue")
	query:GroupBy("status")
	query:Callback(function(result)
		local stats = {
			total = 0,
			pending = 0,
			completed = 0,
			failed = 0,
			expired = 0,
			refunded = 0,
			totalRevenue = 0
		}

		for _, row in ipairs(result) do
			local status = row.status
			local count = tonumber(row.count) or 0
			local revenue = tonumber(row.total_revenue) or 0

			stats.total = stats.total + count
			stats[status] = count

			if (status == "completed") then
				stats.totalRevenue = revenue
			end
		end

		callback(stats)
	end)
	query:Execute()
end

--[[
	Player Meta functions
--]]

local playerMeta = FindMetaTable("Player")

function playerMeta:GivePremiumKey(key)
	if (not self:GetCharacter()) then
		return false
	end

	local premiumPackages = self:GetPremiumPackages()
	premiumPackages[key] = true
	self:SetCharacterNetVar("premiumPackages", premiumPackages)

	hook.Run("OnPlayerGainPremiumKey", self, key)
	return true
end

function playerMeta:RemovePremiumKey(key)
	if (not self:GetCharacter()) then
		return false
	end

	local premiumPackages = self:GetPremiumPackages()
	premiumPackages[key] = nil
	self:SetCharacterNetVar("premiumPackages", premiumPackages)

	hook.Run("OnPlayerLosePremiumKey", self, key)
	return true
end

--[[
	Database functions for payments
--]]

function PLUGIN:CreatePaymentRecord(sessionId, paymentUrl, client, packageKey, packageType, totalPrice, currency,
									callback)
	local cartItems = {
		{
			type = packageType,
			key = packageKey,
			quantity = 1
		}
	}
	local cartItemsJson = util.TableToJSON(cartItems)
	local currentTime = os.time()

	local query = mysql:Insert("exp_premium")
	query:Insert("session_id", sessionId)
	query:Insert("steamid64", client:SteamID64())
	query:Insert("player_name", client:Name())
	query:Insert("cart_items", cartItemsJson)
	query:Insert("total_price", totalPrice)
	query:Insert("currency", currency)
	query:Insert("status", "pending")
	query:Insert("payment_url", paymentUrl)
	query:Insert("created_at", currentTime)
	query:Insert("updated_at", currentTime)
	query:Insert("lemonsqueezy_order_id", sessionId)
	query:Insert("needs_processing", 0)
	query:Callback(function(data, status, lastID)
		if (callback) then
			callback(status, lastID)
		end
	end)
	query:Execute()
end

function PLUGIN:UpdatePaymentStatus(sessionId, newStatus, callback)
	local query = mysql:Update("exp_premium")
	query:Update("status", newStatus)
	query:Update("updated_at", os.time())
	query:Where("session_id", sessionId)
	query:Callback(function(data, status, lastID)
		if (callback) then
			callback(status)
		end
	end)
	query:Execute()
end

function PLUGIN:GetPaymentRecord(sessionId, callback)
	local query = mysql:Select("exp_premium")
	query:Where("session_id", sessionId)
	query:Callback(function(result)
		if (#result > 0) then
			local payment = result[1]
			payment.cart_items = util.JSONToTable(payment.cart_items)
			callback(true, payment)
		else
			callback(false, nil)
		end
	end)
	query:Execute()
end

function PLUGIN:GetPlayerPayments(steamid64, callback)
	local query = mysql:Select("exp_premium")
	query:Where("steamid64", steamid64)
	query:OrderByDesc("created_at")
	query:Callback(function(result)
		for _, payment in ipairs(result) do
			payment.cart_items = util.JSONToTable(payment.cart_items)
		end

		callback(result)
	end)
	query:Execute()
end

function PLUGIN:GetClaimablePackagesForPlayer(client, callback)
	if (not client:GetCharacter()) then
		callback({})
		return
	end

	local steamid64 = client:SteamID64()

	-- Get all completed payments for this player
	local query = mysql:Select("exp_premium")
	query:Where("steamid64", steamid64)
	query:Where("status", "completed")
	query:Callback(function(result)
		local purchasedPackages = {}
		local currentPlayerPackages = client:GetPremiumPackages()

		-- Parse all completed payments to find package purchases
		for _, payment in ipairs(result) do
			local cartItems = util.JSONToTable(payment.cart_items)

			for _, item in ipairs(cartItems) do
				if (item.type == "package") then
					local packageKey = item.key
					local package = PLUGIN.PREMIUM_PACKAGES[packageKey]

					if (package) then
						if (not purchasedPackages[packageKey]) then
							purchasedPackages[packageKey] = 0
						end

						purchasedPackages[packageKey] = purchasedPackages[packageKey] + (item.quantity or 1)
					end
				end
			end
		end

		-- Filter out packages the player already has on current character
		local claimablePackages = {}
		for packageKey, packageData in pairs(purchasedPackages) do
			if (not currentPlayerPackages[packageKey]) then
				claimablePackages[packageKey] = packageData
			end
		end

		callback(claimablePackages)
	end)
	query:Execute()
end

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

	local steamid64 = client:SteamID64()

	PLUGIN:GetPlayerPayments(steamid64, function(payments)
		-- Format the payments for network transmission
		local formattedPayments = {}

		for _, payment in ipairs(payments) do
			table.insert(formattedPayments, {
				session_id = payment.session_id,
				cart_items = payment.cart_items,
				total_price = tonumber(payment.total_price),
				currency = payment.currency,
				status = payment.status,
				created_at = payment.created_at,
				updated_at = payment.updated_at,
				payment_url = payment.payment_url
			})
		end

		respond(formattedPayments)
	end)
end)

-- Handle claimable packages requests
Schema.chunkedNetwork.HandleRequest("ClaimablePackages", function(client, respond, requestData)
	if (not client:GetCharacter()) then
		return
	end

	-- Throttle check to prevent spam
	if (Schema.util.Throttle("premium_claimable", 5, client)) then
		client:Notify("Please wait before requesting claimable packages again.")
		return
	end

	PLUGIN:GetClaimablePackagesForPlayer(client, function(claimablePackages)
		respond(table.GetKeys(claimablePackages))
	end)
end)

-- Handle admin payments requests
Schema.chunkedNetwork.HandleRequest("AdminPayments", function(client, respond, requestData)
	if (not client:IsSuperAdmin()) then
		client:Notify("You don't have permission to access this feature.")
		return
	end

	local searchQuery = requestData.searchQuery or ""
	local statusFilter = requestData.statusFilter or "all"

	PLUGIN:GetAdminPayments(searchQuery, statusFilter, function(payments)
		-- Format the payments for network transmission
		local formattedPayments = {}

		for _, payment in ipairs(payments) do
			table.insert(formattedPayments, {
				payment_id = payment.payment_id,
				session_id = payment.session_id,
				steamid64 = payment.steamid64,
				player_name = payment.player_name,
				cart_items = payment.cart_items,
				total_price = tonumber(payment.total_price),
				currency = payment.currency,
				status = payment.status,
				created_at = payment.created_at,
				updated_at = payment.updated_at,
				payment_url = payment.payment_url
			})
		end

		respond(formattedPayments, {
			searchQuery = searchQuery,
			statusFilter = statusFilter
		})
	end)
end)

-- Handle individual purchases (replaces cart system)
net.Receive("expPremiumShopPurchase", function(length, client)
	local packageKey = net.ReadString()
	local packageType = net.ReadString()

	if (not client:GetCharacter()) then
		return
	end

	-- Throttle check to prevent spam
	if (Schema.util.Throttle("premium_purchase", 5, client)) then
		client:Notify("Please wait before making another purchase.")
		return
	end

	-- Validate purchase
	local package = nil
	local price = 0
	local currency = "EUR"

	if (packageType == "package") then
		package = PLUGIN.PREMIUM_PACKAGES[packageKey]
		if (not package) then
			client:Notify("Invalid premium package.")
			return
		end

		if (client:HasPremiumKey(packageKey)) then
			client:Notify("You already own this premium package!")
			return
		end

		price = package.price
		currency = package.currency or "EUR"
	elseif (packageType == "item") then
		local itemTable = ix.item.Get(packageKey)
		if (not itemTable or not itemTable.premiumPriceInEuro) then
			client:Notify("Invalid premium item.")
			return
		end

		price = itemTable.premiumPriceInEuro
		currency = "EUR"
		package = itemTable
	else
		client:Notify("Invalid purchase type.")
		return
	end

	-- Create LemonSqueezy checkout
	PLUGIN:CreateLemonSqueezyCheckout(client, packageKey, packageType)
end)

net.Receive("expPremiumShopRefreshPayment", function(length, client)
	local sessionId = net.ReadString()

	if (not client:GetCharacter()) then
		return
	end

	-- Throttle check per session (10 second cooldown per specific payment)
	if (Schema.util.Throttle("premium_refresh_" .. sessionId, 10, client)) then
		client:Notify("Please wait before refreshing this payment again.")
		return
	end

	-- Verify the payment belongs to this user
	PLUGIN:GetPaymentRecord(sessionId, function(success, payment)
		if (not success) then
			client:Notify("Payment session not found.")
			return
		end

		if (payment.steamid64 ~= client:SteamID64()) then
			client:Notify("You don't have permission to refresh this payment.")
			return
		end

		-- Force check with database
		PLUGIN:ForceCheckClientPayment(client, sessionId, payment)
	end)
end)

net.Receive("expPremiumShopClaimPackage", function(length, client)
	local packageKey = net.ReadString()

	if (not client:GetCharacter()) then
		return
	end

	-- Throttle check to prevent spam
	if (Schema.util.Throttle("premium_claim_" .. packageKey, 3, client)) then
		client:Notify("Please wait before claiming this package again.")
		return
	end

	-- Validate package exists
	if (not PLUGIN.PREMIUM_PACKAGES[packageKey]) then
		client:Notify("Invalid package key.")
		return
	end

	-- Check if player already has the package on current character
	if (client:HasPremiumKey(packageKey)) then
		client:Notify("You already own this package on this character.")
		return
	end

	-- Attempt to claim the package
	client:GivePremiumKey(packageKey)
end)

net.Receive("expPremiumShopAdminForceCheck", function(length, client)
	if (not client:IsSuperAdmin()) then
		client:Notify("You need superadmin permissions to force check payments.")
		return
	end

	local sessionId = net.ReadString()
	local steamid64 = net.ReadString()

	-- Get the payment record
	PLUGIN:GetPaymentRecord(sessionId, function(success, payment)
		if (not success) then
			client:Notify("Payment session not found.")
			return
		end

		if (payment.steamid64 ~= steamid64) then
			client:Notify("Steam ID mismatch for payment session.")
			return
		end

		if (payment.status ~= "pending") then
			client:Notify("Payment is not pending (Status: " .. payment.status .. ")")
			return
		end

		-- Find the target player (if online)
		local targetPlayer = nil
		for _, ply in ipairs(player.GetAll()) do
			if (ply:SteamID64() == steamid64) then
				targetPlayer = ply
				break
			end
		end

		-- Force check the payment
		PLUGIN:ForceCheckClientPayment(targetPlayer, sessionId, payment)

		-- Log the admin action
		ix.log.Add(client, "premiumAdminAction",
			"Force checked payment session " .. sessionId .. " for " .. payment.player_name
		)

		if (targetPlayer) then
			client:Notify("Force checked payment for " .. targetPlayer:Name() .. " (online)")
		else
			client:Notify("Force checked payment for " .. payment.player_name .. " (offline)")
		end
	end)
end)
