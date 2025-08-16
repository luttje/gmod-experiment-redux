local SCENE = SCENE

SCENE.cinematicSpawnID = "prologue_gateway"

-- TODO: Show the prologue once to each new player and prevent showing the spawn point selection until the prologue is finished
function SCENE:OnEnterServer(client)
	Schema.instance.AddPlayer(client)

	timer.Simple(10, function()
		if (IsValid(client) and Schema.cinematics.IsPlayerInScene(client, "prologue_gateway")) then
			Schema.cinematics.TransitionPlayerToScene(client, "prologue_riot1")
		end
	end)
end

function SCENE:OnLeaveServer(client)
	local instanceID = Schema.instance.GetPlayerInstance(client)
	Schema.instance.DestroyInstance(instanceID, "end_of_scene")
end

if (CLIENT) then
	function SCENE:OnEnterLocalPlayer()
		Schema.cinematics.ShowCinematicText("The Guardian Testing Facility. A place they told us was safe.")

		Schema.cinematics.SetBlackAndWhite(true)

		Schema.cinematics.prologueMusic = "music/HL2_song6.mp3"
		Schema.cinematics.PlayCinematicSound(Schema.cinematics.prologueMusic, 0.2, 2.0)

		-- Show only to this client some welcome information on the nemesis monitors
		local nemesisPlugin = ix.plugin.Get("nemesis_ai")

		if (nemesisPlugin) then
			nemesisPlugin:SetClientSpecificMonitorVgui("prologue_gateway", function(parent)
				return vgui.Create("expPrologueMonitorGateway", parent)
			end)
		end
	end

	function SCENE:OnLeaveLocalPlayer()
		local nemesisPlugin = ix.plugin.Get("nemesis_ai")

		if (nemesisPlugin) then
			nemesisPlugin:ClearClientSpecificMonitorVgui("prologue_gateway")
		end
	end
end

hook.Add("ExperimentMonitorsFilter", "expPrologueGatewayDisableNormalBehaviour", function(monitors, filterType)
	for i = #monitors, 1, -1 do
		local monitor = monitors[i]
		local specialID = monitor:GetSpecialID()

		if (specialID and specialID == "prologue_gateway") then
			table.remove(monitors, i)
		end
	end
end)
