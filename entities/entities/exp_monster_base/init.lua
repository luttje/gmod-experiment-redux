AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("base_ai")

AccessorFunc(ENT, "expVoicePitch", "VoicePitch", FORCE_NUMBER)
AccessorFunc(ENT, "expAttackMeleeRange", "AttackMeleeRange", FORCE_NUMBER)
AccessorFunc(ENT, "expAttackRange", "AttackRange", FORCE_NUMBER) -- TODO: when we get ranged monsters
AccessorFunc(ENT, "expSenseRange", "SenseRange", FORCE_NUMBER)
AccessorFunc(ENT, "expChatClass", "ChatClass", FORCE_STRING)

function ENT:Initialize()
	self:Boot()
end

function ENT:Boot()
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetCustomCollisionCheck(true)

	self:SetSolid(SOLID_BBOX)

	-- Setting this to custom prevents the NPC from trying to walk up walls
	self:SetMoveType(MOVETYPE_CUSTOM)

	self:CapabilitiesClear()

	self:CapabilitiesAdd(
		bit.bor(
			CAP_SKIP_NAV_GROUND_CHECK,
			CAP_USE_SHOT_REGULATOR,
			CAP_MOVE_GROUND,
			CAP_ANIMATEDFACE,
			CAP_TURN_HEAD,
			CAP_INNATE_MELEE_ATTACK1
		)
	)

	self:SetNPCClass(CLASS_ZOMBIE)
	-- self:SetSaveValue("m_flFieldOfView", 999)
	-- Without a proper range, the monster will never find enemies, even if we SetEnemy them
	self:SetMaxLookDistance(9000)

	self:SetMaxYawSpeed(256)

	if (self:GetAttackMeleeRange() == nil and self:GetAttackRange() == nil) then
		self:SetAttackMeleeRange(55) -- Must be right up against the target, otherwise their hands wont reach the target
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

	self.enemiesOfNoInterest = {}

	self.expEnemiesOfNoInterest = {}

	self.expInventory = {}

	-- Initialize attack handles (points of contact to do damage during attachs)
	self.expAttackHandles = {}

	-- TODO: Unneccesary?
	-- -- Set up attack handles after a short delay to ensure bones are ready
	timer.Simple(0.1, function()
		if IsValid(self) then
			self:SetupAttackHandles()
		end
	end)

	-- Note on setting up node graphs:
	-- You might want to use https:--steamcommunity.com/sharedfiles/filedetails/?id=2004023752 to setup node graphs for better pathfinding
	-- To do that I suggest:
	-- 1. Install the addon
	-- 2. Start a new game on the map you want to setup the node graph for
	-- 3. Open the console and type "nav_edit 1" (this builds a navmesh)
	-- 4. Wait until the navmesh is built (you'll see the map being restarted)
	-- 5. Use the installed addon to generate the node graph from the navmesh
end

function ENT:AnimEventID(eventName)
	return util.GetAnimEventIDByName(eventName)
end

-- Override this function in your monster subclasses to set up attack handles
-- Example for typical biped monsters:
function ENT:SetupAttackHandles()
	-- Clear any existing handles
	self:ClearAttackHandles()

	-- Example setup for hands - override this in subclasses

	-- Left hand
	local leftHandBone = self:LookupBone("ValveBiped.Bip01_L_Hand")
	if (leftHandBone) then
		self:CreateAttackHandle("left_hand", leftHandBone, Vector(0, 0, 0), 8)
	end

	-- Right hand
	local rightHandBone = self:LookupBone("ValveBiped.Bip01_R_Hand")
	if (rightHandBone) then
		self:CreateAttackHandle("right_hand", rightHandBone, Vector(0, 0, 0), 8)
	end

	-- For zombies, you might also want claws or fingertips:
	-- self:CreateAttackHandle("left_claw", leftHandBone, Vector(8, 0, 0))
	-- self:CreateAttackHandle("right_claw", rightHandBone, Vector(8, 0, 0))
end

-- Create an attack handle attached to a specific bone
function ENT:CreateAttackHandle(name, boneIndex, offset, handleSize)
	if not boneIndex or boneIndex == -1 then
		print("Warning: Invalid bone index for attack handle:", name)
		return
	end

	local handle = ents.Create("exp_attack_handle")
	if not IsValid(handle) then
		print("Error: Failed to create attack handle:", name)
		return
	end

	handle:Spawn()
	handle:SetOwnerMonster(self)

	handle:SetSize(handleSize)

	-- Attach to bone
	handle:FollowBone(self, boneIndex)

	-- Apply offset if provided
	handle:SetLocalPos(offset or Vector(0, 0, 0))

	-- Store reference
	self.expAttackHandles[name] = {
		entity = handle,
		boneIndex = boneIndex,
		offset = offset
	}

	return handle
end

-- Clear all attack handles
function ENT:ClearAttackHandles()
	if self.expAttackHandles then
		for name, handleData in pairs(self.expAttackHandles) do
			if IsValid(handleData.entity) then
				handleData.entity:Remove()
			end
		end
	end
	self.expAttackHandles = {}
end

-- Get an attack handle by name
function ENT:GetAttackHandle(name)
	if self.expAttackHandles and self.expAttackHandles[name] then
		return self.expAttackHandles[name].entity
	end
	return nil
end

-- Start an attack - activates all attack handles
function ENT:StartAttackHandles(attackData)
	if not self.expAttackHandles then return end

	for name, handleData in pairs(self.expAttackHandles) do
		if IsValid(handleData.entity) then
			handleData.entity:StartAttack(attackData)
		end
	end

	self.expAttackHandlesActive = true
	self.expCurrentAttackData = attackData
end

-- End an attack - deactivates all attack handles
function ENT:EndAttackHandles()
	if not self.expAttackHandles then return end

	for name, handleData in pairs(self.expAttackHandles) do
		if IsValid(handleData.entity) then
			handleData.entity:EndAttack()
		end
	end

	self.expAttackHandlesActive = false
	self.expCurrentAttackData = nil
end

--- Get the NPC's inventory
--- @return table # The NPC's inventory
function ENT:GetInventory()
	return self.expInventory
end

--- Give the NPC an Item Instance
--- @param itemInstance table The item instance to give to the NPC
function ENT:GiveItemInstance(itemInstance)
	table.insert(self.expInventory, itemInstance)
end

--- Remove an Item Instance from the NPC's inventory
--- @param itemInstance table The item instance to remove from the NPC's inventory
function ENT:TakeItemInstance(itemInstance)
	for i, item in ipairs(self.expInventory) do
		if (item == itemInstance) then
			table.remove(self.expInventory, i)
			break
		end
	end
end

--- Count the number of items an NPC has
--- @param itemUniqueID string The class of the item to count
--- @return number # The number of items the NPC has
function ENT:CountItem(itemUniqueID)
	local count = 0

	for _, item in ipairs(self.expInventory) do
		if (item.uniqueID == itemUniqueID) then
			count = count + 1
		end
	end

	return count
end

--- Get if the NPC has an item
--- @param itemUniqueID string The class of the item to check
--- @return boolean # If the NPC has the item
function ENT:HasItem(itemUniqueID)
	return self:CountItem(itemUniqueID) > 0
end

-- Monsters might get stuck opening doors, if there's an object behind it blocking the door from opening
-- Using this function we can make monsters ignore enemies that have just been attempted to open
function ENT:AddEnemyOfNoInterest(enemy, duration)
	duration = duration or 20
	self.enemiesOfNoInterest[enemy] = CurTime() + duration
end

hook.Add(
	"AcceptInput",
	"expDontAllowDoorsToCloseWhenOpenedByMonsters",
	function(entity, inputName, activator, caller, value)
		if (not entity:IsDoor()) then
			return
		end

		local closing = inputName == "Close" or inputName == "Use"

		if (closing and entity.expIsOpeningFromAttackUntil) then
			if (entity.expIsOpeningFromAttackUntil < CurTime()) then
				entity.expIsOpeningFromAttackUntil = nil
				entity.expDoorHealth = nil
				return
			end

			return true
		end
	end
)

-- Based on https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/sp/src/game/server/ai_task.h#L26
local NO_TASK_FAILURE = 0
local FAIL_NO_TARGET = 1
local FAIL_WEAPON_OWNED = 2
local FAIL_ITEM_NO_FIND = 3
local FAIL_NO_HINT_NODE = 4
local FAIL_SCHEDULE_NOT_FOUND = 5
local FAIL_NO_ENEMY = 6
local FAIL_NO_BACKAWAY_NODE = 7
local FAIL_NO_COVER = 8
local FAIL_NO_FLANK = 9
local FAIL_NO_SHOOT = 10
local FAIL_NO_ROUTE = 11
local FAIL_NO_ROUTE_GOAL = 12
local FAIL_NO_ROUTE_BLOCKED = 13
local FAIL_NO_ROUTE_ILLEGAL = 14
local FAIL_NO_WALK = 15
local FAIL_ALREADY_LOCKED = 16
local FAIL_NO_SOUND = 17
local FAIL_NO_SCENT = 18
local FAIL_BAD_ACTIVITY = 19
local FAIL_NO_GOAL = 20
local FAIL_NO_PLAYER = 21
local FAIL_NO_REACHABLE_NODE = 22
local FAIL_NO_AI_NETWORK = 23
local FAIL_BAD_POSITION = 24
local FAIL_BAD_PATH_GOAL = 25
local FAIL_STUCK_ONTOP = 26
local FAIL_ITEM_TAKEN = 27

--- Returns the message relating to a fail code
--- @param failCode number The fail code
--- @return string The fail message
function ENT:GetFailMessage(failCode)
	local failMessages = {
		[NO_TASK_FAILURE] = "No task failure",
		[FAIL_NO_TARGET] = "No target",
		[FAIL_WEAPON_OWNED] = "Weapon owned",
		[FAIL_ITEM_NO_FIND] = "Item not found",
		[FAIL_NO_HINT_NODE] = "No hint node",
		[FAIL_SCHEDULE_NOT_FOUND] = "Schedule not found",
		[FAIL_NO_ENEMY] = "No enemy",
		[FAIL_NO_BACKAWAY_NODE] = "No backaway node",
		[FAIL_NO_COVER] = "No cover",
		[FAIL_NO_FLANK] = "No flank",
		[FAIL_NO_SHOOT] = "No shoot",
		[FAIL_NO_ROUTE] = "No route",
		[FAIL_NO_ROUTE_GOAL] = "No route (goal)",
		[FAIL_NO_ROUTE_BLOCKED] = "No route (blocked)",
		[FAIL_NO_ROUTE_ILLEGAL] = "No route (illegal)",
		[FAIL_NO_WALK] = "No walk",
		[FAIL_ALREADY_LOCKED] = "Already locked",
		[FAIL_NO_SOUND] = "No sound",
		[FAIL_NO_SCENT] = "No scent",
		[FAIL_BAD_ACTIVITY] = "Bad activity",
		[FAIL_NO_GOAL] = "No goal",
		[FAIL_NO_PLAYER] = "No player",
		[FAIL_NO_REACHABLE_NODE] = "No reachable node",
		[FAIL_NO_AI_NETWORK] = "No AI network",
		[FAIL_BAD_POSITION] = "Bad position",
		[FAIL_BAD_PATH_GOAL] = "Bad path goal",
		[FAIL_STUCK_ONTOP] = "Stuck on top",
		[FAIL_ITEM_TAKEN] = "Item taken",
	}

	return failMessages[failCode] or "Unknown failure"
end

-- CurrentSchedule is defined in base/entities/entities/base_ai/schedules.lua and contains the current lua defined schedule table
function ENT:GetSchedule()
	return self.CurrentSchedule
end

function ENT:GetRangeSquared(range)
	return range ^ 2
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
    - "AttackHitDoor", played when the monster hits a door
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

function ENT:SpeakFromTypedVoiceSet(type, throttle, playOnPrivateChannel, volumeOverride, pitchOverride)
	if (GetConVar("ai_disabled"):GetBool()) then
		return
	end

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
			self.expPrivateSound:PlayEx(volumeOverride or 1, pitchOverride or self:GetVoicePitch())
			return
		end

		if (self.expCurrentSound) then
			self.expCurrentSound:Stop()
			self.expCurrentSound = nil
		end

		-- self:EmitSound(sound, 75, self:GetVoicePitch()) -- doesnt support sound scripts
		self.expCurrentSound = CreateSound(self, sound)
		self.expCurrentSound:PlayEx(volumeOverride or 1, pitchOverride or self:GetVoicePitch())
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

--- Starts a schedule previously created by ai_schedule.New.
--- This overrides the base class StartSchedule to call OnScheduleStarted
--- @param schedule table The schedule to start
function ENT:StartSchedule(schedule)
	BaseClass.StartSchedule(self, schedule)
	self:OnScheduleStarted(schedule)
end

--- Override this to react to a schedule being started
--- @param schedule table The schedule that is being started
function ENT:OnScheduleStarted(schedule)
end

--- Override this to cancel/stop/start schedules
--- By default it will force retrigger the schedule if it has a forceRetrigger value
--- @param schedule table The schedule that is being done
function ENT:OnDoingSchedule(schedule)
	if (not schedule.forceRetrigger) then
		return
	end

	if (Schema.util.Throttle("RecalculatePath", schedule.forceRetrigger, self)) then
		return
	end

	if (not self:OnRetriggerSchedule(schedule)) then
		self:StartSchedule(schedule)
	end
end

--- Override this to prevent the schedule from being retriggered when it has a forceRetrigger value
function ENT:OnRetriggerSchedule(schedule)
end

function ENT:DoSchedule(schedule)
	self:OnDoingSchedule(schedule)

	BaseClass.DoSchedule(self, schedule)
end

function ENT:SelectSchedule()
	if (GetConVar("ai_disabled"):GetBool() or self:GetNPCState() == NPC_STATE_DEAD) then
		return
	end

	if (self.ShouldOverrideSelectSchedule) then
		if (self:ShouldOverrideSelectSchedule()) then
			return
		end
	end

	if (self:HandleEnemy()) then
		return
	end

	self:StartDefaultSchedule()
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

function ENT:OnTaskFailed(failCode, failReason)
	-- If we are blocked we might be stuck, so we set ourselves a few units higher and drop to ground
	if (failCode == FAIL_NO_ROUTE_BLOCKED) then
		local position = self:GetPos()
		self:SetPos(position + Vector(0, 0, 16))
		Schema.MakeFlushToGround(self, position)

		-- Let's keep track of how often we do this, and if it's too often, we should probably despawn
		self.expRouteBlockedCount = (self.expRouteBlockedCount or 0) + 1

		-- The first couple times, we try to break open a door if its in front of the monster
		if (self.expRouteBlockedCount <= 2) then
			-- Try to break open a door if it's in range of the monster
			local entities = ents.FindInSphere(self:GetPos(), self:GetAttackMeleeRange())

			for _, entity in ipairs(entities) do
				if (entity:IsDoor()) then
					self:SpeakFromTypedVoiceSet("AttackHitDoor", nil, true)
					self:HandleDoorAttack(entity)
					return
				end
			end
		end

		if (self.expRouteBlockedCount > 5) then
			local owner = self:GetDTEntity(0)

			ix.util.SchemaErrorNoHalt(
				"Monster (owned by %s) is stuck, despawning",
				IsValid(owner)
				and owner:Name()
				or "unknown"
			)
			self:Remove()
		end

		return
	end

	-- If we fail because we have no enemy, we should go back to patrolling
	if (failCode == FAIL_NO_ENEMY) then
		self:SpeakFromTypedVoiceSet("Lost", 5)
		self:SetEnemy(nil, false)
		self:StartDefaultSchedule()
		return
	end

	-- local enemy = self:GetEnemy()
	-- failReason = failReason or self:GetFailMessage(failCode)
	-- print("Unhandled task fail code", failCode, failReason, enemy)
end

--[[
	You should implement sounds based on animations
	For example for zombies:

	function ENT:HandleAnimEvent(event, eventTime, cycle, type, options)
		local isFootstep = event == self:AnimEventID("AE_ZOMBIE_STEP_RIGHT") or event == self:AnimEventID("AE_ZOMBIE_STEP_LEFT")
		local isFastFootstep = event == self:AnimEventID("AE_FASTZOMBIE_GALLOP_RIGHT") or event == self:AnimEventID("AE_FASTZOMBIE_GALLOP_LEFT")

		if (isFootstep or isFastFootstep) then
			return self:HandleAnimEventFootsteps(event, eventTime, cycle, type, options)
		end

		local isAttack = event == self:AnimEventID("AE_ZOMBIE_ATTACK_RIGHT") or event == self:AnimEventID("AE_ZOMBIE_ATTACK_LEFT")

		if (isAttack) then
			return self:HandleAnimEventAttack(event, eventTime, cycle, type, options)
		end

		print("Unhandled animation event", event, eventTime, cycle, type, options)
	end

	function ENT:HandleAnimEventFootsteps(event, eventTime, cycle, type, options)
		local isFastFootstep = event == self:AnimEventID("AE_FASTZOMBIE_GALLOP_RIGHT") or event == self:AnimEventID("AE_FASTZOMBIE_GALLOP_LEFT")
		local footstepType = isFastFootstep and "FootstepFast" or "Footstep"
		local footstepSide = (event == self:AnimEventID("AE_ZOMBIE_STEP_RIGHT") or event == self:AnimEventID("AE_FASTZOMBIE_GALLOP_RIGHT")) and "Right" or "Left"
		local sound = footstepType .. footstepSide

		if (self:HasTypedVoiceSet(sound)) then
			self:SpeakFromTypedVoiceSet(sound)
			return true
		elseif (isFastFootstep) then
			self:SpeakFromTypedVoiceSet("Footstep" .. footstepSide)
			return true
		end
	end

	function ENT:HandleAnimEventAttack(event, eventTime, cycle, type, options)
		-- Only play the monster attack, we play attack sounds when the attack is performed
		self:SpeakFromTypedVoiceSet("Attack", 5)
		return true
	end
--]]

--[[
	AI (Attack) Logic Schedules
--]]

-- Override this to customize schedules
function ENT:SetupSchedules()
	self.expSchedules.WaitStand = ai_schedule.New("expWaitStand")
	self.expSchedules.WaitStand:EngTask("TASK_WAIT", 1)

	self.expSchedules.Patrol = ai_schedule.New("expPatrol")
	self.expSchedules.Patrol:EngTask("TASK_WAIT_FOR_MOVEMENT", 0)
	self.expSchedules.Patrol:EngTask("TASK_WANDER", 480512) -- 480240 = 48 units to 240 units according to
	self.expSchedules.Patrol:EngTask("TASK_FACE_PATH", 0)
	self.expSchedules.Patrol:EngTask("TASK_WALK_PATH", 0)
	self.expSchedules.Patrol:EngTask("TASK_WAIT_FOR_MOVEMENT", 0)
	self.expSchedules.Patrol.forceRetrigger = 1 -- Force this schedule to retrigger every second (so the path updates)

	self.expSchedules.Chase = ai_schedule.New("expChase")
	self.expSchedules.Chase:EngTask("TASK_GET_PATH_TO_ENEMY", 0)
	self.expSchedules.Chase:EngTask("TASK_RUN_PATH_WITHIN_DIST", 1024) -- the distance seems not respected
	self.expSchedules.Chase:EngTask("TASK_WAIT_FOR_MOVEMENT", 0)
	self.expSchedules.Chase.forceRetrigger = 1                      -- Force this schedule to retrigger every second (so the path updates)

	local attackMelee1 = ai_schedule.New("expAttackMelee1")
	attackMelee1:EngTask("TASK_STOP_MOVING", 0)
	attackMelee1:EngTask("TASK_FACE_ENEMY", 0)
	attackMelee1:EngTask("TASK_MELEE_ATTACK1", 0)
	attackMelee1:EngTask("TASK_WAIT_FOR_MOVEMENT", 0)
	attackMelee1:EngTask("TASK_WAIT", 0.5)
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
	self.expDesiredAttackEnemy = enemy
	self:UpdateEnemyMemory(enemy, enemy:GetPos())
	self:StartSchedule(attackSchedule)

	self:StartAttackHandles(attackSchedule.expAttackData)
end

-- Old system where attack would inflict damage after the task was complete
-- function ENT:HandleAttackTaskComplete()
-- 	self.expRouteBlockedCount = nil

-- 	-- Trace the range of the attack to see if we hit anything
-- 	local attackData = self.expAttackSchedule.expAttackData

-- 	if (Schema.util.Throttle("HandleAttackTaskComplete", attackData.interval or 0.5, self)) then
-- 		return
-- 	end

-- 	local enemy = self.expDesiredAttackEnemy
-- 	local directionToEnemy = (enemy:EyePos() - self:EyePos()):GetNormalized()

-- 	-- Don't get stuck repeating this completed attack task
-- 	self.expDesiredAttackEnemy = nil
-- 	self.expAttackSchedule = nil

-- 	-- If the direction is behind us, don't bother attacking
-- 	if (self:GetForward():Dot(directionToEnemy) < 0) then
-- 		self:SpeakFromTypedVoiceSet("AttackMiss", 0.1)
-- 		return
-- 	end

-- 	if (not self:IsTargetInMeleeRange(enemy)) then
-- 		local traceData = {}
-- 		traceData.start = self:EyePos()
-- 		traceData.endpos = self:EyePos() + (directionToEnemy * attackData.range * self:GetModelScale())
-- 		traceData.filter = function(entity) return self:IsEnemyEntity(entity) end

-- 		local trace = util.TraceLine(traceData)

-- 		enemy = trace.Entity
-- 	end

-- 	if (not IsValid(enemy)) then
-- 		self:SpeakFromTypedVoiceSet("AttackMiss", 0.1)
-- 		return
-- 	end

-- 	if (enemy:IsDoor()) then
-- 		self:SpeakFromTypedVoiceSet("AttackHitDoor", nil, true)

-- 		if (enemy.expIsOpeningFromAttackUntil) then
-- 			if (enemy.expIsOpeningFromAttackUntil > CurTime()) then
-- 				self:AddEnemyOfNoInterest(enemy)
-- 				return
-- 			else
-- 				enemy.expIsOpeningFromAttackUntil = nil
-- 				enemy.expDoorHealth = nil
-- 			end
-- 		end

-- 		if (enemy:GetInternalVariable("m_bLocked")) then
-- 			enemy.expDoorHealth = enemy.expDoorHealth or 3
-- 			enemy.expDoorHealth = enemy.expDoorHealth - 1

-- 			if (enemy.expDoorHealth > 0) then
-- 				return
-- 			end

-- 			enemy:Fire("Unlock")
-- 		end

-- 		if (enemy:GetInternalVariable("m_eDoorState") == 0) then
-- 			enemy:OpenDoorAwayFrom(self:EyePos() - (self:GetForward() * 5))
-- 			enemy.expIsOpeningFromAttackUntil = CurTime() + 2
-- 		end

-- 		self:AddEnemyOfNoInterest(enemy)
-- 	else
-- 		self:SpeakFromTypedVoiceSet("AttackHit", nil, true)
-- 		enemy:TakeDamage(attackData.damage, self, self)
-- 	end
-- end

function ENT:HandleAttackTaskComplete()
	self.expRouteBlockedCount = nil

	local attackData = self.expAttackSchedule.expAttackData

	self:EndAttackHandles()

	-- Don't get stuck repeating this completed attack task
	self.expDesiredAttackEnemy = nil
	self.expAttackSchedule = nil
end

-- Called from the attack handle when it hits a door
function ENT:HandleDoorAttack(door)
	if door.expIsOpeningFromAttackUntil then
		if door.expIsOpeningFromAttackUntil > CurTime() then
			self:AddEnemyOfNoInterest(door)
			return
		else
			door.expIsOpeningFromAttackUntil = nil
			door.expDoorHealth = nil
		end
	end

	if door:GetInternalVariable("m_bLocked") then
		door.expDoorHealth = door.expDoorHealth or 3
		door.expDoorHealth = door.expDoorHealth - 1

		if door.expDoorHealth > 0 then
			return
		end

		door:Fire("Unlock")
	end

	if door:GetInternalVariable("m_eDoorState") == 0 then
		door:OpenDoorAwayFrom(self:EyePos() - (self:GetForward() * 5))
		door.expIsOpeningFromAttackUntil = CurTime() + 2
	end

	self:AddEnemyOfNoInterest(door)
end

function ENT:OnRemove()
	self:ClearAttackHandles()
end

--[[
	Enemy targeting
--]]

-- Defaults to hating every player
function ENT:GetRelationship(entity)
	-- This would cause AddEntityRelationship to not work
	-- if (entity:IsPlayer()) then
	-- 	return D_HT
	-- end

	-- return D_NU
end

function ENT:IsEnemyEntity(entity)
	if (not IsValid(entity) or entity == self) then
		return false
	end

	local disposition, priority = self:Disposition(entity)

	if (entity:IsPlayer()) then
		if (not entity:Alive()) then
			return false
		end
	elseif (entity:IsDoor()) then
		local isClosedDoor = entity:GetInternalVariable("m_eDoorState") == 0

		if (not isClosedDoor) then
			return false
		end
	end

	if (entity:GetMoveType() == MOVETYPE_NOCLIP) then
		return false
	end

	if (disposition == D_HT) then
		return true
	elseif (disposition == D_LI or disposition == D_NU) then
		return false
	end

	-- Check if this enemy is in the list of enemies we're not interested in, or clear it if it's expired
	if (self.expEnemiesOfNoInterest[entity]) then
		if (self.expEnemiesOfNoInterest[entity] < CurTime()) then
			self.expEnemiesOfNoInterest[entity] = nil
		else
			return false
		end
	end

	return true
end

function ENT:TargetNewEnemy(enemy)
	self:SetEnemy(enemy, true)
	self:UpdateEnemyMemory(enemy, enemy:GetPos())
end

-- Override this in the subclass
function ENT:ShouldFindEnemyInView()
	return true
end

function ENT:FindEnemyInView()
	-- This is an expensive operation, so we throttle it
	if (Schema.util.Throttle("FindEnemyInView", 1, self)) then
		return false
	end

	if (not self:ShouldFindEnemyInView()) then
		return false
	end

	local viewDistance = self:GetSenseRange()
	local viewAngle = self:EyeAngles()
	local fieldOfView = 1.221730476396 -- math.rad(70)

	local entities = ents.FindInCone(self:EyePos(), viewAngle:Forward(), viewDistance, math.cos(fieldOfView))

	for k, entity in pairs(entities) do
		if (not self:IsEnemyEntity(entity)) then
			continue
		end

		if (entity:IsPlayer()) then
			self:SpeakFromTypedVoiceSet("Alert", 5)
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

	if (not self:IsEnemyEntity(enemy)) then
		if (IsValid(enemy)) then
			self:HandleLostEnemy(enemy)
		end

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

		if (self:GetSchedule() ~= self.expSchedules.Chase) then
			self:StartSchedule(self.expSchedules.Chase)
		end

		return true
	end

	self:SpeakFromTypedVoiceSet("Lost", 5)
	self:SetEnemy(nil, false)

	return false
end

-- To save on performance, we let the monster not think if there's no players in the area
function ENT:ShouldHibernate()
	local hibernationRange = self:GetRangeSquared(1500)

	for _, entity in ipairs(player.GetAll()) do
		if (entity:GetMoveType() == MOVETYPE_NOCLIP) then
			continue
		end

		if (self:GetPos():DistToSqr(entity:GetPos()) < hibernationRange) then
			return false
		end
	end

	return true
end

function ENT:Think()
	local shouldHibernate = self:ShouldHibernate()

	if (shouldHibernate) then
		self:StopMoving()
		self:ClearSchedule()
		self:NextThink(CurTime() + 5)
		return true
	end

	local enemy = self:GetEnemy()

	if (enemy == nil) then
		if (not self:FindEnemyInView()) then
			self:SpeakFromTypedVoiceSet("Idle", 5)
		end

		return
	elseif (not self:IsEnemyEntity(enemy)) then
		self:SetEnemy(nil, false)
		self:SpeakFromTypedVoiceSet("Lost", 5)
		return
	end

	-- If we're chasing, and we're now in melee range, attack
	if (self:GetSchedule() == self.expSchedules.Chase) then
		if (self:IsTargetInMeleeRange(enemy)) then
			self:ClearSchedule()
			self:StartAttackSchedule(enemy)
		end
	end

	if (Schema.util.Throttle("UpdateEnemyMemory", 1, self)) then
		return
	end

	-- If we can see the enemy, update the memory so enemies cant run by us as we're finding the last known enemy position
	local traceData = {}
	traceData.endpos = enemy:EyePos()
	traceData.start = self:EyePos()
	traceData.filter = self

	local trace = util.TraceLine(traceData)

	if (not IsValid(trace.Entity)) then
		self:HandleLostEnemy(enemy)
		return
	end

	if (trace.Entity ~= enemy) then
		self:HandleLostEnemy(enemy)
		return
	end

	self.expLostEnemyTimes = nil

	self:UpdateEnemyMemory(enemy, enemy:GetPos())

	-- If they're in melee range, attack immediately if they run by us.
	if (self:IsTargetInMeleeRange(enemy)) then
		self:StartAttackSchedule(enemy)
	else
		self:SpeakFromTypedVoiceSet("Chase", 2)
	end
end

--- Handles losing the enemy. After losing them 5 times they go back to patrolling
--- @param enemy Entity The enemy we lost
function ENT:HandleLostEnemy(enemy)
	self.expLostEnemyTimes = (self.expLostEnemyTimes or 0) + 1

	if (self.expLostEnemyTimes < 5) then
		return
	end

	self:SetEnemy(nil, false)
	self:SpeakFromTypedVoiceSet("Lost", 5)
	self:StartDefaultSchedule()
	self.expLostEnemyTimes = nil
end

function ENT:StartDefaultSchedule()
	self:StartSchedule(self.expSchedules.Patrol)
end

function ENT:IsTargetInMeleeRange(target)
	return self:GetPos():DistToSqr(target:GetPos()) < self:GetRangeSquared(self:GetAttackMeleeRange())
end

function ENT:OnTakeDamage(damageInfo)
	if (self.expIsInvincible) then
		return
	end

	local damage = damageInfo:GetDamage()

	self:SetHealth(self:Health() - damage)

	local position = damageInfo:GetDamagePosition()
	local force = damageInfo:GetDamageForce()

	-- local knockbackMultiplier = 0.05

	-- if (self:GetVelocity():Length() < force:Length() * knockbackMultiplier) then
	-- 	self:SetVelocity(force * knockbackMultiplier)
	-- end

	if (not self.expDoesntBleed) then
		Schema.BloodEffect(self, position, 1, force)
	end

	local attacker = damageInfo:GetAttacker()

	hook.Run("OnMonsterTakeDamage", self, damageInfo, attacker)

	if (self:Health() <= 0) then
		self:HandleDeath()
		return damage
	end

	if (not self.expDoesntChase and IsValid(attacker)) then
		if (self:GetEnemy() == nil) then
			self:SpeakFromTypedVoiceSet("Pain", 2)

			self:TargetNewEnemy(attacker)
			self:StartSchedule(self.expSchedules.Chase)
		end
	end

	return damage
end

function ENT:HandleDeath()
	self:SpeakFromTypedVoiceSet("Die", 5)

	local corpse = self:CreateServerRagdoll()
	corpse:SetNetVar("monsterCorpse", self:EntIndex())
	local decayTime = ix.config.Get("corpseDecayTime", 60)

	if (decayTime > 0) then
		local visualDecayTime = math.min(decayTime * .1, 10)

		timer.Simple(decayTime - visualDecayTime, function()
			if (IsValid(corpse)) then
				Schema.DecayEntity(corpse, visualDecayTime)
			end
		end)
	end

	local ownerName = self:GetDisplayName()

	-- TODO: Make customizable from subclass:
	local width, height = 4, 1
	local corpseInventoryType = "monster:corpse:" .. width .. "x" .. height
	ix.inventory.Register(corpseInventoryType, width, height)

	ix.inventory.New(0, corpseInventoryType, function(inventory)
		inventory.vars.isMonsterCorpse = true

		if (not IsValid(corpse)) then
			local query = mysql:Delete("ix_inventories")
			query:Where("inventory_id", inventory:GetID())
			query:Execute()
			return
		end

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

		corpse.GetOwnerID = function(corpse)
			return 0
		end

		corpse.SetMoney = function(corpse, amount)
			hook.Run("OnMonsterCorpseMoneyChanged", corpse, amount, corpse.ixMoney)
			corpse.ixMoney = amount
		end

		corpse.GetMoney = function(corpse)
			return corpse.ixMoney or 0
		end

		-- TODO: Add loot based on subclass settings
		corpse:SetMoney(math.random(300, 600))

		corpse.OnOptionSelected = function(entity, client, option, data)
			if (client:IsRestricted() or not client:Alive() or not client:GetCharacter()) then
				return
			end

			if (option == L("searchCorpse", client) and corpse.StartSearchCorpse) then
				corpse:StartSearchCorpse(client)
				return
			end
		end

		corpse:CallOnRemove("expPersistentCorpse", function(ragdoll)
			hook.Run("OnMonsterCorpseRemoved", ragdoll)
		end)
	end)

	self:Remove()
end

function ENT:PrintChat(message, chatClass)
	local isYelling = chatClass == true or chatClass == MONSTER_CHAT_YELL
	local range = ix.config.Get("chatRange", 280) * (isYelling and 2 or 1)

	if (chatClass == MONSTER_CHAT_WHISPER) then
		range = range * 0.5
	end

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

function ENT:AddChat(message, listeners, chatClass)
	local isYelling = chatClass == true or chatClass == MONSTER_CHAT_YELL
	local range = ix.config.Get("chatRange", 280) * (isYelling and 2 or 1)

	if (chatClass == MONSTER_CHAT_WHISPER) then
		range = range * 0.5
	end

	ix.chat.Send(nil, "monster", message, false, listeners, {
		name = self:GetDisplayName(),
		yelling = isYelling == true,
		whispering = chatClass == MONSTER_CHAT_WHISPER
	})
end
