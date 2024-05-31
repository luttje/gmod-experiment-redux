Schema.stunEffects = Schema.stunEffects or {}
Schema.CachedTextSizes = Schema.CachedTextSizes or {}

-- ! Overrides default net message for the recognition menu, to change the font
local function Recognize(level)
    net.Start("ixRecognize")
    net.WriteUInt(level, 2)
    net.SendToServer()
end

net.Receive("ixRecognizeMenu", function(length)
    local menu = DermaMenu()

	menu:AddOption(L"rgnLookingAt", function()
		Recognize(0)
	end):SetFont("ixMenuButtonFont")
	menu:AddOption(L"rgnWhisper", function()
		Recognize(1)
	end):SetFont("ixMenuButtonFont")
	menu:AddOption(L"rgnTalk", function()
		Recognize(2)
	end):SetFont("ixMenuButtonFont")
	menu:AddOption(L"rgnYell", function()
		Recognize(3)
    end):SetFont("ixMenuButtonFont")

	menu:Open()
	menu:MakePopup()
	menu:Center()
end)

-- ! Overrides the default name and description vars so they display a 'Random' button in the character creation menu.
local characterVarRandomOverrides = {
	["name"] = {
		randomizer = function ()
			return Schema.GetRandomName()
		end
	},
    ["description"] = {
		randomizer = function ()
			return Schema.GetRandomDescription()
		end
	},
}

for varName, characterVarOverride in pairs(characterVarRandomOverrides) do
    local var = ix.char.vars[varName]

    var.OnDisplay = function(self, container, payload)
        local textEntry = container:Add("ixTextEntry")
        textEntry:Dock(TOP)
        textEntry:SetFont("ixMenuButtonHugeFont")
        textEntry:SetUpdateOnType(true)
        textEntry.OnValueChange = function(self, text)
            payload:Set(varName, text)
        end

        local random = textEntry:Add("DImageButton")
        random:SetImage("icon16/arrow_refresh.png")
        random:SetTooltip(L("random"))
        random:Dock(RIGHT)
        random:SetStretchToFit(false)
        random:DockMargin(5, 5, 5, 5)
        random:SizeToContents()
        random.DoClick = function()
            textEntry:SetValue(characterVarOverride.randomizer())
        end

        textEntry:SetValue(characterVarOverride.randomizer())

        return textEntry
    end
end

-- ! Overrides the attributes display so it displays more information about the attributes.
ix.char.vars["attributes"].OnDisplay = function(self, container, payload)
    local maximum = hook.Run("GetDefaultAttributePoints", LocalPlayer(), payload) or 10

    if (maximum < 1) then
        return
    end

	local attributes = container:Add("DPanel")
	attributes:SetPaintBackground(false)
    attributes:Dock(TOP)

    local total = 0

    payload.attributes = {}

    local infoLabel = attributes:Add("DLabel")
	infoLabel:Dock(TOP)
	infoLabel:DockMargin(0, 0, 0, 16)
    infoLabel:SetFont("expSmallerFont")
    infoLabel:SetTextColor(color_white)
    infoLabel:SetWrap(true)
    infoLabel:SetAutoStretchVertical(true)
    infoLabel:SetText(L("attribPointsDesc", maximum))

    -- total spendable attribute points
    local totalBar = attributes:Add("ixAttributeBar")
    totalBar:SetMax(maximum)
    totalBar:SetValue(maximum)
    totalBar:Dock(TOP)
    totalBar:DockMargin(2, 2, 2, 2)
    totalBar:SetText(L("attribPointsLeft"))
    totalBar:SetReadOnly(true)
    totalBar:SetColor(Color(20, 120, 20, 255))

    for attributeKey, attribute in SortedPairsByMemberValue(ix.attributes.list, "name") do
        payload.attributes[attributeKey] = 0

		local bar = attributes:Add("ixAttributeBar")
		bar:SetPaintBackground(false)
        bar:SetMax(maximum)
        bar:Dock(TOP)
        bar:DockMargin(2, 2, 2, 2)
        bar:SetText(L(attribute.name))
		bar.OnChanged = function(this, difference)
			if ((total + difference) > maximum) then
				return false
			end

			total = total + difference
			payload.attributes[attributeKey] = payload.attributes[attributeKey] + difference

			totalBar:SetValue(totalBar.value - difference)
		end

		bar.bar:SetHelixTooltip(function(tooltip)
			local attributeDescription = tooltip:AddRow("description")
			attributeDescription:SetText(attribute.description)
			attributeDescription:SizeToContents()
		end)

        if (attribute.noStartBonus) then
            bar:SetReadOnly()
        end
    end

    local hintLabel = attributes:Add("DLabel")
    hintLabel:Dock(TOP)
	hintLabel:DockMargin(0, 16, 0, 0)
    hintLabel:SetFont("expSmallerFont")
    hintLabel:SetTextColor(ColorAlpha(color_white, 50))
    hintLabel:SetContentAlignment(5)
    hintLabel:SetText(L("attribPointsHint"))

	attributes:InvalidateChildren(true)
	attributes:InvalidateParent(true)
	attributes:InvalidateLayout(true)
	timer.Simple(0, function()
		attributes:SizeToChildren(false, true)
    end)

    return attributes
end

-- ! Overrides ix.menu.Open in helix /libs/sh_menu.lua to ensure options are alphabetically sorted.`
-- ! Additionally it allows for a forceListEnd option to be passed in the options table to ensure the option is displayed at the end of the list.
--- Opens up a context menu for the given entity.
-- @realm client
-- @tparam MenuOptionsStructure options Data describing what options to display
-- @entity[opt] entity Entity to send commands to
-- @treturn boolean Whether or not the menu opened successfully. It will fail when there is already a menu open.
function ix.menu.Open(options, entity)
    if (IsValid(ix.menu.panel)) then
        return false
    end

    local panel = vgui.Create("expEntityMenu")
    panel:SetEntity(entity)

    local listEndOptions = {}

    for text, callbackOrData in SortedPairs(options) do
        local callback = istable(callbackOrData) and callbackOrData.callback or callbackOrData

        if (istable(callbackOrData) and callbackOrData.forceListEnd) then
            listEndOptions[text] = callback
        else
            panel.list:AddOption(text, callback)
        end
    end

    if (table.Count(listEndOptions) > 0) then
        local spacerHeight = 16
        local spacer = panel.list:Add("EditablePanel")
        panel.list.list[#panel.list.list + 1] = spacer

        spacer:Dock(TOP)
        spacer:SetTall(spacerHeight)

        spacer.Paint = function(self, w, h)
            local color = ix.config.Get("color")
            surface.SetDrawColor(color)
            surface.DrawRect(0, spacerHeight * .5, w, 1)
        end

        for text, callback in SortedPairs(listEndOptions) do
            panel.list:AddOption(text, callback)
        end
    end

    panel.list:SizeToContents()
    panel.list:Center()

    return true
end

-- ! Workaround for scaled items not being found by traces
-- Related? https://github.com/Facepunch/garrysmod-issues/issues/5867
local function getScaledObjectRay(client)
	local startPosition = client:GetShootPos()
	local endPosition = startPosition + client:GetAimVector() * 96
	local entities = ents.FindAlongRay(startPosition, endPosition)

	for _, entity in ipairs(entities) do
		if (IsValid(entity) and entity ~= client and entity:GetOwner() ~= client) then
			return entity
		end
	end

	return NULL
end

function Schema:PlayerBindPress(client, bind, pressed)
	bind = bind:lower()

	if (bind:find("use") and pressed) then
		local pickupTime = ix.config.Get("itemPickupTime", 0.5)

		if (pickupTime > 0) then
			local entity = getScaledObjectRay(client)

			if (IsValid(entity) and entity.ShowPlayerInteraction and not ix.menu.IsOpen()) then
				client.ixInteractionTarget = entity
				client.ixInteractionStartTime = SysTime()

				timer.Create("ixItemUse", pickupTime, 1, function()
					client.ixInteractionTarget = nil
					client.ixInteractionStartTime = nil
				end)
			end
		end
	end
end

function ix.hud.DrawItemPickup()
	local pickupTime = ix.config.Get("itemPickupTime", 0.5)

	if (pickupTime == 0) then
		return
	end

	local client = LocalPlayer()
	local entity = client.ixInteractionTarget
	local startTime = client.ixInteractionStartTime

	if (IsValid(entity) and startTime) then
		local sysTime = SysTime()
		local endTime = startTime + pickupTime

		if (sysTime >= endTime or getScaledObjectRay(client) ~= entity) then
			client.ixInteractionTarget = nil
			client.ixInteractionStartTime = nil

			return
		end

		local fraction = math.min((endTime - sysTime) / pickupTime, 1)
		local x, y = ScrW() / 2, ScrH() / 2
		local radius, thickness = 32, 6
		local startAngle = 90
		local endAngle = startAngle + (1 - fraction) * 360
		local color = ColorAlpha(color_white, fraction * 255)

		ix.util.DrawArc(x, y, radius, thickness, startAngle, endAngle, 2, color)
	end
end
-- ! End of workaround for scaled items not being found by traces

function Schema.GetCachedTextSize(font, text)
	Schema.CachedTextSizes[font] = Schema.CachedTextSizes[font] or {}

	if (not Schema.CachedTextSizes[font][text]) then
		surface.SetFont(font)

		Schema.CachedTextSizes[font][text] = { surface.GetTextSize(text) }
	end

	return unpack(Schema.CachedTextSizes[font][text])
end

-- Called once when a new storage panel can have functions injected by the schema.
function Schema.SetupStoragePanel(panel, storageInventoryPanel, localInventoryPanel)
	-- Setup the shortcut for closing the storage panel with the scoreboard key.
	panel.expCloseShortcutOnKeyCodeReleased =
		panel.expCloseShortcutOnKeyCodeReleased
		or panel.OnKeyCodeReleased

    function panel:OnKeyCodeReleased(key)
        local scoreboardBinding = input.LookupBinding("showscores")
        local scoreboardKey = scoreboardBinding and input.GetKeyCode(scoreboardBinding) or KEY_TAB

        if (key == scoreboardKey) then
            self.storageInventory:Close()
        end

        if (self.expCloseShortcutOnKeyCodeReleased) then
            self:expCloseShortcutOnKeyCodeReleased(key)
        end
    end

	Schema.SetupInventorySlots(storageInventoryPanel)

	if (not ix.option.Get("openBags", true)) then
		return
	end

	-- Open bags in the storage panel automatically and lay them out.
	local inventoryPanels = {
		storageInventoryPanel,
		localInventoryPanel,
	}

	for i, inventoryPanel in ipairs(inventoryPanels) do
		local inventory = ix.item.inventories[inventoryPanel.invID]

		local function checkAllBagsSynced()
			for _, item in pairs(inventory:GetItems()) do
				if (not item.isBag) then
					continue
				end

				local index = item:GetData("id", "")
				local bagInventory = ix.item.inventories[index]

				if (not bagInventory or not bagInventory.slots) then
					return false
				end
			end

			return true
		end

		-- Wait a couple of frames for the inventory to be arrive on the client, trying a couple times.
		local retryTimerName = "ixStoragePanelBagsRetry" .. inventoryPanel.invID
		timer.Create(retryTimerName, 0.1, 10, function()
			if (checkAllBagsSynced()) then
				Schema.SetupStoragePanelBags(inventoryPanel, inventory, i == 1)
				timer.Remove(retryTimerName)
			end
		end)
	end
end

function Schema.SetupStoragePanelBags(inventoryPanel, inventory, isStoragePanelBags)
    local bagPanelsToPosition = {}
    local totalBagPanelHeight = 0

    for _, item in pairs(inventory:GetItems()) do
        if (not item.isBag) then
            continue
        end

        item.functions.View.OnClick(item)

        local index = item:GetData("id", "")
        local bagPanel = ix.gui["inv" .. index]

        if (not IsValid(bagPanel)) then
            continue
        end

        bagPanelsToPosition[#bagPanelsToPosition + 1] = bagPanel
        totalBagPanelHeight = totalBagPanelHeight + bagPanel:GetTall()
    end

    if (#bagPanelsToPosition == 0) then
        return
    end

    local screenH = ScrH()
    local parentX, parentY, parentW, parentH = inventoryPanel:GetBounds()
    local padding = 4

    if (totalBagPanelHeight > screenH) then
        local bagHeight = math.floor((screenH - padding * 2) / #bagPanelsToPosition) - 2

        for b, panel in ipairs(bagPanelsToPosition) do
            local bagWidth = panel:GetWide()
            local bagY = padding + (bagHeight + 2) * (b - 1)
            local bagX

            if (isStoragePanelBags) then
                bagX = parentX - bagWidth - padding
            else
                bagX = parentX + parentW + padding
            end

            panel:SetPos(bagX, bagY)
        end
    else
        local bagY = padding + (screenH - totalBagPanelHeight) * .5

        for _, panel in ipairs(bagPanelsToPosition) do
            local bagWidth = panel:GetWide()
            local bagX

            if (isStoragePanelBags) then
                bagX = parentX - bagWidth - padding
            else
                bagX = parentX + parentW + padding
            end

            panel:SetPos(bagX, bagY)

            bagY = bagY + panel:GetTall() + 2
        end
    end
end

-- Sets up inventory slots to allow custom PaintOver from plugins
function Schema.SetupInventorySlots(inventoryPanel)
    inventoryPanel.expOriginalAddIcon = inventoryPanel.expOriginalAddIcon or inventoryPanel.AddIcon

	local function PaintOverOverride(self, width, height)
		local itemTable = self.itemTable

		if (not itemTable) then
			return
		end

		if (hook.Run("PaintOverItemIcon", self, itemTable, width, height)) then
			return
		end

		if (itemTable.PaintOver) then
			itemTable.PaintOver(self, itemTable, width, height)
		end
	end

	-- Setup existing items
	for x, rows in pairs(inventoryPanel.slots) do
        for y, data in pairs(rows) do
            local itemIcon = data.item

			if (not itemIcon) then
				continue
			end

			itemIcon.PaintOver = PaintOverOverride
		end
    end

	function inventoryPanel:AddIcon(model, x, y, w, h, skin)
		local panel = self:expOriginalAddIcon(model, x, y, w, h, skin)

		if (not panel) then
			return
		end

        panel.PaintOver = PaintOverOverride

		return panel
	end
end

net.Receive("expTearGassed", function()
	Schema.tearGassed = CurTime() + 20
end)

net.Receive("expFlashed", function()
	local curTime = CurTime()

	Schema.stunEffects[#Schema.stunEffects + 1] = {
		endAt = curTime + 10,
		duration = 10,
	}
	Schema.flashEffect = {
		endAt = curTime + 20,
		duration = 20,
	}

	surface.PlaySound("hl1/fvox/flatline.wav")
end)

net.Receive("exp_ClearEffects", function()
	Schema.stunEffects = {}
	Schema.flashEffect = nil
	Schema.tearGassed = nil
end)

---@enum SNDLVL
--- Sound plays everywhere
SNDLVL_NONE = 0
--- Rustling leaves
SNDLVL_20dB = 20
--- Whispering
SNDLVL_25dB = 25
--- Library
SNDLVL_30dB = 30
SNDLVL_35dB = 35
SNDLVL_40dB = 40
--- Refrigerator
SNDLVL_45dB = 45
--- Average home
SNDLVL_50dB = 50
SNDLVL_55dB = 55
--- Normal conversation, clothes dryer
SNDLVL_60dB = 60
--- *The same as SNDLVL_60dB*
SNDLVL_IDLE = 60
--- Washing machine, dishwasher
SNDLVL_65dB = 65
SNDLVL_STATIC = 66
--- Car, vacuum cleaner, mixer, electric sewing machine
SNDLVL_70dB = 70
--- Busy traffic
SNDLVL_75dB = 75
--- *The same as SNDLVL_75dB*
SNDLVL_NORM = 75
--- Mini-bike, alarm clock, noisy restaurant, office tabulator, outboard motor, passing snowmobile
SNDLVL_80dB = 80
--- *The same as SNDLVL_80dB*
SNDLVL_TALKING = 80
--- Average factory, electric shaver
SNDLVL_85dB = 85
--- Screaming child, passing motorcycle, convertible ride on freeway
SNDLVL_90dB = 90
SNDLVL_95dB = 95
--- Subway train, diesel truck, woodworking shop, pneumatic drill, boiler shop, jackhammer
SNDLVL_100dB = 100
--- Helicopter, power mower
SNDLVL_105dB = 105
--- Snowmobile (drivers seat), inboard motorboat, sandblasting
SNDLVL_110dB = 110
--- Car horn, propeller aircraft
SNDLVL_120dB = 120
--- Air raid siren
SNDLVL_130dB = 130
--- Threshold of pain, gunshot, jet engine
SNDLVL_140dB = 140
--- *The same as SNDLVL_140dB*
SNDLVL_GUNFIRE = 140
SNDLVL_150dB = 150
--- Rocket launching
SNDLVL_180dB = 180
