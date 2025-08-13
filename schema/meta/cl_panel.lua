--- @class Panel
local META = FindMetaTable("Panel")

--- (Only for DComboBox) Gets an option ID by its data.
--- @param data any
--- @return number?
function META:FindOptionByData(data)
	for i, choice in pairs(self.Choices) do
		local optionData = self:GetOptionData(i)

		if (optionData == data) then
			return i
		end
	end
end

local panelsOnTop = {}

--- Forces this panel to stay in front. The last panel to call this function will be on top.
--- @param isAlwaysOnTop? boolean Defaults to true
function META:SetAlwaysOnTop(isAlwaysOnTop)
	if (isAlwaysOnTop == nil) then
		isAlwaysOnTop = true
	end

	-- Insert in front so when we reverse the loop it is in the correct order
	table.insert(panelsOnTop, 1, {
		panel = self,
		isAlwaysOnTop = isAlwaysOnTop
	})
end

local panelsToWatch = {}

--- Closes the given panel once the specified panel is no longer valid.
--- @param panelToWatch Panel
function META:SetToRemoveOnceInvalid(panelToWatch)
	panelsToWatch[panelToWatch] = panelsToWatch[panelToWatch] or {}
	table.insert(panelsToWatch[panelToWatch], self)
end

hook.Add("Think", "expMetaPanelAlwaysOnTop", function()
	-- -- Reverse loop so we can remove elements without breaking the loop
	-- for i = #panelsOnTop, 1, -1 do
	-- 	local panelData = panelsOnTop[i]

	-- 	if (IsValid(panelData.panel) and panelData.isAlwaysOnTop) then
	-- 		panelData.panel:MoveToFront()
	-- 	else
	-- 		table.remove(panelsOnTop, i)
	-- 	end
	-- end
	-- Just place the first panel on top
	local firstPanel = panelsOnTop[1]

	if (firstPanel and IsValid(firstPanel.panel) and firstPanel.isAlwaysOnTop) then
		if (not firstPanel.panel:HasHierarchicalFocus()) then
			firstPanel.panel:MoveToFront()
		end
	elseif (firstPanel) then
		table.remove(panelsOnTop, 1)
	end

	for panelToWatch, panelsToRemove in pairs(panelsToWatch) do
		if (not IsValid(panelToWatch)) then
			for _, panelToClose in ipairs(panelsToRemove) do
				if (IsValid(panelToClose)) then
					panelToClose:Remove()
				end
			end

			panelsToWatch[panelToWatch] = nil
		end
	end
end)
