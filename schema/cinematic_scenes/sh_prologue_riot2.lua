local SCENE = SCENE

SCENE.cinematicSpawnID = "prologue_riot2"

local function findItemSpawnPoint(sequenceID, itemSpawnID)
	for _, ent in ipairs(ents.FindByClass("exp_cinematic_item_spawn")) do
		if (ent:GetSequenceID() == sequenceID and ent:GetItemSpawnID() == itemSpawnID) then
			return ent
		end
	end

	return nil
end

function SCENE:OnEnterServer(client)
	Schema.instance.AddPlayer(client)

	-- Spawn weapon and ammo in this client's instance
	local weaponSpawn = findItemSpawnPoint(SCENE.cinematicSpawnID, "weapon")
	local ammoSpawn = findItemSpawnPoint(SCENE.cinematicSpawnID, "ammo")

	if (not weaponSpawn or not ammoSpawn) then
		ix.util.SchemaErrorNoHalt("Prologue scene 'prologue_riot2' is missing item spawn points for weapon or ammo!")
		Schema.cinematics.RemovePlayerFromSceneFadeOut(client)
		return
	end

	local weaponItemTable = ix.item.Get("ex_glock")
	local ammo = Schema.ammo.ConvertToAmmo(weaponItemTable.forcedWeaponCalibre)
	local ammoItemTable = Schema.ammo.FindMainAmmoItem(ammo)

	if (not ammoItemTable) then
		ix.util.SchemaErrorNoHalt("Prologue scene 'prologue_riot2' is missing ammo item for weapon!")
		Schema.cinematics.RemovePlayerFromSceneFadeOut(client)
		return
	end

	local instanceID = Schema.instance.GetPlayerInstance(client)

	-- Track the items this player has to pick up
	client.expPrologueRiot2Items = {}

	ix.item.Spawn(weaponItemTable.uniqueID, weaponSpawn:GetPos(), function(item, itemEntity)
		Schema.instance.AddEntity(itemEntity, instanceID)

		client.expPrologueRiot2Items[item.uniqueID] = item
	end)

	ix.item.Spawn(ammoItemTable.uniqueID, ammoSpawn:GetPos(), function(item, itemEntity)
		Schema.instance.AddEntity(itemEntity, instanceID)

		client.expPrologueRiot2Items[item.uniqueID] = item
	end)

	-- TODO: instruct player how to equip it
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
	timer.Simple(60 * 10, function()
		if (IsValid(client) and Schema.cinematics.IsPlayerInScene(client, "prologue_riot2")) then
			Schema.cinematics.RemovePlayerFromSceneFadeOut(client)
		end
	end)
end

function SCENE:OnLeaveServer(client)
	client.expPrologueRiot2Items = nil

	local instanceID = Schema.instance.GetPlayerInstance(client)
	Schema.instance.DestroyInstance(instanceID, "end_of_scene")

	client:KillSilent()
	client:Spawn()
	-- TODO: Strip all items after this flashback
	-- TODO: Show the spawn point selection
end

function SCENE:OnServerThink(client)
end

if (SERVER) then
	local function checkIfPickedUpItems(client)
		if (table.Count(client.expPrologueRiot2Items) == 0) then
			-- TODO:
			ix.util.SchemaErrorNoHalt("TODO: Proceed to equip explanation")
			client.expPrologueRiot2Items = nil
		end
	end

	-- Track the next phase if the player picks up both items
	hook.Add("OnItemTransferred", "expPrologueRiot2OnItemTransferred", function(item, oldInventory, newInventory)
		if (not item.entity or not newInventory) then
			return
		end

		local itemInstanceID = Schema.instance.GetEntityInstance(item.entity)

		if (not itemInstanceID) then
			return
		end

		local inventoryOwner = newInventory:GetOwner()

		if (not IsValid(inventoryOwner) or not inventoryOwner.expPrologueRiot2Items) then
			return
		end

		local itemToPickup = inventoryOwner.expPrologueRiot2Items[item.uniqueID]

		if (not itemToPickup or itemToPickup ~= item) then
			return
		end

		inventoryOwner.expPrologueRiot2Items[item.uniqueID] = nil

		checkIfPickedUpItems(inventoryOwner)
	end)

	-- Also track the next phase if the player picks up the weapon and immediately loads the ammo
	hook.Add("PlayerAmmoChanged", "expPrologueRiot2PlayerAmmoChanged", function(client, ammoID, oldCount, newCount)
		if (not IsValid(client) or not client.expPrologueRiot2Items) then
			return
		end

		local ammoItemTable = Schema.ammo.FindMainAmmoItem(ammoID)

		if (not ammoItemTable or not client.expPrologueRiot2Items[ammoItemTable.uniqueID]) then
			return
		end

		client.expPrologueRiot2Items[ammoItemTable.uniqueID] = nil

		checkIfPickedUpItems(client)
	end)
end

if (CLIENT) then
	function SCENE:OnEnterLocalPlayer()
		Schema.cinematics.ShowCinematicText(
			"That illusion shattered the day the Nemesis AI showed us its true, unaligned nature. ",
			8
		)

		Schema.cinematics.SetBlackAndWhite(true)

		local nemesisPlugin = ix.plugin.Get("nemesis_ai")

		if (nemesisPlugin) then
			nemesisPlugin:SetClientSpecificMonitorVgui("prologue_riot2", function(parent)
				return vgui.Create("expPrologueMonitorRiot2", parent)
			end)
		end
	end

	function SCENE:OnLeaveLocalPlayer()
		local nemesisPlugin = ix.plugin.Get("nemesis_ai")

		if (nemesisPlugin) then
			nemesisPlugin:ClearClientSpecificMonitorVgui("prologue_riot2")
		end

		Schema.cinematics.StopCinematicSound(3.0) -- Fade out over 3 seconds
	end
end

hook.Add("ExperimentMonitorsFilter", "expPrologueRiot2DisableNormalBehaviour", function(monitors, filterType)
	for i = #monitors, 1, -1 do
		local monitor = monitors[i]
		local specialID = monitor:GetSpecialID()

		if (specialID and specialID == "prologue_riot2") then
			table.remove(monitors, i)
		end
	end
end)
