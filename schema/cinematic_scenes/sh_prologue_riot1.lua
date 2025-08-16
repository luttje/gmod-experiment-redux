local SCENE = SCENE

SCENE.cinematicSpawnID = "prologue_riot1"

function SCENE:OnEnterServer(client)
	timer.Simple(15, function()
		if (IsValid(client) and Schema.cinematics.IsPlayerInScene(client, "prologue_riot1")) then
			Schema.cinematics.TransitionPlayerToScene(client, "prologue_riot2")
		end
	end)
end

function SCENE:OnServerThink(client)
end

if (CLIENT) then
	function SCENE:OnEnterLocalPlayer()
		Schema.cinematics.ShowCinematicText(
			"A place where even rioting was part of the schedule. A harmless experiment to test their crowd controlling AI...",
			12
		)

		Schema.cinematics.SetBlackAndWhite(true)

		local nemesisPlugin = ix.plugin.Get("nemesis_ai")

		if (nemesisPlugin) then
			nemesisPlugin:SetClientSpecificMonitorVgui("prologue_riot1", function(parent)
				return vgui.Create("expPrologueMonitorRiot1", parent)
			end)
		end
	end

	function SCENE:OnLeaveLocalPlayer()
		local nemesisPlugin = ix.plugin.Get("nemesis_ai")

		if (nemesisPlugin) then
			nemesisPlugin:ClearClientSpecificMonitorVgui("prologue_riot1")
		end
	end
end

hook.Add("ExperimentMonitorsFilter", "expPrologueRiot1DisableNormalBehaviour", function(monitors, filterType)
	for i = #monitors, 1, -1 do
		local monitor = monitors[i]
		local specialID = monitor:GetSpecialID()

		if (specialID and specialID == "prologue_riot1") then
			table.remove(monitors, i)
		end
	end
end)
