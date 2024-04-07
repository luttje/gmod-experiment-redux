if (SERVER) then
    AddCSLuaFile()
end

SWEP.Base = "exp_base_grenade"

SWEP.PrintName = "Flare Grenade"
SWEP.Purpose = "Ignite the night with a burst of brilliant light to reveal hidden enemies."
SWEP.ViewModel = "models/weapons/cstrike/c_eq_flashbang.mdl"

function SWEP.CreateEffectAtGrenadeEntity(entity, client)
	local position = entity:GetPos()
	local angles = entity:GetAngles()
	local flare = ents.Create("exp_flare")

	Schema.MakeExplosion(position, 1)

	Schema.grenades.SpawnSmoke(position, 0.2)

	-- Remove as the exp_flare entity will handle showing the flare + grenade.
	entity:Remove()

	flare:SetAngles(angles)
	flare:SetPos(position)
	flare:Spawn()
	flare:StartFlare(64 + math.random(0, 32))
end
