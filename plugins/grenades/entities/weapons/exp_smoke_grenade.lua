if (SERVER) then
	AddCSLuaFile()
end

SWEP.Base = "exp_base_grenade"

SWEP.PrintName = "Smoke Grenade"
SWEP.Purpose = "Create a thick veil of smoke to conceal movements and strategic positions."
SWEP.ViewModel = "models/weapons/cstrike/c_eq_smokegrenade.mdl"

function SWEP.CreateEffectAtGrenadeEntity(entity, client)
	local position = entity:GetPos()

	Schema.MakeExplosion(position, 2)
	Schema.grenades.SpawnSmoke(position, 2)

	Schema.DecayEntity(entity, 30)
end
