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

-- The commented code above is problematic, because sometimes the audio is still playing when we receive a new audio to play
-- A queue system to play the audio in sequence where we unqueue the next audio to play when the current audio finishes playing
PLUGIN.audioQueue = PLUGIN.audioQueue or {}

function PLUGIN:AddToAudioQueue(sentence, audioUrl, duration)
    table.insert(PLUGIN.audioQueue, {
		duration = duration,
		sentence = sentence,
		audioUrl = audioUrl
	})

	if (#PLUGIN.audioQueue == 1) then
		PLUGIN:PlayNextInAudioQueue()
	end
end

function PLUGIN:PlayNextInAudioQueue()
	local audioData = PLUGIN.audioQueue[1]

	if (not audioData) then
		return
	end

    local audioUrl = audioData.audioUrl
    local duration = audioData.duration

	sound.PlayURL(audioUrl, "", function(channel)
		if (IsValid(channel)) then
            PLUGIN:AddReferenceToAudioChannel(channel)

			duration = duration or channel:GetLength()

			channel:Play()

			timer.Simple(duration, function()
				table.remove(PLUGIN.audioQueue, 1)
				PLUGIN:PlayNextInAudioQueue()
			end)
		end
	end)
end

net.Receive("expPlayNemesisAudio", function(length)
	local sentence = net.ReadString()
	local audioUrl = net.ReadString()

    ix.chat.Send(nil, "nemesis_ai", sentence)
	PLUGIN:AddToAudioQueue(sentence, audioUrl)
end)

net.Receive("expPlayNemesisSentences", function()
	local sentence = net.ReadString()
    local audioWithPauses = net.ReadTable()

    for _, part in ipairs(audioWithPauses) do
        local duration = part[1]
        local url = part[2]

        PLUGIN:AddToAudioQueue(sentence, url, duration)
    end

    ix.chat.Send(nil, "nemesis_ai", sentence)
end)

-- Draw location to locker with anti-virus (if this player has a locker rot event)
function PLUGIN:DrawLockerRotAntiVirusIfNeeded()
    local client = LocalPlayer()

    if (not IsValid(client)) then
        return
    end

    local lockerRotAntiVirusRevealTime = client:GetCharacterNetVar("lockerRotAntiVirusRevealTime")

	if (lockerRotAntiVirusRevealTime and lockerRotAntiVirusRevealTime > CurTime()) then
		local timeRemaining = lockerRotAntiVirusRevealTime - CurTime()

		Schema.draw.DrawLabeledValue("Time until locker with anti-virus is revealed to you:", string.NiceTime(math.max(1, math.ceil(timeRemaining))))
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
    Schema.draw.DrawLabeledValue("Time to reach locker with anti-virus:", string.NiceTime(math.max(1, math.ceil(timeRemaining))))
end

function PLUGIN:PaintLockerRotOverItemIcon(itemIcon, itemTable, width, height)
	local margin = 16
    local size = math.min(width, height) - margin

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(self.lockerRotIcon)
	surface.DrawTexturedRect((width * .5) - (size * .5), (height * .5) - (size * .5), size, size)
end
