local PLUGIN = PLUGIN

--- Supporters get a heart icon in OOC chat, except if they're also moderator/operator, admin or superadmin
function PLUGIN:GetPlayerIcon(speaker)
	if (speaker:IsSuperAdmin() or speaker:IsAdmin() or speaker:IsUserGroup("moderator") or speaker:IsUserGroup("operator")) then
		return
	end

	if (speaker:HasPremiumKey("supporter_role")) then
		return "icon16/heart.png"
	end
end

function PLUGIN:CreateStyledButton(parent, text, color, scale)
	local button = vgui.Create("DButton", parent)
	button:SetText("")

	local targetScale = scale or 1.0
	local fontSize = targetScale > 1.2 and "ixBigFont" or (targetScale < 0.9 and "ixSmallFont" or "ixMediumFont")

	button.Paint = function(btn, width, height)
		local backgroundColor = color or PLUGIN.THEME.primary

		if (btn:IsHovered()) then
			backgroundColor = Color(
				math.min(backgroundColor.r + 20, 255),
				math.min(backgroundColor.g + 20, 255),
				math.min(backgroundColor.b + 20, 255),
				backgroundColor.a
			)
		end

		if (btn:IsDown()) then
			backgroundColor = Color(
				math.max(backgroundColor.r - 20, 0),
				math.max(backgroundColor.g - 20, 0),
				math.max(backgroundColor.b - 20, 0),
				backgroundColor.a
			)
		end

		draw.RoundedBox(4, 0, 0, width, height, backgroundColor)

		-- Draw text
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetFont(fontSize)

		local textWidth, textHeight = surface.GetTextSize(text)
		surface.SetTextPos(width * 0.5 - textWidth * 0.5, height * 0.5 - textHeight * 0.5)
		surface.DrawText(text)
	end

	return button
end
