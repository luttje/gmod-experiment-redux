local PLUGIN = PLUGIN

PLUGIN.spawns = PLUGIN.spawns or {}

util.AddNetworkString("expSpawnSelectOpen")
util.AddNetworkString("expSpawnRequestSelect")
util.AddNetworkString("expSpawnSelectResponse")

net.Receive("expSpawnRequestSelect", function(len, client)
	local index = net.ReadUInt(8)
	local spawn = PLUGIN.spawns[index]

	if (not spawn) then
		client:Notify("This spawn point is invalid!")
		return
	end

	PLUGIN:DoAnimatedSpawn(client, spawn.position, spawn.angles)
end)

function PLUGIN:LoadData()
	self.spawns = self:GetData() or {}
end

function PLUGIN:SaveData()
	self:SetData(self.spawns)
end

function PLUGIN:PlayerLoadout(client)
	local character = client:GetCharacter()

	if (not character) then
		return
	end

	if (#PLUGIN.spawns == 0) then
		print("[Experiment Redux] No spawn points have been set! Spawning without spawn selection.\n")
		return
	end

	local mapDetails = self:GetMapDetails()

	if (not mapDetails) then
		ErrorNoHalt("[Experiment Redux] No map details found! Spawning without spawn selection.\n")
		return
	end

	if (client:GetNetVar("expChoosingSpawn", false)) then
		-- During initial character selection PlayerLoadout is called twice.
		return
	end

	-- When a player spawns, lock them so they can't move until they've selected a spawn point.
	client:SetPos(mapDetails.waitingPosition)
	client:SetEyeAngles(mapDetails.waitingAngles)
	client:SetColor(Color(255, 255, 255, 0))
	client:SetRenderMode(RENDERMODE_TRANSALPHA)
	client:SetNetVar("expChoosingSpawn", true)
	client:Lock()

	net.Start("expSpawnSelectOpen")
	net.WriteTable(self:GetAvailableSpawns(client))
	net.Send(client)
end

function PLUGIN:GetAvailableSpawns(client)
	local spawns = {}

	for k, spawn in ipairs(self.spawns) do
		-- TODO: Filter out unsafe spawn points and spawns where the player recently died.

		spawns[k] = {
			position = spawn.position,
			angles = spawn.angles,
			name = spawn.name,
			status = "safe" -- TODO
		}
	end

	return spawns
end

local teleportSounds = {
	"ambient/machines/teleport1.wav",
	"ambient/machines/teleport3.wav",
	"ambient/machines/teleport4.wav"
}

function PLUGIN:DoAnimatedSpawn(client, spawnPosition, spawnAngles)
	local hitNormal = Vector(0, 0, 1)
	local animationDuration = DEBUG_DISABLE_SPAWN_ANIM and 0 or 1
	local effectData
	local scale = 20

	client:UnLock()
	client:Freeze(true)
	client:SetPos(spawnPosition)
	client:SetEyeAngles(spawnAngles)
	-- For some reason Eye Angles wont set properly without a delay
	timer.Simple(1, function()
		if (IsValid(client)) then
			client:SetEyeAngles(spawnAngles)
		end
	end)
	client:SetColor(Color(0, 0, 255, 75))
	client:EmitSound(
		"ambient/levels/labs/teleport_preblast_suckin1.wav",
		75 * math.Rand(.5, 1),
		100 * math.Rand(.75, 1.25)
	)

	net.Start("expSpawnSelectResponse")
	net.WriteUInt(self.spawnResult.OK, 4)
	net.Send(client)

	for i = 1, 10 do
		timer.Simple(animationDuration - (i * .5), function()
			effectData = EffectData()
			effectData:SetOrigin(spawnPosition + VectorRand(100, 100) + Vector(0, 0, 400))
			effectData:SetScale(.1)
			effectData:SetMagnitude(2)
			effectData:SetNormal(hitNormal)
			util.Effect("Sparks", effectData)
		end)
	end

	-- TODO: Some lightning here

	timer.Simple(animationDuration, function()
		if (not IsValid(client)) then
			return
		end

		client:Freeze(false)
		client:SetNetVar("expChoosingSpawn", false)
		client:SetRenderMode(RENDERMODE_TRANSCOLOR)
		client:SetColor(Color(255, 255, 255, 255))
		client:EmitSound(table.Random(teleportSounds), 75 * math.Rand(.5, 1), 100 * math.Rand(.75, 1.25))

		effectData = EffectData()
		effectData:SetOrigin(spawnPosition)
		effectData:SetRadius(scale * 4)
		effectData:SetNormal(hitNormal)
		util.Effect("AR2Explosion", effectData)

		effectData = EffectData()
		effectData:SetOrigin(spawnPosition)
		effectData:SetScale(scale)
		effectData:SetColor(20)
		util.Effect("camera_flash", effectData)

		effectData = EffectData()
		effectData:SetOrigin(spawnPosition)
		effectData:SetScale(scale * 50)
		effectData:SetNormal(hitNormal)
		util.Effect("ThumperDust", effectData)
	end)
end
