ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Experiment Redux"
ENT.PrintName = "Monster Spawner"
ENT.Spawnable = false
ENT.AdminOnly = true

if (not SERVER) then
    return
end

local monsterSpawnerEnabledConVar = CreateConVar("exp_monster_spawner_enabled", "1", FCVAR_ARCHIVE, "Enable/disable the monster spawner")

function ENT:KeyValue(key, value)
    if (key == "monsterClasses") then
        self.monsterClasses = string.Explode(",", value)
    elseif (key == "monsterMax") then
        self.monsterMax = tonumber(value)
    elseif (key == "monsterSpawnDelay") then
        self.monsterSpawnDelay = tonumber(value)
    elseif (key == "monsterSpawnRadius") then
        self.monsterSpawnRadius = tonumber(value)
    end
end

function ENT:Initialize()
    self:SetModel("models/editor/scriptedsequence.mdl")
    self:SetNoDraw(true)

    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)

	self.monsterCount = 0
    self.nextSpawnTime = CurTime()
end

function ENT:Think()
    if (not monsterSpawnerEnabledConVar:GetBool()) then
		self:NextThink(CurTime() + 5)
		return true
    end

    if (self.nextSpawnTime > CurTime()) then
        return
    end

    if (self.monsterCount >= self.monsterMax) then
        return
    end

    self:SpawnMonster()

	self:NextThink(CurTime() + 1)
	return true
end

function ENT:SpawnMonster()
    local monsterClass = self.monsterClasses[math.random(1, #self.monsterClasses)]
    local monster = ents.Create(monsterClass)

    if (not IsValid(monster)) then
        return
    end

    local spawnPos = self:GetPos() + (VectorRand() * self.monsterSpawnRadius)
    monster:SetPos(spawnPos)
    monster:SetAngles(self:GetAngles() + Angle(0, math.random(0, 40), 0))
    monster:CallOnRemove("exp_monster_spawner", function()
        self.monsterCount = self.monsterCount - 1
    end)
    monster:Spawn()
    monster:Activate()

    self:SpawnEffect(monster)

    self.monsterCount = self.monsterCount + 1

    self.nextSpawnTime = CurTime() + self.monsterSpawnDelay
end

local hitNormal = Vector(0, 0, 1)
local effectData
local scale = 20
local teleportSounds = {
	"ambient/machines/teleport1.wav",
	"ambient/machines/teleport3.wav",
	"ambient/machines/teleport4.wav"
}

function ENT:SpawnEffect(monster)
	local spawnPosition = monster:GetPos()
	local volume = math.Rand(0.8, 0.99)
	local pitch = math.random(75, 125)

	monster:EmitSound(
		table.Random(teleportSounds),
		75,
		pitch,
		volume,
		CHAN_AUTO,
		0,
		34 -- "EXPLOSION RING 3" DSP
    )

	for i = 1, 4 do
		timer.Simple(i * .5, function()
			effectData = EffectData()
			effectData:SetOrigin(spawnPosition + VectorRand(100, 100) + Vector(0, 0, 100))
			effectData:SetScale(.1)
			effectData:SetMagnitude(2)
			effectData:SetNormal(hitNormal)
			util.Effect("Sparks", effectData)
		end)
	end

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
end
