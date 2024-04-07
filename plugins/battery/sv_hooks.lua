local PLUGIN = PLUGIN

function PLUGIN:PlayerTick(client, moveData)
    if (self.nextBatteryCheck and CurTime() < self.nextBatteryCheck) then
        return
    end

	self.nextBatteryCheck = CurTime() + 1

    local character = client:GetCharacter()

    if (not character) then
        return
    end

	local usingThermal = client:HasThermalActivated()
	local usingStealth = client:HasStealthActivated()
	local usingImplant = usingThermal or usingStealth

    if (not usingImplant or client:GetMoveType() == MOVETYPE_NOCLIP) then
        character:SetData("battery", math.Clamp(character:GetData("battery", 0) + self.batteryRegeneration, 0, PLUGIN.batteryMax))
        client:CheckImplants()
        return
    end

	local isMoving = client:GetVelocity():Length() > 1
	local decrease = 0

	local decreaseFunc = function(decrease)
		return decrease + (client:IsRunning() and self.batteryDecrement.running or (isMoving and self.batteryDecrement.active or self.batteryDecrement.passive))
	end

	if(usingThermal)then
		decrease = decreaseFunc(decrease)
	end

	if(usingStealth)then
		decrease = decreaseFunc(decrease)
	end

	character:SetData("battery", math.Clamp(character:GetData("battery", 0) - decrease, 0, PLUGIN.batteryMax))
	client:CheckImplants()
end
