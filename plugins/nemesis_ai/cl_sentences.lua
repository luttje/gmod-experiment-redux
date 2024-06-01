local PLUGIN = PLUGIN

local audioChannelReferences = {}

-- Keeps a reference of at most 5 audio channels, so they don't get garbage collected
-- This allows the audio to reverb and echo properly
function PLUGIN:AddReferenceToAudioChannel(channel)
	table.insert(audioChannelReferences, channel)

	if (#audioChannelReferences > 5) then
		table.remove(audioChannelReferences, 1)
	end
end

net.Receive("expPlayNemesisAudio", function(length)
	local sentence = net.ReadString()
    local audioUrl = net.ReadString()

	ix.chat.Send(nil, "nemesis_ai", sentence)
	sound.PlayURL(audioUrl, "", function(channel)
        if (IsValid(channel)) then
			PLUGIN:AddReferenceToAudioChannel(channel)

			channel:Play()
		end
	end)
end)

net.Receive("expPlayNemesisSentences", function()
	local sentence = net.ReadString()
    local audioWithPauses = net.ReadTable()

	local function playPart(index)
		local part = audioWithPauses[index]

		if (not part) then
			return
		end

		local duration = part[1]
		local url = part[2]

		sound.PlayURL(url, "", function(channel)
            if (IsValid(channel)) then
				PLUGIN:AddReferenceToAudioChannel(channel)

				channel:Play()

				timer.Simple(duration, function()
					playPart(index + 1)
				end)
			end
		end)
	end

	ix.chat.Send(nil, "nemesis_ai", sentence)
	playPart(1)
end)

-- Draw location to locker with anti-virus (if this player has a locker rot event)
function PLUGIN:DrawLockerRotAntiVirusIfNeeded()
    local client = LocalPlayer()

	if (not IsValid(client)) then
		return
	end

    local lockerRotAntiVirusPosition = client:GetCharacterNetVar("lockerRotAntiVirusPosition")
    local lockerRotAntiVirusTime = client:GetCharacterNetVar("lockerRotAntiVirusTime")

    if (not lockerRotAntiVirusPosition or not lockerRotAntiVirusTime) then
        return
    end

	-- Draw the symbol to the position of the locker
    local position = lockerRotAntiVirusPosition:ToScreen()

	if (position.visible) then
		local size = 32
		local x, y = position.x - size * 0.5, position.y - size * 0.5

		surface.SetDrawColor(ColorAlpha(color_white, 255 * math.abs(math.sin(CurTime()))))
		surface.SetMaterial(self.lockerRotAntiVirusSymbol)
		surface.DrawTexturedRect(x, y, size, size)
	end

	-- Draw the time remaining to reach the locker
	local timeRemaining = lockerRotAntiVirusTime - CurTime()
    Schema.draw.DrawLabeledValue("Time to reach locker with anti-virus:", math.max(1, math.ceil(timeRemaining)))
end

function PLUGIN:PaintLockerRotOverItemIcon(itemIcon, itemTable, width, height)
	local margin = 8
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(self.lockerRotIcon)
	surface.DrawTexturedRect(margin, margin, width - (margin * 2), height - (margin * 2))
end
