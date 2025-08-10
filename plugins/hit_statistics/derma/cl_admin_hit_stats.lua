local PLUGIN = PLUGIN

-- Helper function to convert array back to stats format
function PLUGIN:ConvertArrayToStats(statsArray)
	local stats = {
		totals = {},
		accuracy = {},
		hitgroups = {},
	}

	for _, entry in ipairs(statsArray) do
		if (entry.type == "totals") then
			stats.totals = entry.data
		elseif (entry.type == "accuracy") then
			stats.accuracy = entry.data
		elseif (entry.type == "hitgroup") then
			stats.hitgroups[entry.hitgroup] = entry.data
		end
	end

	return stats
end

function PLUGIN:ShowHitStatsPanel()
	if (not LocalPlayer():IsAdmin()) then
		LocalPlayer():Notify("You don't have permission to access this panel.")
		return
	end

	if (IsValid(self.hitStatsPanel)) then
		self.hitStatsPanel:Close()
		self:CleanupNetworkOperations()
	end

	self.hitStatsPanel = vgui.Create("expAdminHitStats")
	self.hitStatsPanel:MakePopup()

	-- Override the close function to cleanup network operations
	local originalClose = self.hitStatsPanel.Close
	self.hitStatsPanel.Close = function(panel)
		PLUGIN:CleanupNetworkOperations()
		originalClose(panel)
	end

	-- Request initial data (overview of all players)
	net.Start("expPlayerHitOverview")
	net.SendToServer()
end

function PLUGIN:ShowHitStatsPanel()
	if (not LocalPlayer():IsAdmin()) then
		LocalPlayer():Notify("You don't have permission to access this panel.")
		return
	end

	if (IsValid(self.hitStatsPanel)) then
		self.hitStatsPanel:Close()
	end

	self.hitStatsPanel = vgui.Create("expAdminHitStats")
	self.hitStatsPanel:MakePopup()

	-- Override close to cleanup any pending operations
	local originalClose = self.hitStatsPanel.Close
	self.hitStatsPanel.Close = function(panel)
		Schema.chunkedNetwork.Cleanup() -- Cleanup all pending operations
		originalClose(panel)
	end

	-- Request initial data
	Schema.chunkedNetwork.Request("PlayersOverview", {}, function(playersStats, extraData)
		if (IsValid(PLUGIN.hitStatsPanel)) then
			PLUGIN.hitStatsPanel:DisplayPlayersOverview(playersStats)
		end
	end)
end

-- Individual player stats entry panel
local PANEL = {}

function PANEL:Init()
	self:SetTall(120)
	self:DockPadding(10, 10, 10, 10)
end

function PANEL:SetPlayerStats(playerData, index)
	self.playerData = playerData
	self.index = index

	-- Top row: Player info
	local topRow = self:Add("EditablePanel")
	topRow:SetTall(25)
	topRow:Dock(TOP)

	-- Player name and Steam ID
	self.playerLabel = topRow:Add("DLabel")
	self.playerLabel:SetText(playerData.steam_name .. " (" .. playerData.steam_id .. ")")
	self.playerLabel:SetFont("ixMediumFont")
	self.playerLabel:SetTextColor(Color(255, 255, 255))
	self.playerLabel:Dock(LEFT)
	self.playerLabel:SizeToContents()

	-- Suspicion level indicator
	local suspicionLevel = self:CalculateSuspicionLevel(playerData)
	self.suspicionLabel = topRow:Add("DLabel")
	self.suspicionLabel:SetText(suspicionLevel.text)
	self.suspicionLabel:SetFont("ixSmallFont")
	self.suspicionLabel:SetTextColor(suspicionLevel.color)
	self.suspicionLabel:SetContentAlignment(6) -- Right align
	self.suspicionLabel:Dock(RIGHT)
	self.suspicionLabel:SizeToContents()

	-- Stats row
	local statsRow = self:Add("EditablePanel")
	statsRow:SetTall(25)
	statsRow:Dock(TOP)
	statsRow:DockMargin(0, 5, 0, 0)

	-- Accuracy
	self.accuracyLabel = statsRow:Add("DLabel")
	local accuracyText = string.format("Accuracy: %.1f%%", playerData.accuracy or 0)
	self.accuracyLabel:SetText(accuracyText)
	self.accuracyLabel:SetFont("DermaDefault")
	self.accuracyLabel:SetTextColor(self:GetAccuracyColor(playerData.accuracy or 0))
	self.accuracyLabel:Dock(LEFT)
	self.accuracyLabel:SizeToContents()

	-- Headshot rate
	self.headshotLabel = statsRow:Add("DLabel")
	local headshotText = string.format("  |  Headshots: %.1f%%", playerData.headshot_rate or 0)
	self.headshotLabel:SetText(headshotText)
	self.headshotLabel:SetFont("DermaDefault")
	self.headshotLabel:SetTextColor(self:GetHeadshotColor(playerData.headshot_rate or 0))
	self.headshotLabel:Dock(LEFT)
	self.headshotLabel:SizeToContents()

	-- K/D Ratio
	self.kdLabel = statsRow:Add("DLabel")
	local kdText = string.format("  |  K/D: %.2f", playerData.kd_ratio or 0)
	self.kdLabel:SetText(kdText)
	self.kdLabel:SetFont("DermaDefault")
	self.kdLabel:SetTextColor(Color(200, 200, 200))
	self.kdLabel:Dock(LEFT)
	self.kdLabel:SizeToContents()

	-- Shots fired
	self.shotsLabel = statsRow:Add("DLabel")
	local shotsText = string.format("Shots: %d", playerData.total_shots or 0)
	self.shotsLabel:SetText(shotsText)
	self.shotsLabel:SetFont("DermaDefault")
	self.shotsLabel:SetTextColor(Color(180, 180, 180))
	self.shotsLabel:SetContentAlignment(6) -- Right align
	self.shotsLabel:Dock(RIGHT)
	self.shotsLabel:SizeToContents()

	-- Button row
	local buttonRow = self:Add("EditablePanel")
	buttonRow:Dock(FILL)
	buttonRow:DockMargin(0, 5, 0, 0)

	-- View details button
	self.detailsButton = buttonRow:Add("expButton")
	self.detailsButton:SetText("View Details")
	self.detailsButton:SizeToContents()
	self.detailsButton:Dock(LEFT)
	self.detailsButton.DoClick = function()
		Schema.chunkedNetwork.Request("PlayerHitStats", {
			steamID = playerData.steam_id
		}, function(statsArray, extraData)
			local stats = PLUGIN:ConvertArrayToStats(statsArray)
			local steamID = extraData.steamID

			if (IsValid(PLUGIN.hitStatsPanel)) then
				PLUGIN.hitStatsPanel:DisplayPlayerStats(stats, steamID)
			end
		end)
	end

	-- Find player button (if online)
	local onlinePlayer = self:FindOnlinePlayer(playerData.steam_id)
	if (onlinePlayer) then
		self.findPlayerButton = buttonRow:Add("expButton")
		self.findPlayerButton:SetText("Spectate")
		self.findPlayerButton:SizeToContents()
		self.findPlayerButton:Dock(RIGHT)
		self.findPlayerButton:DockMargin(5, 0, 0, 0)
		self.findPlayerButton.DoClick = function()
			if (IsValid(onlinePlayer)) then
				LocalPlayer():ConCommand("ulx spectate " .. onlinePlayer:Nick())
			else
				LocalPlayer():Notify("Player is no longer online")
			end
		end
	end

	-- Paint background with suspicion-based coloring
	self.Paint = function(pnl, w, h)
		local bgColor = Color(40, 40, 45)

		if (suspicionLevel.level == "HIGH") then
			bgColor = Color(60, 40, 40) -- Red tint
		elseif (suspicionLevel.level == "MEDIUM") then
			bgColor = Color(60, 55, 40) -- Yellow tint
		elseif (suspicionLevel.level == "LOW") then
			bgColor = Color(45, 55, 45) -- Green tint
		end

		draw.RoundedBox(4, 0, 0, w, h, bgColor)
	end
end

function PANEL:CalculateSuspicionLevel(playerData)
	local accuracy = playerData.accuracy or 0
	local headshotRate = playerData.headshot_rate or 0
	local totalShots = playerData.total_shots or 0

	-- Don't flag players with too few shots
	if (totalShots < 50) then
		return {
			level = "INSUFFICIENT_DATA",
			text = "INSUFFICIENT DATA",
			color = Color(150, 150, 150)
		}
	end

	local suspicionScore = 0

	-- High accuracy is suspicious
	if (accuracy > 85) then
		suspicionScore = suspicionScore + 3
	elseif (accuracy > 70) then
		suspicionScore = suspicionScore + 1
	end

	-- High headshot rate is suspicious
	if (headshotRate > 60) then
		suspicionScore = suspicionScore + 3
	elseif (headshotRate > 40) then
		suspicionScore = suspicionScore + 1
	end

	-- Very high K/D with high accuracy is suspicious
	local kdRatio = playerData.kd_ratio or 0
	if (kdRatio > 5 and accuracy > 60) then
		suspicionScore = suspicionScore + 2
	end

	if (suspicionScore >= 4) then
		return {
			level = "HIGH",
			text = "HIGH SUSPICION",
			color = Color(255, 100, 100)
		}
	elseif (suspicionScore >= 2) then
		return {
			level = "MEDIUM",
			text = "MEDIUM SUSPICION",
			color = Color(255, 200, 100)
		}
	else
		return {
			level = "LOW",
			text = "LOW SUSPICION",
			color = Color(100, 255, 100)
		}
	end
end

function PANEL:GetAccuracyColor(accuracy)
	if (accuracy > 85) then
		return Color(255, 100, 100) -- Red for very high
	elseif (accuracy > 70) then
		return Color(255, 200, 100) -- Yellow for high
	elseif (accuracy > 40) then
		return Color(100, 255, 100) -- Green for normal
	else
		return Color(150, 150, 150) -- Gray for low
	end
end

function PANEL:GetHeadshotColor(headshotRate)
	if (headshotRate > 60) then
		return Color(255, 100, 100) -- Red for very high
	elseif (headshotRate > 40) then
		return Color(255, 200, 100) -- Yellow for high
	elseif (headshotRate > 20) then
		return Color(100, 255, 100) -- Green for normal
	else
		return Color(150, 150, 150) -- Gray for low
	end
end

function PANEL:FindOnlinePlayer(steamID)
	for _, ply in ipairs(player.GetAll()) do
		if (ply:SteamID() == steamID) then
			return ply
		end
	end
	return nil
end

vgui.Register("expPlayerHitPlayerEntryPanel", PANEL, "EditablePanel")

-- Detailed player statistics panel
local PANEL = {}

function PANEL:Init()
	self:SetSize(700, 600)
	self:Center()
	self:SetTitle("Hit Statistics: Player Details")
	self:SetDeleteOnClose(true)

	self.playerStatsParent = self:Add("EditablePanel")
	self.playerStatsParent:Dock(FILL)
end

function PANEL:SetPlayerStats(stats, steamID)
	self.stats = stats
	self.steamID = steamID

	-- Clear existing content
	for _, child in ipairs(self.playerStatsParent:GetChildren()) do
		child:Remove()
	end

	-- Player info header
	local headerPanel = self.playerStatsParent:Add("EditablePanel")
	headerPanel:SetTall(60)
	headerPanel:Dock(TOP)
	headerPanel:DockMargin(10, 10, 10, 10)
	headerPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 55))
	end

	local playerName = "Unknown Player"
	for _, ply in ipairs(player.GetAll()) do
		if (ply:SteamID() == steamID) then
			playerName = ply:Name()
			break
		end
	end

	local headerLabel = headerPanel:Add("DLabel")
	headerLabel:SetText("Player: " .. playerName .. " (" .. steamID .. ")")
	headerLabel:SetFont("ixMediumFont")
	headerLabel:SetTextColor(Color(255, 255, 255))
	headerLabel:SetPos(15, 15)
	headerLabel:SizeToContents()

	-- Main stats panel
	local mainStatsPanel = self.playerStatsParent:Add("DSizeToContents")
	mainStatsPanel:Dock(TOP)
	mainStatsPanel:DockMargin(10, 0, 0, 10)
	mainStatsPanel:DockPadding(6, 10, 6, 10)
	mainStatsPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 45))
	end

	-- Create main stats layout
	self:CreateMainStatsLayout(mainStatsPanel, stats)

	-- Hitgroup distribution
	local hitgroupPanel = self.playerStatsParent:Add("EditablePanel")
	hitgroupPanel:SetTall(250)
	hitgroupPanel:Dock(TOP)
	hitgroupPanel:DockMargin(10, 0, 10, 10)
	hitgroupPanel:DockPadding(6, 10, 6, 10)
	hitgroupPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 45))
	end

	-- Header for hitgroup section
	local hitgroupHeader = hitgroupPanel:Add("DLabel")
	hitgroupHeader:SetText("Body Part Hit Distribution")
	hitgroupHeader:SetFont("ixMediumFont")
	hitgroupHeader:SetTextColor(Color(255, 255, 255))
	hitgroupHeader:SetTall(25)
	hitgroupHeader:Dock(TOP)
	hitgroupHeader:DockMargin(10, 10, 10, 5)

	self:CreateHitgroupLayout(hitgroupPanel, stats.hitgroups or {})
end

function PANEL:CreateStatLabel(parent, labelText, valueText, valueColor)
	local container = parent:Add("DSizeToContents")
	container:Dock(TOP)
	container:DockMargin(10, 0, 10, 5)

	local label = container:Add("DLabel")
	label:SetText(labelText)
	label:SetFont("ixMediumFont")
	label:SetTextColor(Color(255, 255, 255))
	label:Dock(LEFT)
	label:SizeToContents()

	local value = container:Add("DLabel")
	value:SetText(" " .. valueText)
	value:SetFont("ixMediumFont")
	value:SetTextColor(valueColor)
	value:Dock(FILL)
end

function PANEL:CreateMainStatsLayout(parent, stats)
	local totals = stats.totals or {}
	local accuracy = stats.accuracy or {}

	self:CreateStatLabel(
		parent,
		"Accuracy:",
		string.format(
			"%.1f%% (%d/%d)",
			accuracy.hit_rate or 0,
			totals.total_hits or 0,
			totals.shots_fired or 0
		),
		self:GetAccuracyColor(accuracy.hit_rate or 0)
	)

	self:CreateStatLabel(
		parent,
		"Headshot Rate:",
		string.format(
			"%.1f%% (%d/%d)",
			accuracy.headshot_rate or 0,
			totals.headshot_hits or 0,
			totals.total_hits or 0
		),
		self:GetHeadshotColor(accuracy.headshot_rate or 0)
	)

	self:CreateStatLabel(
		parent,
		"K/D Ratio:",
		string.format(
			"%.2f (%d/%d)",
			totals.kd_ratio or 0,
			totals.kills or 0,
			totals.deaths or 0
		),
		Color(200, 200, 200)
	)

	self:CreateStatLabel(
		parent,
		"Headshot Kills:",
		string.format(
			"%d/%d",
			totals.headshot_kills or 0,
			totals.kills or 0
		),
		Color(200, 200, 200)
	)

	self:CreateStatLabel(
		parent,
		"Total Shots:",
		tostring(totals.shots_fired or 0),
		Color(180, 180, 180)
	)
	self:CreateStatLabel(
		parent,
		"Total Hits:",
		tostring(totals.total_hits or 0),
		Color(180, 180, 180)
	)
end

function PANEL:CreateHitgroupLayout(parent, hitgroups)
	local listPanel = parent:Add("DScrollPanel")
	listPanel:Dock(FILL)
	listPanel:DockMargin(10, 0, 10, 10)

	-- Calculate total hits for percentages
	local totalHits = 0
	for _, data in pairs(hitgroups) do
		totalHits = totalHits + (data.hits or 0)
	end

	if (totalHits == 0) then
		local noDataLabel = listPanel:Add("DLabel")
		noDataLabel:SetText("No hit data available")
		noDataLabel:SetFont("ixMediumFont")
		noDataLabel:SetTextColor(Color(150, 150, 150))
		noDataLabel:SetContentAlignment(5)
		noDataLabel:Dock(FILL)
		return
	end

	-- Sort hitgroups by hit count
	local sortedHitgroups = {}
	for hitgroup, data in pairs(hitgroups) do
		table.insert(sortedHitgroups, { name = hitgroup, data = data })
	end

	table.sort(sortedHitgroups, function(a, b)
		return (a.data.hits or 0) > (b.data.hits or 0)
	end)

	for i, hitgroupData in ipairs(sortedHitgroups) do
		local hitgroup = hitgroupData.name
		local data = hitgroupData.data
		local percentage = (data.hits / totalHits) * 100

		local entryPanel = listPanel:Add("EditablePanel")
		entryPanel:SetTall(25)
		entryPanel:Dock(TOP)
		entryPanel:DockMargin(0, 2, 0, 2)

		local nameLabel = entryPanel:Add("DLabel")
		nameLabel:SetText(hitgroup .. ":")
		nameLabel:SetFont("ixMediumFont")
		nameLabel:SetTextColor(Color(255, 255, 255))
		nameLabel:SetSize(100, 25)
		nameLabel:Dock(LEFT)

		local statsLabel = entryPanel:Add("DLabel")
		local statsText = string.format("%d hits (%.1f%%) | Avg: %.1f dmg, %.0f units",
			data.hits or 0, percentage, data.avg_damage or 0, data.avg_distance or 0)
		statsLabel:SetText(statsText)
		statsLabel:SetFont("DermaDefault")

		-- Color code based on hit type
		local textColor = Color(200, 200, 200)
		if (hitgroup == "Head") then
			textColor = Color(255, 150, 150)
		elseif (hitgroup == "Chest") then
			textColor = Color(150, 255, 150)
		end

		statsLabel:SetTextColor(textColor)
		statsLabel:Dock(FILL)
	end
end

function PANEL:GetAccuracyColor(accuracy)
	if (accuracy > 85) then
		return Color(255, 100, 100)
	elseif (accuracy > 70) then
		return Color(255, 200, 100)
	elseif (accuracy > 40) then
		return Color(100, 255, 100)
	else
		return Color(150, 150, 150)
	end
end

function PANEL:GetHeadshotColor(headshotRate)
	if (headshotRate > 60) then
		return Color(255, 100, 100)
	elseif (headshotRate > 40) then
		return Color(255, 200, 100)
	elseif (headshotRate > 20) then
		return Color(100, 255, 100)
	else
		return Color(150, 150, 150)
	end
end

vgui.Register("expPlayerHitDetailPanel", PANEL, "expFrame")

-- Main hit statistics panel
local PANEL = {}

function PANEL:Init()
	self:SetSize(1000, 700)
	self:Center()
	self:SetTitle("Hit Statistics")
	self:SetDeleteOnClose(true)

	-- Tab system
	self.tabPanel = self:Add("DPropertySheet")
	self.tabPanel:Dock(FILL)
	self.tabPanel:DockMargin(8, 8, 8, 8)

	-- Overview tab
	self.overviewPanel = vgui.Create("DPanel")
	self.overviewPanel.Paint = function() end
	self.tabPanel:AddSheet("All Players", self.overviewPanel, "icon16/group.png")

	-- Suspicious players tab
	self.suspiciousPanel = vgui.Create("DPanel")
	self.suspiciousPanel.Paint = function() end
	self.tabPanel:AddSheet("Suspicious", self.suspiciousPanel, "icon16/error.png")

	self:CreateOverviewTab()
	self:CreateSuspiciousTab()
end

function PANEL:CreateOverviewTab()
	-- Search and filter panel
	local searchPanel = self.overviewPanel:Add("EditablePanel")
	searchPanel:SetTall(60)
	searchPanel:Dock(TOP)
	searchPanel:DockMargin(8, 8, 8, 8)

	-- Search label
	local searchLabel = searchPanel:Add("DLabel")
	searchLabel:SetText("Search players:")
	searchLabel:SetFont("ixMediumFont")
	searchLabel:SetTextColor(Color(255, 255, 255))
	searchLabel:SetPos(0, 5)
	searchLabel:SizeToContents()

	-- Search entry
	self.searchEntry = searchPanel:Add("DTextEntry")
	self.searchEntry:SetSize(300, 25)
	self.searchEntry:SetPos(0, 30)
	self.searchEntry:SetFont("ixMediumFont")
	self.searchEntry:SetPlaceholderText("Search by player name or Steam ID...")
	self.searchEntry.OnTextChanged = function(entry)
		self:FilterPlayers(entry:GetText())
	end

	-- Refresh button
	self.refreshButton = searchPanel:Add("expButton")
	self.refreshButton:SetText("Refresh Data")
	self.refreshButton:SizeToContents()
	self.refreshButton:SetPos(320, 30)
	self.refreshButton.DoClick = function()
		Schema.chunkedNetwork.Request("PlayersOverview", {}, function(playersStats, extraData)
			if (IsValid(self)) then
				self:DisplayPlayersOverview(playersStats)
			end
		end)
	end

	-- Create loading indicator
	self.loadingLabel = self.overviewPanel:Add("DLabel")
	self.loadingLabel:SetText("Loading player statistics...")
	self.loadingLabel:SetFont("ixMediumFont")
	self.loadingLabel:SetTextColor(Color(150, 150, 150))
	self.loadingLabel:SetContentAlignment(5)
	self.loadingLabel:Dock(FILL)

	-- Scroll panel (hidden initially)
	self.overviewScroll = self.overviewPanel:Add("DScrollPanel")
	self.overviewScroll:Dock(FILL)
	self.overviewScroll:DockMargin(8, 8, 8, 8)
	self.overviewScroll:SetVisible(false)

	self.allPlayers = {}
	self.filteredPlayers = {}
end

function PANEL:CreateSuspiciousTab()
	-- Info panel
	local infoPanel = self.suspiciousPanel:Add("EditablePanel")
	infoPanel:SetTall(40)
	infoPanel:Dock(TOP)
	infoPanel:DockMargin(8, 8, 8, 8)
	infoPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(60, 40, 40))
	end

	local infoLabel = infoPanel:Add("DLabel")
	infoLabel:SetText("Players flagged with suspicious accuracy patterns (>85% accuracy or >60% headshot rate)")
	infoLabel:SetFont("ixMediumFont")
	infoLabel:SetTextColor(Color(255, 200, 200))
	infoLabel:SetPos(10, 10)
	infoLabel:SizeToContents()

	-- Refresh suspicious button
	self.refreshSuspiciousButton = self.suspiciousPanel:Add("expButton")
	self.refreshSuspiciousButton:SetText("Refresh Suspicious Players")
	self.refreshSuspiciousButton:SizeToContents()
	self.refreshSuspiciousButton:Dock(TOP)
	self.refreshSuspiciousButton:DockMargin(8, 0, 8, 8)
	self.refreshSuspiciousButton.DoClick = function()
		Schema.chunkedNetwork.Request("SuspiciousPlayers", {
			thresholds = {
				min_shots = 100,
				max_accuracy = 85,
				max_headshot_rate = 60
			}
		}, function(suspiciousPlayers, extraData)
			if (IsValid(self)) then
				self:DisplaySuspiciousPlayers(suspiciousPlayers)
			end
		end)
	end

	-- Suspicious players scroll
	self.suspiciousScroll = self.suspiciousPanel:Add("DScrollPanel")
	self.suspiciousScroll:Dock(FILL)
	self.suspiciousScroll:DockMargin(8, 8, 8, 8)

	-- Request suspicious players data
	Schema.chunkedNetwork.Request("SuspiciousPlayers", {}, function(suspiciousPlayers, extraData)
		if (IsValid(self)) then
			self:DisplaySuspiciousPlayers(suspiciousPlayers)
		end
	end)
end

function PANEL:DisplayPlayersOverview(playersStats)
	-- Hide loading indicator
	self.loadingLabel:SetVisible(false)

	-- Show scroll panel
	self.overviewScroll:SetVisible(true)
	self.overviewScroll:Clear()

	self.allPlayers = playersStats
	self.filteredPlayers = playersStats

	if (#playersStats == 0) then
		local emptyLabel = self.overviewScroll:Add("DLabel")
		emptyLabel:SetText("No player statistics found")
		emptyLabel:SetFont("ixMediumFont")
		emptyLabel:SetTextColor(Color(150, 150, 150))
		emptyLabel:SetContentAlignment(5)
		emptyLabel:Dock(FILL)
		return
	end

	-- Sort players by total shots (most active first)
	table.sort(playersStats, function(a, b)
		return (a.total_shots or 0) > (b.total_shots or 0)
	end)

	-- Create player entries
	for i, playerData in ipairs(playersStats) do
		local playerPanel = self.overviewScroll:Add("expPlayerHitPlayerEntryPanel")
		playerPanel:SetPlayerStats(playerData, i)
		playerPanel:Dock(TOP)
		playerPanel:DockMargin(5, 5, 5, 5)
	end
end

function PANEL:DisplaySuspiciousPlayers(suspiciousPlayers)
	self.suspiciousScroll:Clear()

	if (#suspiciousPlayers == 0) then
		local emptyLabel = self.suspiciousScroll:Add("DLabel")
		emptyLabel:SetText("No suspicious players found")
		emptyLabel:SetFont("ixMediumFont")
		emptyLabel:SetTextColor(Color(100, 255, 100))
		emptyLabel:SetContentAlignment(5)
		emptyLabel:Dock(FILL)
		return
	end

	-- Create suspicious player entries
	for i, playerData in ipairs(suspiciousPlayers) do
		local playerPanel = self.suspiciousScroll:Add("expPlayerHitPlayerEntryPanel")
		playerPanel:SetPlayerStats(playerData, i)
		playerPanel:Dock(TOP)
		playerPanel:DockMargin(5, 5, 5, 5)
	end
end

function PANEL:DisplayPlayerStats(stats, steamID)
	-- Create detailed stats panel
	local detailPanel = vgui.Create("expPlayerHitDetailPanel")
	detailPanel:SetPlayerStats(stats, steamID)
	detailPanel:MakePopup()
end

function PANEL:FilterPlayers(searchText)
	if (not searchText or searchText == "") then
		self.filteredPlayers = self.allPlayers
	else
		searchText = string.lower(searchText)
		self.filteredPlayers = {}

		for _, playerData in ipairs(self.allPlayers) do
			local playerName = string.lower(playerData.steam_name or "")
			local steamID = string.lower(playerData.steam_id or "")

			if (string.find(playerName, searchText) or string.find(steamID, searchText)) then
				table.insert(self.filteredPlayers, playerData)
			end
		end
	end

	-- Rebuild the display with filtered players
	self:DisplayPlayersOverview(self.filteredPlayers)
end

vgui.Register("expAdminHitStats", PANEL, "expFrame")

concommand.Add("exp_hitstats_panel", function()
	if (not LocalPlayer():IsAdmin()) then
		LocalPlayer():Notify("You don't have permission to access this panel.")
		return
	end

	PLUGIN:ShowHitStatsPanel()
end)
