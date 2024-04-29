local PLUGIN = PLUGIN

PLUGIN.spawns = PLUGIN.spawns or {}

PLUGIN.spawnNearDeathRange = 4096
PLUGIN.spawnNearDeathAfterSeconds = 60 * 5

util.AddNetworkString("expSpawnSelectOpen")
util.AddNetworkString("expSpawnRequestSelect")
util.AddNetworkString("expSpawnSelectResponse")

net.Receive("expSpawnRequestSelect", function(len, client)
	local index = net.ReadUInt(8)
	local spawn = PLUGIN.spawns[index]

    if (not spawn) then
        client:Notify("This spawn point is invalid!")
		net.Start("expSpawnSelectResponse")
		net.WriteUInt(PLUGIN.spawnResult.FAIL, 4)
		net.Send(client)
        return
    end

    local canSpawn, reason = hook.Run("PlayerCanSelectSpawnPoint", client, spawn, index)

	if (canSpawn == false) then
		client:Notify(reason or "You cannot spawn at this location!")
		net.Start("expSpawnSelectResponse")
		net.WriteUInt(PLUGIN.spawnResult.FAIL, 4)
		net.Send(client)
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

function PLUGIN:PostPlayerLoadout(client)
    local character = client:GetCharacter()

    if (not character) then
        return
    end

    if (#PLUGIN.spawns == 0) then
        ix.util.SchemaPrint("No spawn points have been set! Spawning without spawn selection.\n")
        return
    end

    local mapDetails = self:GetMapDetails()

    if (not mapDetails) then
        ix.util.SchemaErrorNoHalt("No map details found! Spawning without spawn selection.\n")
        return
    end

    if (client:GetNetVar("expChoosingSpawn", false)) then
        -- During initial character selection PlayerLoadout is called twice.
        return
    end

    local shouldShowSpawnSelection = hook.Run("ShouldShowSpawnSelection", client)

	if (shouldShowSpawnSelection == false) then
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

function PLUGIN:PlayerDeath(client, inflictor, attacker)
    local character = client:GetCharacter()

    if (not character) then
        return
    end

    -- Store this vector so we can use it to determine if the player can spawn at a spawn point.
    character:SetData("lastDeathPosition", client:GetPos())
	character:SetData("lastDeathTime", os.time())
end

function PLUGIN:GetAvailableSpawns(client)
    local character = client:GetCharacter()
    local lastDeathPosition = character:GetData("lastDeathPosition")
	local lastDeathTime = character:GetData("lastDeathTime")
    local spawnNearDeathRange = self.spawnNearDeathRange * self.spawnNearDeathRange
	local canSpawnNearDeath = not lastDeathTime or (os.time() - lastDeathTime) > self.spawnNearDeathAfterSeconds
    local safeCount = 0
    local spawns = {}

    for k, spawn in ipairs(self.spawns) do
        local status = self.spawnStatus.SAFE
		local unsafeUntil

        -- Filter out spawns where the player recently died.
        if (not canSpawnNearDeath and lastDeathPosition) then
            local distance = spawn.position:DistToSqr(lastDeathPosition)

            if (distance < spawnNearDeathRange) then
                status = self.spawnStatus.LOCKED
				unsafeUntil = CurTime() + (self.spawnNearDeathAfterSeconds - (os.time() - lastDeathTime))
            end
        end

		-- TODO: Unsafe because of nearby players activity

        if (status == self.spawnStatus.SAFE) then
            safeCount = safeCount + 1
        end

        spawns[k] = {
            position = spawn.position,
            angles = spawn.angles,
            name = spawn.name,
            status = status,
			unsafeUntil = unsafeUntil
        }
    end

    -- If everything is unsafe, unlock all spawns, setting CHAOS status.
    if (safeCount == 0) then
        for k, spawn in ipairs(spawns) do
            spawn.status = self.spawnStatus.CHAOS
        end
    end

    return spawns
end

function PLUGIN:PlayerCanSelectSpawnPoint(client, spawn, spawnIndex)
    local availableSpawns = self:GetAvailableSpawns(client)
    local spawn = availableSpawns[spawnIndex]

	if (spawn.status ~= self.spawnStatus.SAFE and spawn.status ~= self.spawnStatus.CHAOS) then
		return false, "You cannot spawn at this location!"
	end

	return true
end

local teleportSounds = {
	"ambient/machines/teleport1.wav",
	"ambient/machines/teleport3.wav",
	"ambient/machines/teleport4.wav"
}

function PLUGIN:DoAnimatedSpawn(client, spawnPosition, spawnAngles)
	local hitNormal = Vector(0, 0, 1)
	local animationDuration = DEBUG_DISABLE_SPAWN_ANIM and 0 or 3
	local effectData
	local scale = 20

	client:UnLock()
	client:Freeze(true)
	client:SetPos(spawnPosition)
	client:SetEyeAngles(spawnAngles)

	-- For some reason Eye Angles wont set properly without a delay
	timer.Simple(3, function()
		if (IsValid(client)) then
			client:SetEyeAngles(spawnAngles)
		end
    end)

    local volume = math.Rand(0.8, 0.99)
	local pitch = math.random(75, 125)

	client:SetColor(Color(0, 0, 255, 75))
	client:EmitSound(
		"ambient/levels/labs/teleport_preblast_suckin1.wav",
		75,
		pitch,
		volume,
		CHAN_AUTO
	)

	net.Start("expSpawnSelectResponse")
	net.WriteUInt(self.spawnResult.OK, 4)
	net.Send(client)

	for i = 1, 8 do
		timer.Simple(animationDuration - (i * .5), function()
			effectData = EffectData()
			effectData:SetOrigin(spawnPosition + VectorRand(100, 100) + Vector(0, 0, 400))
			effectData:SetScale(.1)
			effectData:SetMagnitude(2)
			effectData:SetNormal(hitNormal)
			util.Effect("Sparks", effectData)
		end)
	end

	timer.Simple(animationDuration, function()
		if (not IsValid(client)) then
			return
		end

		client:Freeze(false)
		client:SetNetVar("expChoosingSpawn", false)
		client:SetRenderMode(RENDERMODE_TRANSCOLOR)
		client:SetColor(Color(255, 255, 255, 255))
        client:EmitSound(
            table.Random(teleportSounds),
			75,
            pitch,
            volume,
            CHAN_AUTO,
            0,
			34 -- "EXPLOSION RING 3" DSP
		)

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
