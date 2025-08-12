local PLUGIN = PLUGIN

util.AddNetworkString("expPremiumShopLemonSqueezyURL")
util.AddNetworkString("expPremiumShopCheckPayment")
util.AddNetworkString("expPremiumShopFinishPayment")

local LEMONSQUEEZY_API_KEY,
LEMONSQUEEZY_STORE_ID,
LEMONSQUEEZY_SUCCESS_URL

PLUGIN.LEMONSQUEEZY_API_URL = "https://api.lemonsqueezy.com/v1"

-- Store active polling timers
PLUGIN.activePollingTimers = PLUGIN.activePollingTimers or {}

function PLUGIN:OnLoaded()
	local envFile = file.Read(self.folder .. "/.env", "LUA")

	if (not envFile) then
		ix.util.SchemaErrorNoHalt("The .env file is missing from the premium shop folder.")
		self.disabled = true
		return
	end

	local variables = Schema.util.EnvToTable(envFile)

	LEMONSQUEEZY_API_KEY = variables.LEMONSQUEEZY_API_KEY
	LEMONSQUEEZY_STORE_ID = variables.LEMONSQUEEZY_STORE_ID
	LEMONSQUEEZY_SUCCESS_URL = variables.LEMONSQUEEZY_SUCCESS_URL

	if (not LEMONSQUEEZY_API_KEY or not LEMONSQUEEZY_STORE_ID) then
		ix.util.SchemaErrorNoHalt("LemonSqueezy API credentials are missing from .env file.")
		self.disabled = true
		return
	end

	print("[Premium Shop] LemonSqueezy integration loaded successfully")
end

function PLUGIN:CreateLemonSqueezyCheckout(client, packageKey, packageType, callback)
	if (self.disabled) then
		client:Notify("Premium shop is currently unavailable.")
		return
	end

	local package = nil
	local price = 0
	local currency = "EUR"
	local itemName = ""
	local itemDescription = ""

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
		itemName = package.name
		itemDescription = package.description
	elseif (packageType == "item") then
		local itemTable = ix.item.Get(packageKey)
		if (not itemTable or not itemTable.premiumPriceInEuro) then
			client:Notify("Invalid premium item.")
			return
		end

		price = itemTable.premiumPriceInEuro
		currency = "EUR"
		itemName = itemTable.name
		itemDescription = itemTable.description or ""
		package = itemTable
	else
		client:Notify("Invalid purchase type.")
		return
	end

	-- Create checkout data with correct structure
	local checkoutData = {
		data = {
			type = "checkouts",
			attributes = {
				custom_price = math.floor(price * 100), -- Convert to cents
				product_options = {
					name = itemName,
					description = itemDescription,
					media = {},
					redirect_url = LEMONSQUEEZY_SUCCESS_URL,
					-- receipt_button_text = "Return to Game",
					-- receipt_link_url = "steam://run/4000"
				},
				checkout_options = {
					embed = false,
					media = false,
					logo = false,
					dark = true
				},
				checkout_data = {
					custom = {
						steamid64 = client:SteamID64(),
						player_name = client:Name(),
						package_key = packageKey,
						package_type = packageType,
						server_name = GetHostName()
					}
				},
				expires_at = nil,
				preview = false,
				test_mode = false
			},
			relationships = {
				store = {
					data = {
						type = "stores",
						id = LEMONSQUEEZY_STORE_ID
					}
				},
				variant = {
					data = {
						type = "variants",
						id = tostring(package.lemonsqueezyVariantId or "0")
					}
				}
			}
		}
	}

	client:Notify("Creating secure payment session. Please wait...")

	HTTP({
		url = PLUGIN.LEMONSQUEEZY_API_URL .. "/checkouts",
		method = "POST",
		headers = {
			["Authorization"] = "Bearer " .. LEMONSQUEEZY_API_KEY,
			["Accept"] = "application/vnd.api+json",
			["Content-Type"] = "application/vnd.api+json"
		},
		body = util.TableToJSON(checkoutData),
		success = function(code, body, headers)
			if (not IsValid(client) or not client:GetCharacter()) then
				return
			end

			if (code ~= 201) then
				print("[LemonSqueezy] Failed to create checkout: " .. code .. " - " .. tostring(body))
				client:Notify("Failed to create payment session. Please try again.")

				if (callback) then
					callback(false, "HTTP error: " .. code)
				end
				return
			end

			local response = util.JSONToTable(body)

			if (response and response.data and response.data.attributes) then
				local checkoutUrl = response.data.attributes.url
				local checkoutId = response.data.id

				-- Store payment record in database
				PLUGIN:CreatePaymentRecord(
					checkoutId,
					checkoutUrl,
					client,
					packageKey,
					packageType,
					price,
					currency,
					function(success, paymentId)
						if (not success) then
							print("[LemonSqueezy] Failed to create payment record for checkout: " .. checkoutId)
						else
							-- Start automatic polling for this payment
							PLUGIN:StartPaymentPolling(checkoutId, client:SteamID64())
						end
					end
				)

				net.Start("expPremiumShopLemonSqueezyURL")
				net.WriteString(checkoutUrl)
				net.WriteString(checkoutId)
				net.Send(client)

				print("[LemonSqueezy] Created checkout: " .. checkoutId .. " for " .. client:Name())

				if (callback) then
					callback(true, response)
				end
			else
				print("[LemonSqueezy] Invalid response format: " .. tostring(body))
				client:Notify("Failed to create payment session. Please try again.")

				if (callback) then
					callback(false, "Invalid response format")
				end
			end
		end,
		failed = function(reason)
			print("[LemonSqueezy] HTTP request failed: " .. reason)
			client:Notify("Payment system temporarily unavailable. Please try again later.")

			if (callback) then
				callback(false, "Network error: " .. reason)
			end
		end
	})
end

function PLUGIN:StartPaymentPolling(sessionId, steamid64)
	-- Clear any existing timer for this session
	if (self.activePollingTimers[sessionId]) then
		timer.Remove(self.activePollingTimers[sessionId])
	end

	local timerName = "PremiumPaymentPoll_" .. sessionId
	local pollCount = 0
	local maxPolls = 240 -- 1 hour with 15-second intervals (240 * 15 = 3600 seconds)

	print("[Premium Shop] Starting automatic payment polling for session: " .. sessionId)

	-- Store timer name for cleanup
	self.activePollingTimers[sessionId] = timerName

	timer.Create(timerName, 15, maxPolls, function()
		pollCount = pollCount + 1

		-- Get payment record from database
		PLUGIN:GetPaymentRecord(sessionId, function(success, payment)
			if (not success) then
				print("[Premium Shop] Payment record not found during polling: " .. sessionId)
				timer.Remove(timerName)
				self.activePollingTimers[sessionId] = nil
				return
			end

			-- Check if payment is completed
			if (payment.status == "completed") then
				print("[Premium Shop] Payment completed during polling: " .. sessionId)

				-- Find the player if they're online
				local targetPlayer = nil
				for _, ply in ipairs(player.GetAll()) do
					if (ply:SteamID64() == steamid64) then
						targetPlayer = ply
						break
					end
				end

				if (targetPlayer and IsValid(targetPlayer) and targetPlayer:GetCharacter()) then
					-- Player is online, process immediately
					PLUGIN:HandleSuccessfulPayment(targetPlayer, payment, sessionId)
				else
					-- Player is offline, mark for processing when they join
					PLUGIN:MarkPaymentForOfflineProcessing(sessionId, steamid64, payment)
				end

				-- Stop polling
				timer.Remove(timerName)
				self.activePollingTimers[sessionId] = nil
				return
			end

			-- Check if payment failed or expired
			if (payment.status == "failed" or payment.status == "expired" or payment.status == "refunded") then
				print("[Premium Shop] Payment " .. payment.status .. " during polling: " .. sessionId)
				timer.Remove(timerName)
				self.activePollingTimers[sessionId] = nil
				return
			end

			-- Continue polling if still pending
			if (pollCount >= maxPolls) then
				-- The player can manually refresh their payment status
				print("[Premium Shop] Payment polling timeout for session: " .. sessionId)
				self.activePollingTimers[sessionId] = nil
			end
		end)
	end)
end

function PLUGIN:MarkPaymentForOfflineProcessing(sessionId, steamid64, payment)
	-- Add a flag to the payment record indicating it needs processing when player joins
	local query = mysql:Update("exp_premium")
	query:Update("needs_processing", 1)
	query:Update("updated_at", os.time())
	query:Where("session_id", sessionId)
	query:Callback(function(data, status)
		if (status) then
			print("[Premium Shop] Marked payment for offline processing: " .. sessionId)
		else
			print("[Premium Shop] Failed to mark payment for offline processing: " .. sessionId)
		end
	end)
	query:Execute()
end

function PLUGIN:ProcessOfflinePayments(client)
	if (not IsValid(client) or not client:GetCharacter()) then
		return
	end

	local steamid64 = client:SteamID64()

	-- Find completed payments that need processing for this player
	local query = mysql:Select("exp_premium")
	query:Where("steamid64", steamid64)
	query:Where("status", "completed")
	query:Where("needs_processing", 1)
	query:Callback(function(result)
		for _, payment in ipairs(result) do
			payment.cart_items = util.JSONToTable(payment.cart_items)

			-- Process the payment
			PLUGIN:HandleSuccessfulPayment(client, payment, payment.session_id)

			-- Remove the processing flag
			local updateQuery = mysql:Update("exp_premium")
			updateQuery:Update("needs_processing", 0)
			updateQuery:Update("updated_at", os.time())
			updateQuery:Where("session_id", payment.session_id)
			updateQuery:Execute()
		end
	end)
	query:Execute()
end

function PLUGIN:CheckLemonSqueezyOrder(orderId, callback)
	if (self.disabled) then
		callback(false, "LemonSqueezy integration disabled")
		return
	end

	HTTP({
		url = PLUGIN.LEMONSQUEEZY_API_URL .. "/orders/" .. orderId,
		method = "GET",
		headers = {
			["Authorization"] = "Bearer " .. LEMONSQUEEZY_API_KEY,
			["Accept"] = "application/vnd.api+json"
		},
		success = function(code, body, headers)
			if (code == 200) then
				local response = util.JSONToTable(body)
				callback(true, response)
			else
				callback(false, "HTTP error: " .. code)
			end
		end,
		failed = function(reason)
			callback(false, "Network error: " .. reason)
		end
	})
end

function PLUGIN:HandleSuccessfulPayment(client, payment, orderId)
	if (not IsValid(client) or not client:GetCharacter()) then
		return
	end

	client.expIsUpdatingPaymentStatus = client.expIsUpdatingPaymentStatus or {}

	if (client.expIsUpdatingPaymentStatus[orderId]) then
		return
	end

	client.expIsUpdatingPaymentStatus[orderId] = true

	PLUGIN:UpdatePaymentStatus(orderId, "completed", function(status)
		if (not IsValid(client) or not client:GetCharacter()) then
			PLUGIN:UpdatePaymentStatus(orderId, "pending", function(status)
				if (not status) then
					ix.util.SchemaErrorNoHalt(
						"Failed to revert payment status to pending for " .. orderId .. ". Please check the database."
					)
				end
			end)
			return
		end

		client.expIsUpdatingPaymentStatus[orderId] = nil

		if (not status) then
			client:Notify(
				"Failed to update payment status. Please try again later or contact a developer if the issue persists.")
			return
		end

		local cartItems = payment.cart_items
		local purchasedItems = {}

		for _, cartItem in ipairs(cartItems) do
			if (cartItem.type == "package") then
				if (client:GivePremiumKey(cartItem.key)) then
					table.insert(purchasedItems, cartItem.item and cartItem.item.name or cartItem.key .. " (Package)")

					ix.log.Add(
						client,
						"premiumPurchase",
						"Purchased premium package: " .. cartItem.key .. " (LemonSqueezy: " .. orderId .. ")"
					)
				else
					ix.log.Add(
						client,
						"premiumPurchaseFailed",
						"Failed to purchase premium package: " ..
						cartItem.key .. " (LemonSqueezy: " .. orderId .. ") - Already has package"
					)
				end
			elseif (cartItem.type == "item") then
				-- TODO: Implement item rewards
				ix.util.SchemaErrorNoHalt("Not yet implemented item rewards. TODO!")
			end
		end

		if (#purchasedItems > 0) then
			client:Notify("Payment successful! You've automatically received: " .. table.concat(purchasedItems, ", "))

			hook.Run("OnPremiumPurchaseCompleted", client, cartItems, orderId)

			print("[LemonSqueezy] Successfully processed payment for " ..
				client:Name() .. " - Items: " .. table.concat(purchasedItems, ", "))

			net.Start("expPremiumShopFinishPayment")
			net.Send(client)
		end
	end)
end

net.Receive("expPremiumShopCheckPayment", function(length, client)
	local orderId = net.ReadString()

	-- Check if payment exists and belongs to this player
	PLUGIN:GetPaymentRecord(orderId, function(success, payment)
		if (not success) then
			client:Notify("Payment session not found.")
			return
		end

		if (payment.steamid64 ~= client:SteamID64()) then
			client:Notify("Invalid payment session.")
			return
		end

		PLUGIN:ForceCheckClientPayment(client, orderId, payment)
	end)
end)

function PLUGIN:ForceCheckClientPayment(client, orderId, payment)
	-- For LemonSqueezy, we just check the database status since webhooks handle the updates
	if (payment.status == "completed") then
		if (not client.expIsUpdatingPaymentStatus or not client.expIsUpdatingPaymentStatus[orderId]) then
			PLUGIN:HandleSuccessfulPayment(client, payment, orderId)
		else
			client:Notify("Payment has already been processed.")
		end
	elseif (payment.status == "pending") then
		client:Notify("Payment is still being processed. Please wait a moment and try again.")
	elseif (payment.status == "expired") then
		client:Notify("Payment session expired. Please try again.")
	elseif (payment.status == "refunded") then
		client:Notify("This payment has been refunded.")
	else
		client:Notify("Payment status: " .. payment.status)
	end
end

-- Clean up old pending payments (mark as expired)
timer.Create("LemonSqueezyCleanupExpiredPayments", 3600, 0, function()
	local expiredTime = os.time() - (60 * 60 * 24) -- 24 hours ago

	local query = mysql:Update("exp_premium")
	query:Update("status", "expired")
	query:Update("updated_at", os.time())
	query:Where("status", "pending")
	query:WhereLT("created_at", expiredTime)
	query:Callback(function(data, status, affectedRows)
		if (affectedRows and affectedRows > 0) then
			print("[LemonSqueezy] Marked " .. affectedRows .. " pending payments as expired")
		end
	end)
	query:Execute()
end)

-- Clean up old polling timers on plugin unload
function PLUGIN:OnUnloaded()
	for sessionId, timerName in pairs(self.activePollingTimers) do
		timer.Remove(timerName)
	end
	self.activePollingTimers = {}
end
