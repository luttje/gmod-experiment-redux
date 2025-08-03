DEFINE_BASECLASS("exp_monster_base")

if (SERVER) then
	AddCSLuaFile()
end

ENT.Base = "exp_monster_base"
ENT.PrintName = "Experiment Runner"
ENT.Author = "Experiment Redux"
ENT.Category = "Experiment Redux"

ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:GetDisplayName()
	return "Runner"
end

if (not SERVER) then
	function ENT:GetPacData()
		self.expCharacterModel = self.expCharacterModel
			or MONSTER_SCIENTIST_MODELS[math.random(#MONSTER_SCIENTIST_MODELS)]

		local headBoneTransform = nil

		if (self.expHasNoHead or math.random() < 0.3) then
			self.expHasNoHead = true

			headBoneTransform = {
				["children"] = {
				},
				["self"] = {
					["FollowAnglesOnly"] = false,
					["DrawOrder"] = 0,
					["InvertHideMesh"] = false,
					["TargetEntityUID"] = "",
					["AimPartName"] = "",
					["FollowPartUID"] = "",
					["Bone"] = "head",
					["ScaleChildren"] = true,
					["UniqueID"] = pac.Hash(),
					["MoveChildrenToOrigin"] = false,
					["Position"] = Vector(0, 0, 0),
					["AimPartUID"] = "",
					["Angles"] = Angle(0, 0, 0),
					["Hide"] = false,
					["Name"] = "",
					["Scale"] = Vector(0, 0, 0),
					["EditorExpand"] = false,
					["ClassName"] = "bone3",
					["Size"] = 1,
					["PositionOffset"] = Vector(0, 0, 0),
					["IsDisturbing"] = false,
					["AngleOffset"] = Angle(0, 0, 0),
					["EyeAngles"] = false,
					["HideMesh"] = false,
				},
			}
		end

		return {
			[1] = {
				["children"] = {
					[1] = {
						["children"] = {
							[1] = headBoneTransform
						},
						["self"] = {
							["Skin"] = 0,
							["UniqueID"] = pac.Hash(),
							["NoLighting"] = false,
							["AimPartName"] = "",
							["IgnoreZ"] = false,
							["AimPartUID"] = "",
							["Materials"] = "models/experiment-redux/characters/guardian_scientist_sheet_bloody" ..
								math.random(1, 3) .. ";;;;;;;;",
							["Name"] = "replacement",
							["LevelOfDetail"] = 0,
							["NoTextureFiltering"] = false,
							["PositionOffset"] = Vector(0, 0, 0),
							["IsDisturbing"] = false,
							["EyeAngles"] = false,
							["DrawOrder"] = -0.1,
							["TargetEntityUID"] = "",
							["Alpha"] = 1,
							["Material"] = "",
							["Invert"] = false,
							["ForceObjUrl"] = false,
							["Bone"] = "head",
							["Angles"] = Angle(0, 0, 0),
							["AngleOffset"] = Angle(-0.10000000149012, 0, 0),
							["BoneMerge"] = true,
							["Color"] = Vector(1, 1, 1),
							["Position"] = Vector(-0.0001220703125, -25.66455078125, -3.0517578125e-05),
							["ClassName"] = "model2",
							["Brightness"] = 1,
							["Hide"] = false,
							["NoCulling"] = false,
							["Scale"] = Vector(0.89999997615814, 1, 1),
							["LegacyTransform"] = false,
							["EditorExpand"] = true,
							["Size"] = 1,
							["ModelModifiers"] = "",
							["Translucent"] = false,
							["BlendMode"] = "",
							["EyeTargetUID"] = "",
							["Model"] = self.expCharacterModel,
						},
					},
				},
				["self"] = {
					["DrawOrder"] = 0,
					["UniqueID"] = pac.Hash(),
					["Hide"] = false,
					["TargetEntityUID"] = "",
					["EditorExpand"] = true,
					["OwnerName"] = "self",
					["IsDisturbing"] = false,
					["Name"] = "my outfit",
					["Duplicate"] = false,
					["ClassName"] = "group",
				},
			},
		}
	end

	return
end

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:SetModel("models/zombie/fast.mdl")
	self:SetHealth(500)
	self:SetMaxHealth(500)
	self:Activate()

	self:SetAttackMeleeRange(35) -- Must be right up against the target, otherwise their hands wont reach the target
end

function ENT:SetupVoiceSounds()
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

	self:SetTypedVoiceSet("AttackHitDoor", {
		"NPC_BaseZombie.PoundDoor"
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
end

function ENT:HandleAnimEvent(event, eventTime, cycle, type, options)
	local isFootstep = event == self:AnimEventID("AE_ZOMBIE_STEP_RIGHT") or
		event == self:AnimEventID("AE_ZOMBIE_STEP_LEFT")
	local isFastFootstep = event == self:AnimEventID("AE_FASTZOMBIE_GALLOP_RIGHT") or
		event == self:AnimEventID("AE_FASTZOMBIE_GALLOP_LEFT")

	if (isFootstep or isFastFootstep) then
		return self:HandleAnimEventFootsteps(event, eventTime, cycle, type, options)
	end

	local isAttack = event == self:AnimEventID("AE_ZOMBIE_ATTACK_RIGHT") or
		event == self:AnimEventID("AE_ZOMBIE_ATTACK_LEFT")

	if (isAttack) then
		return self:HandleAnimEventAttack(event, eventTime, cycle, type, options)
	end

	-- print(self, "Unhandled animation event", event, eventTime, cycle, type, options)
end

function ENT:HandleAnimEventFootsteps(event, eventTime, cycle, type, options)
	local isFastFootstep = event == self:AnimEventID("AE_FASTZOMBIE_GALLOP_RIGHT")
		or event == self:AnimEventID("AE_FASTZOMBIE_GALLOP_LEFT")
	local footstepType = isFastFootstep and "FootstepFast" or "Footstep"
	local footstepSide = (event == self:AnimEventID("AE_ZOMBIE_STEP_RIGHT")
			or event == self:AnimEventID("AE_FASTZOMBIE_GALLOP_RIGHT")) and
		"Right" or "Left"
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
