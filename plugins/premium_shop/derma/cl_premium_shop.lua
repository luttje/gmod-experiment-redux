local PLUGIN = PLUGIN
local PANEL = {}

local BUTTON_HEIGHT = 36

function PANEL:GetItems(category, search)
	category = category ~= "searchResults" and category or nil
	search = search and search:lower() or nil

	local items = {}

	-- Get premium packages
	for key, package in pairs(PLUGIN.PREMIUM_PACKAGES) do
		local searchMismatch = search and search ~= "" and not package.name:lower():find(search, 1, true)

		if (searchMismatch and not package.description:lower():find(search, 1, true)) then
			continue
		end

		if (not category or package.category == category) then
			package.isPremiumPackage = true
			package.uniqueID = key
			items[#items + 1] = package
		end
	end

	-- Get premium items
	for uniqueID, itemTable in pairs(ix.item.list) do
		if (not itemTable.premiumPriceInEuro) then
			continue
		end

		local searchMismatch = search and search ~= "" and not itemTable.name:lower():find(search, 1, true)

		if (searchMismatch and itemTable.description and not itemTable.description:lower():find(search, 1, true)) then
			continue
		end

		local itemCategory = itemTable.premiumCategory or "Items"
		if (not category or itemCategory == category) then
			itemTable.isPremiumPackage = false
			items[#items + 1] = itemTable
		end
	end

	return items
end

function PANEL:Init()
	ix.gui.premiumShop = self
	Schema.premiumShopPanel = self

	self:Dock(FILL)

	self:SetupHeader()

	self.categories = self:Add("DIconLayout")
	self.categories:SetSpaceY(5)
	self.categories:SetSpaceX(5)
	self.categories:SetBorder(5)
	self.categories:DockPadding(0, 0, 0, 5)
	self.categories:DockMargin(0, 0, 0, 16)
	self.categories:Dock(TOP)
	self.categories.Paint = function(this, w, h)
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(0, 0, w, h)
	end
	self.categoryPanels = {}

	self.scroll = self:Add("DScrollPanel")
	self.scroll:Dock(FILL)

	self.itemList = self.scroll:Add("DIconLayout")
	self.itemList:Dock(TOP)
	self.itemList:SetSpaceX(16)
	self.itemList:SetSpaceY(16)
	self.itemList:SetMinimumSize(128, 400)

	-- Build categories from premium packages and items
	for key, package in pairs(PLUGIN.PREMIUM_PACKAGES) do
		if (not self.categoryPanels[package.category]) then
			self.categoryPanels[package.category] = package.category
		end
	end

	for uniqueID, itemTable in pairs(ix.item.list) do
		if (itemTable.premiumPriceInEuro) then
			local category = itemTable.premiumCategory or "Items"
			if (not self.categoryPanels[category]) then
				self.categoryPanels[category] = category
			end
		end
	end

	local label = self.categories:Add("DLabel")
	label:SetText("Categories:")
	label:SetFont("expSmallerFont")
	label:DockMargin(5, 5, 5, 5)
	label:SetTextColor(Color(255, 255, 255, 100))
	label:SetExpensiveShadow(1, Color(0, 0, 0, 150))
	label:SizeToContents()
	label:SetContentAlignment(5)
	label:SetTall(25)

	local function addCategoryButton(category, realName)
		local button = self.categories:Add("expButton")
		button:SetText(category)
		button:SetScale(BUTTON_SCALE_SMALL)
		button:DockMargin(5, 5, 5, 5)
		button.Paint = function(this, width, height)
			if (self.selected ~= this) then
				return
			end

			this:PaintBackground(width, height)
		end
		button.DoClick = function(this)
			if (self.selected ~= this) then
				self.selected = this
				PLUGIN.lastPremiumCategory = realName

				self:LoadItems(realName, self.search:GetText())
				timer.Simple(0.01, function()
					self.scroll:InvalidateLayout()
				end)
			end
		end
		button.category = realName

		if (not PLUGIN.lastPremiumCategory or PLUGIN.lastPremiumCategory == realName) then
			self.selected = button
			PLUGIN.lastPremiumCategory = realName
		end

		self.categoryPanels[realName] = button

		return button
	end

	for category, realName in SortedPairs(self.categoryPanels) do
		addCategoryButton(category, realName)
	end

	local searchResultButton = addCategoryButton("Search Results", "searchResults")

	if (not PLUGIN.lastPremiumSearch) then
		searchResultButton:SetVisible(false)
	end

	self.categories:Layout()

	self:SetupSearch()
	self:SetupHistoryButton()
	self:SetupDisclaimer()

	if (self.selected) then
		self:LoadItems(self.selected.category, self.search:GetText())
	end
end

function PANEL:SetupHeader()
	local header = self:Add("DPanel")
	header:SetTall(60)
	header:DockMargin(0, 16, 0, 16)
	header:Dock(TOP)
	header.Paint = function(pnl, w, h)
		-- Gradient background
		draw.RoundedBox(8, 0, 0, w, h, PLUGIN.THEME.premium)

		-- Shine effect
		surface.SetDrawColor(255, 255, 255, 30)
		surface.DrawRect(0, 0, w, h * 0.5)
	end

	local titleLabel = header:Add("DLabel")
	titleLabel:SetText("Premium Shop")
	titleLabel:SetFont("ixBigFont")
	titleLabel:SetTextColor(Color(0, 0, 0))
	titleLabel:Dock(LEFT)
	titleLabel:DockMargin(20, 0, 0, 0)
	titleLabel:SizeToContents()

	local subtitleLabel = header:Add("DLabel")
	subtitleLabel:SetText("Support the server and unlock exclusive content!")
	subtitleLabel:SetFont("ixMediumFont")
	subtitleLabel:SetTextColor(Color(50, 50, 50))
	subtitleLabel:Dock(RIGHT)
	subtitleLabel:DockMargin(0, 0, 20, 0)
	subtitleLabel:SizeToContents()
end

function PANEL:SetupSearch()
	-- Create a panel to hold the search bar and history button
	self.searchPanel = self:Add("DPanel")
	self.searchPanel:Dock(TOP)
	self.searchPanel:SetTall(BUTTON_HEIGHT)
	self.searchPanel:DockMargin(0, 0, 0, 16)
	self.searchPanel:SetPaintBackground(false)

	-- Search bar
	self.search = self.searchPanel:Add("DTextEntry")
	self.search:SetText(PLUGIN.lastPremiumSearch or "")
	self.search:Dock(FILL)
	self.search:SetFont("ixMediumFont")
	self.search:DockMargin(0, 0, 140, 0) -- Make room for history button
	self.search.OnTextChanged = function(this)
		local query = self.search:GetText()

		self.selected = self.categoryPanels["searchResults"]
		self.selected:SetVisible(query ~= "")
		self.categories:Layout()

		if (query == "") then
			self.selected = self.categories:GetChildren()[2] -- skip the label
			timer.Simple(0.01, function()
				self.scroll:InvalidateLayout()
			end)
		end

		PLUGIN.lastPremiumCategory = self.selected.category
		PLUGIN.lastPremiumSearch = query
		self:LoadItems(self.selected.category, query:find("%S") and query or nil)

		self.scroll:InvalidateLayout()
	end
	self.search.PaintOver = function(this, cw, ch)
		if (self.search:GetValue() == "" and not self.search:HasFocus()) then
			ix.util.DrawText("V", 10, ch / 2 - 1, color_black, 3, 1, "ixIconsSmall")
		end
	end
end

function PANEL:SetupHistoryButton()
	-- Payment history button
	self.historyButton = self.searchPanel:Add("expButton")
	self.historyButton:SetText("Payment History")
	self.historyButton:Dock(RIGHT)
	self.historyButton:SizeToContents()
	self.historyButton.DoClick = function()
		PLUGIN:ShowPaymentHistory()
	end
end

function PANEL:SetupDisclaimer()
	local disclaimer = self:Add("DPanel")
	disclaimer:SetTall(48)
	disclaimer:DockMargin(0, 16, 0, 0)
	disclaimer:Dock(BOTTOM)
	disclaimer:SetPaintBackground(false)

	local disclaimerLabel = disclaimer:Add("DLabel")
	disclaimerLabel:SetText("Once an item has been utilized, it cannot be refunded. Contact us if you want a refund.")
	disclaimerLabel:SetFont("ixSmallFont")
	disclaimerLabel:DockMargin(5, 5, 5, 5)
	disclaimerLabel:SetTextColor(Color(255, 255, 255, 100))
	disclaimerLabel:SizeToContents()
	disclaimerLabel:Dock(FILL)
end

function PANEL:DisplayItems(items)
	self.itemList:Clear()
	self.itemList:InvalidateLayout(true)

	table.SortByMember(items, "name", true)

	for _, item in ipairs(items) do
		if (item.isPremiumPackage) then
			self.itemList:Add("expPremiumPackageItem"):SetItem(item)
		else
			self.itemList:Add("expPremiumItem"):SetItem(item)
		end
	end

	if (#items > 0) then
		return
	end

	local label = self.itemList:Add("DLabel")
	label:Dock(TOP)
	label:SetText("No premium items found")
	label:SetFont("ixMediumFont")
	label:SetTextColor(color_white)
	label:SetExpensiveShadow(1, Color(0, 0, 0, 150))
	label:SizeToContents()
	label:SetContentAlignment(5)
	label:DockMargin(0, 0, 0, 16)

	local clearButton = self.itemList:Add("expButton")
	clearButton:Dock(TOP)
	clearButton:SetText("Clear Search")
	clearButton:SizeToContents()
	clearButton.DoClick = function()
		self.search:SetText("")
		self.categoryPanels["searchResults"]:SetVisible(false)
		self.categories:Layout()
		self.selected = self.categories:GetChildren()[2] -- skip the label
		PLUGIN.lastPremiumCategory = self.selected.category
		PLUGIN.lastPremiumSearch = nil
		self:LoadItems(self.selected.category)

		timer.Simple(0.01, function()
			self.scroll:InvalidateLayout()
		end)
	end
end

function PANEL:LoadItems(category, search)
	self.itemList:Clear()
	self.itemList:InvalidateLayout(true)

	local items = self:GetItems(category, search)

	self:DisplayItems(items)
end

function PANEL:PurchasePackage(packageKey)
	local package = PLUGIN.PREMIUM_PACKAGES[packageKey]
	if (not package) then
		return
	end

	if (LocalPlayer():HasPremiumKey(packageKey)) then
		Derma_Message("You already own this premium package!", "Purchase Error", "OK")
		return
	end

	-- Create purchase confirmation dialog
	local confirmFrame = vgui.Create("expFrame")
	confirmFrame:SetTitle("Confirm Purchase")
	confirmFrame:SetWide(400)
	confirmFrame:SetTall(200)
	confirmFrame:Center()
	confirmFrame:MakePopup()
	confirmFrame:SetDeleteOnClose(true)

	local packageLabel = confirmFrame:Add("DLabel")
	packageLabel:SetText("Package: " .. package.name)
	packageLabel:SetFont("ixMediumFont")
	packageLabel:SetTextColor(Color(255, 255, 255))
	packageLabel:Dock(TOP)
	packageLabel:DockMargin(8, 8, 8, 4)
	packageLabel:SizeToContents()

	local priceLabel = confirmFrame:Add("DLabel")
	local currencySymbol = PLUGIN.PREMIUM_CURRENCIES[package.currency] or "€"
	priceLabel:SetText("Price: " .. currencySymbol .. string.format("%.2f", package.price))
	priceLabel:SetFont("ixMediumFont")
	priceLabel:SetTextColor(PLUGIN.THEME.premium)
	priceLabel:Dock(TOP)
	priceLabel:DockMargin(8, 4, 8, 8)
	priceLabel:SizeToContents()

	local descLabel = confirmFrame:Add("DLabel")
	descLabel:SetText(package.description)
	descLabel:SetFont("ixSmallFont")
	descLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	descLabel:Dock(TOP)
	descLabel:DockMargin(8, 8, 8, 8)
	descLabel:SetWrap(true)
	descLabel:SetAutoStretchVertical(true)

	local buttonPanel = confirmFrame:Add("DPanel")
	buttonPanel:SetTall(40)
	buttonPanel:Dock(BOTTOM)
	buttonPanel:DockMargin(8, 8, 8, 8)
	buttonPanel:SetPaintBackground(false)

	local cancelButton = buttonPanel:Add("expButton")
	cancelButton:SetText("Cancel")
	cancelButton:Dock(LEFT)
	cancelButton:SizeToContents()
	cancelButton:DockMargin(0, 0, 8, 0)
	cancelButton.DoClick = function()
		confirmFrame:Close()
	end

	local purchaseButton = buttonPanel:Add("expButton")
	purchaseButton:SetText("Purchase")
	purchaseButton:Dock(FILL)
	purchaseButton.DoClick = function()
		confirmFrame:Close()

		net.Start("expPremiumShopPurchase")
		net.WriteString(packageKey)
		net.WriteString("package")
		net.SendToServer()
	end

	confirmFrame:InvalidateChildren(true)
end

function PANEL:PurchaseItem(itemTable)
	-- Create purchase confirmation dialog
	local confirmFrame = vgui.Create("expFrame")
	confirmFrame:SetTitle("Confirm Purchase")
	confirmFrame:SetWide(400)
	confirmFrame:SetTall(200)
	confirmFrame:Center()
	confirmFrame:MakePopup()
	confirmFrame:SetDeleteOnClose(true)

	local itemLabel = confirmFrame:Add("DLabel")
	itemLabel:SetText("Item: " .. itemTable.name)
	itemLabel:SetFont("ixMediumFont")
	itemLabel:SetTextColor(Color(255, 255, 255))
	itemLabel:Dock(TOP)
	itemLabel:DockMargin(8, 8, 8, 4)
	itemLabel:SizeToContents()

	local priceLabel = confirmFrame:Add("DLabel")
	priceLabel:SetText("Price: €" .. string.format("%.2f", itemTable.premiumPriceInEuro))
	priceLabel:SetFont("ixMediumFont")
	priceLabel:SetTextColor(PLUGIN.THEME.premium)
	priceLabel:Dock(TOP)
	priceLabel:DockMargin(8, 4, 8, 8)
	priceLabel:SizeToContents()

	local descLabel = confirmFrame:Add("DLabel")
	descLabel:SetText(itemTable.description or "No description available")
	descLabel:SetFont("ixSmallFont")
	descLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	descLabel:Dock(TOP)
	descLabel:DockMargin(8, 8, 8, 8)
	descLabel:SetWrap(true)
	descLabel:SetAutoStretchVertical(true)

	local buttonPanel = confirmFrame:Add("DPanel")
	buttonPanel:SetTall(40)
	buttonPanel:Dock(BOTTOM)
	buttonPanel:DockMargin(8, 8, 8, 8)
	buttonPanel:SetPaintBackground(false)

	local cancelButton = buttonPanel:Add("expButton")
	cancelButton:SetText("Cancel")
	cancelButton:Dock(LEFT)
	cancelButton:SizeToContents()
	cancelButton:DockMargin(0, 0, 8, 0)
	cancelButton.DoClick = function()
		confirmFrame:Close()
	end

	local purchaseButton = buttonPanel:Add("expButton")
	purchaseButton:SetText("Purchase")
	purchaseButton:Dock(FILL)
	purchaseButton.DoClick = function()
		confirmFrame:Close()

		net.Start("expPremiumShopPurchase")
		net.WriteString(itemTable.uniqueID)
		net.WriteString("item")
		net.SendToServer()
	end

	confirmFrame:InvalidateChildren(true)
end

function PANEL:Refresh()
	self:LoadItems(self.selected.category, self.search:GetText():lower())
end

vgui.Register("expPremiumShop", PANEL, "EditablePanel")

-- Premium Package Item Panel
PANEL = {}

DEFINE_BASECLASS("ixBusinessItem")

function PANEL:Init()
	local size = math.max(ScrW() * 0.12, 140)

	self:SetSizeX(false)
	self:SetWide(size)
end

function PANEL:SetItem(package)
	self:Clear()

	self:SetHelixTooltip(function(tooltip)
		local name = tooltip:AddRow("name")
		name:SetImportant()
		name:SetText(package.name)
		name:SizeToContents()

		local description = tooltip:AddRow("description")
		description:SetText(package.description)
		description:SizeToContents()

		for i, benefit in ipairs(package.benefits) do
			local row = tooltip:AddRow("benefit_" .. benefit)
			row:SetText("• " .. benefit)
			row:SetBackgroundColor(i % 2 == 0 and Color(240, 240, 240, 25) or Color(255, 255, 255, 50))
			row:SizeToContents()
		end

		local priceRow = tooltip:AddRow("price")
		priceRow:SetText(
			"Price: " .. (PLUGIN.PREMIUM_CURRENCIES[package.currency] or "€") .. string.format("%.2f", package.price)
		)
		priceRow:SetTextColor(PLUGIN.THEME.premium)
		priceRow:SizeToContents()
	end)

	-- Icon background
	self.icon = self:Add("DPanel")
	self.icon:Dock(TOP)
	self.icon:SetSize(self:GetWide() - 16, self:GetWide() - 16)
	self.icon:DockMargin(8, 8, 8, 8)
	self.icon.Paint = function(pnl, w, h)
		if (package.image) then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(package.image)
			surface.DrawTexturedRect(0, 0, w, h)
		else
			surface.SetDrawColor(PLUGIN.THEME.premium)
			surface.DrawRect(0, 0, w, h)
		end

		-- Owned overlay
		if (LocalPlayer():HasPremiumKey(package.uniqueID)) then
			surface.SetDrawColor(40, 167, 69, 50)
			surface.DrawRect(0, 0, w, h)

			surface.SetTextColor(255, 255, 255)
			surface.SetFont("ixSmallFont")
			local ownedW, ownedH = surface.GetTextSize("OWNED")
			surface.SetTextPos(w * 0.5 - ownedW * 0.5, h * 0.5 - ownedH * 0.5)
			surface.DrawText("OWNED")
		end
	end
	self.icon:SetMouseInputEnabled(false)

	-- Name label
	self.name = self:Add("DLabel")
	self.name:SetText(package.name)
	self.name:SetFont("ixSmallFont")
	self.name:SetTextColor(color_white)
	self.name:SetExpensiveShadow(1, Color(0, 0, 0, 200))
	self.name:Dock(TOP)
	self.name:DockMargin(8, 0, 8, 8)
	self.name:SetContentAlignment(5)
	self.name:SizeToContents()

	-- Price label
	self.price = self:Add("DLabel")
	local currencySymbol = PLUGIN.PREMIUM_CURRENCIES[package.currency] or "€"
	self.price:SetText(currencySymbol .. string.format("%.2f", package.price))
	self.price:SetFont("ixSmallFont")
	self.price:SetTextColor(PLUGIN.THEME.premium)
	self.price:SetExpensiveShadow(1, Color(0, 0, 0, 200))
	self.price:Dock(TOP)
	self.price:DockMargin(8, 0, 8, 8)
	self.price:SetContentAlignment(5)
	self.price:SizeToContents()

	self.package = package
end

function PANEL:OnMousePressed(key)
	if (key == MOUSE_LEFT) then
		ix.gui.premiumShop:PurchasePackage(self.package.uniqueID)
	end
end

-- On hover, we highlight the item
function PANEL:Paint(width, height)
	if (self:IsHovered() or self:IsChildHovered()) then
		surface.SetDrawColor(PLUGIN.THEME.hover)
		surface.DrawRect(0, 0, width, height)
	end
end

vgui.Register("expPremiumPackageItem", PANEL, "DSizeToContents")

-- Premium Item Panel
PANEL = {}

DEFINE_BASECLASS("ixBusinessItem")

function PANEL:Init()
	local size = math.max(ScrW() * 0.1, 128)
	self:SetSize(size, size * 1.4)
end

function PANEL:SetItem(itemTable)
	BaseClass.SetItem(self, itemTable)

	-- Override price to show premium price
	self.price:SetText("€" .. string.format("%.2f", itemTable.premiumPriceInEuro))
	self.price:SetTextColor(PLUGIN.THEME.premium)

	-- Add premium indicator
	self.premiumIndicator = self:Add("DLabel")
	self.premiumIndicator:SetText("PREMIUM")
	self.premiumIndicator:SetFont("DermaDefault")
	self.premiumIndicator:SetTextColor(PLUGIN.THEME.premium)
	self.premiumIndicator:SetExpensiveShadow(1, Color(0, 0, 0, 200))
	self.premiumIndicator:Dock(BOTTOM)
	self.premiumIndicator:SetContentAlignment(5)
	self.premiumIndicator:SizeToContents()

	self.itemTable = itemTable
end

function PANEL:OnMousePressed(key)
	if (key == MOUSE_LEFT) then
		ix.gui.premiumShop:PurchaseItem(self.itemTable)
	end
end

vgui.Register("expPremiumItem", PANEL, "ixBusinessItem")

-- Add premium shop button to main menu
hook.Add("CreateMenuButtons", "expPremiumShop", function(tabs)
	tabs["premiumShop"] = function(container)
		container:Add("expPremiumShop")
	end
end)
