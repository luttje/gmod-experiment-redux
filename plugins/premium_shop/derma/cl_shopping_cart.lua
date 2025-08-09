local PLUGIN = PLUGIN

-- Shopping cart system
PLUGIN.shoppingCart = PLUGIN.shoppingCart or {}

function PLUGIN:AddToCart(itemType, itemKey, quantity)
	quantity = quantity or 1

	-- Find existing item in cart
	for i, cartItem in ipairs(self.shoppingCart) do
		if (cartItem.type == itemType and cartItem.key == itemKey) then
			cartItem.quantity = cartItem.quantity + quantity
			self:UpdateCartUI()

			return true
		end
	end

	-- Add new item to cart
	table.insert(self.shoppingCart, {
		type = itemType,
		key = itemKey,
		quantity = quantity
	})

	self:UpdateCartUI()
	return true
end

function PLUGIN:RemoveFromCart(itemType, itemKey, quantity)
	quantity = quantity or math.huge

	for i, cartItem in ipairs(self.shoppingCart) do
		if (cartItem.type == itemType and cartItem.key == itemKey) then
			if quantity >= cartItem.quantity then
				table.remove(self.shoppingCart, i)
			else
				cartItem.quantity = cartItem.quantity - quantity
			end

			self:UpdateCartUI()

			return true
		end
	end

	return false
end

-- Clear entire cart
function PLUGIN:ClearCart()
	self.shoppingCart = {}
	self:UpdateCartUI()
end

-- Get cart total
function PLUGIN:GetCartTotal()
	local total = 0
	local currency = nil

	for _, cartItem in ipairs(self.shoppingCart) do
		local price = 0
		local itemCurrency = "EUR"

		if (cartItem.type == "package") then
			local package = PLUGIN.PREMIUM_PACKAGES[cartItem.key]

			if (package) then
				price = package.price
				itemCurrency = package.currency or "EUR"
			end
		elseif (cartItem.type == "item") then
			local item = ix.item.Get(cartItem.key)

			if (item and item.premiumPriceInEuro) then
				price = item.premiumPriceInEuro
				itemCurrency = "EUR"
			end
		end

		-- Check currency consistency
		if (not currency) then
			currency = itemCurrency
		elseif (currency ~= itemCurrency) then
			return 0, "MIXED" -- Mixed currencies not allowed
		end

		total = total + (price * cartItem.quantity)
	end

	return total, currency or "EUR"
end

function PLUGIN:GetCartCount(itemID)
	local count = 0

	for _, cartItem in ipairs(self.shoppingCart) do
		if (not itemID or cartItem.key == itemID) then
			count = count + cartItem.quantity
		end
	end

	return count
end

function PLUGIN:UpdateCartUI()
	-- Update cart button if it exists
	if (IsValid(ix.gui.premiumShop) and IsValid(ix.gui.premiumShop.cartButton)) then
		local count = self:GetCartCount()
		local buttonText = "Shopping Cart"

		if (count > 0) then
			buttonText = "Shopping Cart (" .. count .. ")"
		end

		ix.gui.premiumShop.cartButton:SetText(buttonText)
	end

	-- Update cart panel if it's open
	if (IsValid(self.cartPanel)) then
		self.cartPanel:RefreshCart()
	end
end

function PLUGIN:ShowCartPanel()
	if (IsValid(self.cartPanel)) then
		self.cartPanel:Close()
	end

	if (IsValid(self.paymentHistoryPanel)) then
		self.paymentHistoryPanel:Close()
	end

	self.cartPanel = vgui.Create("expShoppingCartPanel")
	self.cartPanel:MakePopup()
end

-- Shopping Cart Panel
local PANEL = {}

function PANEL:Init()
	self:SetSize(500, 600)
	self:Center()
	self:SetTitle("Shopping Cart")
	self:SetDeleteOnClose(true)

	-- Cart items scroll panel
	self.scroll = self:Add("DScrollPanel")
	self.scroll:Dock(FILL)
	self.scroll:DockMargin(8, 8, 8, 8)

	-- Bottom panel for total and checkout
	self.bottomPanel = self:Add("DPanel")
	self.bottomPanel:SetTall(100)
	self.bottomPanel:Dock(BOTTOM)
	self.bottomPanel:DockMargin(8, 0, 8, 8)
	self.bottomPanel:SetPaintBackground(false)

	self:RefreshCart()
end

function PANEL:RefreshCart()
	-- Clear existing items
	self.scroll:Clear()

	local cartItems = PLUGIN.shoppingCart

	if (#cartItems == 0) then
		self:ShowEmptyCart()
		return
	end

	-- Add each cart item
	for i, cartItem in ipairs(cartItems) do
		local itemPanel = self.scroll:Add("expCartItemPanel")
		itemPanel:SetCartItem(cartItem, i)
		itemPanel:Dock(TOP)
		itemPanel:DockMargin(5, 5, 5, 5)
	end

	self:UpdateTotal()
end

function PANEL:ShowEmptyCart()
	local emptyLabel = self.scroll:Add("DLabel")
	emptyLabel:SetText("Your cart is empty")
	emptyLabel:SetFont("ixMediumFont")
	emptyLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	emptyLabel:SetContentAlignment(5)
	emptyLabel:Dock(FILL)

	-- Hide bottom panel
	self.bottomPanel:SetVisible(false)
end

function PANEL:UpdateTotal()
	self.bottomPanel:Clear()
	self.bottomPanel:SetVisible(true)

	local total, currency = PLUGIN:GetCartTotal()

	if (currency == "MIXED") then
		local errorLabel = self.bottomPanel:Add("DLabel")
		errorLabel:SetText("Error: Cart contains items with different currencies")
		errorLabel:SetFont("ixMediumFont")
		errorLabel:SetTextColor(PLUGIN.THEME.danger)
		errorLabel:SetContentAlignment(5)
		errorLabel:Dock(TOP)
		errorLabel:SetTall(30)
		return
	end

	-- Total display
	local totalPanel = self.bottomPanel:Add("DPanel")
	totalPanel:SetTall(40)
	totalPanel:Dock(TOP)
	totalPanel:DockMargin(0, 0, 0, 8)
	totalPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(4, 0, 0, w, h, PLUGIN.THEME.panel)

		-- Total text
		surface.SetTextColor(255, 255, 255)
		surface.SetFont("ixMediumFont")

		local totalText = "Total: " .. (PLUGIN.PREMIUM_CURRENCIES[currency] or "€") .. string.format("%.2f", total)
		local tw, th = surface.GetTextSize(totalText)

		surface.SetTextPos(w - tw - 15, h / 2 - th / 2)
		surface.DrawText(totalText)

		-- Item count
		surface.SetTextColor(PLUGIN.THEME.textSecondary)
		surface.SetFont("ixSmallFont")

		local countText = PLUGIN:GetCartCount() .. " items"

		surface.SetTextPos(15, h / 2 - 8)
		surface.DrawText(countText)
	end

	-- Button panel
	local buttonPanel = self.bottomPanel:Add("DPanel")
	buttonPanel:Dock(FILL)
	buttonPanel:SetPaintBackground(false)

	-- Clear cart button
	local clearButton = buttonPanel:Add("expButton")
	clearButton:SetText("Clear Cart")
	clearButton:Dock(LEFT)
	clearButton:SizeToContents()
	clearButton:DockMargin(0, 0, 8, 0)
	clearButton.DoClick = function()
		PLUGIN:ClearCart()
		self:RefreshCart()
	end

	-- Checkout button
	local checkoutButton = buttonPanel:Add("expButton")
	checkoutButton:SetText("Checkout")
	checkoutButton:Dock(FILL)
	checkoutButton:SizeToContents()
	checkoutButton.DoClick = function()
		self:ProcessCheckout()
	end
end

function PANEL:ProcessCheckout()
	if (#PLUGIN.shoppingCart == 0) then
		Derma_Message("Your cart is empty!", "Checkout Error", "OK")
		return
	end

	local total, currency = PLUGIN:GetCartTotal()

	if (currency == "MIXED") then
		Derma_Message(
			"Your cart contains items with different currencies. Please remove items so all use the same currency.",
			"Checkout Error", "OK")
		return
	end

	local currencySymbol = PLUGIN.PREMIUM_CURRENCIES[currency] or "€"
	local confirmText = string.format(
		"Confirm purchase of %d items for %s%.2f?\n\nThis will redirect you to our secure payment processor.",
		PLUGIN:GetCartCount(),
		currencySymbol,
		total
	)

	Derma_Query(
		confirmText,
		"Confirm Cart Purchase",
		"Purchase",
		function()
			-- Send cart to server
			net.Start("expPremiumShopCart")
			net.WriteTable({ items = PLUGIN.shoppingCart })
			net.SendToServer()

			self:Close()
		end,
		"Cancel"
	)
end

-- Always keep on top so we don't go behind the main menu
function PANEL:Think()
	self:MoveToFront()
end

vgui.Register("expShoppingCartPanel", PANEL, "expFrame")

-- Individual cart item panel
PANEL = {}

function PANEL:Init()
	self:SetTall(80)
end

function PANEL:SetCartItem(cartItem, index)
	self.cartItem = cartItem
	self.index = index

	-- Get item info
	local item = nil
	local itemName = "Unknown Item"
	local itemPrice = 0
	local currency = "EUR"

	if (cartItem.type == "package") then
		item = PLUGIN.PREMIUM_PACKAGES[cartItem.key]

		if (item) then
			itemName = item.name
			itemPrice = item.price
			currency = item.currency or "EUR"
		end
	elseif (cartItem.type == "item") then
		item = ix.item.Get(cartItem.key)

		if (item) then
			itemName = item.name
			itemPrice = item.premiumPriceInEuro or 0
			currency = "EUR"
		end
	end

	-- Remove button
	local removeButton = self:Add("expButton")
	removeButton:SetText("x")
	removeButton:SetSize(30, 30)
	removeButton.DoClick = function()
		PLUGIN:RemoveFromCart(cartItem.type, cartItem.key)
	end

	self.Paint = function(pnl, w, h)
		removeButton:SetPos(w - 35, h - 35)

		-- Background
		draw.RoundedBox(4, 0, 0, w, h, PLUGIN.THEME.panel)

		-- Item icon area
		local iconSize = h - 10
		draw.RoundedBox(4, 5, 5, iconSize, iconSize, PLUGIN.THEME.surface)

		-- Draw icon if available
		if (item and item.image) then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(item.image)
			surface.DrawTexturedRect(8, 8, iconSize - 6, iconSize - 6)
		end

		-- Item name
		surface.SetTextColor(255, 255, 255)
		surface.SetFont("ixMediumFont")

		local nameY = 15

		surface.SetTextPos(iconSize + 15, nameY)
		surface.DrawText(itemName)

		-- Item type
		surface.SetTextColor(PLUGIN.THEME.textSecondary)
		surface.SetFont("ixSmallFont")

		local typeText = cartItem.type == "package" and "Premium Package" or "Premium Item"

		surface.SetTextPos(iconSize + 15, nameY + 20)
		surface.DrawText(typeText)

		-- Price and quantity
		surface.SetTextColor(PLUGIN.THEME.premium)
		surface.SetFont("ixSmallFont")

		local currencySymbol = PLUGIN.PREMIUM_CURRENCIES[currency] or "€"
		local priceText = currencySymbol .. string.format("%.2f", itemPrice) .. " x " .. cartItem.quantity
		local tw, th = surface.GetTextSize(priceText)

		surface.SetTextPos(w - tw - 80, nameY + 40)
		surface.DrawText(priceText)

		-- Total for this item
		surface.SetTextColor(255, 255, 255)
		surface.SetFont("ixMediumFont")

		local totalText = currencySymbol .. string.format("%.2f", itemPrice * cartItem.quantity)
		local ttw, tth = surface.GetTextSize(totalText)

		surface.SetTextPos(w - ttw - 15, nameY)
		surface.DrawText(totalText)
	end
end

vgui.Register("expCartItemPanel", PANEL, "DPanel")
