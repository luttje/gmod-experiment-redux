do
	--- @class expProgressionTracker : EditablePanel
	local PANEL = {}

	-- Called when the panel is initialized.
	function PANEL:Init()
		self.nextThink = 0
		self.rows = {}
		self.categories = {}

		self:Dock(FILL)
		self:SetSearchEnabled(true)
		self:Update()
	end

	function PANEL:SetSearchEnabled(bValue)
		if (! bValue) then
			if (IsValid(self.searchEntry)) then
				self.searchEntry:Remove()
			end
			return
		end

		-- search entry
		self.searchEntry = self:Add("ixIconTextEntry")
		self.searchEntry:Dock(TOP)
		self.searchEntry:SetEnterAllowed(false)

		self.searchEntry.OnChange = function(entry)
			self:FilterRows(entry:GetValue())
		end
	end

	function PANEL:FilterRows(query)
		if (! query) then return end

		query = string.PatternSafe(query:lower())
		local bEmpty = query == ""

		for categoryName, category in pairs(self.categories) do
			if (! IsValid(category)) then continue end

			local hasVisibleItems = false

			for _, row in ipairs(category:GetChildren()) do
				if (! IsValid(row) or ! row.GetText) then continue end

				local bFound = bEmpty or row:GetText():lower():find(query) or categoryName:lower():find(query)
				row:SetVisible(bFound)

				if (bFound) then
					hasVisibleItems = true
				end
			end

			category:SetVisible(hasVisibleItems or bEmpty)
		end
	end

	function PANEL:AddCategory(name)
		local panel = self.categories[name]

		if (! IsValid(panel)) then
			panel = self.canvas:Add("ixCategoryPanel")
			panel:SetText(name)
			panel:Dock(TOP)
			panel:DockMargin(0, 8, 0, 0)

			self.categories[name] = panel
			return panel
		end

		return panel
	end

	function PANEL:AddRow(category)
		category = self.categories[category]

		local panel = (IsValid(category) and category or self.canvas):Add("expProgressionTrackerRow")
		panel:Dock(TOP)
		panel:SetBackgroundIndex(#self.rows % 2)

		self.rows[#self.rows + 1] = panel
		return panel
	end

	function PANEL:GetRows()
		return self.rows
	end

	function PANEL:Clear()
		for _, v in ipairs(self.rows) do
			if (IsValid(v)) then
				v:Remove()
			end
		end

		for _, v in pairs(self.categories) do
			if (IsValid(v)) then
				v:Remove()
			end
		end

		self.rows = {}
		self.categories = {}
	end

	--- Rebuilds the panel.
	function PANEL:Update()
		-- Clear existing content
		self:Clear()

		-- Create scroll panel
		if (IsValid(self.canvas)) then
			self.canvas:Remove()
		end

		self.canvas = self:Add("DScrollPanel")
		self.canvas:Dock(FILL)
		self.canvas.PerformLayout = function(panel)
			DScrollPanel.PerformLayout(panel)

			if (! panel.VBar.Enabled) then
				panel.pnlCanvas:SetWide(panel:GetWide() - panel.VBar:GetWide())
			end
		end

		-- List of all progression trackers (missions/quests) with their goals.
		local progressions = Schema.progression.GetProgressions() -- Get all progressions for the local player

		local progressionCategories = {
			{
				id = "in_progress",
				name = "In Progress",
				icon = "icon16/star.png",
				alwaysShow = true,
				matcher = function(tracker)
					return tracker:IsInProgress() and not tracker:IsCompleted()
				end
			},
			{
				id = "completed",
				name = "Completed",
				icon = "icon16/tick.png",
				alwaysShow = true,
				matcher = function(tracker)
					return tracker:IsCompleted()
				end
			}
		}

		hook.Run("AdjustProgressionCategories", progressionCategories)

		-- Collect trackers into categories
		for scope, scopeProgressions in pairs(progressions) do
			local trackers = Schema.progression.GetTrackersByScope(scope)

			for uniqueID, tracker in pairs(trackers) do
				for _, category in ipairs(progressionCategories) do
					if (category.matcher(tracker)) then
						category.trackers = category.trackers or {}
						table.insert(category.trackers, tracker)
					end
				end
			end
		end

		-- Create category panels and add trackers
		for _, category in pairs(progressionCategories) do
			if (category.trackers or category.alwaysShow) then
				self:AddCategory(category.name)

				local trackers = category.trackers or {}

				-- Sort trackers by name
				table.sort(trackers, function(trackerA, trackerB)
					return trackerA:GetName() < trackerB:GetName()
				end)

				if (#trackers == 0) then
					local noProgressionRow = self:AddRow(category.name)
					noProgressionRow:SetText("No progress to track in this category!")
					noProgressionRow:SetInfoStyle(true)
				else
					for i, tracker in ipairs(trackers) do
						local trackerRow = self:AddRow(category.name)
						trackerRow:SetProgressionTracker(tracker)
					end
				end
			end
		end

		self:SizeToContents()
	end

	function PANEL:SizeToContents()
		for _, v in pairs(self.categories) do
			if (IsValid(v)) then
				v:SizeToContents()
			end
		end
	end

	-- Called when the layout should be performed.
	function PANEL:PerformLayout()
		-- Auto-size based on content, with maximum height limit
		if (IsValid(self.canvas) and IsValid(self.canvas.pnlCanvas)) then
			local maxHeight = ScrH() * 0.75
			local contentHeight = self.canvas.pnlCanvas:GetTall() + 8

			if (IsValid(self.searchEntry)) then
				contentHeight = contentHeight + self.searchEntry:GetTall() + 8
			end

			self:SetSize(
				self:GetWide(),
				math.min(contentHeight, maxHeight)
			)
		end
	end

	vgui.Register("expProgressionTracker", PANEL, "EditablePanel")
end

do
	--- @class expProgressionTrackerRow : EditablePanel
	local PANEL = {}

	AccessorFunc(PANEL, "backgroundIndex", "BackgroundIndex", FORCE_NUMBER)

	function PANEL:Init()
		self:DockPadding(8, 8, 8, 8)
		self.backgroundIndex = 0

		self.text = self:Add("DLabel")
		self.text:Dock(FILL)
		self.text:SetFont("ixMenuButtonFont")
		self.text:SetExpensiveShadow(1, color_black)

		-- self.expandButton = self:Add("DButton")
		-- self.expandButton:SetText("")
		-- self.expandButton:SetWide(20)
		-- self.expandButton:Dock(RIGHT)
		-- self.expandButton:SetVisible(false)
		-- self.expandButton.Paint = function(panel, w, h)
		-- 	local color = self.isExpanded and Color(255, 100, 100) or Color(100, 255, 100)
		-- 	local text = self.isExpanded and "−" or "+"

		-- 	draw.SimpleText(text, "ixMenuButtonFont", w / 2, h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		-- end
		-- self.expandButton.DoClick = function()
		-- 	self:ToggleExpanded()
		-- end
	end

	function PANEL:SetText(text)
		self.text:SetText(text)
		self.text:SizeToContents()
		self.text:SetTall(self.text:GetTall() + 4) -- Padding needed so g and other tall letters don't cut off
		self:SizeToContents()
	end

	function PANEL:GetText()
		return self.text:GetText()
	end

	function PANEL:SetInfoStyle(bInfo)
		if (bInfo) then
			self.text:SetTextColor(Color(100, 150, 255))
		end
	end

	function PANEL:SetProgressionTracker(tracker)
		self.tracker = tracker
		self.isExpanded = not tracker:IsCompleted(LocalPlayer()) -- Auto-expand in-progress trackers

		self:SetText(tracker:GetName())
		-- self.expandButton:SetVisible(true)

		-- Set color based on completion status
		if (tracker:IsCompleted(LocalPlayer())) then
			self.text:SetTextColor(Color(100, 255, 100))
		else
			self.text:SetTextColor(color_white)
		end

		self:CreateGoalsPanel()
		self:UpdateGoalsVisibility()
	end

	function PANEL:CreateGoalsPanel()
		if (! self.tracker) then return end

		if (IsValid(self.goalsPanel)) then
			self.goalsPanel:Remove()
		end

		self.goalsPanel = vgui.Create("DPanel", self)
		self.goalsPanel:Dock(BOTTOM)
		self.goalsPanel:DockMargin(20, 4, 0, 0)
		self.goalsPanel.Paint = nil

		local goalsList = vgui.Create("DPanelList", self.goalsPanel)
		goalsList:Dock(FILL)
		goalsList:SetPadding(4)
		goalsList:SetSpacing(4)

		local goals = self.tracker:GetGoals()
		local isCompleted = self.tracker:IsCompleted(LocalPlayer())

		for _, goal in ipairs(goals) do
			local goalPanel = vgui.Create("expProgressionGoal", goalsList)
			goalPanel:SetProgressionGoal(goal, isCompleted)
			goalsList:AddItem(goalPanel)
		end

		goalsList:SizeToChildren(false, true)
		self.goalsPanel:SizeToChildren(false, true)
	end

	function PANEL:ToggleExpanded()
		self.isExpanded = not self.isExpanded
		self:UpdateGoalsVisibility()
	end

	function PANEL:UpdateGoalsVisibility()
		if (IsValid(self.goalsPanel)) then
			self.goalsPanel:SetVisible(self.isExpanded)
		end

		self:SizeToContents()
		self:GetParent():InvalidateLayout(true)
	end

	function PANEL:SizeToContents()
		local _, top, _, bottom = self:GetDockPadding()
		local height = self.text:GetTall() + top + bottom

		if (self.isExpanded and IsValid(self.goalsPanel) and self.goalsPanel:IsVisible()) then
			height = height + self.goalsPanel:GetTall() + 4
		end

		self:SetTall(height)
		self.ixRealHeight = height
		self.ixHeight = self.ixRealHeight
	end

	function PANEL:Paint(width, height)
		-- Similar to ixSettingsRow background
		local color = derma.GetColor("DarkerBackground", self)

		if (self.backgroundIndex % 2 == 1) then
			color = ColorAlpha(color, 50)
		end

		surface.SetDrawColor(color)
		surface.DrawRect(0, 0, width, height)
	end

	vgui.Register("expProgressionTrackerRow", PANEL, "EditablePanel")
end

do
	--- @class expProgressionGoal : DPanel
	local PANEL = {}

	-- Called when the panel is initialized.
	function PANEL:Init()
		local padding = 4
		self:SetSize(self:GetParent():GetWide(), 34 + padding + padding)

		self.nameLabel = vgui.Create("DLabel", self)
		self.nameLabel:SetFont("DermaDefaultBold")
		self.nameLabel:SetPos(36 + padding, padding)
		self.nameLabel:SizeToContents()

		self.progressBar = vgui.Create("DPanel", self)
		self.progressBar:SetVisible(true)

		self.progressCheckMark = vgui.Create("DImage", self)
		self.progressCheckMark:SetImage("icon16/tick.png")
		self.progressCheckMark:SetSize(20 + padding, 20 + padding)
		self.progressCheckMark:SetPos(8, 8)
		self.progressCheckMark:SetVisible(false)

		self.progressLabel = vgui.Create("DLabel", self.progressBar)
		self.progressLabel:SetText("")
		self.progressLabel:SetExpensiveShadow(1, Color(0, 0, 0, 150))

		self.maximumLabel = vgui.Create("DLabel", self.progressBar)
		self.maximumLabel:SetText("")
		self.maximumLabel:SetExpensiveShadow(1, Color(0, 0, 0, 150))

		-- Called when the panel should be painted.
		function self.progressBar.Paint(progressBar)
			if (not self.progressionGoal or not self.progressFraction) then
				return
			end

			local color = table.Copy(derma.Color("bg_color", self) or Color(100, 100, 100, 255))

			if (color) then
				color.r = math.min(color.r - 25, 255)
				color.g = math.min(color.g - 25, 255)
				color.b = math.min(color.b - 25, 255)
			end

			draw.RoundedBox(4, 0, 0, progressBar:GetWide(), progressBar:GetTall(), color)
			local width = progressBar:GetWide() * self.progressFraction

			draw.RoundedBox(4, 0, 0, width, progressBar:GetTall(), Color(139, 215, 113, 255))
		end
	end

	function PANEL:SetProgressionGoal(progressionGoal, forceCompleted)
		self.progressionGoal = progressionGoal
		self.isForcedCompleted = forceCompleted

		self.nameLabel:SetText(progressionGoal:GetName())
	end

	-- Called each frame.
	function PANEL:Think()
		local progress, maximum, current

		if (self.isForcedCompleted) then
			progress, maximum, current = true, "", ""
		else
			local currentProgress = Schema.progression.Get(
				self.progressionGoal:GetScope(),
				self.progressionGoal:GetKey()
			)
			progress, maximum, current = self.progressionGoal:GetProgress(LocalPlayer(), currentProgress)
		end

		if (isbool(progress)) then
			self.progressCheckMark:SetVisible(progress)
			self.progressFraction = nil
		else
			self.progressCheckMark:SetVisible(false)
			self.progressFraction = progress
		end

		self.progressLabel:SetText(current)
		self.progressLabel:SizeToContents()

		self.maximumLabel:SetText(maximum)
		self.maximumLabel:SizeToContents()

		self.progressLabel:SetPos(
			0,
			(self.progressBar:GetTall() / 2) - (self.progressLabel:GetTall() / 2) - 1
		)

		self.maximumLabel:SetPos(
			self.progressBar:GetWide() - self.maximumLabel:GetWide() - 8,
			(self.progressBar:GetTall() / 2) - (self.maximumLabel:GetTall() / 2) - 1
		)
	end

	-- Called when the layout should be performed.
	function PANEL:PerformLayout()
		local padding = 4
		self.nameLabel:SizeToContents()

		self.progressBar:SetPos(36 + padding, self.nameLabel.y + self.nameLabel:GetTall())
		self.progressBar:SetSize(self:GetWide() - 38 - padding - padding, 12 + padding)
	end

	vgui.Register("expProgressionGoal", PANEL, "DPanel")
end

hook.Add("CreateMenuButtons", "expAddMissionTrackerMenuButton", function(tabs)
	tabs["missionTracker"] = function(container)
		container:Add("expProgressionTracker")
	end
end)
