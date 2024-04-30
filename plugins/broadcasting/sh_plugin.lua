local PLUGIN = PLUGIN

PLUGIN.name = "Broadcaster"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds a broadcaster entity that can be used to broadcast messages to everyone in the city."

ix.util.Include("sv_hooks.lua")

CHAT_RECOGNIZED = CHAT_RECOGNIZED or {}
CHAT_RECOGNIZED["broadcast"] = true

ix.chat.Register("broadcast", {
	format = "(Broadcast) %s %s",
	GetColor = function(self, speaker, text)
		return  Color(150, 125, 175, 255)
	end,
})
