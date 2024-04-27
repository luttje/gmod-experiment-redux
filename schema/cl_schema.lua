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
