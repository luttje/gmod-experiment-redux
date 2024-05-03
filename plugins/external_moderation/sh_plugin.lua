local PLUGIN = PLUGIN

PLUGIN.name = "External Moderation"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Sends (voice) chat messages to an external moderation system."

ix.util.Include("sv_plugin.lua")

if (not SERVER) then
    return
end

function PLUGIN:PlayerDataRemoved(client, steamID)
	-- TODO: Send the API a request to anonymize the player's data
end
