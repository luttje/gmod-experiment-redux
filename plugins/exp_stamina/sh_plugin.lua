PLUGIN.name = "Experiment Stamina"
PLUGIN.author = "Experiment Redux" -- Based on original system by Chessnut
PLUGIN.description = "Adds a stamina system to limit running."

ix.config.Add("staminaDrain", 2, "How much stamina to drain per tick (every quarter second). This is calculated before attribute reduction.", nil, {
	data = {min = 0, max = 10, decimals = 2},
	category = "attributes"
})

ix.config.Add("staminaRegeneration", 1.75, "How much stamina to regain per tick (every quarter second).", nil, {
	data = {min = 0, max = 10, decimals = 2},
	category = "attributes"
})

ix.config.Add("staminaCrouchRegeneration", 2, "How much stamina to regain per tick (every quarter second) while crouching.", nil, {
	data = {min = 0, max = 10, decimals = 2},
	category = "attributes"
})

ix.config.Add("punchStamina", 10, "How much stamina punches use up.", nil, {
	data = {min = 0, max = 100},
	category = "attributes"
})

local function calcStaminaChange(client)
	local character = client:GetCharacter()

	if (not character or client:GetMoveType() == MOVETYPE_NOCLIP) then
		return 0
	end

	local runSpeed

	if (SERVER) then
		runSpeed = ix.config.Get("runSpeed") + character:GetAttribute("stamina", 0)

		if (client:WaterLevel() > 1) then
			runSpeed = runSpeed * 0.775
		end
	end

	local walkSpeed = ix.config.Get("walkSpeed")
	local maxAttributes = ix.config.Get("maxAttributes", 100)
	local offset

	if (client:KeyDown(IN_SPEED) and client:GetVelocity():LengthSqr() >= (walkSpeed * walkSpeed)) then
        local staminaDrain = ix.config.Get("staminaDrain")
		local maximumTraining = staminaDrain * 0.95

        offset = -staminaDrain
			+ (math.min(character:GetAttribute("endurance", 0), maxAttributes) * maximumTraining / maxAttributes)
	else
		offset = client:Crouching() and ix.config.Get("staminaCrouchRegeneration", 2) or ix.config.Get("staminaRegeneration", 1.75)
	end

	offset = hook.Run("AdjustStaminaOffset", client, offset) or offset

	if (CLIENT) then
		return offset -- For the client we need to return the estimated stamina change
	else
		local current = client:GetLocalVar("stamina", 0)
		local value = math.Clamp(current + offset, 0, 100)

		if (current ~= value) then
			client:SetLocalVar("stamina", value)

			if (value == 0 and not client:GetNetVar("brth", false)) then
				client:SetRunSpeed(walkSpeed)
				client:SetNetVar("brth", true)

				hook.Run("PlayerStaminaLost", client)
			elseif (value >= 50 and client:GetNetVar("brth", false)) then
				local hasGodspeed, godspeedPerkTable = Schema.perk.GetOwned("godspeed", client)

				if (hasGodspeed) then
					runSpeed = runSpeed * godspeedPerkTable.modifyRunSpeed
				end

				client:SetRunSpeed(runSpeed)
				client:SetNetVar("brth", nil)

				hook.Run("PlayerStaminaGained", client)
			end
		end
	end
end

if (SERVER) then
	function PLUGIN:PostPlayerLoadout(client)
		local uniqueID = "expStamina" .. client:SteamID64()

		timer.Create(uniqueID, 0.25, 0, function()
			if (not IsValid(client)) then
				timer.Remove(uniqueID)
				return
			end

			calcStaminaChange(client)
		end)
	end

	function PLUGIN:CharacterPreSave(character)
		local client = character:GetPlayer()

		if (IsValid(client)) then
			character:SetData("stamina", client:GetLocalVar("stamina", 0))
		end
	end

	function PLUGIN:PlayerLoadedCharacter(client, character)
		timer.Simple(0.25, function()
			client:SetLocalVar("stamina", character:GetData("stamina", 100))
		end)
	end

	function PLUGIN:CharacterAttributeUpdated(client, character, attributeKey, value)
		if (attributeKey == "endurance") then
			local requiredAttribute = Schema.achievement.GetProperty("enduring_spirit", "requiredAttribute")

			if (value >= requiredAttribute) then
				Schema.achievement.Progress("enduring_spirit", client)
			end
		end
	end

	-- Note: This is called only for bullet damage a player receives, you should use GM:EntityTakeDamage instead if you need to detect ALL damage.
	function PLUGIN:ScalePlayerDamage(client, hitGroup, damageInfo)
		local character = client:GetCharacter()

		if (not character) then
			return
		end

		-- TODO: Test if this is not too much damage reduction
		local endurance = Schema.GetAttributeFraction(character, "endurance")
		local damageScale = 1.2 - endurance -- Always take at least 20% of the damage

		damageInfo:ScaleDamage(damageScale)
	end

	local playerMeta = FindMetaTable("Player")

	function playerMeta:RestoreStamina(amount)
		local current = self:GetLocalVar("stamina", 0)
		local value = math.Clamp(current + amount, 0, 100)

		self:SetLocalVar("stamina", value)
	end

	function playerMeta:ConsumeStamina(amount)
		local current = self:GetLocalVar("stamina", 0)
		local value = math.Clamp(current - amount, 0, 100)

		self:SetLocalVar("stamina", value)
	end
else
	local predictedStamina = 100

	function PLUGIN:Think()
		local offset = calcStaminaChange(LocalPlayer())
		-- the server check it every 0.25 sec, here we check it every [FrameTime()] seconds
		offset = math.Remap(FrameTime(), 0, 0.25, 0, offset)

		if (offset ~= 0) then
			predictedStamina = math.Clamp(predictedStamina + offset, 0, 100)
		end
	end

	function PLUGIN:OnLocalVarSet(key, var)
		if (key ~= "stamina") then return end
		if (math.abs(predictedStamina - var) > 5) then
			predictedStamina = var
		end
	end

	ix.bar.Add(function()
		return predictedStamina / 100
	end, Color(200, 200, 40), nil, "stamina")
end
