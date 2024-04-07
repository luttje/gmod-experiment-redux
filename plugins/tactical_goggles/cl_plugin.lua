local PLUGIN = PLUGIN

PLUGIN.tacticalOverlay = Material("effects/combine_binocoverlay")
PLUGIN.randomDisplayLines = {
	"Transmitting physical transition vector...",
	"Parsing view ports and data arrays...",
	"Updating biosignal co-ordinates...",
	"Pinging connection to network...",
	"Synchronizing locational data...",
	"Translating radio messages...",
	"Emptying outgoing pipes...",
	"Sensoring proximity...",
	"Pinging loopback...",
	"Idle connection..."
}

net.Receive("exp_DisplayLine", function()
	local text = net.ReadString()
	local color = net.ReadColor()

	PLUGIN:AddDisplayLine(text, color)
end)

function PLUGIN:AddDisplayLine(text, color, ...)
	if (not IsValid(ix.gui.tacticalDisplay)) then
		return
	end

	ix.gui.tacticalDisplay:AddLine(text, color, nil, ...)
end
