local PANEL = {}

function PANEL:Init()
	self:Dock(FILL)

	-- Create HTML panel
	self.htmlPanel = self:Add("DHTML")
	self.htmlPanel:Dock(FILL)

	-- Get the URL from network variable
	local baseUrl = GetNetVar("leaderboards.app_url")

	if (not baseUrl) then
		ix.util.SchemaErrorNoHalt("Leaderboards app URL not set...")
		return
	end

	self.htmlPanel:OpenURL(baseUrl .. "?in-game=true")
end

vgui.Register("expLeaderboardMenu", PANEL, "EditablePanel")

-- Register the leaderboard menu button
hook.Add("CreateMenuButtons", "expLeaderboardMenu", function(tabs)
	tabs["leaderboards"] = function(container)
		container:Add("expLeaderboardMenu")
	end
end)
