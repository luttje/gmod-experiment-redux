AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("base_ai")

AccessorFunc(ENT, "expVoicePitch", "VoicePitch", FORCE_NUMBER)
AccessorFunc(ENT, "expAttackMeleeRange", "AttackMeleeRange", FORCE_NUMBER)
AccessorFunc(ENT, "expAttackRange", "AttackRange", FORCE_NUMBER) -- TODO: when we get ranged monsters
AccessorFunc(ENT, "expSenseRange", "SenseRange", FORCE_NUMBER)

ix.chat.Register("monster", {
	CanSay = function(self, speaker, text)
		return not IsValid(speaker)
	end,
	OnChatAdd = function(self, speaker, text, anonymous, data)
		local format = data.yelling and "%s yells \"%s\"" or "%s says \"%s\""

		chat.AddText(Color(255, 55, 100), format:format(data.name, text))
	end,
})

function ENT:Initialize()
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()

    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_STEP)

    self:CapabilitiesAdd(
        bit.bor(
            CAP_MOVE_GROUND,
            CAP_ANIMATEDFACE,
            CAP_TURN_HEAD,
            CAP_USE_SHOT_REGULATOR,
            CAP_AIM_GUN,
            CAP_INNATE_MELEE_ATTACK1
        )
    )

    self:SetMaxYawSpeed(5000)

    self:AddRelationship("player D_HT 99")

    if (self:GetAttackMeleeRange() == nil and self:GetAttackRange() == nil) then
        -- Default to 64 units for melee range
        self:SetAttackMeleeRange(64)
    end

    if (self:GetSenseRange() == nil) then
        self:SetSenseRange(512)
    end

    if (self:GetVoicePitch() == nil) then
        self:SetVoicePitch(100)
    end

    self.expVoiceSounds = {}
    self.expVoiceSoundThrottle = {}
	self:SetupVoiceSounds()

    self.expSchedules = {}
    self.expSchedules.Attacks = {}
    self:SetupSchedules()

    -- Note on setting up node graphs:
    -- You might want to use https://steamcommunity.com/sharedfiles/filedetails/?id=2004023752 to setup node graphs for better pathfinding
    -- To do that I suggest:
    -- 1. Install the addon
    -- 2. Start a new game on the map you want to setup the node graph for
    -- 3. Open the console and type "nav_edit 1" (this builds a navmesh)
    -- 4. Wait until the navmesh is built (you'll see the map being restarted)
    -- 5. Use the installed addon to generate the node graph from the navmesh
end

--[[
    Available voice sound types:
    - "Idle", played randomly when the monster is idle
    - "Pain", played when the monster takes damage
    - "Die", played when the monster dies
    - "Alert", played when the monster sees an enemy
    - "Chase", played when the monster is chasing an enemy
    - "Lost", played when the monster loses sight of an enemy
    - "Attack", played when the monster attacks
    - "AttackMiss", played when the monster misses an attack
    - "AttackHit", played when the monster hits an attack
    - "Victory", played when the monster wins a fight
    - "FootstepLeft", played when the monster takes a step (left)
    - "FootstepRight", played when the monster takes a step (right)
    - "FootstepFastLeft", played when the monster takes a step while running/galloping (left foot) (defaults to "footstep" if not set)
    - "FootstepFastRight", played when the monster takes a step while running/galloping (right foot) (defaults to "footstep" if not set)
--]]
function ENT:SetupVoiceSounds()
    --[[
        Example voice sounds for Fast Zombie:

		self:SetTypedVoiceSet("Idle", {
			"NPC_FastZombie.Idle"
		})

		self:SetTypedVoiceSet("Pain", {
			"NPC_FastZombie.Pain"
		})

		self:SetTypedVoiceSet("Die", {
			"NPC_FastZombie.Die"
		})

		self:SetTypedVoiceSet("Alert", {
			"npc/fast_zombie/fz_scream1.wav"
		})

		self:SetTypedVoiceSet("Chase", {
			-- "npc/fast_zombie/gurgle_loop1.wav",
		})

		self:SetTypedVoiceSet("Lost", {
			"npc/fast_zombie/fz_alert_far1.wav"
		})

		self:SetTypedVoiceSet("Attack", {
			"NPC_FastZombie.Attack"
		})

		self:SetTypedVoiceSet("AttackMiss", {
			"NPC_FastZombie.AttackMiss"
		})

		self:SetTypedVoiceSet("AttackHit", {
			"NPC_FastZombie.AttackHit"
		})

		self:SetTypedVoiceSet("Victory", {
			"npc/fast_zombie/leap1.wav"
		})

		self:SetTypedVoiceSet("FootstepLeft", {
			"NPC_FastZombie.FootstepLeft"
		})

		self:SetTypedVoiceSet("FootstepRight", {
			"NPC_FastZombie.FootstepRight"
		})

		self:SetTypedVoiceSet("FootstepFastLeft", {
			"NPC_FastZombie.GallopLeft"
		})

		self:SetTypedVoiceSet("FootstepFastRight", {
			"NPC_FastZombie.GallopRight"
		})
	]]
end

function ENT:SpeakFromTypedVoiceSet(type, throttle, playOnPrivateChannel)
    if (throttle) then
        if (self.expVoiceSoundThrottle[type] and self.expVoiceSoundThrottle[type] > CurTime()) then
            return
        end

        self.expVoiceSoundThrottle[type] = CurTime() + throttle
    end

    local sounds = self.expVoiceSounds[type]
    local sound = sounds and sounds[math.random(#sounds)]

    if (sound) then
        if (playOnPrivateChannel) then
            -- For sounds that always need to play and not be interrupted by other sounds
            self.expPrivateSound = CreateSound(self, sound)
            self.expPrivateSound:PlayEx(1, self:GetVoicePitch())
            return
        end

        if (self.expCurrentSound) then
            self.expCurrentSound:Stop()
            self.expCurrentSound = nil
        end

        -- self:EmitSound(sound, 75, self:GetVoicePitch()) -- doesnt support sound scripts
        self.expCurrentSound = CreateSound(self, sound)
        self.expCurrentSound:PlayEx(1, self:GetVoicePitch())
    end
end

function ENT:HasTypedVoiceSet(type)
    return self.expVoiceSounds[type] ~= nil
end

function ENT:SetTypedVoiceSet(type, sounds)
    if (not istable(sounds)) then
        sounds = { sounds }
    end

    self.expVoiceSounds[type] = sounds
end

--[[
	Sounds based on animations
--]]

-- TODO: Non zombie specific sounds
local AE_FASTZOMBIE_GALLOP_LEFT = 51
local AE_FASTZOMBIE_GALLOP_RIGHT = 52

local AE_ZOMBIE_ATTACK_RIGHT = 54
local AE_ZOMBIE_ATTACK_LEFT = 55

local AE_ZOMBIE_STEP_RIGHT = 58
local AE_ZOMBIE_STEP_LEFT = 59

function ENT:HandleAnimEvent(event, eventTime, cycle, type, options)
    local isFootstep = event == AE_ZOMBIE_STEP_RIGHT or event == AE_ZOMBIE_STEP_LEFT
    local isFastFootstep = event == AE_FASTZOMBIE_GALLOP_RIGHT or event == AE_FASTZOMBIE_GALLOP_LEFT

    if (isFootstep or isFastFootstep) then
        self:HandleAnimEventFootsteps(event, eventTime, cycle, type, options)
        return
    end

    local isAttack = event == AE_ZOMBIE_ATTACK_RIGHT or event == AE_ZOMBIE_ATTACK_LEFT

    if (isAttack) then
        self:HandleAnimEventAttack(event, eventTime, cycle, type, options)
        return
    end
end

function ENT:HandleAnimEventFootsteps(event, eventTime, cycle, type, options)
    local isFastFootstep = event == AE_FASTZOMBIE_GALLOP_RIGHT or event == AE_FASTZOMBIE_GALLOP_LEFT
    local footstepType = isFastFootstep and "FootstepFast" or "Footstep"
    local footstepSide = (event == AE_ZOMBIE_STEP_RIGHT or event == AE_FASTZOMBIE_GALLOP_RIGHT) and "Right" or "Left"
    local sound = footstepType .. footstepSide

    if (self:HasTypedVoiceSet(sound)) then
        self:SpeakFromTypedVoiceSet(sound)
    elseif (isFastFootstep) then
        self:SpeakFromTypedVoiceSet("Footstep" .. footstepSide)
    end
end

function ENT:HandleAnimEventAttack(event, eventTime, cycle, type, options)
    -- Only play the monster attack, we play attack sounds when the attack is performed
    self:SpeakFromTypedVoiceSet("Attack", 5)
end

function ENT:GetRangeSquared(range)
    return range * range
end

--[[
	AI (Attack) Logic Schedules
--]]

-- Override this to customize schedules
function ENT:SetupSchedules()
    self.expSchedules.Patrol = ai_schedule.New("expPatrol")
    self.expSchedules.Patrol:EngTask("TASK_WANDER", 480512) -- 480240 = 48 units to 240 units according to
    self.expSchedules.Patrol:EngTask("TASK_WALK_PATH", 0)
    self.expSchedules.Patrol:EngTask("TASK_WAIT_FOR_MOVEMENT", 0)

    self.expSchedules.Chase = ai_schedule.New("expChase")
    self.expSchedules.Chase:EngTask("TASK_STOP_MOVING", 0)
    self.expSchedules.Chase:EngTask("TASK_GET_PATH_TO_ENEMY", 0)
    self.expSchedules.Chase:EngTask("TASK_RUN_PATH", 0)
    self.expSchedules.Chase:EngTask("TASK_WAIT_FOR_MOVEMENT", 0)

    local attackMelee1 = ai_schedule.New("expAttackMelee1")
    attackMelee1:EngTask("TASK_STOP_MOVING", 0)
    attackMelee1:EngTask("TASK_FACE_ENEMY", 0)
    attackMelee1:EngTask("TASK_MELEE_ATTACK1", 0)
    attackMelee1:EngTask("TASK_WAIT_FOR_MOVEMENT", 0)
    attackMelee1.expAttackData = {
        damageAfterTask = "TASK_MELEE_ATTACK1",
        range = self:GetAttackMeleeRange(),
        damage = 10,
        damageType = DMG_SLASH,
    }

    self.expSchedules.Attacks[#self.expSchedules.Attacks + 1] = attackMelee1
end

function ENT:GetAttackSchedule(enemy)
    -- TODO: Implement selecting ranged or melee attacks based on distance and monster type
    return self.expSchedules.Attacks[math.random(#self.expSchedules.Attacks)]
end

function ENT:StartAttackSchedule(enemy)
    local attackSchedule = self:GetAttackSchedule(enemy)

    if (not attackSchedule) then
        return
    end

    self.expAttackSchedule = attackSchedule
    self:UpdateEnemyMemory(enemy, enemy:GetPos())
    self:StartSchedule(attackSchedule)
end

function ENT:SelectSchedule()
    if (GetConVarNumber("ai_disabled") == 1 or self:GetNPCState() == NPC_STATE_DEAD) then
        return
    end

    if (self:HandleEnemy()) then
        return
    end

    self:StartSchedule(self.expSchedules.Patrol)
end

function ENT:OnTaskComplete()
    BaseClass.OnTaskComplete(self)

    if (not self.CurrentTask or not self.expAttackSchedule) then
        return
    end

    self:HandleAttackTaskComplete()
end

function ENT:ScheduleFinished()
    if (self.CurrentSchedule == self.expAttackSchedule) then
        self.expAttackSchedule = nil
    end

    BaseClass.ScheduleFinished(self)
end

function ENT:HandleAttackTaskComplete()
    -- Trace the range of the attack to see if we hit anything
    local attackData = self.expAttackSchedule.expAttackData
    local enemy = self:GetEnemy()

    if (not IsValid(enemy)) then
        return
    end

    local directionToEnemy = (enemy:EyePos() - self:EyePos()):GetNormalized()

    -- If the direction is behind us, don't bother attacking
    if (self:GetForward():Dot(directionToEnemy) < 0) then
        self:SpeakFromTypedVoiceSet("AttackMiss", 0.1)
        return
    end

    local traceData = {}
    traceData.start = self:EyePos()
    traceData.endpos = self:EyePos() + (directionToEnemy * attackData.range * self:GetModelScale())
    traceData.filter = function(entity) return self:IsEnemyEntity(entity) end

    local trace = util.TraceLine(traceData)

    if (trace.Hit and trace.Entity == enemy) then
        self:SpeakFromTypedVoiceSet("AttackHit", nil, true)
        enemy:TakeDamage(attackData.damage, self, self)
    else
        self:SpeakFromTypedVoiceSet("AttackMiss", 0.1)
    end
end

--[[
	Enemy targeting
--]]

function ENT:IsEnemyEntity(entity)
    if (not IsValid(entity) or entity == self) then
        return false
    end

    if (self:Disposition(entity) ~= D_HT) then
        return false
    end

    if (not entity:IsPlayer() or not entity:Alive()) then
        return false
    end

	if (entity:GetMoveType() == MOVETYPE_NOCLIP) then
		return false
	end

    return true
end

function ENT:TargetNewEnemy(enemy)
    self:SetEnemy(enemy, true)
    self:UpdateEnemyMemory(enemy, enemy:GetPos())
    self:SpeakFromTypedVoiceSet("Alert")
end

function ENT:FindEnemyInView()
    local viewDistance = self:GetSenseRange()
    local viewAngle = self:EyeAngles()
    local fieldOfView = 70

    local entities = ents.FindInSphere(self:GetPos(), viewDistance)

    for k, entity in pairs(entities) do
        if (not self:IsEnemyEntity(entity)) then
            continue
        end

        -- Check if the entity is in our field of view, using viewAngle
        local entityDirection = (entity:GetPos() - self:GetPos()):GetNormalized()
        local dotProduct = viewAngle:Forward():Dot(entityDirection)

        if (dotProduct < math.cos(math.rad(fieldOfView))) then
            continue
        end

        self:TargetNewEnemy(entity)
        self:StartSchedule(self.expSchedules.Chase)

        return true
    end

    return false
end

-- If we've got an enemy, attack, or move to them
function ENT:HandleEnemy()
    local enemy = self:GetEnemy()

    if (not IsValid(enemy)) then
        self:SetEnemy(nil, false)
        self:SpeakFromTypedVoiceSet("Lost", 5)
        return false
    end

    local enemyPosition = enemy:GetPos()
    local distance = self:GetPos():DistToSqr(enemyPosition)

    if (distance < self:GetRangeSquared(self:GetAttackMeleeRange())) then
        self:StartAttackSchedule(enemy)

        return true
    end

    if (distance < self:GetRangeSquared(self:GetSenseRange())) then
        self:UpdateEnemyMemory(enemy, enemyPosition)
        self:StartSchedule(self.expSchedules.Chase)

        return true
    end

    self:SpeakFromTypedVoiceSet("Lost", 5)
    self:SetEnemy(nil, false)

    return false
end

function ENT:Think()
    if (self:GetEnemy() == nil) then
        if (not self:FindEnemyInView()) then
            self:SpeakFromTypedVoiceSet("Idle", 5)
        end

        return
    end

    -- CurrentSchedule is defined in base/entities/entities/base_ai/schedules.lua and contains the current lua defined schedule table
    if (self.CurrentSchedule ~= self.expSchedules.Chase) then
        return
    end

    -- If we can see the enemy, update the memory so enemies cant run by us as we're finding the last known enemy position
    local enemy = self:GetEnemy()
    local traceData = {}
    traceData.endpos = enemy:EyePos()
    traceData.start = self:EyePos()
    traceData.filter = self

    local trace = util.TraceLine(traceData)

    if (trace.Hit and trace.Entity == enemy) then
        self:SpeakFromTypedVoiceSet("Chase", 2)
        self:UpdateEnemyMemory(enemy, enemy:GetPos())

        -- If they're in melee range, attack immediately if they run by us.
        if (self:GetPos():DistToSqr(enemy:GetPos()) < self:GetRangeSquared(self:GetAttackMeleeRange())) then
            self:StartAttackSchedule(enemy)
        end
    end
end

function ENT:OnTakeDamage(damageInfo)
    self:SetHealth(self:Health() - damageInfo:GetDamage())

	local position = damageInfo:GetDamagePosition()
    local force = damageInfo:GetDamageForce()

	-- local knockbackMultiplier = 0.05

	-- if (self:GetVelocity():Length() < force:Length() * knockbackMultiplier) then
    -- 	self:SetVelocity(force * knockbackMultiplier)
    -- end

	Schema.BloodEffect(self, position, 0.6, force)

    if (self:Health() <= 0) then
        self:HandleDeath()
        return
    end

    if (damageInfo:GetAttacker() and damageInfo:GetAttacker():IsValid() and self:GetEnemy() == nil) then
        self:SpeakFromTypedVoiceSet("Pain", 2)

        self:TargetNewEnemy(damageInfo:GetAttacker())
        self:StartSchedule(self.expSchedules.Chase)
    end
end

function ENT:HandleDeath()
	self:SpeakFromTypedVoiceSet("Die")

    local corpse = self:CreateServerRagdoll()
	corpse:SetNetVar("monsterCorpse", true)
	local decayTime = ix.config.Get("corpseDecayTime", 60)
	local uniqueID = "ixMonsterCorpseDecay" .. corpse:EntIndex()

    if (decayTime > 0) then
        local visualDecayTime = math.max(decayTime * .1, math.min(10, decayTime))

        timer.Create(uniqueID, decayTime - visualDecayTime, 1, function()
            if (IsValid(corpse)) then
                Schema.DecayEntity(corpse, visualDecayTime)
            else
                timer.Remove(uniqueID)
            end
        end)
    end

	local ownerName = self:GetDisplayName()
	local width, height = 4, 1 -- Make customizable from subclass
	local inventory = ix.inventory.Create(width, height, os.time())
	inventory.vars.isMonsterCorpse = true
	corpse.ixInventory = inventory

	corpse.StartSearchCorpse = function(corpse, client)
		if (not IsValid(client)) then
			return
		end

        if (not corpse.ixInventory or ix.storage.InUse(corpse.ixInventory)) then
            return
        end

		local name = L("corpseOwnerName", client, ownerName)
		local baseTaskTime = ix.config.Get("corpseSearchTime", 1)
		local searchTime = Schema.GetDexterityTime(client, baseTaskTime)

		ix.storage.Open(client, corpse.ixInventory, {
			entity = corpse,
			name = name,
			searchText = "@searchingCorpse",
			searchTime = searchTime
		})
	end

	corpse.GetInventory = function(corpse)
		return corpse.ixInventory
	end

	corpse.SetMoney = function(corpse, amount)
		hook.Run("OnMonsterCorpseMoneyChanged", corpse, amount, corpse.ixMoney)
		corpse.ixMoney = amount
	end

    corpse.GetMoney = function(corpse)
        return corpse.ixMoney or 0
    end

    -- TODO: Add loot based on subclass settings
	corpse:SetMoney(math.random(10, 50))

	corpse.OnOptionSelected = function(entity, client, option, data)
		if (client:IsRestricted() or not client:Alive() or not client:GetCharacter()) then
			return
		end

		if (option == L("searchCorpse", client) and corpse.StartSearchCorpse) then
			corpse:StartSearchCorpse(client)
			return
		end
	end

    self:Remove()
end

function ENT:TaskStart_FindNearbyEnemy(data) end

function ENT:Task_FindNearbyEnemy(data)
    -- If we already have an enemy, don't bother looking for a new one, but check if the current enemy is still valid
    if (IsValid(self:GetEnemy())) then
        self:TaskComplete()
        return
    end

    local nearbyEntities = ents.FindInSphere(self:GetPos(), data.Radius or 512)
    local closestDistance = math.huge
    local closestEntity = NULL

    for k, entity in pairs(nearbyEntities) do
        if (not self:IsEnemyEntity(entity)) then
            continue
        end

        local distance = self:GetPos():DistToSqr(entity:GetPos())

        if (distance < closestDistance) then
            closestDistance = distance
            closestEntity = entity
        end
    end

    if (IsValid(closestEntity)) then
        self:TaskComplete()
        self:TargetNewEnemy(closestEntity)
    end

    self:HandleEnemy()
end

function ENT:PrintChat(message, isYelling)
    local range = ix.config.Get("chatRange", 280) * (isYelling and 2 or 1)
    local receivers = {}

    for _, entity in ipairs(ents.FindInSphere(self:GetPos(), range)) do
        if (entity:IsPlayer()) then
            receivers[#receivers + 1] = entity
        end
    end

    ix.chat.Send(nil, "monster", message, false, receivers, {
        name = self:GetDisplayName(),
        -- Verbose equality check in case someone calls PrintChat with table.Random (second return value is string key there):
		yelling = isYelling == true
    })
end
