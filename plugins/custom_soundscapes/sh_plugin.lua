local PLUGIN = PLUGIN

PLUGIN.name = "Custom Soundscapes"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Replaces select soundscapes with custom ones."

ix.config.Add("replaceSoundscapes", true,
	"The maximum distance from the ground players can build (in structures on top of structures).")

ix.util.Include("cl_plugin.lua")

function PLUGIN:GetCustomSoundscapes()
	local customSoundscapes = {}

	-- Let Experiment Redux maps adjust custom soundscapes first.
	if (Schema.map) then
		local maps = Schema.map.FindByProperty("mapName", game.GetMap(), true)

		for _, map in ipairs(maps) do
			if (map.AdjustCustomSoundscapes) then
				map:AdjustCustomSoundscapes(customSoundscapes)
			end
		end
	end

	-- This provides which soundscapes to replace and what to replace them with
	-- This function is called once when the map is loaded (SERVER) and everytime a player
	-- walks into the trigger zone of a soundscape (CLIENT). Keep it as fast as possible.
	hook.Run("AdjustCustomSoundscapes", customSoundscapes)

	return customSoundscapes
end

function PLUGIN:GetCustomSoundscapeName(soundscapeKey, ruleIndex)
	return soundscapeKey .. "_" .. ruleIndex
end

function PLUGIN:InitPostEntity()
	if (SERVER) then
		self:ReplaceSoundscapes()
	else
		self:CreateSoundscapeSounds()
	end
end

if (not SERVER) then
	return
end

util.AddNetworkString("expSetCustomSoundscape")

function PLUGIN:PlayerSetSoundscape(client, soundscapeKey, customSoundscapeEntity)
	net.Start("expSetCustomSoundscape")
	net.WriteString(soundscapeKey)
	net.Send(client)
end

function PLUGIN:EntityKeyValue(entity, key, value)
	if (entity:GetClass() ~= "env_soundscape") then
		return
	end

	key = key:lower()

	entity.expSoundscapeInfo = entity.expSoundscapeInfo or {}
	entity.expSoundscapeInfo[key] = value

	-- Since we cannot remove env_soundscape entities (or the player will crash), we'll just disable them.
	-- if (key == "soundscape") then
	-- 	return "" -- This caused errors in the console.
	-- else
	if (key == "radius") then
		return 0
	end
end

-- Replaces all soundscapes with custom ones, if they exist.
function PLUGIN:ReplaceSoundscapes()
	local customSoundscapes = self:GetCustomSoundscapes()
	local soundscapesToReplace = {}

	for _, entity in ipairs(ents.FindByClass("env_soundscape")) do
		if (not entity.expSoundscapeInfo) then
			ix.util.SchemaErrorNoHalt(
				"Entity missing soundscape info: "
				.. tostring(entity) ..
				". I'm convinced this should never happen (if it does and you see this, let the developer know: #pluginCustomSoundscapes01)\n"
			)
			continue
		end

		local soundscape = entity.expSoundscapeInfo.soundscape

		if (customSoundscapes[soundscape]) then
			soundscapesToReplace[#soundscapesToReplace + 1] = {
				entity = entity,
				soundscapeInfo = entity.expSoundscapeInfo,
				soundscapeKey = soundscape,
			}
		end
	end

	for _, data in ipairs(soundscapesToReplace) do
		local entity = ents.Create("exp_custom_soundscape")
		entity:SetPos(data.entity:GetPos())
		entity:SetAngles(data.entity:GetAngles())
		entity:SetReplaceSoundscape(data.soundscapeInfo, data.soundscapeKey)
		entity:Spawn()

		-- Don't remove the env_soundscape entity, that will crash the game as soon as the player gets in range.
		-- data.entity:Remove()
		data.entity:Fire("Disable")
	end
end
