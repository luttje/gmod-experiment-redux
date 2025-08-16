local SCENE = SCENE

SCENE.cinematicSpawnID = "prologue_riot2"

function SCENE:OnEnterServer(client)
	-- TODO: Spawn weapon and ammo + instruct player how to equip it
	-- TODO: Spawn manhack for them to practice shooting at
	-- TODO: End scene after they kill the manhack, or when the time expires
	-- TODO: Handle softlocks, like where they drop the weapon outside bounds or something

	--[[
		Some sounds to have an NPC possibly say:
			vo/canals/arrest_helpme.wav <- cry for help

			vo/npc/female01/coverwhilereload01.wav
			vo/npc/female01/coverwhilereload02.wav
			vo/npc/male01/coverwhilereload01.wav
			vo/npc/male01/coverwhilereload02.wav

			vo/npc/male01/ammo03.wav
			vo/npc/male01/ammo04.wav
			vo/npc/male01/ammo05.wav

			vo/npc/male01/behindyou01.wav

			vo/npc/male01/gethellout.wav

			vo/npc/male01/herecomehacks01.wav
			vo/npc/male01/herecomehacks02.wav
			vo/npc/male01/heretheycome01.wav

			vo/npc/male01/youdbetterreload01.wav
	--]]

	-- Hard-timer to end scene after some time
	timer.Simple(10, function()
		if (IsValid(client) and Schema.cinematics.IsPlayerInScene(client, "prologue_riot2")) then
			Schema.cinematics.RemovePlayerFromSceneFadeOut(client)
		end
	end)
end

function SCENE:OnLeaveServer(client)
	Schema.instance.DestroyInstance(client:SteamID64(), "end_of_scene")

	client:KillSilent()
	client:Spawn()
	-- TODO: Strip all items after this flashback
	-- TODO: Show the spawn point selection
end

function SCENE:OnServerThink(client)
end

if (CLIENT) then
	function SCENE:OnEnterLocalPlayer()
		Schema.cinematics.ShowCinematicText(
			"That illusion shattered the day the Nemesis AI showed us its real purpose.",
			8
		)

		Schema.cinematics.SetBlackAndWhite(true)
	end

	function SCENE:OnLeaveLocalPlayer()
		Schema.cinematics.StopCinematicSound(3.0) -- Fade out over 3 seconds
	end
end
