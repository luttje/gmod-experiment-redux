DEFINE_BASECLASS("exp_monster_base")

if (SERVER) then
	AddCSLuaFile()
end

ENT.Base = "exp_monster_base"
ENT.PrintName = "Experiment Giant Mutant"
ENT.Author = "Experiment Redux"
ENT.Category = "Experiment Redux"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.ModelScale = 2

function ENT:GetDisplayName()
	return "Giant Mutant"
end

if (not SERVER) then
    function ENT:GetPacData()
        return {
			[1] = {
				["children"] = {
					[1] = {
						["children"] = {
						},
						["self"] = {
							["Skin"] = 0,
							["Invert"] = false,
							["LightBlend"] = 1,
							["CellShade"] = -0.1,
							["OwnerName"] = "self",
							["AimPartName"] = "",
							["IgnoreZ"] = false,
							["AimPartUID"] = "",
							["Passes"] = 1,
							["Name"] = "",
							["NoTextureFiltering"] = false,
							["DoubleFace"] = false,
							["PositionOffset"] = Vector(0, 8.3000001907349, 0),
							["IsDisturbing"] = false,
							["Fullbright"] = false,
							["EyeAngles"] = false,
							["DrawOrder"] = 0,
							["TintColor"] = Vector(0, 0, 0),
							["UniqueID"] = "3279694713",
							["Translucent"] = false,
							["LodOverride"] = -1,
							["BlurSpacing"] = 0,
							["Alpha"] = 1,
							["Material"] = "",
							["UseWeaponColor"] = false,
							["UsePlayerColor"] = false,
							["UseLegacyScale"] = false,
							["Bone"] = "spine 2",
							["Color"] = Vector(255, 255, 255),
							["Brightness"] = 1,
							["BoneMerge"] = false,
							["BlurLength"] = 0,
							["Position"] = Vector(0.5576171875, -2.36474609375, 5.4425659179688),
							["AngleOffset"] = Angle(1.6000000238419, 30.299999237061, 30),
							["AlternativeScaling"] = false,
							["Hide"] = false,
							["OwnerEntity"] = false,
							["Scale"] = Vector(1, 1, 1),
							["ClassName"] = "model",
							["EditorExpand"] = false,
							["Size"] = 1.825,
							["ModelFallback"] = "",
							["Angles"] = Angle(66.944885253906, 104.19304656982, -71.3447265625),
							["TextureFilter"] = 3,
							["Model"] = "models/gibs/hgibs_spine.mdl",
							["BlendMode"] = "",
						},
					},
					[2] = {
						["children"] = {
						},
						["self"] = {
							["Jiggle"] = false,
							["DrawOrder"] = 0,
							["AlternativeBones"] = false,
							["FollowPartName"] = "",
							["OwnerName"] = "self",
							["AimPartName"] = "",
							["FollowPartUID"] = "",
							["Bone"] = "pelvis",
							["ScaleChildren"] = false,
							["FollowAnglesOnly"] = false,
							["AngleOffset"] = Angle(0, 0, 0),
							["Position"] = Vector(0, 0, 0),
							["AimPartUID"] = "",
							["UniqueID"] = "206527392",
							["Hide"] = false,
							["Name"] = "",
							["Scale"] = Vector(1, 1, 1),
							["MoveChildrenToOrigin"] = false,
							["Angles"] = Angle(0, 0, 0),
							["Size"] = 1.775,
							["PositionOffset"] = Vector(0, 0, 0),
							["IsDisturbing"] = false,
							["EditorExpand"] = false,
							["EyeAngles"] = false,
							["ClassName"] = "bone",
						},
					},
					[3] = {
						["children"] = {
						},
						["self"] = {
							["Jiggle"] = false,
							["DrawOrder"] = 0,
							["AlternativeBones"] = false,
							["FollowPartName"] = "",
							["OwnerName"] = "self",
							["AimPartName"] = "",
							["FollowPartUID"] = "",
							["Bone"] = "spine 4",
							["ScaleChildren"] = false,
							["FollowAnglesOnly"] = false,
							["AngleOffset"] = Angle(0, 0, 0),
							["Position"] = Vector(0, 0, 0),
							["AimPartUID"] = "",
							["UniqueID"] = "4056377950",
							["Hide"] = false,
							["Name"] = "",
							["Scale"] = Vector(1, 1, 1),
							["MoveChildrenToOrigin"] = false,
							["Angles"] = Angle(0, 0, 0),
							["Size"] = 1.2,
							["PositionOffset"] = Vector(0, 0, 0),
							["IsDisturbing"] = false,
							["EditorExpand"] = false,
							["EyeAngles"] = false,
							["ClassName"] = "bone",
						},
					},
					[4] = {
						["children"] = {
						},
						["self"] = {
							["HidePhysgunBeam"] = false,
							["Skin"] = 0,
							["Invert"] = false,
							["HideBullets"] = false,
							["FallApartOnDeath"] = false,
							["DeathRagdollizeParent"] = true,
							["SprintSpeed"] = 0,
							["BlendMode"] = "",
							["HideEntity"] = false,
							["AimPartUID"] = "",
							["DrawWeapon"] = true,
							["EyeTargetUID"] = "",
							["Name"] = "",
							["LodOverride"] = -1,
							["AllowOggWhenMuted"] = false,
							["NoTextureFiltering"] = false,
							["DoubleFace"] = false,
							["WalkSpeed"] = 0,
							["Color"] = Vector(255, 255, 255),
							["Fullbright"] = false,
							["EyeAngles"] = false,
							["IgnoreZ"] = false,
							["IsDisturbing"] = false,
							["DrawOrder"] = 0,
							["RunSpeed"] = 0,
							["DrawPlayerOnDeath"] = false,
							["HideRagdollOnDeath"] = false,
							["ClassName"] = "entity",
							["MuteSounds"] = false,
							["DrawShadow"] = true,
							["Alpha"] = 1,
							["Material"] = "",
							["InverseKinematics"] = false,
							["SuppressFrames"] = false,
							["AimPartName"] = "",
							["Bone"] = "head",
							["EyeTargetName"] = "",
							["MuteFootsteps"] = false,
							["CrouchSpeed"] = 0,
							["Weapon"] = false,
							["Position"] = Vector(0, 0, 0),
							["UniqueID"] = "3024190472",
							["OwnerName"] = "self",
							["Hide"] = false,
							["Brightness"] = 1,
							["Scale"] = Vector(1, 1, 1),
							["Translucent"] = false,
							["EditorExpand"] = false,
							["Size"] = self.ModelScale,
							["UseLegacyScale"] = false,
							["Angles"] = Angle(0, 0, 0),
							["AnimationRate"] = 1,
							["Model"] = "",
							["RelativeBones"] = true,
						},
					},
				},
				["self"] = {
					["DrawOrder"] = 0,
					["UniqueID"] = "364212636",
					["AimPartUID"] = "",
					["Hide"] = false,
					["Duplicate"] = false,
					["ClassName"] = "group",
					["OwnerName"] = "self",
					["IsDisturbing"] = false,
					["Name"] = "my outfit",
					["EditorExpand"] = true,
				},
			},
		}
    end

	return
end

function ENT:Initialize()
    BaseClass.Initialize(self)

    self:SetModel("models/zombie/classic.mdl")
    self:SetHealth(1500)
    self:SetModelScale(self.ModelScale)
	self:Activate()
end

function ENT:SetupVoiceSounds()
    self:SetTypedVoiceSet("Idle", {
        "Zombie.Idle"
    })

    self:SetTypedVoiceSet("Pain", {
        "Zombie.Pain"
    })

    self:SetTypedVoiceSet("Die", {
        "Zombie.Die"
    })

    self:SetTypedVoiceSet("Alert", {
        "Zombie.Alert"
    })

    self:SetTypedVoiceSet("Chase", {
        -- "npc/zombie/moan_loop1.wav",
    })

    self:SetTypedVoiceSet("Lost", {
        -- "npc/zombie/zo_attack1.wav"
    })

    self:SetTypedVoiceSet("Attack", {
        "Zombie.Attack"
    })

    self:SetTypedVoiceSet("AttackMiss", {
        "Zombie.AttackMiss"
    })

    self:SetTypedVoiceSet("AttackHit", {
        "Zombie.AttackHit"
    })

    self:SetTypedVoiceSet("Victory", {
        -- "npc/fast_zombie/leap1.wav"
    })

    self:SetTypedVoiceSet("FootstepLeft", {
        "Zombie.ScuffLeft"
    })

    self:SetTypedVoiceSet("FootstepRight", {
        "Zombie.ScuffRight"
    })

    self:SetTypedVoiceSet("FootstepFastLeft", {
        "Zombie.FootstepLeft"
    })

    self:SetTypedVoiceSet("FootstepFastRight", {
        "Zombie.FootstepRight"
    })
end
