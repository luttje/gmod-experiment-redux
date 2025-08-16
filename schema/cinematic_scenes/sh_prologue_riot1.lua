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
	end
end
