local PLUGIN = PLUGIN

local SCENE = {}
SCENE.cinematicSpawnID = "prologue_gateway"

-- TODO: Show the prologue once to each new player and prevent showing the spawn point selection until the prologue is finished
function SCENE:OnEnterServer(client)
	Schema.instance.AddPlayer(client, client:SteamID64())

	timer.Simple(10, function()
		if (IsValid(client) and PLUGIN:IsPlayerInScene(client, "prologue_gateway")) then
			PLUGIN:TransitionPlayerToScene(client, "prologue_riot1")
		end
	end)
end

if (CLIENT) then
	function SCENE:OnEnterLocalPlayer()
		PLUGIN:ShowCinematicText("The Guardian Testing Facility. A place they told us was safe.")

		PLUGIN:SetBlackAndWhite(true)

		PLUGIN.prologueMusic = "music/HL2_song6.mp3"
		PLUGIN:PlayCinematicSound(PLUGIN.prologueMusic, 0.2, 2.0)
	end
end

PLUGIN:RegisterScene("prologue_gateway", SCENE)
