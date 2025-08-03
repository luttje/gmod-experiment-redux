DEFINE_BASECLASS("base_ai")

function ENT:InitializeAttackSystem()
	self.expAttackHandles = {}
	self.expAttackSchedule = nil
	self.expCurrentAttackData = nil

	timer.Simple(0.1, function()
		if IsValid(self) then
			self:SetupAttackHandles()
		end
	end)
end

--[[
	Attack Handles
	These are used to track collision with entities during attacks.
--]]
function ENT:CreateAttackHandle(name, boneIndex, offset, handleSize)
	if (not boneIndex or boneIndex == -1) then
		return
	end

	local handle = ents.Create("exp_attack_handle")

	if (not IsValid(handle)) then
		return
	end

	handle:Spawn()
	handle:SetOwnerMonster(self)
	handle:SetSize(handleSize)
	handle:FollowBone(self, boneIndex)
	handle:SetLocalPos(offset or Vector(0, 0, 0))

	self.expAttackHandles[name] = {
		entity = handle,
		boneIndex = boneIndex,
		offset = offset
	}

	return handle
end

function ENT:ClearAttackHandles()
	if (self.expAttackHandles) then
		for name, handleData in pairs(self.expAttackHandles) do
			if (IsValid(handleData.entity)) then
				handleData.entity:Remove()
			end
		end
	end

	self.expAttackHandles = {}
end

function ENT:StartAttackHandles(attackData)
	if (not self.expAttackHandles) then
		return
	end

	for name, handleData in pairs(self.expAttackHandles) do
		if (IsValid(handleData.entity)) then
			handleData.entity:StartAttack(attackData)
		end
	end

	self.expCurrentAttackData = attackData
end

function ENT:EndAttackHandles()
	if (not self.expAttackHandles) then
		return
	end

	for name, handleData in pairs(self.expAttackHandles) do
		if (IsValid(handleData.entity)) then
			handleData.entity:EndAttack()
		end
	end

	self.expCurrentAttackData = nil
end

--[[
	Damage and Death
--]]
function ENT:OnTakeDamage(damageInfo)
	if (self.expIsInvincible) then
		return
	end

	local damage = damageInfo:GetDamage()
	self:SetHealth(self:Health() - damage)

	local position = damageInfo:GetDamagePosition()
	local force = damageInfo:GetDamageForce()

	if (not self.expDoesntBleed) then
		Schema.BloodEffect(self, position, 1, force)
	end

	local attacker = damageInfo:GetAttacker()
	hook.Run("OnMonsterTakeDamage", self, damageInfo, attacker)

	if (self:Health() <= 0) then
		self:HandleDeath()
		return damage
	end

	-- Always target the attacker if they're valid, even if we have another target
	if (not self.expDoesntChase and IsValid(attacker) and self:IsValidTarget(attacker)) then
		self:SpeakFromTypedVoiceSet("Pain", 2)
		self:SetTargetEntity(attacker)
		self:StartSchedule(self.expSchedules.Chase)
	end

	return damage
end

function ENT:HandleDeath()
	self:SpeakFromTypedVoiceSet("Die", 5)
	local corpse = self:CreateServerRagdoll()
	corpse:SetNetVar("monsterCorpse", self:EntIndex())

	-- Handle corpse decay and inventory setup (keeping original logic)
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
	local width, height = 4, 1
	local corpseInventoryType = "monster:corpse:" .. width .. "x" .. height
	ix.inventory.Register(corpseInventoryType, width, height)

	ix.inventory.New(0, corpseInventoryType, function(inventory)
		inventory.vars.isMonsterCorpse = true

		if not IsValid(corpse) then
			local query = mysql:Delete("ix_inventories")
			query:Where("inventory_id", inventory:GetID())
			query:Execute()
			return
		end

		corpse.ixInventory = inventory
		corpse.StartSearchCorpse = function(corpse, client)
			if not IsValid(client) or not corpse.ixInventory or ix.storage.InUse(corpse.ixInventory) then
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

		corpse.GetInventory = function() return corpse.ixInventory end
		corpse.GetOwnerID = function() return 0 end
		corpse.SetMoney = function(corpse, amount)
			hook.Run("OnMonsterCorpseMoneyChanged", corpse, amount, corpse.ixMoney)
			corpse.ixMoney = amount
		end
		corpse.GetMoney = function() return corpse.ixMoney or 0 end

		corpse:SetMoney(math.random(300, 600))

		corpse.OnOptionSelected = function(entity, client, option, data)
			if client:IsRestricted() or not client:Alive() or not client:GetCharacter() then
				return
			end
			if option == L("searchCorpse", client) and corpse.StartSearchCorpse then
				corpse:StartSearchCorpse(client)
			end
		end

		corpse:CallOnRemove("expPersistentCorpse", function(ragdoll)
			hook.Run("OnMonsterCorpseRemoved", ragdoll)
		end)
	end)

	self:Remove()
end

--[[
	Door Interaction System
--]]
function ENT:HandleDoorAttack(door)
	if (door.expIsOpeningFromAttackUntil) then
		if (door.expIsOpeningFromAttackUntil > CurTime()) then
			self:IgnoreTarget(door)

			return
		else
			door.expIsOpeningFromAttackUntil = nil
			door.expDoorHealth = nil
		end
	end

	-- If the door is locked, the monster does damage until it opens
	local doorOpened = false

	if (door:GetInternalVariable("m_bLocked")) then
		-- TODO: Make the health configurable per door or door type
		door.expDoorHealth = door.expDoorHealth or 3
		door.expDoorHealth = door.expDoorHealth - 1

		if (door.expDoorHealth <= 0) then
			door:Fire("Unlock")
			doorOpened = true
		end
	else
		doorOpened = true
	end

	if (doorOpened and door:GetInternalVariable("m_eDoorState") == 0) then
		door:OpenDoorAwayFrom(self:EyePos() - (self:GetForward() * 5))
		door.expIsOpeningFromAttackUntil = CurTime() + 2
		-- Only ignore the door after we've successfully opened it
		self:IgnoreTarget(door, 5)
	end

	-- Don't ignore the door if we haven't opened it yet - keep attacking!
end

hook.Add("AcceptInput", "expDontAllowDoorsToCloseWhenOpenedByMonsters",
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
