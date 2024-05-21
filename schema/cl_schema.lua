Schema.stunEffects = Schema.stunEffects or {}
Schema.CachedTextSizes = Schema.CachedTextSizes or {}

-- ! Overrides default net message for door to check if the door access is being cleared and the gui should be closed.
net.Receive("ixDoorMenu", function(length)
	if (IsValid(ix.gui.door)) then
		return ix.gui.door:Remove()
	end

    if (length == 0) then
        -- For some reason Helix doesnt send data and I guess we're the only ones who use this ?!
		-- I swear I will eventually make a PR to Helix for all these workarounds I'm having to do.
		return
	end

    local door = net.ReadEntity()
	local access = net.ReadTable()
	local entity = net.ReadEntity()

    if (not IsValid(door)) then
        return
    end

    local doorMenu = hook.Run("GetDoorMenu", door, access, entity)

	if (doorMenu) then
		ix.gui.door = doorMenu
		return
	end

	ix.gui.door = vgui.Create("ixDoorMenu")
	ix.gui.door:SetDoor(door, access, entity)
end)

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
ix.char.vars["name"].OnDisplay = function(self, container, payload)
    local panel = container:Add("ixTextEntry")
	panel:Dock(TOP)
	panel:SetFont("ixMenuButtonHugeFont")
	panel:SetUpdateOnType(true)
	panel.OnValueChange = function(this, text)
		payload:Set("name", text)
	end

    local random = container:Add("DButton")
    random:SetText(L "random")
    random:SetFont("ixMenuButtonFont")
    random:Dock(TOP)
    random:DockMargin(0, 4, 0, 0)
    random.DoClick = function()
        panel:SetValue(Schema.GetRandomName())
    end
end

ix.char.vars["description"].OnDisplay = function(self, container, payload)
	local panel = container:Add("ixTextEntry")
	panel:Dock(TOP)
	panel:SetFont("ixMenuButtonHugeFont")
	panel:SetUpdateOnType(true)
	panel.OnValueChange = function(this, text)
		payload:Set("description", text)
	end

	local random = container:Add("DButton")
	random:SetText(L "random")
	random:SetFont("ixMenuButtonFont")
	random:Dock(TOP)
	random:DockMargin(0, 4, 0, 0)
	random.DoClick = function()
		panel:SetValue(Schema.GetRandomDescription())
	end
end

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
