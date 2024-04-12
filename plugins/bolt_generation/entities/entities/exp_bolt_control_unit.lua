if (SERVER) then
    AddCSLuaFile()
end

DEFINE_BASECLASS("exp_generator")

ENT.Type = "anim"
ENT.Base = "exp_generator"
ENT.Model = "models/props_combine/suit_charger001.mdl"
ENT.PrintName = "Bolt Control Unit"
ENT.PhysgunDisabled = true
ENT.IsBoltControlUnit = true
