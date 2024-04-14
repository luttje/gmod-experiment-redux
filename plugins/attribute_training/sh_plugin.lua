local PLUGIN = PLUGIN

PLUGIN.name = "Attribute Training"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Implements several new ways to train attributes."

if (CLIENT) then
	function PLUGIN:HUDPaint()
		local client = LocalPlayer()

		if (not IsValid(client)) then
			return
		end

		local raceStartEntity = client:GetNWEntity("expRaceJoined")

		if (not IsValid(raceStartEntity)) then
			return
		end

		local npc = Schema.npc.Get(raceStartEntity:GetNpcId())

		if (not npc) then
			return
		end

		local raceEntityPosition = raceStartEntity:GetPos()
		local distance = client:GetPos():Distance(raceEntityPosition)

		if (distance < npc.raceStartDistanceLimit) then
			local position = (raceEntityPosition + Vector(0, 0, 52)):ToScreen()
			local limitInMeters = math.floor(Schema.util.UnitToCentimeters(npc.raceStartDistanceLimit) / 100)
			local distanceInMeters = math.ceil(Schema.util.UnitToCentimeters(distance) / 100)

			if (position.visible) then
				local color = distanceInMeters > (limitInMeters * .8) and Color(255, 50, 50) or Color(90, 140, 90)

				draw.SimpleTextOutlined("Stay within " .. limitInMeters .. "m to stay in race.", "ixSmallFont", position.x,
					position.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
				draw.SimpleTextOutlined("Distance: " .. distanceInMeters .. "m", "ixBigFont", position.x, position.y + 8,
					color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
			end
		end
	end
end
