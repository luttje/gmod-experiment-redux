local PLUGIN = PLUGIN

ix.option.Add("showTutorial", ix.type.bool, true, {
	category = "general"
})

PLUGIN.tutorials = PLUGIN.tutorials or {}
PLUGIN.currentTutorial = PLUGIN.currentTutorial or 0
PLUGIN.currentFade = PLUGIN.currentFade or 0

-- TODO: Remove this
function debugSetTutorial(tutorialIndex)
    for _, tutorial in pairs(PLUGIN.tutorials) do
        tutorial.active = false
    end

	PLUGIN.currentTutorial = tutorialIndex
end

local function importantText(text)
    return {
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
			local args = {...}
			self:HideCurrentTutorial()

            timer.Simple(delay, function()
				if (not data.active and order == 1 or self.currentTutorial == order - 1) then
					self:SetCurrentTutorial(order, unpack(args))
				end
			end)
		end)
	end
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

PLUGIN:AddTutorial(1, {
    ActivateOn = "CharacterLoaded",
	ActivateOnDelay = 1,

    GetText = function(tutorial)
		return {
            "Welcome! Let's go through the basics.",
			"You get to choose where you spawn.",
			importantText("Click any safe spawn point to continue."),
		}
    end,

	GetFocusArea = function(tutorial, scrW, scrH)
        if (not IsValid(ix.gui.spawnSelection)) then
            return
        end

		local x, y = ix.gui.spawnSelection:LocalToScreen(0, 0)
        local w, h = ix.gui.spawnSelection:GetSize()

		return x, y, w, h
    end,
})

PLUGIN:AddTutorial(2, {
    ActivateOn = "OnSpawnSelectSuccess",
	ActivateOnDelay = 4,

    GetText = function(tutorial)
        local menuKey = Schema.util.LookupBinding("+showscores") or "TAB"

        return {
			"Great! You've spawned in safely.",
            "Let's head to your inventory to see what you have.",
			importantText("Press " .. menuKey .. " once to open the main menu."),
		}
	end,
})

PLUGIN:AddTutorial(3, {
    ActivateOn = "OnMainMenuCreated",

    OnActivate = function(tutorial, menuPanel)
        local inventoryButton

        for k, tabButton in pairs(menuPanel.tabs.buttons) do
            if (tabButton.name ~= "inv") then
                continue
            end

			-- Note that the next tutorial will progress itself when the tab button becomes active, so this is redundant
            -- if (tabButton:GetSelected()) then
            --     PLUGIN:NextTutorial()
            --     return
            -- end

            inventoryButton = tabButton
        end

		-- If somehow the menu is not in the default tab, we have to explain the player how to get there.
		tutorial.inventoryButton = inventoryButton
    end,

	GetFocusArea = function(tutorial, scrW, scrH)
        if (not IsValid(tutorial.inventoryButton)) then
            return
        end

		local x, y = tutorial.inventoryButton:LocalToScreen(0, 0)
        local w, h = tutorial.inventoryButton:GetSize()

		if (tutorial.inventoryButton:GetSelected()) then
			PLUGIN:NextTutorial()
			return
		end

		return x, y, w, h
    end,

    GetText = function(tutorial)
        if (not IsValid(tutorial.inventoryButton)) then
			local menuKey = Schema.util.LookupBinding("+showscores") or "TAB"

			return {
				importantText("Press " .. menuKey .. " once to open the main menu."),
			}
        end

		local x, y = tutorial.inventoryButton:LocalToScreen(0, 0)
        local w, h = tutorial.inventoryButton:GetSize()

		return importantText("Click on the inventory tab to continue."), x + w + 8, y + (h * .5), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
	end,
})

PLUGIN:AddTutorial(4, {
    GetFocusArea = function(tutorial, scrW, scrH)
        if (not IsValid(ix.gui.inv1)) then
            return
        end

		local x, y = ix.gui.inv1:LocalToScreen(0, 0)
        local w, h = ix.gui.inv1:GetSize()

		return x, y, w, h
    end,

    GetText = function(tutorial)
        if (not IsValid(ix.gui.inv1)) then
			local menuKey = Schema.util.LookupBinding("+showscores") or "TAB"

			return {
                "Press " .. menuKey .. " once to open the main menu.",
				importantText("Click on the inventory tab to continue."),
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

PLUGIN:AddTutorial(5, {
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
end

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

    local scrW, scrH = ScrW(), ScrH()
    local x, y, w, h

    if (currentTutorial.GetFocusArea) then
        x, y, w, h = currentTutorial:GetFocusArea(scrW, scrH)
    end

    x = x or 0
    y = y or 0
    w = w or 0
	h = h or 0

    local text, textX, textY, textAlignX, textAlignY

    if (currentTutorial.GetText) then
        text, textX, textY, textAlignX, textAlignY = currentTutorial:GetText()
    end

    text = text or currentTutorial.text
    textX = textX or scrW * .5
    textY = textY or scrH * .5
    textAlignX = textAlignX or TEXT_ALIGN_CENTER
	textAlignY = textAlignY or TEXT_ALIGN_CENTER

	self.currentFade = math.Approach(self.currentFade, 1, FrameTime())
	self:DrawUndimmedRect(x, y, w, h, self.currentFade * 200)

	surface.SetDrawColor(255, 255, 255, self.currentFade * 255)
    surface.DrawOutlinedRect(x, y, w, h)

	if (isstring(text)) then
		text = {text}
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
