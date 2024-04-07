local PLUGIN = PLUGIN

PLUGIN.name = "Bolt Generation"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Add entities that generate bolts over time."

PLUGIN.boltProtectorRange = 256
PLUGIN.boltInformerWarnInterval = 5

ix.util.Include("sv_hooks.lua")

ix.chat.Register("bolt_informer", {
	OnChatAdd = function(self, speaker, text)
		chat.AddText("(Bolt Informer) ", Color(255, 125, 175, 255), text)
	end,
})
