local PLUGIN = PLUGIN

function PLUGIN:OpenDoor(entity, client, noSound)
	if (not entity:IsDoor()) then
		return
	end

	local origin = client:GetShootPos() - (client:GetAimVector() * 5)
    entity:Fire("Unlock")

	if (origin and string.lower(entity:GetClass()) == "prop_door_rotating") then
		entity:OpenDoorAwayFrom(origin, nil, true)
	else
		entity:Fire("Open")
	end

	if (not noSound) then
		sound.Play("physics/wood/wood_plank_break3.wav", entity:GetPos())
	end
end
