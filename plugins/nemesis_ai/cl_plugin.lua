local PLUGIN = PLUGIN

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
