--[[
	Include our modified version of TacRP.

	This is in libs, such that it is loaded before the plugin's weapons are loaded.
	(See Helix source-code for plugin content load order)
--]]
local PLUGIN = PLUGIN

local searchDirectory = PLUGIN.folder .. "/libs/tacrp/"

for _, v in pairs(file.Find(searchDirectory .. "shared/*", "LUA")) do
	include(searchDirectory .. "shared/" .. v)
	AddCSLuaFile(searchDirectory .. "shared/" .. v)
end

for _, v in pairs(file.Find(searchDirectory .. "client/*", "LUA")) do
	AddCSLuaFile(searchDirectory .. "client/" .. v)
	if CLIENT then
		include(searchDirectory .. "client/" .. v)
	end
end

for _, v in pairs(file.Find(searchDirectory .. "client/vgui/*", "LUA")) do
	AddCSLuaFile(searchDirectory .. "client/vgui/" .. v)
	if CLIENT then
		include(searchDirectory .. "client/vgui/" .. v)
	end
end

if SERVER then
	for _, v in pairs(file.Find(searchDirectory .. "server/*", "LUA")) do
		include(searchDirectory .. "server/" .. v)
	end
end

--[[
	Download assets required for our TacRP modification
--]]
if (SERVER) then
	local downloadContent

	--- Finds all files in the directory matching this path and downloads them to clients.
	--- @param path string The path to search for files
	function downloadContent(path)
		local files, directories = file.Find(path .. "/*", "LUA")

		if (files) then
			for _, fileName in ipairs(files) do
				local filePath = path .. "/" .. fileName

				-- Remove content/ prefix from the file path
				local filePathWithoutContent = filePath:StartsWith("content/")
					and filePath:sub(("content/"):len() + 1)
					or filePath

				ix.util.AddResourceSingleFile(filePathWithoutContent)
			end
		end

		if (directories) then
			for _, dirName in ipairs(directories) do
				downloadContent(path .. "/" .. dirName)
			end
		end
	end

	local contentPath = Schema.folder .. "/content/"

	-- Materials
	downloadContent(contentPath .. "materials/effects")
	downloadContent(contentPath .. "materials/entities")
	downloadContent(contentPath .. "materials/models/tacint")
	downloadContent(contentPath .. "materials/models/tacint_extras")
	downloadContent(contentPath .. "materials/models/tacint_shark")
	downloadContent(contentPath .. "materials/particle")

	-- Models
	downloadContent(contentPath .. "models/weapons/tacint")
	downloadContent(contentPath .. "models/weapons/tacint_extras")
	downloadContent(contentPath .. "models/weapons/tacint_melee")

	-- Particles
	downloadContent(contentPath .. "particles")

	-- Sounds
	downloadContent(contentPath .. "sound/tacint_shark")
	downloadContent(contentPath .. "sound/tacrp")
	downloadContent(contentPath .. "sound/tacrp_extras")
end
