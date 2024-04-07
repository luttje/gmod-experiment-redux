if (SERVER) then
	AddCSLuaFile()
end

SWEP.Base = "exp_base_grenade"

SWEP.PrintName = "Flash Grenade"
SWEP.Purpose = "Blind and disorient your foes with a sudden explosion of intense light."
SWEP.ViewModel = "models/weapons/cstrike/c_eq_flashbang.mdl"

function SWEP.CreateEffectAtGrenadeEntity(entity, client)
	local position = entity:GetPos()

	Schema.grenades.SpawnFlash(position)

	if (IsValid(client)) then
        local emitSmoke = Schema.perk.GetOwned(PRK_EXPERIMENTALIST, client)

		if (emitSmoke) then
			Schema.grenades.SpawnSmoke(position, 1)
		end
	end

	entity:Remove()
end
