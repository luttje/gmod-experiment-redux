local PLUGIN = PLUGIN

ix.bar.Add(function()
    local client = LocalPlayer()
    local character = IsValid(client) and client:GetCharacter() or nil

	if (not character) then
		return 0
	end

	local battery = character:GetData("battery", 0)

	return battery / PLUGIN.batteryMax
end, Color(182, 255, 0), nil, "battery")

function PLUGIN:ShouldBarDraw(bar)
    if (bar.identifier == "battery") then
		return bar:GetValue() < 1
	end
end

function PLUGIN:ShouldDrawLocalPlayer(client)
    if (client:HasStealthActivated()) then
        return false
    end
end

function PLUGIN:Think()
    -- Without throttling we would force the player to drop noticable frames (about 30 fps for 128 players on my machine)
	-- With this I notice no difference in performance.
    if (Schema.util.Throttle("StealthThink", 0.1)) then
        return
    end

	for _, client in ipairs(player.GetAll()) do
        if (client:HasStealthActivated()) then
			-- We repeat this every think so any new PAC parts are hidden.
			client.expIsHidingPacForStealth = true
			pac.TogglePartDrawing(client, false)
		elseif (client.expIsHidingPacForStealth) then
			client.expIsHidingPacForStealth = nil
			pac.TogglePartDrawing(client, true)
		end
	end
end

function PLUGIN:ShouldPopulateEntityInfo(entity)
	if ((entity:IsPlayer() or entity.IsBot) and entity:HasStealthActivated()) then
		return false
	end
end

function PLUGIN:RenderScreenspaceEffects()
    local client = LocalPlayer()

	if (not IsValid(client)) then
		return
	end

	local stealthCammo = client:HasStealthActivated()
    local thermalVision = client:HasThermalActivated()

	local colorModify = {}
    local modulation = { 1, 1, 1 }

	if (stealthCammo) then
        modulation = { 0, 1, 0 }

        colorModify["$pp_colour_brightness"] = -0.1
        colorModify["$pp_colour_contrast"] = 1
        colorModify["$pp_colour_colour"] = 0.1
        colorModify["$pp_colour_addr"] = 0
        colorModify["$pp_colour_addg"] = 0.1
        colorModify["$pp_colour_addb"] = 0
        colorModify["$pp_colour_mulr"] = 0
        colorModify["$pp_colour_mulg"] = 1
        colorModify["$pp_colour_mulb"] = 0

        render.SetMaterial(self.heatwaveMaterial)
        render.DrawScreenQuad()
	end

    if (thermalVision) then
        modulation = { 1, 0, 0 }

        colorModify["$pp_colour_brightness"] = 0
        colorModify["$pp_colour_contrast"] = 1
        colorModify["$pp_colour_colour"] = 0.1
        colorModify["$pp_colour_addr"] = 0
        colorModify["$pp_colour_addg"] = 0
        colorModify["$pp_colour_addb"] = 0.1
        colorModify["$pp_colour_mulr"] = 25
        colorModify["$pp_colour_mulg"] = 0
        colorModify["$pp_colour_mulb"] = 25
    end

    if (stealthCammo or thermalVision) then
        DrawColorModify(colorModify)
    end

	cam.Start3D(EyePos(), EyeAngles())
    for _, otherClient in ipairs(player.GetAll()) do
        if (otherClient == client and GetViewEntity() == client) then
            continue
        end

		if (otherClient:GetMoveType() == MOVETYPE_NOCLIP) then
			continue
		end

		local material = self.heatwaveMaterial

		if (thermalVision) then
			material = self.shinyMaterial
		elseif (not otherClient:HasStealthActivated() or otherClient:GetVelocity():Length() == 0) then
			continue
		end

		render.SuppressEngineLighting(true)
		render.SetColorModulation(unpack(modulation))

		render.MaterialOverride(material)

		otherClient:DrawModel()

		render.MaterialOverride()

		render.SetColorModulation(1, 1, 1)
		render.SuppressEngineLighting(false)
	end
	cam.End3D()
end
