-- sh_plugin.lua
local PLUGIN = PLUGIN

PLUGIN.name = "Cinematics"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Scene-based cinematic system for immersive storytelling."

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("sh_commands.lua")

PLUGIN.scenes = PLUGIN.scenes or {}
PLUGIN.playerScenes = PLUGIN.playerScenes or {}
PLUGIN.registeredScenes = PLUGIN.registeredScenes or {}

PLUGIN.REMOVE_FROM_SCENE_ID = "!REMOVE!"

if (SERVER) then
	util.AddNetworkString("ixCinematicFadeIn")
	util.AddNetworkString("ixCinematicFadeOut")
	util.AddNetworkString("ixCinematicFadeComplete")
	util.AddNetworkString("ixCinematicSetBlackWhite")
	util.AddNetworkString("ixCinematicShowText")
	util.AddNetworkString("ixCinematicEnterScene")
	util.AddNetworkString("ixCinematicLeaveScene")
end

ix.config.Add("cinematicFadeTime", 2, "Duration of fade in/out effects during cinematics.", nil, {
	data = { min = 0.5, max = 10, decimals = 1 },
	category = "cinematics"
})

ix.config.Add("cinematicTextDuration", 5, "Default duration for cinematic text display.", nil, {
	data = { min = 1, max = 30, decimals = 0 },
	category = "cinematics"
})

ix.config.Add("cinematicBlackPeriod", 0.5, "Duration of black screen during cinematic transitions.", nil, {
	data = { min = 0.1, max = 2, decimals = 1 },
	category = "cinematics"
})

function PLUGIN:RegisterScene(sceneID, sceneData)
	if (sceneID == PLUGIN.REMOVE_FROM_SCENE_ID) then
		ix.util.SchemaError("Cannot register scene with reserved ID: " .. PLUGIN.REMOVE_FROM_SCENE_ID)
	end

	self.registeredScenes[sceneID] = sceneData
	sceneData.sceneID = sceneID
end

function PLUGIN:GetScene(sceneID)
	return self.registeredScenes[sceneID]
end

ix.util.IncludeDir(PLUGIN.folder .. "/scenes", true)
