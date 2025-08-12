local PLUGIN = PLUGIN

function PLUGIN:ShowPaymentHistory()
	if (IsValid(self.adminPaymentsPanel)) then
		self.adminPaymentsPanel:Close()
	end

	if (IsValid(self.paymentHistoryPanel)) then
		self.paymentHistoryPanel:Close()
	end

	self.paymentHistoryPanel = vgui.Create("expPaymentHistoryPanel")
	self.paymentHistoryPanel:MakePopup()

	-- Request payment history
	Schema.chunkedNetwork.Request("PaymentHistory", {}, function(paymentRecords, extraData)
		if (IsValid(PLUGIN.paymentHistoryPanel)) then
			PLUGIN.paymentHistoryPanel:DisplayPaymentRecords(paymentRecords)
		end
	end)
end

-- Individual payment record entry panel
local PANEL = {}

function PANEL:Init()
	self:SetTall(150)
	self:DockPadding(10, 10, 10, 10)
end

function PANEL:SetPaymentRecord(record, index)
	self.record = record
	self.index = index

	-- Top row: Package name and Status
	local topRow = self:Add("EditablePanel")
	topRow:SetTall(25)
	topRow:Dock(TOP)

	-- Package name
	local packageName = "Unknown Package"
	local package = PLUGIN.PREMIUM_PACKAGES[record.item_slug]
	if (package) then
		packageName = package.name
	end

	self.packageLabel = topRow:Add("DLabel")
	self.packageLabel:SetText(packageName)
	self.packageLabel:SetFont("ixMediumFont")
	self.packageLabel:SetTextColor(PLUGIN.THEME.premium)
	self.packageLabel:Dock(LEFT)
	self.packageLabel:SizeToContents()

	-- Status label
	self.statusLabel = topRow:Add("DLabel")
	self.statusLabel:SetText(string.upper(record.status))
	self.statusLabel:SetFont("ixSmallFont")
	self.statusLabel:SetContentAlignment(6) -- Right align
	self.statusLabel:Dock(RIGHT)
	self.statusLabel:SizeToContents()

	-- Set status color
	local statusColor = Color(255, 255, 255)
	if (record.status == "purchased" or record.status == "renewed") then
		statusColor = PLUGIN.THEME.success
	elseif (record.status == "expired") then
		statusColor = PLUGIN.THEME.warning
	elseif (record.status == "refunded" or record.status == "canceled") then
		statusColor = PLUGIN.THEME.danger
	end

	self.statusLabel:SetTextColor(statusColor)

	-- Date and Order ID row
	local infoRow = self:Add("EditablePanel")
	infoRow:SetTall(25)
	infoRow:Dock(TOP)
	infoRow:DockMargin(0, 5, 0, 0)

	-- Date
	local dateText = os.date("%Y-%m-%d %H:%M", record.created_at)
	self.dateLabel = infoRow:Add("DLabel")
	self.dateLabel:SetText("Date: " .. dateText)
	self.dateLabel:SetFont("DermaDefault")
	self.dateLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	self.dateLabel:Dock(LEFT)
	self.dateLabel:SizeToContents()

	-- Order ID
	self.orderLabel = infoRow:Add("DLabel")
	self.orderLabel:SetText("Order: " .. record.order_id)
	self.orderLabel:SetFont("DermaDefault")
	self.orderLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	self.orderLabel:SetContentAlignment(6) -- Right align
	self.orderLabel:Dock(RIGHT)
	self.orderLabel:SizeToContents()

	-- Package description row
	local descRow = self:Add("EditablePanel")
	descRow:SetTall(30)
	descRow:Dock(TOP)
	descRow:DockMargin(0, 5, 0, 0)

	local descLabel = descRow:Add("DLabel")
	if (package and package.description) then
		descLabel:SetText(package.description)
	else
		descLabel:SetText("No description available")
	end
	descLabel:SetFont("ixSmallFont")
	descLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	descLabel:Dock(FILL)
	descLabel:SetWrap(true)

	-- Button row
	local buttonRow = self:Add("EditablePanel")
	buttonRow:Dock(FILL)
	buttonRow:DockMargin(0, 5, 0, 0)

	-- Check if player owns this package on current character
	local hasPackage = LocalPlayer():HasPremiumPackage(record.item_slug)
	local canClaim = (record.status == "purchased" or record.status == "renewed") and not hasPackage

	if (canClaim) then
		-- Show claim button
		self.claimButton = buttonRow:Add("expButton")
		self.claimButton:SetText("Claim on This Character")
		self.claimButton:Dock(RIGHT)
		self.claimButton:SizeToContents()
		self.claimButton.DoClick = function()
			net.Start("expPremiumShopClaimPackage")
			net.WriteString(record.item_slug)
			net.SendToServer()

			PLUGIN:ShowPaymentHistory()
		end
	elseif (hasPackage) then
		-- Show owned status
		local ownedLabel = buttonRow:Add("DLabel")
		ownedLabel:SetText("OWNED ON THIS CHARACTER")
		ownedLabel:SetFont("ixSmallFont")
		ownedLabel:SetTextColor(PLUGIN.THEME.success)
		ownedLabel:SetContentAlignment(6)
		ownedLabel:Dock(RIGHT)
		ownedLabel:SizeToContents()
	elseif (record.status == "expired" or record.status == "refunded" or record.status == "canceled") then
		-- Show status for non-claimable packages
		local statusInfo = buttonRow:Add("DLabel")
		statusInfo:SetText("NOT AVAILABLE")
		statusInfo:SetFont("ixSmallFont")
		statusInfo:SetTextColor(PLUGIN.THEME.danger)
		statusInfo:SetContentAlignment(6)
		statusInfo:Dock(RIGHT)
		statusInfo:SizeToContents()
	end

	-- Paint background with status-based coloring
	self.Paint = function(pnl, w, h)
		local bgColor = PLUGIN.THEME.panel

		if (record.status == "expired") then
			bgColor = Color(60, 60, 40) -- Yellow tint
		elseif (record.status == "refunded" or record.status == "canceled") then
			bgColor = Color(60, 40, 40) -- Red tint
		elseif (canClaim) then
			bgColor = Color(60, 60, 40) -- Yellow tint for claimable
		elseif (hasPackage) then
			bgColor = Color(40, 60, 40) -- Green tint for owned
		end

		draw.RoundedBox(4, 0, 0, w, h, bgColor)
	end
end

vgui.Register("expPaymentRecordPanel", PANEL, "EditablePanel")

-- Main payment history panel
local PANEL = {}

function PANEL:Init()
	self:SetSize(800, 700)
	self:Center()
	self:SetTitle("Payment History")
	self:SetDeleteOnClose(true)

	-- Create loading indicator
	self.loadingLabel = self:Add("DLabel")
	self.loadingLabel:SetText("Loading payment records...")
	self.loadingLabel:SetFont("ixMediumFont")
	self.loadingLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	self.loadingLabel:SetContentAlignment(5)
	self.loadingLabel:Dock(FILL)

	-- Scroll panel (hidden initially)
	self.scroll = self:Add("DScrollPanel")
	self.scroll:Dock(FILL)
	self.scroll:DockMargin(8, 8, 8, 8)
	self.scroll:SetVisible(false)

	self.paymentRecords = {}
end

function PANEL:DisplayPaymentRecords(paymentRecords)
	-- Hide loading indicator
	self.loadingLabel:SetVisible(false)

	-- Show scroll panel
	self.scroll:SetVisible(true)
	self.scroll:Clear()

	self.paymentRecords = paymentRecords

	-- Update statistics
	self:UpdateStatistics(paymentRecords)

	if (#paymentRecords == 0) then
		local emptyLabel = self.scroll:Add("DLabel")
		emptyLabel:SetText("No payment records found")
		emptyLabel:SetFont("ixMediumFont")
		emptyLabel:SetTextColor(PLUGIN.THEME.textSecondary)
		emptyLabel:SetContentAlignment(5)
		emptyLabel:Dock(FILL)
		return
	end

	-- Sort records by date (newest first)
	table.sort(paymentRecords, function(a, b)
		return a.created_at > b.created_at
	end)

	-- Create payment record entries
	for i, record in ipairs(paymentRecords) do
		local recordPanel = self.scroll:Add("expPaymentRecordPanel")
		recordPanel:SetPaymentRecord(record, i)
		recordPanel:Dock(TOP)
		recordPanel:DockMargin(5, 5, 5, 5)
	end
end

function PANEL:UpdateStatistics(paymentRecords)
	local stats = {
		total = #paymentRecords,
		purchased = 0,
		renewed = 0,
		expired = 0,
		refunded = 0,
		canceled = 0,
		claimable = 0,
		owned = 0
	}

	for _, record in ipairs(paymentRecords) do
		stats[record.status] = (stats[record.status] or 0) + 1

		-- Count claimable and owned packages
		local hasPackage = LocalPlayer():HasPremiumPackage(record.item_slug)
		if (record.status == "purchased" or record.status == "renewed") then
			if (hasPackage) then
				stats.owned = stats.owned + 1
			else
				stats.claimable = stats.claimable + 1
			end
		end
	end
end

-- Always keep on top so we don't go behind the main menu
function PANEL:Think()
	self:MoveToFront()
end

vgui.Register("expPaymentHistoryPanel", PANEL, "expFrame")
