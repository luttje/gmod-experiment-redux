local PLUGIN = PLUGIN

util.AddNetworkString("expPremiumShopStripeURL")
util.AddNetworkString("expPremiumShopCheckPayment")
util.AddNetworkString("expPremiumShopFinishPayment")

local STRIPE_SECRET_KEY,
STRIPE_PUBLISHABLE_KEY,
STRIPE_SUCCESS_URL,
STRIPE_CANCEL_URL

PLUGIN.STRIPE_API_URL = "https://api.stripe.com/v1"

function PLUGIN:OnLoaded()
	local envFile = file.Read(self.folder .. "/.env", "LUA")

	if (not envFile) then
		ix.util.SchemaErrorNoHalt("The .env file is missing from the premium shop folder.")
		self.disabled = true
		return
	end

	local variables = Schema.util.EnvToTable(envFile)

	STRIPE_SECRET_KEY = variables.STRIPE_SECRET_KEY
	STRIPE_PUBLISHABLE_KEY = variables.STRIPE_PUBLISHABLE_KEY
	STRIPE_SUCCESS_URL = variables.STRIPE_SUCCESS_URL
	STRIPE_CANCEL_URL = variables.STRIPE_CANCEL_URL

	if (not STRIPE_SECRET_KEY or not STRIPE_PUBLISHABLE_KEY) then
		ix.util.SchemaErrorNoHalt("Stripe keys are missing from .env file.")
		self.disabled = true
		return
	end

	print("[Premium Shop] Stripe integration loaded successfully")
end

function PLUGIN:CreateStripeCheckoutSessionForCart(client, cartItems, totalPrice, currency, callback)
	if (self.disabled) then
		client:Notify("Premium shop is currently unavailable.")
		return
	end

	local currencyLower = string.lower(currency or "eur")

	local postData = {
		["mode"] = "payment",
		["success_url"] = STRIPE_SUCCESS_URL .. "?session_id={CHECKOUT_SESSION_ID}",
		["cancel_url"] = STRIPE_CANCEL_URL,
		["metadata[player_steamid]"] = client:SteamID64(),
		["metadata[player_name]"] = client:Name(),
		["metadata[server_name]"] = GetHostName(),
		["metadata[cart_total]"] = tostring(totalPrice),
		["metadata[cart_currency]"] = currency
	}

	for i, cartItem in ipairs(cartItems) do
		local lineIndex = i - 1
		local itemPrice = math.floor(cartItem.price * 100)

		postData[string.format("line_items[%d][price_data][currency]", lineIndex)] = currencyLower
		postData[string.format("line_items[%d][price_data][product_data][name]", lineIndex)] = cartItem.item.name
		postData[string.format("line_items[%d][price_data][product_data][description]", lineIndex)] = cartItem.item
			.description or ""
		postData[string.format("line_items[%d][price_data][unit_amount]", lineIndex)] = tostring(itemPrice)
		postData[string.format("line_items[%d][quantity]", lineIndex)] = tostring(cartItem.quantity)

		postData[string.format("metadata[item_%d_type]", lineIndex)] = cartItem.type
		postData[string.format("metadata[item_%d_key]", lineIndex)] = cartItem.key
		postData[string.format("metadata[item_%d_quantity]", lineIndex)] = tostring(cartItem.quantity)
	end

	local function encodePostData(data)
		local encoded = {}
		for key, value in pairs(data) do
			table.insert(encoded, key .. "=" .. Schema.util.UrlEncode(tostring(value)))
		end
		return table.concat(encoded, "&")
	end

	client:Notify("Opening secure payment window. Please wait...")

	HTTP({
		url = PLUGIN.STRIPE_API_URL .. "/checkout/sessions",
		method = "POST",
		headers = {
			["Authorization"] = "Bearer " .. STRIPE_SECRET_KEY,
			["Content-Type"] = "application/x-www-form-urlencoded",
			["Stripe-Version"] = "2023-10-16"
		},
		body = encodePostData(postData),
		success = function(code, body, headers)
			if (not IsValid(client) or not client:GetCharacter()) then
				-- We can safely do nothing, as the payment has been created at stripe, but not here. No money will have been transferred.
				return
			end

			if (code ~= 200) then
				print("[Stripe] Failed to create checkout session: " .. code .. " - " .. tostring(body))

				client:Notify("Failed to create payment session. Please try again.")

				if (callback) then
					callback(false, "HTTP error: " .. code)
				end

				return
			end

			local response = util.JSONToTable(body)

			if (response and response.id) then
				-- Create payment record in database
				PLUGIN:CreatePaymentRecord(response.id, response.url, client, cartItems, totalPrice, currency,
					function(success, paymentDatabaseId)
						if (not IsValid(client) or not client:GetCharacter()) then
							-- We can safely do nothing as this payment can just be ignored as incomplete.
							return
						end

						if (success) then
							net.Start("expPremiumShopStripeURL")
							net.WriteString(response.url)
							net.WriteString(response.id)
							net.Send(client)

							print("[Stripe] Created checkout session: " .. response.id .. " for " .. client:Name())

							if (callback) then
								callback(true, response)
							end
						else
							client:Notify("Failed to create payment record. Please try again.")
							if (callback) then
								callback(false, "Database error")
							end
						end
					end)
			else
				print("[Stripe] Invalid response format: " .. tostring(body))
				client:Notify("Failed to create payment session. Please try again.")
				if (callback) then
					callback(false, "Invalid response format")
				end
			end
		end,
		failed = function(reason)
			print("[Stripe] HTTP request failed: " .. reason)
			client:Notify("Payment system temporarily unavailable. Please try again later.")
			if (callback) then
				callback(false, "Network error: " .. reason)
			end
		end
	})
end

function PLUGIN:CheckStripeCheckoutSession(sessionId, callback)
	if (self.disabled) then
		callback(false, "Stripe integration disabled")
		return
	end

	HTTP({
		url = PLUGIN.STRIPE_API_URL .. "/checkout/sessions/" .. sessionId,
		method = "GET",
		headers = {
			["Authorization"] = "Bearer " .. STRIPE_SECRET_KEY,
			["Stripe-Version"] = "2023-10-16"
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

function PLUGIN:HandleSuccessfulCartPayment(client, payment, sessionId)
	if (not IsValid(client) or not client:GetCharacter()) then
		-- We can safely do nothing, as when the player rejoins they can re-check their payment status
		return
	end

	client.expIsUpdatingPaymentStatus = client.expIsUpdatingPaymentStatus or {}

	if (client.expIsUpdatingPaymentStatus[sessionId]) then
		-- If we're already updating this payment status, we can ignore the request
		return
	end

	client.expIsUpdatingPaymentStatus[sessionId] = true

	PLUGIN:UpdatePaymentStatus(sessionId, "completed", function(status)
		if (not IsValid(client) or not client:GetCharacter()) then
			-- The client has left! We have to return their payment status to pending so they can pickup the items later.
			PLUGIN:UpdatePaymentStatus(sessionId, "pending", function(status)
				if (not status) then
					-- Throw a Lua error if the status could not be reverted while the player was away so a developer can find it later.
					ix.util.SchemaErrorNoHalt(
						"Failed to revert payment status to pending for " .. sessionId .. ". Please check the database."
					)
				end
			end)

			return
		end

		client.expIsUpdatingPaymentStatus[sessionId] = nil

		if (not status) then
			client:Notify(
				"Failed to update payment status. Please try again later or contact a developer if the issue persists."
			)
			return
		end

		local cartItems = payment.cart_items
		local purchasedItems = {}

		for _, cartItem in ipairs(cartItems) do
			if (cartItem.type == "package") then
				if (client:GivePremiumKey(cartItem.key)) then
					table.insert(purchasedItems, cartItem.item.name .. " (Package)")

					ix.log.Add(
						client,
						"premiumPurchase",
						"Purchased premium package: " .. cartItem.key .. " (Stripe: " .. sessionId .. ")"
					)
				else
					ix.log.Add(
						client,
						"premiumPurchaseFailed",
						"Failed to purchase premium package: " ..
						cartItem.key .. " (Stripe: " .. sessionId .. ") - Already has package"
					)
				end
			elseif (cartItem.type == "item") then
				-- TODO: Implement this in a way that players get all items, or that we check they have an inventory spot
				ix.util.SchemaErrorNoHalt("Not yet implemented item rewards. TODO!")
				-- local character = client:GetCharacter()
				-- local itemTable = ix.item.Get(cartItem.key)

				-- if (character and itemTable) then
				-- 	local inventory = character:GetInventory()

				-- 	for i = 1, cartItem.quantity do
				-- 		local status, errorMessage = inventory:Add(cartItem.key, 1)

				-- 		if (status) then
				-- 			if (i == 1) then
				-- 				table.insert(purchasedItems, cartItem.item.name .. " x" .. cartItem.quantity)
				-- 			end
				-- 		else
				-- 			table.insert(failedItems, cartItem.item.name .. " (Inventory full: " .. errorMessage .. ")")
				-- 			break
				-- 		end
				-- 	end
				-- else
				-- 	table.insert(failedItems, cartItem.item.name .. " (Character/Item not found)")
				-- end
			end
		end

		if (#purchasedItems > 0) then
			client:Notify("Payment successful! Purchased: " .. table.concat(purchasedItems, ", "))

			hook.Run("OnPremiumCartPurchaseCompleted", client, cartItems, sessionId)

			print(
				"[Stripe] Successfully processed cart payment for " ..
				client:Name() .. " - Items: " .. table.concat(purchasedItems, ", ")
			)

			net.Start("expPremiumShopFinishPayment")
			net.Send(client)
		end
	end)
end

net.Receive("expPremiumShopCheckPayment", function(length, client)
	local sessionId = net.ReadString()

	PLUGIN:GetPaymentRecord(sessionId, function(success, payment)
		if (not success) then
			client:Notify("Payment session not found.")
			return
		end

		if (payment.steamid64 ~= client:SteamID64()) then
			client:Notify("Invalid payment session.")
			return
		end

		PLUGIN:ForceCheckClientPayment(client, sessionId, payment)
	end)
end)

function PLUGIN:ForceCheckClientPayment(client, sessionId, payment)
	PLUGIN:CheckStripeCheckoutSession(sessionId, function(success, response)
		if (not IsValid(client) or not client:GetCharacter()) then
			-- We can safely do nothing, as when the player rejoins they can re-check their payment status
			return
		end

		if (success and response) then
			if (response.payment_status == "paid") then
				if (payment.status == "pending") then
					PLUGIN:HandleSuccessfulCartPayment(client, payment, sessionId)
				else
					client:Notify("Payment has already been processed.")
				end
			elseif (response.status == "expired") then
				client:Notify("Payment session expired. Please try again.")
				PLUGIN:UpdatePaymentStatus(sessionId, "expired")
			else
				client:Notify(
					"Payment not yet completed. Visit 'Payment History' in the shop to or try completing the payment again."
				)
			end
		else
			client:Notify("Unable to check payment status. Please try again.")
		end
	end)
end

-- Clean up old pending payments (mark as expired)
timer.Create("StripeCleanupExpiredPayments", 3600, 0, function() -- Run every hour
	local expiredTime = os.time() - (60 * 60 * 2)                -- 2 hours ago

	local query = mysql:Update("exp_premium")
	query:Update("status", "expired")
	query:Update("updated_at", os.time())
	query:Where("status", "pending")
	query:Where("created_at", "<", expiredTime)
	query:Callback(function(data, status, affectedRows)
		if (affectedRows and affectedRows > 0) then
			print("[Stripe] Marked " .. affectedRows .. " pending payments as expired")
		end
	end)
	query:Execute()
end)
