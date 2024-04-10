local PLUGIN = PLUGIN
local PANEL = {}

function PANEL:GetItemsForCategory(category)
	local items = {}

	for uniqueID, itemTable in SortedPairsByMemberValue(ix.item.list, "name") do
		if (hook.Run("CanPlayerUseBusiness", LocalPlayer(), uniqueID) == false) then
			continue
		end

		if (itemTable.category == category) then
			items[#items + 1] = itemTable
		end
	end

	return items
end

function PANEL:Init()
	-- Create a panel to hold the search bar and category list
	self.searchPanel = self:Add("EditablePanel")
	self.searchPanel:Dock(TOP)
	self.searchPanel:SetTall(36)
	self.searchPanel:DockMargin(0, 0, 0, 5)

	-- Reparent the search bar to the search panel
	self.search:SetParent(self.searchPanel)
	self.search:Dock(FILL)
	self.search:DockMargin(5, 0, 5, 5)

	-- A button to open the filter menu
	self.filterButton = self.searchPanel:Add("DButton")
	self.filterButton:Dock(LEFT)
	self.filterButton:SetWide(100)
	self.filterButton:SetText("Filter")
	self.filterButton:SetTextColor(color_white)
	self.filterButton:SetFont("ixMediumFont")
	self.filterButton:SetExpensiveShadow(1, Color(0, 0, 0, 150))
	self.filterButton:DockMargin(5, 0, 5, 5)
	self.filterButton.DoClick = function(button)
		local allItems = self:GetItemsForCategory(self.selected.category)
		local filters = {}

		for _, itemTable in ipairs(allItems) do
			if (not itemTable.GetFilters) then
				continue
			end

			for filter, filterType in pairs(itemTable:GetFilters()) do
				filters[filter] = filters[filter] or {
					type = filterType,
					items = {},
				}
				filters[filter].items[#filters[filter].items + 1] = itemTable
			end
		end

		if (IsValid(self.filterMenu)) then
			self.filterMenu:SetVisible(true)
			self.filterMenu:MakePopup()
			self.filterMenu:SetPos(button:LocalToScreen(0, button:GetTall()))
			return
		end

		self.filterMenu = vgui.Create("expEnhancedBusinessFilters", self)
		self.filterMenu:SetFilters(filters, allItems)
		self.filterMenu:MakePopup()
		self.filterMenu:SetPos(button:LocalToScreen(0, button:GetTall()))
	end
end

function PANEL:DisplayItems(items)
	self.itemList:Clear()
	self.itemList:InvalidateLayout(true)

	table.SortByMember(items, "name", true)

	for _, itemTable in ipairs(items) do
		self.itemList:Add("ixBusinessItem"):SetItem(itemTable)
	end
end

function PANEL:LoadItems(category, search)
	category = category or "misc"

	self.itemList:Clear()
	self.itemList:InvalidateLayout(true)

	if (IsValid(self.filterMenu)) then
		self.filterMenu:Close()
		self.filterMenu:Remove()
	end

	local items = self:GetItemsForCategory(category)
	local matchedItems = {}

	for _, itemTable in ipairs(items) do
		local searchMismatch = search and search ~= "" and not L(itemTable.name):lower():find(search, 1, true)

		if (searchMismatch and not itemTable.GetSearchMatches) then
			continue
		end

		if (searchMismatch and itemTable.GetSearchMatches and not itemTable:GetSearchMatches(search)) then
			continue
		end

		matchedItems[#matchedItems + 1] = itemTable
	end

	self:DisplayItems(matchedItems)
end

vgui.Register("expEnhancedBusiness", PANEL, "ixBusiness")

PANEL = {}

function PANEL:Init()
	self:SetTitle("Filter")
	self:SetSize(ScrW() * 0.25, ScrH() * 0.5)
	self:Center()
	self:MakePopup()
	self:SetDeleteOnClose(false)

	-- Buttons to bulk manage all filters at top
	local bulkActions = self:Add("EditablePanel")
	bulkActions:Dock(TOP)
	bulkActions:SetTall(25)
	bulkActions:DockMargin(0, 0, 0, 5)

	local selectNoFilters = bulkActions:Add("DButton")
	selectNoFilters:Dock(LEFT)
	selectNoFilters:DockMargin(0, 0, 5, 0)
	selectNoFilters:SetText("Select None")
	selectNoFilters:SetTextColor(color_white)
	selectNoFilters:SetFont("ixSmallFont")
	selectNoFilters:SetExpensiveShadow(1, Color(0, 0, 0, 150))
	selectNoFilters:SizeToContents()
	selectNoFilters.DoClick = function(button)
		for _, filterInput in ipairs(self.filterInputs) do
			if (filterInput.SetChecked) then
				filterInput:SetChecked(false)
			elseif (filterInput.SetValue) then
				filterInput:SetValue("")
			end
		end

		self:RefreshMatchedItems()
	end

	local selectFilters = bulkActions:Add("DButton")
	selectFilters:Dock(LEFT)
	selectFilters:DockMargin(0, 0, 5, 0)
	selectFilters:SetText("Select All")
	selectFilters:SetTextColor(color_white)
	selectFilters:SetFont("ixSmallFont")
	selectFilters:SetExpensiveShadow(1, Color(0, 0, 0, 150))
	selectFilters:SizeToContents()
	selectFilters.DoClick = function(button)
		for _, filterInput in ipairs(self.filterInputs) do
			if (filterInput.SetChecked) then
				filterInput:SetChecked(true)
			end
		end

		self:RefreshMatchedItems()
	end

	self.filterList = self:Add("DScrollPanel")
	self.filterList:Dock(FILL)

	self.filters = {}
end

function PANEL:Think()
	if (input.IsMouseDown(MOUSE_FIRST)) then
		local mouseX = gui.MouseX()
		local mouseY = gui.MouseY()

		local x, y, w, h = self:GetBounds()

		-- If the user clicks outside of the frame, close it
		if (mouseX < x or mouseY < y or mouseX > x + w or mouseY > y + h) then
			self:Close()
		end
	end

	self:MoveToFront()
end

function PANEL:RefreshMatchedItems()
	local matchedItems = {}

	for _, filterInput in ipairs(self.filterInputs) do
		local filterItems = filterInput:GetMatchedItems()

		for _, itemTable in ipairs(filterItems) do
			if (not matchedItems[itemTable.uniqueID]) then
				matchedItems[itemTable.uniqueID] = itemTable
			end
		end
	end

	self:GetParent():DisplayItems(table.ClearKeys(matchedItems))
end

function PANEL:SetFilters(filters, allItems)
	self.allItems = allItems

	self.filterList:Clear()
	self.filterInputs = {}

	local filterableItems = {}

	for filter, filterData in pairs(filters) do
		local filterInput = self:CreateFilterInput(filter, filterData.items, filterData.type)
		self.filterInputs[#self.filterInputs + 1] = filterInput

		for _, itemTable in ipairs(filterData.items) do
			filterableItems[itemTable.uniqueID] = itemTable
		end
	end

	-- Put any non-filterable items into their own filter
	local otherItems = {}

	for _, itemTable in ipairs(allItems) do
		if (not filterableItems[itemTable.uniqueID]) then
			otherItems[#otherItems + 1] = itemTable
		end
	end

	if (#otherItems > 0) then
		local filterInput = self:CreateFilterInput("Uncategorized", otherItems, "checkbox")
		self.filterInputs[#self.filterInputs + 1] = filterInput
	end
end

function PANEL:CreateFilterInput(filter, filterItems, filterType)
	local filterPanel = self.filterList:Add("DPanel")
	filterPanel:Dock(TOP)
	filterPanel:DockMargin(0, 0, 0, 5)

	local filterLabel = filterPanel:Add("DLabel")
	filterLabel:Dock(LEFT)
	filterLabel:SetText(filter)
	filterLabel:SetFont("ixSmallFont")
	filterLabel:SetTextColor(color_white)
	filterLabel:SetExpensiveShadow(1, Color(0, 0, 0, 150))
	filterLabel:SizeToContents()
	filterLabel:DockMargin(5, 5, 5, 5)

	local filterInput

	if (filterType == "checkbox") then
		filterInput = filterPanel:Add("DCheckBox")
		filterInput:SetSize(24, 24)
		filterInput:SetValue(true)

		filterInput.OnChange = function(input, isChecked)
			self:RefreshMatchedItems()
		end

		filterInput.GetMatchedItems = function(input)
			local matchedItems = {}
			local isChecked = input:GetChecked()

			for _, itemTable in ipairs(filterItems) do
				if (isChecked) then
					matchedItems[#matchedItems + 1] = itemTable
				end
			end

			return matchedItems
		end
	elseif (filterType:StartsWith("slider")) then
		ErrorNoHalt("Not yet implemented! This filter type is not yet supported.")
		-- -- TODO: Slider filter
		-- local min, max = filterType:match("slider:(%d+),(%d+)")

		-- if (min and max) then
		-- 	min = tonumber(min)
		-- 	max = tonumber(max)
		-- else
		-- 	min = 0
		-- 	max = 100
		-- end

		-- filterInput = filterPanel:Add("DNumSlider")
		-- filterInput:SetMin(min)
		-- filterInput:SetMax(max)
		-- filterInput:SetDecimals(0)
		-- filterInput:SetValue(0)

		-- filterInput.OnValueChanged = function(input, value)
		-- 	self:RefreshMatchedItems()
		-- end

		-- filterInput.GetMatchedItems = function(input)
		-- 	local matchedItems = {}

		-- 	for _, itemTable in ipairs(filterItems) do
		-- 		print("TODO: Implement slider filter", itemTable.name, value)
		-- 	end

		-- 	return matchedItems
		-- end
	else
		ErrorNoHalt("Not yet implemented! This filter type is not yet supported.")
		-- -- TODO: Text filter
		-- filterInput = filterPanel:Add("DTextEntry")
		-- filterInput:SetValue("")

		-- filterInput.OnEnter = function(input)
		-- 	self:RefreshMatchedItems()
		-- end

		-- filterInput.GetMatchedItems = function(input)
		-- 	local value = input:GetValue()
		-- 	local matchedItems = {}

		-- 	for _, itemTable in ipairs(filterItems) do
		-- 		if (value == "" or L(itemTable.name):lower():find(value, 1, true)) then
		-- 			matchedItems[#matchedItems + 1] = itemTable
		-- 		end
		-- 	end

		-- 	return matchedItems
		-- end
	end

	filterInput:DockMargin(5, 5, 5, 5)
	filterInput:Dock(RIGHT)

	filterPanel:SetTall(math.max(filterLabel:GetTall(), filterInput:GetTall()) + 10)

	return filterInput
end

vgui.Register("expEnhancedBusinessFilters", PANEL, "DFrame")
