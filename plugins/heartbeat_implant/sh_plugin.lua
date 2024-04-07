local PLUGIN = PLUGIN

PLUGIN.name = "Heartbeat Implant"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds Heartbeat Implants that allow you to sense the heartbeats of others."

if (not CLIENT) then
	return
end

PLUGIN.heartbeatScanRange = 1024
PLUGIN.heartbeatScanInterval = 3
PLUGIN.heartbeatGradient = Material("gui/gradient_up")
PLUGIN.heartbeatOverlay = Material("effects/combine_binocoverlay")
PLUGIN.heartbeatPoint = Material("sprites/glow04_noz")

function PLUGIN:HasHeartbeatImplantActivated(character)
	local item = character:GetInventory():HasItem("heartbeat_implant", {equip = true})

	return item ~= false
end

function PLUGIN:Tick()
    if (not IsValid(LocalPlayer())) then
        return
    end

	local character = LocalPlayer():GetCharacter()

	if (not character) then
		return
	end

	if (not self:HasHeartbeatImplantActivated(character)) then
		if (IsValid(ix.gui.heartbeatDisplay)) then
			ix.gui.heartbeatDisplay:Remove()
		end

		return
	elseif (not IsValid(ix.gui.heartbeatDisplay)) then
		ix.gui.heartbeatDisplay = vgui.Create("expHeartbeatDisplay")
	end
end
