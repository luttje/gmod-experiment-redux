local PLUGIN = PLUGIN

PLUGIN.name = "Belongings"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Fallen players drop their belongings in suitcases."

ix.util.Include("sv_plugin.lua")
ix.util.Include("sv_hooks.lua")

ix.config.Add("belongingsCleanupSeconds", 60 * 15, "How many seconds it takes for belongings to be removed.", nil, {
	data = {min = 0, max = 3600},
	category = "belongings"
})
