local PLUGIN = PLUGIN

ix.option.Add("showTutorial", ix.type.bool, true, {
	category = "general"
})

PLUGIN.tutorials = PLUGIN.tutorials or {}

PLUGIN.currentTutorial = PLUGIN.currentTutorial or 0
PLUGIN.currentFade = PLUGIN.currentFade or 0
PLUGIN.undimmedRectsCache = PLUGIN.undimmedRectsCache or {}

-- TODO: Remove this
function debugSetTutorial(tutorialIndex)
	for _, tutorial in pairs(PLUGIN.tutorials) do
		tutorial.active = false
	end

	PLUGIN.currentTutorial = tutorialIndex
end

local function importantText(text)
	return {
		important = true,
		text = text,
		color = ix.config.Get("color"),
	}
end

function PLUGIN:AddTutorial(order, data)
	data.active = false
	self.tutorials[order] = data

	if (data.ActivateOn) then
		hook.Add(data.ActivateOn, "expTutorial" .. order, function(...)
			local delay = data.ActivateOnDelay or 0
			local args = { ... }

			if (not data.active and (order == 1 or self.currentTutorial == order - 1)) then
				self:HideCurrentTutorial()
			end

			timer.Simple(delay, function()
				if (not data.active and (order == 1 or self.currentTutorial == order - 1)) then
					self:SetCurrentTutorial(order, unpack(args))
				end
			end)
		end)
	end

	return order
end

function PLUGIN:GetCurrentTutorial()
	return self.tutorials[self.currentTutorial]
end

function PLUGIN:HideCurrentTutorial()
	local id = self.currentTutorial

	if (not self.tutorials[id] or self.tutorials[id].active == false) then
		return
	end

	self.tutorials[id].active = false
	self.currentFade = 0

	if (self.tutorials[id].OnDeactivate) then
		self.tutorials[id]:OnDeactivate()
	end
end

function PLUGIN:SetCurrentTutorial(id, ...)
	self:HideCurrentTutorial()

	self.currentTutorial = id

	if (not self.tutorials[id]) then
		return
	end

	self.tutorials[id].active = true

	if (self.tutorials[id].OnActivate) then
		self.tutorials[id]:OnActivate(...)
	end
end

function PLUGIN:NextTutorial(...)
	self:SetCurrentTutorial(self.currentTutorial + 1, ...)
end

--- Draws dimmed rectangles everywhere except for the specified rectangle.
--- Useful to draw attention to a specific area.
---@param x number
---@param y number
---@param w number
---@param h number
---@param a number
function PLUGIN:DrawUndimmedRect(x, y, w, h, a)
	local scrW, scrH = ScrW(), ScrH()

	surface.SetDrawColor(0, 0, 0, a)
	surface.DrawRect(0, 0, scrW, y)
	surface.DrawRect(0, y, x, h)
	surface.DrawRect(x + w, y, scrW - x - w, h)
	surface.DrawRect(0, y + h, scrW, scrH - y - h)

	surface.SetDrawColor(255, 255, 255, a)
	surface.DrawOutlinedRect(x, y, w, h)
end

--- Finds all rectangles that cover the given area, without overlapping the given rectangles.
---@param rects table
---@param areaWidth number
---@param areaHeight number
---@return table
function PLUGIN:GetCoveringRects(rects, areaWidth, areaHeight)
	local coveringRects = {}
    local covered = {}
    for i = 1, areaWidth do
        covered[i] = {}
        for j = 1, areaHeight do
            covered[i][j] = false
        end
    end

    -- Mark the rectangles in 'rects' as covered
    for _, rect in ipairs(rects) do
        for x = rect.x, math.min(rect.x + rect.width - 1, areaWidth) do
            for y = rect.y, math.min(rect.y + rect.height - 1, areaHeight) do
                covered[x][y] = true
            end
        end
    end

    -- Find uncovered areas and cover them with new rectangles
    for x = 1, areaWidth do
        for y = 1, areaHeight do
            if not covered[x][y] then
                local maxWidth = 0
                -- Determine maxWidth where all cells are uncovered
                repeat
                    maxWidth = maxWidth + 1
                until x + maxWidth > areaWidth or covered[x + maxWidth][y]

                local maxHeight = 0
                local valid = true
                -- Determine maxHeight for the current maxWidth
                repeat
                    maxHeight = maxHeight + 1
                    for testX = x, x + maxWidth - 1 do
                        if y + maxHeight > areaHeight or covered[testX][y + maxHeight] then
                            valid = false
                            break
                        end
                    end
                until not valid or y + maxHeight > areaHeight

                -- Add the new rectangle
                table.insert(coveringRects, {x = x, y = y, width = maxWidth, height = maxHeight})

                -- Mark the new rectangle as covered
                for coverX = x, x + maxWidth - 1 do
                    for coverY = y, y + maxHeight - 1 do
                        covered[coverX][coverY] = true
                    end
                end
            end
        end
    end

    return coveringRects
end

--- Draws dimmed rectangles everywhere except for the specified rectangles.
--- Useful to draw attention to multiple areas.
---@param rects table
---@param a number
---@param cacheKey string
function PLUGIN:DrawUndimmedRects(rects, a, cacheKey)
	local coveringRects = PLUGIN.undimmedRectsCache[cacheKey]

	if (not coveringRects) then
		coveringRects = self:GetCoveringRects(rects, ScrW(), ScrH())
		PLUGIN.undimmedRectsCache[cacheKey] = coveringRects
	end

	surface.SetDrawColor(0, 0, 0, a)

	for _, rect in ipairs(coveringRects) do
		local x, y, w, h = rect.x, rect.y, rect.width, rect.height

		surface.DrawRect(x, y, w, h)
	end

	surface.SetDrawColor(255, 255, 255, a)

	for _, rect in ipairs(rects) do
		local x, y, w, h = rect.x, rect.y, rect.width, rect.height

		surface.DrawOutlinedRect(x, y, w, h)
	end
end

local lastOrder = PLUGIN:AddTutorial(1, {
	ActivateOn = "CharacterLoaded",
	ActivateOnDelay = 0.5,

	GetText = function(tutorial)
		return {
			"Welcome! Let's go through the basics.",
			"You get to choose where you spawn.",
			importantText("Click any safe spawn point to continue."),
		}
	end,

	DrawFocusAreas = function(tutorial, scrW, scrH, alpha)
		if (not IsValid(ix.gui.spawnSelection)) then
			return
		end

		local x, y = ix.gui.spawnSelection:LocalToScreen(0, 0)
		local w, h = ix.gui.spawnSelection:GetSize()

		PLUGIN:DrawUndimmedRect(x, y, w, h, alpha)
	end,
})

lastOrder = PLUGIN:AddTutorial(lastOrder + 1, {
	ActivateOn = "OnSpawnSelectSuccess",
	ActivateOnDelay = 2,

	GetText = function(tutorial)
		local menuKey = Schema.util.LookupBinding("+showscores") or "TAB"

		return {
			"Great! You've spawned in safely.",
			"Let's check how you're doing.",
			importantText("Press " .. menuKey .. " once to open the main menu."),
		}
	end,
})

lastOrder = PLUGIN:AddTutorial(lastOrder + 1, {
	ActivateOn = "OnMainMenuCreated",

	OnActivate = function(tutorial, menuPanel)
		local youButton

		for k, tabButton in pairs(menuPanel.tabs.buttons) do
			if (tabButton.name ~= "you") then
				continue
			end

			youButton = tabButton
			break
		end

		tutorial.youButton = youButton
		tutorial.menuPanel = menuPanel
	end,

	DrawFocusAreas = function(tutorial, scrW, scrH, alpha)
		if (not IsValid(tutorial.menuPanel) or tutorial.menuPanel.bClosing) then
			return
		end

		local x, y = tutorial.youButton:LocalToScreen(0, 0)
		local w, h = tutorial.youButton:GetSize()

		if (tutorial.youButton:GetSelected()) then
			PLUGIN:NextTutorial()
			return
		end

		PLUGIN:DrawUndimmedRect(x, y, w, h, alpha)
	end,

	GetText = function(tutorial)
		if (not IsValid(tutorial.menuPanel) or tutorial.menuPanel.bClosing) then
			local menuKey = Schema.util.LookupBinding("+showscores") or "TAB"

			return {
				importantText("Press " .. menuKey .. " once to open the main menu."),
			}
		end

		local x, y = tutorial.youButton:LocalToScreen(0, 0)
		local w, h = tutorial.youButton:GetSize()

		return importantText("Click on the 'You' tab to continue."), x + w + 8, y + (h * .5), TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER
	end,
})

lastOrder = PLUGIN:AddTutorial(lastOrder + 1, {
	ActivateOn = "CreateCharacterBuffInfo",

	OnActivate = function(tutorial, menuPanel, buffsPanel)
		tutorial.buffsPanel = buffsPanel
	end,

	DrawFocusAreas = function(tutorial, scrW, scrH, alpha)
		local menuPanel = ix.gui.menu

		if (not IsValid(menuPanel) or not IsValid(menuPanel.tabs) or menuPanel.bClosing) then
			return
		end

		local inventoryButton = tutorial.inventoryButton

		if (not IsValid(inventoryButton)) then
			for k, tabButton in pairs(menuPanel.tabs.buttons) do
				if (tabButton.name ~= "inv") then
					continue
				end

				inventoryButton = tabButton
				break
			end
		end

		tutorial.inventoryButton = inventoryButton

		if (IsValid(inventoryButton) and inventoryButton:GetSelected()) then
			local tabs = inventoryButton:GetParent()
			local buttons = tabs:GetParent()
			local menu = buttons:GetParent()
			PLUGIN:NextTutorial(menu)
			return
		end

		if (not IsValid(tutorial.buffsPanel)) then
			return
		end

		local x, y = tutorial.buffsPanel:LocalToScreen(0, 0)
		local w, h = tutorial.buffsPanel:GetSize()

		local inventoryX, inventoryY = inventoryButton:LocalToScreen(0, 0)
		local inventoryW, inventoryH = inventoryButton:GetSize()

		-- PLUGIN:DrawUndimmedRect(x, y, w, h, alpha)
		PLUGIN:DrawUndimmedRects({
			{
				x = x,
				y = y,
				width = w,
				height = h,
			},
			{
				x = inventoryX,
				y = inventoryY,
				width = inventoryW,
				height = inventoryH,
			},
		}, alpha, scrW .. scrH)
	end,

	GetText = function(tutorial)
		if (not IsValid(tutorial.buffsPanel)) then
			local menuKey = Schema.util.LookupBinding("+showscores") or "TAB"

			return {
				importantText("Press " .. menuKey .. " once to open the main menu."),
				importantText("Go to the 'You' tab to continue."),
			}
		end

		local x, y = tutorial.buffsPanel:LocalToScreen(0, 0)
		local w, h = tutorial.buffsPanel:GetSize()

		if (IsValid(tutorial.inventoryButton)) then
			local inventoryX, inventoryY = tutorial.inventoryButton:LocalToScreen(0, 0)
			local inventoryW, inventoryH = tutorial.inventoryButton:GetSize()

			y = math.max(inventoryY, y)
			x = (inventoryX + inventoryW + x) * .5
		end

		return {
			"Here you can see your buffs.",
			"Hovering over a buff will show more information.",
			importantText("Hover over your buffs to view what they do."),
			importantText("Next, click on the inventory tab to continue."),
		}, x, y, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM
	end,
})

lastOrder = PLUGIN:AddTutorial(lastOrder + 1, {
	ActivateOn = "OnMainMenuCreated",

	OnActivate = function(tutorial, menuPanel)
		local inventoryButton

		for k, tabButton in pairs(menuPanel.tabs.buttons) do
			if (tabButton.name ~= "inv") then
				continue
			end

			inventoryButton = tabButton
			break
		end

		tutorial.inventoryButton = inventoryButton
		tutorial.menuPanel = menuPanel
	end,

	DrawFocusAreas = function(tutorial, scrW, scrH, alpha)
		if (not IsValid(tutorial.menuPanel) or tutorial.menuPanel.bClosing) then
			return
		end

		local x, y = tutorial.inventoryButton:LocalToScreen(0, 0)
		local w, h = tutorial.inventoryButton:GetSize()

		if (tutorial.inventoryButton:GetSelected()) then
			PLUGIN:NextTutorial()
			return
		end

		PLUGIN:DrawUndimmedRect(x, y, w, h, alpha)
	end,

	GetText = function(tutorial)
		if (not IsValid(tutorial.menuPanel) or tutorial.menuPanel.bClosing) then
			local menuKey = Schema.util.LookupBinding("+showscores") or "TAB"

			return {
				importantText("Press " .. menuKey .. " once to open the main menu."),
			}
		end

		local x, y = tutorial.inventoryButton:LocalToScreen(0, 0)
		local w, h = tutorial.inventoryButton:GetSize()

		return importantText("Click on the inventory tab to continue."), x + w + 8, y + (h * .5), TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER
	end,
})

lastOrder = PLUGIN:AddTutorial(lastOrder + 1, {
	DrawFocusAreas = function(tutorial, scrW, scrH, alpha)
		if (not IsValid(ix.gui.inv1)) then
			return
		end

		local x, y = ix.gui.inv1:LocalToScreen(0, 0)
		local w, h = ix.gui.inv1:GetSize()

		PLUGIN:DrawUndimmedRect(x, y, w, h, alpha)
	end,

	GetText = function(tutorial)
		if (not IsValid(ix.gui.inv1)) then
			local menuKey = Schema.util.LookupBinding("+showscores") or "TAB"

			return {
				importantText("Press " .. menuKey .. " once to open the main menu and continue."),
			}
		end

		local x, y = ix.gui.inv1:LocalToScreen(0, 0)
		local w, h = ix.gui.inv1:GetSize()

		return {
			"Here you can see your inventory.",
			"You can drag items around to organize them.",
			"Hovering over an item will show more information.",
			importantText("Now, first right-click the piece of paper,"),
			importantText("then select 'Read' to continue."),
		}, x, y + h, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
	end,
})

lastOrder = PLUGIN:AddTutorial(lastOrder + 1, {
	ActivateOn = "OnPlayerItemRead",

	OnActivate = function(tutorial, item, frame)
		tutorial.item = item
	end,

	Skippable = true,

	GetText = function(tutorial)
		if (tutorial.item.uniqueID ~= "tutorial") then
			return {
				"That's not the right item.",
				importantText("Right click the piece of paper and select 'Read'."),
			}
		end

		return {
			"This should help you get started.",
			"Good luck!",
		}, ScrW() * .5, ScrH() * .5
	end,

	OnDeactivate = function()
		-- After the last one, we are done and disable the tutorial.
		ix.option.Set("showTutorial", false)
	end,
})

function PLUGIN:DrawOverlay()
	local showTutorial = ix.option.Get("showTutorial", true)

	if (not showTutorial) then
		return
	end

	local currentTutorial = self:GetCurrentTutorial()

	if (not currentTutorial) then
		return
	end

	if (not currentTutorial.active) then
		return
	end

	self.currentFade = math.Approach(self.currentFade, 1, FrameTime())
	local scrW, scrH = ScrW(), ScrH()

	if (currentTutorial.DrawFocusAreas) then
		currentTutorial:DrawFocusAreas(scrW, scrH, self.currentFade * 200)
	else
		surface.SetDrawColor(0, 0, 0, self.currentFade * 200)
		surface.DrawRect(0, 0, scrW, scrH)
	end

	local text, textX, textY, textAlignX, textAlignY

	if (currentTutorial.GetText) then
		text, textX, textY, textAlignX, textAlignY = currentTutorial:GetText()
	end

	text = text or currentTutorial.text
	textX = textX or scrW * .5
	textY = textY or scrH * .5
	textAlignX = textAlignX or TEXT_ALIGN_CENTER
	textAlignY = textAlignY or TEXT_ALIGN_CENTER

	if (isstring(text) or text.important) then
		text = { text }
	end

	for i = 1, #text do
		local line = textAlignY == TEXT_ALIGN_BOTTOM and text[#text - i + 1] or text[i]
		local yOffset = textAlignY == TEXT_ALIGN_BOTTOM and -1 or 1
		local color = color_white

		if (istable(line)) then
			if (line.color) then
				color = line.color
			end

			line = line.text
		end

		color = Color(color.r, color.g, color.b, self.currentFade * 255)

		draw.SimpleTextOutlined(line, "ixMediumFont", textX, textY + (i - 1) * 20 * yOffset, color, textAlignX,
			textAlignY, 1, color_black)
	end

	if (not currentTutorial.Skippable) then
		return
	end

	local skipX, skipY = textX, textY + (#text + 1) * 20
	local textWidth, textHeight = Schema.GetCachedTextSize("ixMediumFont", "Close")
	local buttonWidth = math.max(textWidth + 8, 200)

	local cursorX, cursorY = input.GetCursorPos()
	local color = ix.config.Get("color")

	if (cursorX >= skipX - buttonWidth * .5 and cursorX <= skipX + buttonWidth * .5 and
			cursorY >= skipY - textHeight * .5 - 4 and cursorY <= skipY + textHeight * .5 + 4) then
		if (input.IsMouseDown(MOUSE_LEFT)) then
			self:NextTutorial()
			return
		end

		color = Color(255, 255, 255, 255)
	end

	surface.SetDrawColor(color.r, color.g, color.b, self.currentFade * 255)

	surface.DrawRect(
		skipX - buttonWidth * .5,
		skipY - textHeight * .5 - 4,
		buttonWidth,
		textHeight + 8
	)

	draw.SimpleText(
		"Close", "ixMediumFont",
		skipX, skipY,
		color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
	)
end
