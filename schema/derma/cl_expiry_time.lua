local PANEL = {}

AccessorFunc(PANEL, "backgroundColor", "BackgroundColor", FORCE_COLOR)
AccessorFunc(PANEL, "textColor", "TextColor", FORCE_COLOR)
AccessorFunc(PANEL, "prefix", "Prefix", FORCE_STRING)
AccessorFunc(PANEL, "timeFormat", "TimeFormat", FORCE_STRING)
AccessorFunc(PANEL, "expiryTime", "ExpiryTime", FORCE_NUMBER)

function PANEL:Init()
	self:SetTall(26)

	self:SetBackgroundColor(Color(50, 50, 50, 200))
	self:SetTextColor(color_white)
	self:SetPrefix("Expires In ")
	self:SetTimeFormat("%02dh %02dm %02ds")
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(self:GetBackgroundColor())
	surface.DrawRect(0, 0, w, h)

	local secondsFromNow = self:GetExpiryTime() and math.ceil(self:GetExpiryTime() - CurTime()) or 0
	local expiryTimeFormatted

	if (secondsFromNow < 0) then
		secondsFromNow = 0
	end

	local expiryTimeData = string.FormattedTime(secondsFromNow)
	expiryTimeFormatted = string.format(
		self:GetTimeFormat(),
		expiryTimeData.h,
		expiryTimeData.m,
		expiryTimeData.s,
		expiryTimeData.ms
	)

	draw.SimpleTextOutlined(
		self:GetPrefix() .. expiryTimeFormatted,
		"ixSmallFont",
		4,
		h * .5,
		color_white,
		TEXT_ALIGN_LEFT,
		TEXT_ALIGN_CENTER,
		1,
		color_black
	)
end

vgui.Register("expExpiryTime", PANEL, "EditablePanel")
