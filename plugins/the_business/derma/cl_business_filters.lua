local PLUGIN = PLUGIN
local PANEL = {}

function PANEL:Init()
	self:SetTitle("Filter")
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

	local height = 70

	local filterableItems = {}

	for filter, filterData in pairs(filters) do
		local filterInput = self:CreateFilterInput(filter, filterData.items, filterData.type)
		self.filterInputs[#self.filterInputs + 1] = filterInput

		for _, itemTable in ipairs(filterData.items) do
			filterableItems[itemTable.uniqueID] = itemTable
		end

		height = height + filterInput:GetTall() + 10
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

		height = height + filterInput:GetTall() + 10
	end

	self:SetSize(ScrW() * 0.25, math.min(height, ScrH() * 0.75))
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
		ix.util.SchemaErrorNoHalt("Not yet implemented! This filter type is not yet supported.")
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
		ix.util.SchemaErrorNoHalt("Not yet implemented! This filter type is not yet supported.")
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

vgui.Register("expBusinessFilters", PANEL, "DFrame")
