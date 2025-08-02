local PLUGIN = PLUGIN

PLUGIN.name = "External Moderation"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Sends (voice) chat messages to an external moderation system."

ix.util.Include("sv_plugin.lua")

ix.chat.Register("sanction", {
	CanSay = function(self, speaker, text)
		return ! IsValid(speaker)
	end,
	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		local icon = ix.util.GetMaterial("icon16/exclamation.png")
		chat.AddText(icon, Color(255, 150, 150, 255), text)
	end,
	noSpaceAfter = true
})

if (not SERVER) then
	return
end

function PLUGIN:PlayerDataRemoved(client, steamID)
	-- TODO: Send the API a request to anonymize the player's data
end
