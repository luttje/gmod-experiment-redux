local PLUGIN = PLUGIN

PLUGIN.name = "Flashlight"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds flashlights to allow players to see in the dark."

if (not SERVER) then
	return
end

function PLUGIN:PlayerSwitchFlashlight(client, on)
	if (not on) then
		return
	end

    local hasFlashlight = hook.Run("PlayerHasFlashlight", client)

	if (not hasFlashlight) then
		return false
	end
end

function PLUGIN:PlayerSecondElapsed(client)
    if (not client:FlashlightIsOn()) then
        return
    end

    local hasFlashlight = hook.Run("PlayerHasFlashlight", client)

	if (not hasFlashlight) then
		client:Flashlight(false)
	end
end

function PLUGIN:PlayerHasFlashlight(client)
	-- Other plugins can override this hook to check for a flashlight that the player has.
	-- E.g: attached to a weapon.

    local weapon = client:GetActiveWeapon()

	if (not IsValid(weapon)) then
		return
	end

    if (weapon:GetClass() == "exp_flashlight") then
		client:AllowFlashlight(true)
        return true
    end
end
