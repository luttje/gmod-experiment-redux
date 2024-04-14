local PLUGIN = PLUGIN

PLUGIN.name = "Battery"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds battery to limit client movement."

ix.util.Include("sv_meta.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")

PLUGIN.batteryMax = 100
PLUGIN.batteryRegeneration = 1
PLUGIN.batteryDecrement = {
    passive = 0.1,
    active = 1.2,
	running = 2.5,
}

local playerMeta = FindMetaTable("Player")

function playerMeta:HasStealthActivated()
    return self:GetCharacterNetVar("expStealth", false)
end

function playerMeta:HasThermalActivated()
    return self:GetCharacterNetVar("expThermal", false)
end

if (not CLIENT) then
    return
end

PLUGIN.heatwaveMaterial = Material("sprites/heatwave")
PLUGIN.heatwaveMaterial:SetFloat("$refractamount", 0.01)
PLUGIN.shinyMaterial = Material("models/shiny")
