local PLUGIN = PLUGIN

ix.option.Add("showTutorial", ix.type.bool, true, {
	category = "general",
	OnChanged = function(oldValue, newValue)
		if (newValue) then
			PLUGIN.isDisabled = false
			ix.util.Notify("The tutorial will now be shown when you rejoin the server.")
		end
	end,
})

PLUGIN.tutorials = PLUGIN.tutorials or {}

PLUGIN.currentTutorial = PLUGIN.currentTutorial or 0
PLUGIN.currentFade = PLUGIN.currentFade or 0
PLUGIN.undimmedRectsCache = PLUGIN.undimmedRectsCache or {}

-- Let the player skip by holding backspace for 3 seconds.
function PLUGIN:Think()
	if (self.isDisabled) then
		return
	end

	if (not self.skipButtonDownAt and input.IsKeyDown(KEY_BACKSPACE)) then
		self.skipButtonDownAt = CurTime()
	elseif (self.skipButtonDownAt and not input.IsKeyDown(KEY_BACKSPACE)) then
		self.skipButtonDownAt = nil
	elseif (self.skipButtonDownAt and CurTime() - self.skipButtonDownAt >= 3) then
		ix.util.Notify("Tutorial disabled, you can always re-enable it in the settings.")
		self:DisableTutorial()
	end
end

function PLUGIN:DisableTutorial()
	if (self.isDisabled) then
		return
	end

	self.isDisabled = true

	ix.option.Set("showTutorial", false)
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

		Schema.draw.DrawUndimmedRect(x, y, w, h, alpha)
	end,
})

function PLUGIN:FindMenuButton(buttonName)
	local menuPanel = ix.gui.menu

	if (not IsValid(menuPanel) or not IsValid(menuPanel.tabs) or menuPanel.bClosing) then
		return
	end

	for k, tabButton in pairs(menuPanel.tabs.buttons) do
		if (tabButton.name ~= buttonName) then
			continue
		end

		return tabButton
	end
end

lastOrder = PLUGIN:AddTutorial(lastOrder + 1, {
	ActivateOn = "OnSpawnSelectSuccess",
	ActivateOnDelay = 5,

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
		--
	end,

	DrawFocusAreas = function(tutorial, scrW, scrH, alpha)
		local youButton = PLUGIN:FindMenuButton("you")

		if (not youButton or not IsValid(youButton)) then
			return
		end

		tutorial.youButton = youButton

		local x, y = youButton:LocalToScreen(0, 0)
		local w, h = youButton:GetSize()

		if (youButton:GetSelected()) then
			PLUGIN:NextTutorial()
			return
		end

		Schema.draw.DrawUndimmedRect(x, y, w, h, alpha)
	end,

	GetText = function(tutorial)
		local menuPanel = ix.gui.menu

		if (not IsValid(menuPanel) or menuPanel.bClosing) then
			local menuKey = Schema.util.LookupBinding("+showscores") or "TAB"

			return {
				importantText("Press " .. menuKey .. " once to open the main menu."),
			}
		end

		if (not tutorial.youButton or not IsValid(tutorial.youButton)) then
			return
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

		local inventoryButton = PLUGIN:FindMenuButton("inv")

		if (not inventoryButton or not IsValid(inventoryButton)) then
			return
		end

		tutorial.inventoryButton = inventoryButton

		if (inventoryButton:GetSelected()) then
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
		local combinedW, combinedH = w + (x - inventoryX), h + (y - inventoryY)

		Schema.draw.DrawUndimmedRect(
			math.min(x, inventoryX),
			math.min(y, inventoryY),
			combinedW,
			combinedH,
			alpha
		)
	end,

	GetText = function(tutorial)
		if (not IsValid(tutorial.buffsPanel)) then
			local menuKey = Schema.util.LookupBinding("+showscores") or "TAB"

			return {
				importantText("Press " .. menuKey .. " once to open the main menu."),
			}
		end

		local x, y = tutorial.buffsPanel:LocalToScreen(0, 0)
		local w, h = tutorial.buffsPanel:GetSize()
		local combinedW, combinedH = w, h

		if (tutorial.inventoryButton and IsValid(tutorial.inventoryButton)) then
			local inventoryX, inventoryY = tutorial.inventoryButton:LocalToScreen(0, 0)

			combinedW = w + (x - inventoryX)
			combinedH = h + (y - inventoryY)

			x = math.min(x, inventoryX)
			y = math.min(y, inventoryY)
		end

		return {
			"Through nano technology you can be (de)buffed.",
			"Hovering over a buff will show how it affects you.",
			importantText("Hover over a nano buff to view what it does."),
			importantText("Next, click on the inventory tab to continue."),
		}, x + (combinedW * .5), y + combinedH, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP
	end,
})

lastOrder = PLUGIN:AddTutorial(lastOrder + 1, {
	ActivateOn = "OnMainMenuCreated",

	OnActivate = function(tutorial, menuPanel)
		--
	end,

	DrawFocusAreas = function(tutorial, scrW, scrH, alpha)
		local inventoryButton = PLUGIN:FindMenuButton("inv")

		if (not inventoryButton or not IsValid(inventoryButton)) then
			return
		end

		tutorial.inventoryButton = inventoryButton

		local x, y = inventoryButton:LocalToScreen(0, 0)
		local w, h = inventoryButton:GetSize()

		if (inventoryButton:GetSelected()) then
			PLUGIN:NextTutorial()
			return
		end

		Schema.draw.DrawUndimmedRect(x, y, w, h, alpha)
	end,

	GetText = function(tutorial)
		local menuPanel = ix.gui.menu

		if (not IsValid(menuPanel) or menuPanel.bClosing) then
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

		Schema.draw.DrawUndimmedRect(x, y, w, h, alpha)
	end,

	GetText = function(tutorial)
		local menuPanel = ix.gui.menu

		if (not IsValid(menuPanel) or menuPanel.bClosing) then
			local menuKey = Schema.util.LookupBinding("+showscores") or "TAB"

			return {
				importantText("Press " .. menuKey .. " once to open the main menu."),
			}
		end

		if (not IsValid(ix.gui.inv1) or not ix.gui.inv1:IsVisible()) then
			return {
				importantText("Click on the inventory tab to continue."),
			}
		end

		local x, y = ix.gui.inv1:LocalToScreen(0, 0)
		local w, h = ix.gui.inv1:GetSize()

		return {
			"Here you see your inventory. Hover over an item to show more information.",
			"You can drag items around to organize them.",
			importantText("Now, first right-click the piece of paper named 'An Introduction',"),
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
				importantText("Right click the piece of paper named 'An Introduction' then select 'Read'."),
			}
		end

		return {
			"This should help you get started.",
			"Good luck!",
		}, ScrW() * .5, ScrH() * .5
	end,

	OnDeactivate = function()
		-- After the last one, we are done and disable the tutorial.
		PLUGIN:DisableTutorial()
	end,
})

function PLUGIN:DrawOverlay()
	local showTutorial = ix.option.Get("showTutorial")

	if (not showTutorial or self.hasAlreadyNotShown) then
		-- Prevent the tutorial from starting during gameplay (awkward, since it starts from spawn selection).
		self.hasAlreadyNotShown = true
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
		currentTutorial:DrawFocusAreas(scrW, scrH, self.currentFade * 230)
	else
		surface.SetDrawColor(0, 0, 0, self.currentFade * 230)
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

	-- Show disable tutorial hint in bottom right corner.
	local disableTutorialText = "Hold BACKSPACE for 3 seconds to disable tutorial."

	draw.SimpleTextOutlined(disableTutorialText, "expSmallerFont", scrW - 8, scrH - 8, color_white, TEXT_ALIGN_RIGHT,
		TEXT_ALIGN_BOTTOM, 1, color_black)

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
