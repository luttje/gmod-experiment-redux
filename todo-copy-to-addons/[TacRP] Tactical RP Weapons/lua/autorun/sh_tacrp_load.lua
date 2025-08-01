AddCSLuaFile()

TacRP = {}

local searchdir = "tacrp/"

for _, v in pairs(file.Find(searchdir .. "shared/*", "LUA")) do
    include(searchdir .. "shared/" .. v)
    AddCSLuaFile(searchdir .. "shared/" .. v)
end

for _, v in pairs(file.Find(searchdir .. "client/*", "LUA")) do
    AddCSLuaFile(searchdir .. "client/" .. v)
    if CLIENT then
        include(searchdir .. "client/" .. v)
    end
end

for _, v in pairs(file.Find(searchdir .. "client/vgui/*", "LUA")) do
    AddCSLuaFile(searchdir .. "client/vgui/" .. v)
    if CLIENT then
        include(searchdir .. "client/vgui/" .. v)
    end
end

if SERVER then
    for _, v in pairs(file.Find(searchdir .. "server/*", "LUA")) do
        include(searchdir .. "server/" .. v)
    end
end