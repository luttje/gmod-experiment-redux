local PLUGIN = PLUGIN

PLUGIN.name = "Broadcaster"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds a broadcaster entity that can be used to broadcast messages to everyone in the city."

ix.util.Include("sv_hooks.lua")

ix.chat.Register("broadcast", {
	OnChatAdd = function(self, speaker, text)
		chat.AddText("(Broadcast) ", Color(150, 125, 175, 255), speaker:Name() .. ": " .. text)
	end,
})
