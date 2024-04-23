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
		local target = ents.Create("info_target")

		target:SetName( tostring(target) )
		target:SetPos(origin)
		target:Spawn()

		entity:Fire("OpenAwayFrom", tostring(target))

		timer.Simple(1, function()
			if ( IsValid(target) ) then
				target:Remove()
			end
		end)
	else
		entity:Fire("Open")
	end

	if (not noSound) then
		sound.Play("physics/wood/wood_plank_break3.wav", entity:GetPos())
	end
end
