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
