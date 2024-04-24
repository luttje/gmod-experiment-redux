Schema.stunEffects = Schema.stunEffects or {}
Schema.CachedTextSizes = Schema.CachedTextSizes or {}

function Schema.GetCachedTextSize(font, text)
	Schema.CachedTextSizes[font] = Schema.CachedTextSizes[font] or {}

	if (not Schema.CachedTextSizes[font][text]) then
		surface.SetFont(font)

		Schema.CachedTextSizes[font][text] = { surface.GetTextSize(text) }
	end

	return unpack(Schema.CachedTextSizes[font][text])
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
