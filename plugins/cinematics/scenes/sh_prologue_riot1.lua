local PLUGIN = PLUGIN

local SCENE = {}
SCENE.cinematicSpawnID = "prologue_riot1"

function SCENE:OnEnterServer(client)
	timer.Simple(15, function()
		if (IsValid(client) and PLUGIN:IsPlayerInScene(client, "prologue_riot1")) then
			PLUGIN:TransitionPlayerToScene(client, "prologue_riot2")
		end
	end)
end

function SCENE:OnServerThink(client)
end

if (CLIENT) then
	function SCENE:OnEnterLocalPlayer()
		PLUGIN:ShowCinematicText(
			"A place where even rioting was part of the schedule. A harmless experiment to test their crowd controlling AI...",
			12
		)

		PLUGIN:SetBlackAndWhite(true)
	end
end

PLUGIN:RegisterScene("prologue_riot1", SCENE)
