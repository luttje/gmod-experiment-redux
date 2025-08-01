local PLUGIN = PLUGIN

function PLUGIN:NetworkEntityCreated(entity)
	self:HandleMonitorEntityEnteringPVS(entity)
end

-- Draw location to locker with anti-virus (if this player has a locker rot event)
function PLUGIN:HUDPaint()
	self:DrawLockerRotAntiVirusIfNeeded()
end

function PLUGIN:PaintOverItemIcon(itemIcon, itemTable, width, height)
	if (not itemTable:GetData("lockerRot")) then
		return
	end

	self:PaintLockerRotOverItemIcon(itemIcon, itemTable, width, height)
end

function PLUGIN:PostDrawTranslucentRenderables(isDrawingDepth, isDrawingSkybox)
	if (isDrawingSkybox or isDrawingDepth) then return end

	local monitorEntities = ents.FindByClass("exp_monitor")

	for _, monitor in pairs(monitorEntities) do
		if (not monitor:GetPoweredOn() or monitor:IsDormant()) then
			continue
		end

		self:SetupMonitorDrawing(monitor)
	end
end

function PLUGIN:OnStoragePanelSetup(panel, storageInventoryPanel, localInventoryPanel)
	local storageInventory = ix.item.inventories[storageInventoryPanel.invID]
	local anyHasLockerRot = false

	for _, item in pairs(storageInventory:GetItems()) do
		if (item:GetData("lockerRot")) then
			anyHasLockerRot = true
			break
		end
	end

	if (not anyHasLockerRot) then
		return
	end

	local lockerRotInfo = panel:Add("DPanel")
	lockerRotInfo:SetWide(storageInventoryPanel:GetWide() + localInventoryPanel:GetWide())
	lockerRotInfo:SetPaintBackground(false)
	lockerRotInfo.Paint = function(this, w, h)
		local color = ix.config.Get("color")

		surface.SetDrawColor(ColorAlpha(color, 50))
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(color)
		surface.DrawOutlinedRect(0, 0, w, h, 2)
	end

	local symbol = lockerRotInfo:Add("DPanel")
	symbol:Dock(LEFT)
	symbol:SetPaintBackground(false)
	symbol:SetSize(64 + 16, 80 + 16)
	symbol.Paint = function(this, w, h)
		local smallestSize = math.min(w, h)
		local padding = 8
		smallestSize = smallestSize - (padding * 2)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(PLUGIN.lockerRotSymbol)
		surface.DrawTexturedRect(
			padding,
			(h * 0.5) - (smallestSize * 0.5),
			smallestSize, smallestSize
		)
	end

	local explanation = lockerRotInfo:Add("DPanel")
	explanation:DockPadding(8, 8, 8, 8)
	explanation:Dock(FILL)
	explanation:SetPaintBackground(false)

	local explanationHeading = explanation:Add("DLabel")
	explanationHeading:Dock(TOP)
	explanationHeading:SetText("Some items in this locker are at risk of being lost!")
	explanationHeading:SetFont("ixSmallTitleFont")
	explanationHeading:SetWrap(true)
	explanationHeading:SetAutoStretchVertical(true)
	explanationHeading:SetTextColor(ColorAlpha(color_white, 150))

	local explanationText = explanation:Add("DLabel")
	explanationText:Dock(FILL)
	explanationText:SetText(
		"The 'Locker Rot Virus' will destroy items in this locker infected by it. "
		.. "You can prevent this by taking the items out of the locker and bringing them to the locker with the anti-virus."
	)
	explanationText:SetFont("ixSmallFont")
	explanationText:SetTextColor(color_white)
	explanationText:SetWrap(true)
	explanationText:SetAutoStretchVertical(true)

	lockerRotInfo:SizeToChildren(false, true)
	lockerRotInfo:SetX(storageInventoryPanel:GetX())
	lockerRotInfo:SetY(storageInventoryPanel:GetY() - lockerRotInfo:GetTall() - 16)
end

-- Draw location to locker with anti-virus (if this player has a locker rot event)
function PLUGIN:DrawLockerRotAntiVirusIfNeeded()
	local client = LocalPlayer()

	if (not IsValid(client)) then
		return
	end

	local lockerRotAntiVirusRevealTime = client:GetCharacterNetVar("lockerRotAntiVirusRevealTime")

	if (lockerRotAntiVirusRevealTime and lockerRotAntiVirusRevealTime > CurTime()) then
		local timeRemaining = lockerRotAntiVirusRevealTime - CurTime()

		local y = Schema.draw.DrawLabeledValue(
			"Time until locker with anti-virus is revealed to you:",
			string.NiceTime(math.max(1, math.ceil(timeRemaining)))
		)

		draw.SimpleTextOutlined(
			"Your name is known! Run, hide, or fight until the anti-virus locker is revealed.",
			"ixSmallTitleFont",
			ScrW() * 0.5,
			y,
			Color(255, 60, 56),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER,
			1,
			Color(0, 0, 0)
		)
	end

	local lockerRotAntiVirusPosition = client:GetCharacterNetVar("lockerRotAntiVirusPosition")
	local lockerRotAntiVirusTime = client:GetCharacterNetVar("lockerRotAntiVirusTime")

	if (not lockerRotAntiVirusPosition or not lockerRotAntiVirusTime) then
		return
	end

	-- Draw the symbol to the position of the locker
	local position = lockerRotAntiVirusPosition:ToScreen()

	if (position.visible) then
		local size = 64
		local x, y = position.x - size * 0.5, position.y - size * 0.5
		local alpha = 255 * math.abs(math.sin(CurTime()))

		surface.SetDrawColor(ColorAlpha(color_white, alpha))
		surface.SetMaterial(self.lockerRotAntiVirusSymbol)
		surface.DrawTexturedRect(x, y, size, size)

		-- Draw the distance in meters to the locker
		local distance = math.Round(LocalPlayer():GetPos():Distance(lockerRotAntiVirusPosition))
		local distanceInMeters = math.ceil(Schema.util.UnitToCentimeters(distance) / 100)
		local distanceText = string.format("%d %s away", distanceInMeters, distanceInMeters == 1 and "meter" or "meters")

		draw.SimpleTextOutlined(
			distanceText,
			"ixSmallTitleFont",
			x + size * 0.5,
			y + size + 5,
			Color(255, 255, 255, alpha),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_TOP,
			1,
			Color(0, 0, 0, alpha)
		)
	end

	-- Draw the time remaining to reach the locker
	local timeRemaining = lockerRotAntiVirusTime - CurTime()
	local y = Schema.draw.DrawLabeledValue(
		"Time to reach locker with anti-virus:",
		string.NiceTime(math.max(1, math.ceil(timeRemaining)))
	)

	draw.SimpleTextOutlined(
		"You are being hunted! The on-screen symbol shows the location of the locker with anti-virus.",
		"ixSmallTitleFont",
		ScrW() * 0.5,
		y,
		Color(255, 60, 56),
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		1,
		Color(0, 0, 0)
	)
end

function PLUGIN:PaintLockerRotOverItemIcon(itemIcon, itemTable, width, height)
	local margin = 16
	local size = math.min(width, height, 64) - margin

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(self.lockerRotIcon)
	surface.DrawTexturedRect((width * .5) - (size * .5), (height * .5) - (size * .5), size, size)
end
