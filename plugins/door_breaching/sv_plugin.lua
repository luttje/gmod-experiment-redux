local PLUGIN = PLUGIN

function PLUGIN:OpenDoor(entity, client, noSound)
	if (not entity:IsDoor()) then
		return
	end

	-- local breachPosition = breach:GetPos()
	-- local velocityAwayFromBreach = entity:GetPos() - breachPosition
	-- entity:BlastDoor(velocityAwayFromBreach)

	local origin = client:GetShootPos()
	entity:Fire("Unlock")

	if (origin and string.lower(entity:GetClass()) == "prop_door_rotating") then
		entity:OpenDoorAwayFrom(origin)
	else
		entity:Fire("Open")
	end

	if (not noSound) then
		sound.Play("physics/wood/wood_plank_break3.wav", entity:GetPos())
	end
end
