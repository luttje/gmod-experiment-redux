local PLUGIN = PLUGIN

PLUGIN.name = "Leaderboards"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds tracking metrics and leaderboards to track player progress."

PLUGIN.currentEpoch = {
    name = "Beta Test Epoch",
    started_at = "2024-06-01",
	ends_at = "2024-06-23",
}

ix.util.Include("sv_plugin.lua")
ix.util.Include("sv_hooks.lua")

--[[
	Although the Leaderboards API and Game Server are currently on the same server, we use an API
	to authenticate, rather than storing data in the database directly. This is to ensure that the
	Leaderboards API could be hosted on a separate server in the future, without needing to change
	any code in the Gameserver.

	The Game Server will store all metrics locally first. Every day (e.g: at midnight), the Game Server
	will synchrnoize all metrics with the Leaderboards API. This is to ensure that the Leaderboards
	API is not overwhelmed with requests, and to ensure that the Game Server can continue to function
	even if the Leaderboards API is down.
--]]
