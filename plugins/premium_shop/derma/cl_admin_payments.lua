local PLUGIN = PLUGIN

-- Receive admin payments data
net.Receive("expPremiumShopAdminPaymentsResponse", function()
	local payments = net.ReadTable()
	local searchQuery = net.ReadString()

	if (IsValid(PLUGIN.adminPaymentsPanel)) then
		PLUGIN.adminPaymentsPanel:DisplayPayments(payments, searchQuery)
	end
end)

-- Show admin payments panel
function PLUGIN:ShowAdminPaymentsPanel()
	if (not LocalPlayer():IsSuperAdmin()) then
		LocalPlayer():Notify("You don't have permission to access this panel.")
		return
	end

	if (IsValid(self.adminPaymentsPanel)) then
		self.adminPaymentsPanel:Close()
	end

	self.adminPaymentsPanel = vgui.Create("expAdminPaymentsPanel")
	self.adminPaymentsPanel:MakePopup()

	-- Request initial data
	net.Start("expPremiumShopAdminPayments")
	net.WriteString("") -- Empty search initially
	net.SendToServer()
end

-- Individual admin payment entry panel
local PANEL = {}

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

	-- Top row: Player info and Status
	local topRow = self:Add("EditablePanel")
	topRow:SetTall(25)
	topRow:Dock(TOP)

	-- Player name and Steam ID
	self.playerLabel = topRow:Add("DLabel")
	self.playerLabel:SetText(payment.player_name .. " (" .. payment.steamid64 .. ")")
	self.playerLabel:SetFont("ixMediumFont")
	self.playerLabel:SetTextColor(Color(255, 255, 255))
	self.playerLabel:Dock(LEFT)
	self.playerLabel:SizeToContents()

	-- Status label
	self.statusLabel = topRow:Add("DLabel")
	self.statusLabel:SetText(string.upper(payment.status))
	self.statusLabel:SetFont("ixSmallFont")
	self.statusLabel:SetContentAlignment(6) -- Right align
	self.statusLabel:Dock(RIGHT)
	self.statusLabel:SizeToContents()

	-- Set status color
	local statusColor = Color(255, 255, 255)
	if (payment.status == "completed") then
		statusColor = PLUGIN.THEME.success
		self:SetTall(160)
	elseif (payment.status == "pending") then
		statusColor = PLUGIN.THEME.warning
		self:SetTall(200)
	elseif (payment.status == "failed" or payment.status == "expired") then
		statusColor = PLUGIN.THEME.danger
		self:SetTall(160)
	end

	self.statusLabel:SetTextColor(statusColor)

	-- Total and date row
	local infoRow = self:Add("EditablePanel")
	infoRow:SetTall(25)
	infoRow:Dock(TOP)
	infoRow:DockMargin(0, 5, 0, 0)

	-- Total price
	local currencySymbol = PLUGIN.PREMIUM_CURRENCIES[payment.currency] or "€"
	local totalText = currencySymbol .. string.format("%.2f", payment.total_price)

	self.totalLabel = infoRow:Add("DLabel")
	self.totalLabel:SetText("Total: " .. totalText)
	self.totalLabel:SetFont("ixMediumFont")
	self.totalLabel:SetTextColor(PLUGIN.THEME.premium)
	self.totalLabel:Dock(LEFT)
	self.totalLabel:SizeToContents()

	-- Date
	local dateText = os.date("%Y-%m-%d %H:%M", payment.created_at)
	self.dateLabel = infoRow:Add("DLabel")
	self.dateLabel:SetText("Date: " .. dateText)
	self.dateLabel:SetFont("DermaDefault")
	self.dateLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	self.dateLabel:SetContentAlignment(6) -- Right align
	self.dateLabel:Dock(RIGHT)
	self.dateLabel:SizeToContents()

	-- Session ID row
	local sessionRow = self:Add("EditablePanel")
	sessionRow:SetTall(25)
	sessionRow:Dock(TOP)
	sessionRow:DockMargin(0, 5, 0, 0)

	local sessionLabel = sessionRow:Add("DLabel")
	sessionLabel:SetText("Session ID:")
	sessionLabel:SetFont("DermaDefault")
	sessionLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	sessionLabel:SizeToContents()
	sessionLabel:Dock(LEFT)

	-- Session ID text entry (read-only)
	self.sessionEntry = sessionRow:Add("DTextEntry")
	self.sessionEntry:SetText(payment.session_id)
	self.sessionEntry:SetDisabled(true)
	self.sessionEntry:SetFont("DermaDefault")
	self.sessionEntry:Dock(FILL)
	self.sessionEntry:DockMargin(5, 0, 5, 0)

	-- Copy button for session ID
	self.copyButton = sessionRow:Add("expButton")
	self.copyButton:SetText("Copy")
	self.copyButton:SizeToContents()
	self.copyButton:Dock(RIGHT)
	self.copyButton.DoClick = function()
		self.sessionEntry:SelectAll()
		SetClipboardText(payment.session_id)
		LocalPlayer():Notify("Session ID copied to clipboard!")
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
	if (#itemsDisplay > 80) then
		itemsDisplay = string.sub(itemsDisplay, 1, 77) .. "..."
	end
	self.itemsLabel:SetText(itemsDisplay)
	self.itemsLabel:SetFont("ixSmallFont")
	self.itemsLabel:SetTextColor(Color(255, 255, 255))
	self.itemsLabel:Dock(FILL)
	self.itemsLabel:DockMargin(5, 0, 0, 0)

	-- Button row
	local buttonRow = self:Add("EditablePanel")
	buttonRow:Dock(FILL)
	buttonRow:DockMargin(0, 5, 0, 0)

	-- Force check button (for superadmins and pending payments)
	if (LocalPlayer():IsSuperAdmin() and payment.status == "pending") then
		self.forceCheckButton = buttonRow:Add("expButton")
		self.forceCheckButton:SetText("Force Check Payment")
		self.forceCheckButton:SizeToContents()
		self.forceCheckButton:Dock(RIGHT)
		self.forceCheckButton:DockMargin(8, 0, 0, 0)
		self.forceCheckButton.DoClick = function()
			net.Start("expPremiumShopAdminForceCheck")
			net.WriteString(payment.session_id)
			net.WriteString(payment.steamid64)
			net.SendToServer()

			LocalPlayer():Notify("Force checking payment...")

			-- Refresh the list after a delay
			timer.Simple(3, function()
				if (IsValid(self:GetParent():GetParent():GetParent())) then
					local searchText = self:GetParent():GetParent():GetParent().searchEntry:GetText()
					net.Start("expPremiumShopAdminPayments")
					net.WriteString(searchText)
					net.SendToServer()
				end
			end)
		end
	end

	-- View player button
	self.viewPlayerButton = buttonRow:Add("expButton")
	self.viewPlayerButton:SetText("View Player")
	self.viewPlayerButton:SizeToContents()
	self.viewPlayerButton:Dock(LEFT)
	self.viewPlayerButton.DoClick = function()
		-- Try to find the player
		local targetPlayer = nil

		for _, ply in ipairs(player.GetAll()) do
			if (ply:SteamID64() == payment.steamid64) then
				targetPlayer = ply
				break
			end
		end

		if (targetPlayer) then
			LocalPlayer():Notify("Found player: " .. targetPlayer:Name() .. " (online)")
		else
			LocalPlayer():Notify("Player not currently online")
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

vgui.Register("expAdminPaymentEntryPanel", PANEL, "EditablePanel")

-- Main admin payments panel
local PANEL = {}

function PANEL:Init()
	self:SetSize(900, 700)
	self:Center()
	self:SetTitle("Admin: Payment Management")
	self:SetDeleteOnClose(true)

	-- Search and filter panel
	local searchPanel = self:Add("EditablePanel")
	searchPanel:SetTall(60)
	searchPanel:Dock(TOP)
	searchPanel:DockMargin(8, 8, 8, 8)

	-- Search label
	local searchLabel = searchPanel:Add("DLabel")
	searchLabel:SetText("Search payments:")
	searchLabel:SetFont("ixMediumFont")
	searchLabel:SetTextColor(Color(255, 255, 255))
	searchLabel:SetPos(0, 5)
	searchLabel:SizeToContents()

	-- Search entry
	self.searchEntry = searchPanel:Add("DTextEntry")
	self.searchEntry:SetSize(300, 25)
	self.searchEntry:SetPos(0, 30)
	self.searchEntry:SetFont("ixMediumFont")
	self.searchEntry:SetPlaceholderText("Search by player name, Steam ID, or session ID...")
	self.searchEntry.OnTextChanged = function(entry)
		-- Debounced search
		timer.Remove("AdminPaymentSearch")
		timer.Create("AdminPaymentSearch", 0.5, 1, function()
			if (IsValid(self)) then
				self:SearchPayments(entry:GetText())
			end
		end)
	end

	-- Status filter buttons
	local statusPanel = searchPanel:Add("EditablePanel")
	statusPanel:SetSize(500, 25)
	statusPanel:SetPos(320, 30)

	local statusButtons = {}
	local statuses = { "all", "pending", "completed" }
	local statusColors = {
		all = Color(100, 100, 100),
		pending = PLUGIN.THEME.warning,
		completed = PLUGIN.THEME.success,
		failed = PLUGIN.THEME.danger,
		expired = PLUGIN.THEME.danger
	}

	self.selectedStatus = "all"

	for i, status in ipairs(statuses) do
		local button = statusPanel:Add("expButton")
		button:SetText(string.upper(status))
		button:SizeToContents()
		button:Dock(LEFT)
		button:SetScale(BUTTON_SCALE_SMALL)

		local originalPaint = button.Paint
		button.Paint = function(btn, w, h)
			local color = statusColors[status]
			if (self.selectedStatus == status) then
				color = Color(
					math.min(color.r + 40, 255),
					math.min(color.g + 40, 255),
					math.min(color.b + 40, 255),
					color.a
				)
			end

			draw.RoundedBox(4, 0, 0, w, h, color)

			-- Draw text
			surface.SetTextColor(255, 255, 255, 255)
			surface.SetFont("ixSmallFont")
			local text = btn:GetText()
			local textWidth, textHeight = surface.GetTextSize(text)
			surface.SetTextPos(w * 0.5 - textWidth * 0.5, h * 0.5 - textHeight * 0.5)
			surface.DrawText(text)
		end

		button.DoClick = function()
			self.selectedStatus = status
			self:SearchPayments(self.searchEntry:GetText())
		end

		statusButtons[status] = button
	end

	-- Stats panel
	self.statsPanel = self:Add("EditablePanel")
	self.statsPanel:SetTall(40)
	self.statsPanel:Dock(TOP)
	self.statsPanel:DockMargin(8, 0, 8, 8)
	self.statsPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(4, 0, 0, w, h, PLUGIN.THEME.surface)
	end

	self.statsLabel = self.statsPanel:Add("DLabel")
	self.statsLabel:SetText("Loading payment statistics...")
	self.statsLabel:SetFont("ixMediumFont")
	self.statsLabel:SetTextColor(Color(255, 255, 255))
	self.statsLabel:SetPos(10, 10)
	self.statsLabel:SizeToContents()

	-- Create loading indicator
	self.loadingLabel = self:Add("DLabel")
	self.loadingLabel:SetText("Loading payments...")
	self.loadingLabel:SetFont("ixMediumFont")
	self.loadingLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	self.loadingLabel:SetContentAlignment(5)
	self.loadingLabel:Dock(FILL)

	-- Scroll panel (hidden initially)
	self.scroll = self:Add("DScrollPanel")
	self.scroll:Dock(FILL)
	self.scroll:DockMargin(8, 8, 8, 8)
	self.scroll:SetVisible(false)

	self.payments = {}
	self.filteredPayments = {}
end

function PANEL:SearchPayments(query)
	net.Start("expPremiumShopAdminPayments")
	net.WriteString(query or "")
	net.WriteString(self.selectedStatus)
	net.SendToServer()
end

function PANEL:DisplayPayments(payments, searchQuery)
	-- Hide loading indicator
	self.loadingLabel:SetVisible(false)

	-- Show scroll panel
	self.scroll:SetVisible(true)
	self.scroll:Clear()

	self.payments = payments
	self.filteredPayments = payments

	-- Update statistics
	self:UpdateStatistics(payments)

	if (#payments == 0) then
		local emptyLabel = self.scroll:Add("DLabel")
		if (searchQuery and searchQuery ~= "") then
			emptyLabel:SetText("No payments found matching search criteria")
		else
			emptyLabel:SetText("No payments found")
		end
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

	-- Create payment entries
	for i, payment in ipairs(payments) do
		local paymentPanel = self.scroll:Add("expAdminPaymentEntryPanel")
		paymentPanel:SetPayment(payment, i)
		paymentPanel:Dock(TOP)
		paymentPanel:DockMargin(5, 5, 5, 5)
	end
end

function PANEL:UpdateStatistics(payments)
	local stats = {
		total = #payments,
		pending = 0,
		completed = 0,
		failed = 0,
		expired = 0,
		totalRevenue = 0
	}

	for _, payment in ipairs(payments) do
		stats[payment.status] = (stats[payment.status] or 0) + 1

		if (payment.status == "completed") then
			stats.totalRevenue = stats.totalRevenue + tonumber(payment.total_price)
		end
	end

	local statsText = string.format(
		"Total: %d | Pending: %d | Completed: %d | Failed: %d | Expired: %d | Revenue: €%.2f",
		stats.total, stats.pending, stats.completed, stats.failed, stats.expired, stats.totalRevenue
	)

	self.statsLabel:SetText(statsText)
	self.statsLabel:SizeToContents()
end

-- Always keep on top so we don't go behind the main menu
function PANEL:Think()
	self:MoveToFront()
end

vgui.Register("expAdminPaymentsPanel", PANEL, "expFrame")
