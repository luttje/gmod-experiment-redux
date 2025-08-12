local PLUGIN = PLUGIN

function PLUGIN:ShowPaymentHistory()
	if (IsValid(self.cartPanel)) then
		self.cartPanel:Close()
	end

	if (IsValid(self.paymentHistoryPanel)) then
		self.paymentHistoryPanel:Close()
	end

	self.paymentHistoryPanel = vgui.Create("expPaymentHistoryPanel")
	self.paymentHistoryPanel:MakePopup()

	-- Request payment history
	Schema.chunkedNetwork.Request("PaymentHistory", {}, function(payments, extraData)
		if (IsValid(PLUGIN.paymentHistoryPanel)) then
			PLUGIN.paymentHistoryPanel:DisplayPayments(payments)
		end
	end)

	-- Also request claimable packages
	Schema.chunkedNetwork.Request("ClaimablePackages", {}, function(claimablePackages, extraData)
		if (IsValid(PLUGIN.paymentHistoryPanel)) then
			PLUGIN.paymentHistoryPanel:DisplayClaimablePackages(claimablePackages)
		end
	end)
end

-- Individual payment entry panel
PANEL = {}

function PANEL:Init()
	self:SetTall(200)
	self:DockPadding(10, 10, 10, 10)
end

function PANEL:SetPayment(payment, index)
	self.payment = payment
	self.index = index

	-- Parse items for display
	local itemNames = {}
	for _, item in ipairs(payment.cart_items) do
		local name = "Unknown"

		if (item.type == "package") then
			local package = PLUGIN.PREMIUM_PACKAGES[item.key]
			if (package) then
				name = package.name
			end
		elseif (item.type == "item") then
			local itemTable = ix.item.Get(item.key)
			if (itemTable) then
				name = itemTable.name
			end
		end

		if (item.quantity > 1) then
			name = name .. " x" .. item.quantity
		end

		table.insert(itemNames, name)
	end

	local itemsText = table.concat(itemNames, ", ")

	-- Top row: Status and Total
	local topRow = self:Add("EditablePanel")
	topRow:SetTall(25)
	topRow:Dock(TOP)

	-- Status label
	self.statusLabel = topRow:Add("DLabel")
	self.statusLabel:SetText(string.upper(payment.status))
	self.statusLabel:SetFont("ixSmallFont")
	self.statusLabel:Dock(LEFT)
	self.statusLabel:SizeToContents()

	-- Set status color and adjust panel height
	local statusColor = Color(255, 255, 255)
	if (payment.status == "completed") then
		statusColor = PLUGIN.THEME.success
		self:SetTall(140)
	elseif (payment.status == "pending") then
		statusColor = PLUGIN.THEME.warning
		self:SetTall(180)
	elseif (payment.status == "failed" or payment.status == "expired") then
		statusColor = PLUGIN.THEME.danger
		self:SetTall(140)
	end
	self.statusLabel:SetTextColor(statusColor)

	-- Total price label
	local currencySymbol = PLUGIN.PREMIUM_CURRENCIES[payment.currency] or "€"
	local totalText = currencySymbol .. string.format("%.2f", payment.total_price)

	self.totalLabel = topRow:Add("DLabel")
	self.totalLabel:SetText(totalText)
	self.totalLabel:SetFont("ixMediumFont")
	self.totalLabel:SetTextColor(PLUGIN.THEME.premium)
	self.totalLabel:SetContentAlignment(6) -- Right align
	self.totalLabel:Dock(RIGHT)
	self.totalLabel:SizeToContents()

	-- Tracking ID row
	local trackingRow = self:Add("EditablePanel")
	trackingRow:SetTall(25)
	trackingRow:Dock(TOP)
	trackingRow:DockMargin(0, 5, 0, 0)

	local trackingLabel = trackingRow:Add("DLabel")
	trackingLabel:SetText("ID:")
	trackingLabel:SetFont("DermaDefault")
	trackingLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	trackingLabel:SizeToContents()
	trackingLabel:Dock(LEFT)

	-- Tracking ID text entry (read-only)
	self.trackingEntry = trackingRow:Add("DTextEntry")
	self.trackingEntry:SetText(payment.tracking_id)
	self.trackingEntry:SetDisabled(true)
	self.trackingEntry:SetFont("DermaDefault")
	self.trackingEntry:Dock(FILL)
	self.trackingEntry:DockMargin(5, 0, 5, 0)

	-- Copy button for tracking ID
	self.copyButton = trackingRow:Add("expButton")
	self.copyButton:SetText("Copy")
	self.copyButton:SizeToContents()
	self.copyButton:Dock(RIGHT)
	self.copyButton.DoClick = function()
		self.trackingEntry:SelectAll()
		SetClipboardText(payment.tracking_id)
		LocalPlayer():Notify("ID copied to clipboard!")
	end

	-- Items row
	local itemsRow = self:Add("EditablePanel")
	itemsRow:SetTall(25)
	itemsRow:Dock(TOP)
	itemsRow:DockMargin(0, 5, 0, 0)

	local itemsLabel = itemsRow:Add("DLabel")
	itemsLabel:SetText("Items:")
	itemsLabel:SetFont("ixSmallFont")
	itemsLabel:SetTextColor(Color(255, 255, 255))
	itemsLabel:SizeToContents()
	itemsLabel:Dock(LEFT)

	self.itemsLabel = itemsRow:Add("DLabel")
	local itemsDisplay = itemsText
	if (#itemsDisplay > 60) then
		itemsDisplay = string.sub(itemsDisplay, 1, 57) .. "..."
	end
	self.itemsLabel:SetText(itemsDisplay)
	self.itemsLabel:SetFont("ixSmallFont")
	self.itemsLabel:SetTextColor(Color(255, 255, 255))
	self.itemsLabel:Dock(FILL)
	self.itemsLabel:DockMargin(5, 0, 0, 0)

	-- Date row
	local dateRow = self:Add("EditablePanel")
	dateRow:SetTall(25)
	dateRow:Dock(TOP)
	dateRow:DockMargin(0, 5, 0, 0)

	local dateLabel = dateRow:Add("DLabel")
	dateLabel:SetText("Date:")
	dateLabel:SetFont("DermaDefault")
	dateLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	dateLabel:SizeToContents()
	dateLabel:Dock(LEFT)

	local dateText = os.date("%Y-%m-%d %H:%M", payment.created_at)
	self.dateLabel = dateRow:Add("DLabel")
	self.dateLabel:SetText(dateText)
	self.dateLabel:SetFont("DermaDefault")
	self.dateLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	self.dateLabel:Dock(FILL)
	self.dateLabel:DockMargin(5, 0, 0, 0)

	-- Button row
	local buttonRow = self:Add("EditablePanel")
	buttonRow:Dock(FILL)
	buttonRow:DockMargin(0, 5, 0, 0)

	-- Refresh button for pending payments
	if (payment.status == "pending") then
		self.refreshButton = buttonRow:Add("expButton")
		self.refreshButton:SetText("Check Status")
		self.refreshButton:SizeToContents()
		self.refreshButton:Dock(RIGHT)
		self.refreshButton:DockMargin(8, 0, 0, 0)
		self.refreshButton.DoClick = function()
			net.Start("expPremiumShopRefreshPayment")
			net.WriteString(payment.tracking_id)
			net.SendToServer()
		end

		self.openPaymentUrl = buttonRow:Add("expButton")
		self.openPaymentUrl:SetText("Open Payment URL")
		self.openPaymentUrl:SizeToContents()
		self.openPaymentUrl:Dock(RIGHT)
		self.openPaymentUrl.DoClick = function()
			gui.OpenURL(payment.payment_url)
		end
	end

	-- Paint background with status-based coloring
	self.Paint = function(pnl, w, h)
		local bgColor = PLUGIN.THEME.panel

		if (payment.status == "completed") then
			bgColor = Color(40, 60, 40) -- Green tint
		elseif (payment.status == "pending") then
			bgColor = Color(60, 60, 40) -- Yellow tint
		elseif (payment.status == "failed" or payment.status == "expired") then
			bgColor = Color(60, 40, 40) -- Red tint
		end

		draw.RoundedBox(4, 0, 0, w, h, bgColor)
	end
end

vgui.Register("expPaymentEntryPanel", PANEL, "EditablePanel")

-- Claimable package entry panel
PANEL = {}

function PANEL:Init()
	self:SetTall(170)
	self:DockPadding(10, 10, 10, 10)
end

function PANEL:SetClaimablePackage(packageData, packageKey)
	self.packageData = packageData
	self.packageKey = packageKey

	-- Package name row
	local nameRow = self:Add("EditablePanel")
	nameRow:SetTall(25)
	nameRow:Dock(TOP)

	local nameLabel = nameRow:Add("DLabel")
	nameLabel:SetText(packageData.name)
	nameLabel:SetFont("ixMediumFont")
	nameLabel:SetTextColor(Color(255, 255, 255))
	nameLabel:Dock(LEFT)
	nameLabel:SizeToContents()

	-- Description row
	local descRow = self:Add("EditablePanel")
	descRow:SetTall(25)
	descRow:Dock(TOP)
	descRow:DockMargin(0, 5, 0, 0)

	local descLabel = descRow:Add("DLabel")
	descLabel:SetText(packageData.description or "")
	descLabel:SetFont("ixSmallFont")
	descLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	descLabel:Dock(FILL)
	descLabel:SetWrap(true)

	-- Claim button
	local buttonRow = self:Add("EditablePanel")
	buttonRow:Dock(FILL)
	buttonRow:DockMargin(0, 5, 0, 0)

	self.claimButton = buttonRow:Add("expButton")
	self.claimButton:SetText("Claim Package")
	self.claimButton:Dock(RIGHT)
	self.claimButton:SizeToContents()
	self.claimButton.DoClick = function()
		net.Start("expPremiumShopClaimPackage")
		net.WriteString(packageKey)
		net.SendToServer()

		LocalPlayer():Notify("Claiming " .. packageData.name .. "...")

		self:Remove()
	end

	-- Paint background
	self.Paint = function(pnl, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 40))
	end
end

vgui.Register("expClaimablePackagePanel", PANEL, "EditablePanel")

-- History panel
local PANEL = {}

function PANEL:Init()
	self:SetSize(700, 600)
	self:Center()
	self:SetTitle("Payment History & Claims")
	self:SetDeleteOnClose(true)

	-- Tab selection
	self.tabPanel = self:Add("DPanel")
	self.tabPanel:SetTall(40)
	self.tabPanel:Dock(TOP)
	self.tabPanel:DockMargin(8, 8, 8, 0)
	self.tabPanel:SetPaintBackground(false)

	-- Payment History tab
	self.historyTab = self.tabPanel:Add("expButton")
	self.historyTab:SetText("Payment History")
	self.historyTab:Dock(LEFT)
	self.historyTab:SizeToContents()
	self.historyTab:DockMargin(0, 0, 8, 0)
	self.historyTab.DoClick = function()
		self:ShowTab("history")
	end

	-- Claims tab
	self.claimsTab = self.tabPanel:Add("expButton")
	self.claimsTab:SetText("Claims")
	self.claimsTab:Dock(LEFT)
	self.claimsTab:SizeToContents()
	self.claimsTab.DoClick = function()
		self:ShowTab("claims")
	end

	-- Current tab indicator
	self.currentTab = "history"

	-- History content
	self.historyContent = self:Add("DPanel")
	self.historyContent:Dock(FILL)
	self.historyContent:DockMargin(8, 8, 8, 8)
	self.historyContent:SetPaintBackground(false)

	-- Create loading indicator for history
	self.historyLoadingLabel = self.historyContent:Add("DLabel")
	self.historyLoadingLabel:SetText("Loading payment history...")
	self.historyLoadingLabel:SetFont("ixMediumFont")
	self.historyLoadingLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	self.historyLoadingLabel:SetContentAlignment(5)
	self.historyLoadingLabel:Dock(FILL)

	-- History scroll panel (hidden initially)
	self.historyScroll = self.historyContent:Add("DScrollPanel")
	self.historyScroll:Dock(FILL)
	self.historyScroll:SetVisible(false)

	-- Bottom panel for refresh all button
	self.historyBottomPanel = self.historyContent:Add("EditablePanel")
	self.historyBottomPanel:SetTall(50)
	self.historyBottomPanel:Dock(BOTTOM)
	self.historyBottomPanel:DockMargin(0, 8, 0, 0)
	self.historyBottomPanel:SetVisible(false)

	self.refreshAllButton = self.historyBottomPanel:Add("expButton")
	self.refreshAllButton:SetText("Check All Pending Payments")
	self.refreshAllButton:Dock(FILL)
	self.refreshAllButton.DoClick = function()
		self:RefreshAllPending()
	end

	-- Claims content
	self.claimsContent = self:Add("DPanel")
	self.claimsContent:Dock(FILL)
	self.claimsContent:DockMargin(8, 8, 8, 8)
	self.claimsContent:SetPaintBackground(false)
	self.claimsContent:SetVisible(false)

	-- Create loading indicator for claims
	self.claimsLoadingLabel = self.claimsContent:Add("DLabel")
	self.claimsLoadingLabel:SetText("Loading claimable packages...")
	self.claimsLoadingLabel:SetFont("ixMediumFont")
	self.claimsLoadingLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	self.claimsLoadingLabel:SetContentAlignment(5)
	self.claimsLoadingLabel:Dock(FILL)

	-- Claims scroll panel (hidden initially)
	self.claimsScroll = self.claimsContent:Add("DScrollPanel")
	self.claimsScroll:Dock(FILL)
	self.claimsScroll:SetVisible(false)

	if (LocalPlayer():IsSuperAdmin()) then
		local button = self:Add("expButton")
		button:SetText("(Admin) Global Payment Management")
		button:Dock(TOP)
		button:DockMargin(8, 8, 8, 8)
		button:SizeToContents()
		button.DoClick = function()
			self:Close()
			PLUGIN:ShowAdminPaymentsPanel()
		end
	end

	self.payments = {}
	self.claimablePackages = {}

	self:UpdateTabAppearance()
end

function PANEL:ShowTab(tabName)
	self.currentTab = tabName

	if (tabName == "history") then
		self.historyContent:SetVisible(true)
		self.claimsContent:SetVisible(false)
	elseif (tabName == "claims") then
		self.historyContent:SetVisible(false)
		self.claimsContent:SetVisible(true)
	end

	self:UpdateTabAppearance()
end

function PANEL:UpdateTabAppearance()
	-- Update tab button colors
	local activeColor = PLUGIN.THEME.premium
	local inactiveColor = PLUGIN.THEME.surface

	if (self.currentTab == "history") then
		self.historyTab:SetColor(activeColor)
		self.claimsTab:SetColor(inactiveColor)
	else
		self.historyTab:SetColor(inactiveColor)
		self.claimsTab:SetColor(activeColor)
	end
end

function PANEL:DisplayPayments(payments)
	-- Hide loading indicator
	self.historyLoadingLabel:SetVisible(false)

	-- Show scroll panel
	self.historyScroll:SetVisible(true)
	self.historyScroll:Clear()

	self.payments = payments

	if (#payments == 0) then
		local emptyLabel = self.historyScroll:Add("DLabel")
		emptyLabel:SetText("No payment history found")
		emptyLabel:SetFont("ixMediumFont")
		emptyLabel:SetTextColor(PLUGIN.THEME.textSecondary)
		emptyLabel:SetContentAlignment(5)
		emptyLabel:Dock(FILL)
		return
	end

	-- Sort payments by date (newest first)
	table.sort(payments, function(a, b)
		return a.created_at > b.created_at
	end)

	local hasPending = false

	-- Create payment entries
	for i, payment in ipairs(payments) do
		local paymentPanel = self.historyScroll:Add("expPaymentEntryPanel")
		paymentPanel:SetPayment(payment, i)
		paymentPanel:Dock(TOP)
		paymentPanel:DockMargin(5, 5, 5, 5)

		if (payment.status == "pending") then
			hasPending = true
		end
	end

	-- Show refresh all button if there are pending payments
	self.historyBottomPanel:SetVisible(hasPending)
end

function PANEL:DisplayClaimablePackages(claimablePackages)
	-- Hide loading indicator
	self.claimsLoadingLabel:SetVisible(false)

	-- Show scroll panel
	self.claimsScroll:SetVisible(true)
	self.claimsScroll:Clear()

	self.claimablePackages = {}

	-- claimablePackages is only the key (in the key) and the amount this player has
	for _, packageKey in ipairs(claimablePackages) do
		local package = PLUGIN.PREMIUM_PACKAGES[packageKey]

		if (not package) then
			ix.util.SchemaErrorNoHalt("Unknown premium package: ", packageKey)
			return
		end

		self.claimablePackages[packageKey] = {
			name = package.name,
			description = package.description,
			image = package.image,
			category = package.category,
			benefits = package.benefits,
		}
	end

	claimablePackages = self.claimablePackages

	if (table.Count(claimablePackages) == 0) then
		local emptyLabel = self.claimsScroll:Add("DLabel")
		emptyLabel:SetText("No packages need claiming on this character")
		emptyLabel:SetFont("ixMediumFont")
		emptyLabel:SetTextColor(PLUGIN.THEME.textSecondary)
		emptyLabel:SetContentAlignment(5)
		emptyLabel:Dock(FILL)

		return
	end

	-- Sort packages by name
	local sortedPackages = {}
	for packageKey, packageData in pairs(claimablePackages) do
		table.insert(sortedPackages, { key = packageKey, data = packageData })
	end

	table.sort(sortedPackages, function(a, b)
		return (a.data.name or "") < (b.data.name or "")
	end)

	-- Create claimable package entries
	for _, packageInfo in ipairs(sortedPackages) do
		local packagePanel = self.claimsScroll:Add("expClaimablePackagePanel")
		packagePanel:SetClaimablePackage(packageInfo.data, packageInfo.key)
		packagePanel:Dock(TOP)
		packagePanel:DockMargin(5, 5, 5, 5)
	end

	-- Update claims tab text to show count
	self.claimsTab:SetText("Claims (" .. table.Count(claimablePackages) .. ")")
end

function PANEL:RefreshAllPending()
	for _, payment in ipairs(self.payments) do
		if (payment.status == "pending") then
			timer.Simple(_ * 0.5, function() -- Stagger requests
				net.Start("expPremiumShopRefreshPayment")
				net.WriteString(payment.tracking_id)
				net.SendToServer()
			end)
		end
	end

	LocalPlayer():Notify("Checking status of all pending payments...")

	-- Refresh the list after a delay
	timer.Simple(3, function()
		if (IsValid(self)) then
			Schema.chunkedNetwork.Request("PaymentHistory", {}, function(payments, extraData)
				if (IsValid(self)) then
					self:DisplayPayments(payments)
				end
			end)
		end
	end)
end

-- Always keep on top so we don't go behind the main menu
function PANEL:Think()
	self:MoveToFront()
end

vgui.Register("expPaymentHistoryPanel", PANEL, "expFrame")
