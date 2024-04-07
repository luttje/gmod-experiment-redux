if (SERVER) then
	AddCSLuaFile()
end

SWEP.Base = "exp_base_grenade"

SWEP.PrintName = "Tear Gas Grenade"
SWEP.Purpose = "Disperse crowds and break enemy lines with a cloud of irritating gas."
SWEP.ViewModel = "models/weapons/cstrike/c_eq_smokegrenade.mdl"

function SWEP.CreateEffectAtGrenadeEntity(entity, client)
	local entIndex = entity:EntIndex()
	local position = entity:GetPos()

	Schema.grenades.SpawnTearGas(position, entIndex)
	Schema.grenades.SpawnSmoke(position, 1)

	Schema.DecayEntity(entity, 30)
end
