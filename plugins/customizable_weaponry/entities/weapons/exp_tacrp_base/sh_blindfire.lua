local PLUGIN = PLUGIN

function SWEP:GetMuzzleOrigin()
	if not IsValid(self:GetOwner()) then
		return self:GetPos()
	end
	if self:GetOwner():IsNPC() then
		return SERVER and self:GetOwner():GetShootPos() or self:GetOwner():EyePos()
	end

	if self:GetBlindFire() then
		local pos = self:GetOwner():EyePos()
		local eyeang = self:GetOwner():EyeAngles()

		local testpos = pos + eyeang:Up() * 24

		if self:GetBlindFireLeft() or self:GetBlindFireRight() then
			testpos = pos + eyeang:Forward() * 24
		end

		local tr = util.TraceLine({
			start = pos,
			endpos = testpos,
			filter = self:GetOwner()
		})

		return tr.HitPos
	else
		return self:GetOwner():EyePos()
	end
end

--[[

ValveBiped.Bip01_Spine
ValveBiped.Bip01_Spine1
ValveBiped.Bip01_Spine2
ValveBiped.Bip01_Spine4
ValveBiped.Bip01_Neck1
ValveBiped.Bip01_Head1
ValveBiped.forward
ValveBiped.Bip01_R_Clavicle
ValveBiped.Bip01_R_UpperArm
ValveBiped.Bip01_R_Forearm
ValveBiped.Bip01_R_Hand
ValveBiped.Anim_Attachment_RH
ValveBiped.Bip01_L_Clavicle
ValveBiped.Bip01_L_UpperArm
ValveBiped.Bip01_L_Forearm
ValveBiped.Bip01_L_Hand
ValveBiped.Anim_Attachment_LH
ValveBiped.Bip01_R_Thigh
ValveBiped.Bip01_R_Calf
ValveBiped.Bip01_R_Foot
ValveBiped.Bip01_R_Toe0
ValveBiped.Bip01_L_Thigh
ValveBiped.Bip01_L_Calf
ValveBiped.Bip01_L_Foot
ValveBiped.Bip01_L_Toe0
ValveBiped.Bip01_L_Finger4
ValveBiped.Bip01_L_Finger41
ValveBiped.Bip01_L_Finger42
ValveBiped.Bip01_L_Finger3
ValveBiped.Bip01_L_Finger31
ValveBiped.Bip01_L_Finger32
ValveBiped.Bip01_L_Finger2
ValveBiped.Bip01_L_Finger21
ValveBiped.Bip01_L_Finger22
ValveBiped.Bip01_L_Finger1
ValveBiped.Bip01_L_Finger11
ValveBiped.Bip01_L_Finger12
ValveBiped.Bip01_L_Finger0
ValveBiped.Bip01_L_Finger01
ValveBiped.Bip01_L_Finger02
ValveBiped.Bip01_R_Finger4
ValveBiped.Bip01_R_Finger41
ValveBiped.Bip01_R_Finger42
ValveBiped.Bip01_R_Finger3
ValveBiped.Bip01_R_Finger31
ValveBiped.Bip01_R_Finger32
ValveBiped.Bip01_R_Finger2
ValveBiped.Bip01_R_Finger21
ValveBiped.Bip01_R_Finger22
ValveBiped.Bip01_R_Finger1
ValveBiped.Bip01_R_Finger11
ValveBiped.Bip01_R_Finger12
ValveBiped.Bip01_R_Finger0
ValveBiped.Bip01_R_Finger01
ValveBiped.Bip01_R_Finger02

--]]

local bone_list = {
	"ValveBiped.Bip01_R_UpperArm",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
}

local bone_mods = {
	-- ["ValveBiped.Bip01_R_UpperArm"] = Angle(0, -70, 0),
	-- ["ValveBiped.Bip01_R_Hand"] = Angle(-55, 45, -90),
	["ValveBiped.Bip01_R_UpperArm"] = Angle(45, -90, 0),
	["ValveBiped.Bip01_R_Hand"] = Angle(-90, 0, 0),
}

local bone_mods_left = {
	-- ["ValveBiped.Bip01_R_UpperArm"] = Angle(0, -70, 0),
	-- ["ValveBiped.Bip01_R_Hand"] = Angle(-55, 45, -90),
	["ValveBiped.Bip01_R_UpperArm"] = Angle(45, 0, 0),
	["ValveBiped.Bip01_R_Forearm"] = Angle(0, 0, 0),
	["ValveBiped.Bip01_R_Hand"] = Angle(0, -75, 0),
}

local bone_mods_right = {
	["ValveBiped.Bip01_R_UpperArm"] = Angle(-45, 0, 0),
	["ValveBiped.Bip01_R_Forearm"] = Angle(0, 0, 0),
	["ValveBiped.Bip01_R_Hand"] = Angle(35, 75, 0),
}

local bone_mods_kys = {
	["ValveBiped.Bip01_R_UpperArm"] = Angle(5, 0, 0),
	["ValveBiped.Bip01_R_Forearm"] = Angle(0, -5, 0),
	["ValveBiped.Bip01_R_Hand"] = Angle(0, -165, 0),
}
local bone_mods_kys_pistol = {
	["ValveBiped.Bip01_R_UpperArm"] = Angle(55, 0, 0),
	["ValveBiped.Bip01_R_Forearm"] = Angle(0, -75, 5),
	["ValveBiped.Bip01_R_Hand"] = Angle(45, -75, 0),
}
local bone_mods_kys_dual = {
	["ValveBiped.Bip01_L_UpperArm"] = Angle(-60, 0, -45),
	["ValveBiped.Bip01_L_Forearm"] = Angle(0, -60, -30),
	["ValveBiped.Bip01_L_Hand"] = Angle(-30, -45, -90),
	["ValveBiped.Bip01_R_UpperArm"] = Angle(55, 0, 30),
	["ValveBiped.Bip01_R_Forearm"] = Angle(0, -60, 30),
	["ValveBiped.Bip01_R_Hand"] = Angle(45, -75, 90),
}

local bone_mods_index = {
	[PLUGIN.BLINDFIRE_UP]    = bone_mods,
	[PLUGIN.BLINDFIRE_LEFT]  = bone_mods_left,
	[PLUGIN.BLINDFIRE_RIGHT] = bone_mods_right,
	[PLUGIN.BLINDFIRE_KYS]   = bone_mods_kys,
}

function SWEP:ToggleBoneMods(on)
	if on == PLUGIN.BLINDFIRE_NONE or on == false or on == nil then
		for _, i in ipairs(bone_list) do
			local boneindex = self:GetOwner():LookupBone(i)
			if not boneindex then continue end

			self:GetOwner():ManipulateBoneAngles(boneindex, Angle(0, 0, 0))
			-- self:GetOwner():ManipulateBonePosition(boneindex, Vector(0, 0, 0))
		end
	else
		local tbl = bone_mods_index[on]
		if on == PLUGIN.BLINDFIRE_KYS and self:GetValue("HoldTypeSuicide") == "duel" then
			tbl = bone_mods_kys_dual
		elseif on == PLUGIN.BLINDFIRE_KYS and self:GetValue("HoldType") == "revolver" then
			tbl = bone_mods_kys_pistol
		end

		for i, k in pairs(tbl) do
			local boneindex = self:GetOwner():LookupBone(i)
			if not boneindex then continue end

			self:GetOwner():ManipulateBoneAngles(boneindex, k)
		end

		-- for i, k in pairs(tbl[2]) do
		--     local boneindex = self:GetOwner():LookupBone(i)
		--     if !boneindex then continue end

		--     self:GetOwner():ManipulateBonePosition(boneindex, k)
		-- end
	end
end

function SWEP:GetBlindFireMode()
	if not self:GetBlindFire() then
		return PLUGIN.BLINDFIRE_NONE
	elseif self:GetBlindFireLeft() and self:GetBlindFireRight() then
		return PLUGIN.BLINDFIRE_KYS
	elseif self:GetBlindFireLeft() then
		return PLUGIN.BLINDFIRE_LEFT
	elseif self:GetBlindFireRight() then
		return PLUGIN.BLINDFIRE_RIGHT
	else
		return PLUGIN.BLINDFIRE_UP
	end
end

local bfmode = {
	[PLUGIN.BLINDFIRE_NONE] = { false, false, false },
	[PLUGIN.BLINDFIRE_UP] = { true, false, false },
	[PLUGIN.BLINDFIRE_LEFT] = { true, true, false },
	[PLUGIN.BLINDFIRE_RIGHT] = { true, false, true },
	[PLUGIN.BLINDFIRE_KYS] = { true, true, true },
}
function SWEP:SetBlindFireMode(mode)
	if not bfmode[mode] then
		print("[TacRP] WARNINGnot Trying to set invalid blindfire mode: " .. tostring(mode))
		mode = 0
	end
	self:SetBlindFire(bfmode[mode][1])
	self:SetBlindFireLeft(bfmode[mode][2])
	self:SetBlindFireRight(bfmode[mode][3])
end

function SWEP:CheckBlindFire(suicide)
	if not self:GetValue("CanBlindFire") and (not suicide or not self:GetValue("CanSuicide")) then return false end
	if ((self:GetIsSprinting() and not self:DoForceSightsBehavior())
			or self:GetAnimLockTime() > CurTime()
			or self:GetPrimedGrenade()
			or self:IsInScope()
			or self:GetSafe()) then
		return false
	end
	return true
end

function SWEP:ToggleBlindFire(bf)
	local kms = bf == PLUGIN.BLINDFIRE_KYS or bf == PLUGIN.BLINDFIRE_NONE
	if bf ~= PLUGIN.BLINDFIRE_NONE and (not self:CheckBlindFire(kms) or bf == self:GetBlindFireMode()) then return end

	local diff = bf ~= self:GetBlindFireMode()

	if diff then
		self:ToggleCustomize(false)
		self:ScopeToggle(0)
		self:SetBlindFireFinishTime(CurTime() + (bf == PLUGIN.BLINDFIRE_KYS and 1 or 0.3))
	end

	self:SetBlindFireMode(bf)
	self:ToggleBoneMods(bf)
	self:SetShouldHoldType()

	if diff then
		if self:StillWaiting(true) then
			self:IdleAtEndOfAnimation()
		else
			self:Idle()
		end
	end
end

function SWEP:ThinkBlindFire()
	if (self:GetOwner():KeyDown(IN_ZOOM) or self:GetOwner().TacRPBlindFireDown) and not tobool(self:GetOwner():GetInfo("tacrp_blindfiremenu")) then
		if CLIENT then self.LastHintLife = CurTime() end
		if self:GetOwner():KeyDown(IN_FORWARD) then
			self:ToggleBlindFire(PLUGIN.BLINDFIRE_UP)
		elseif self:GetOwner():KeyDown(IN_MOVELEFT) and not self:GetOwner():KeyDown(IN_MOVERIGHT) then
			self:ToggleBlindFire(PLUGIN.BLINDFIRE_LEFT)
		elseif self:GetOwner():KeyDown(IN_MOVERIGHT) and not self:GetOwner():KeyDown(IN_MOVELEFT) then
			self:ToggleBlindFire(PLUGIN.BLINDFIRE_RIGHT)
		elseif self:GetOwner():KeyDown(IN_SPEED) and self:GetOwner():KeyDown(IN_WALK) and not tobool(self:GetOwner():GetInfo("tacrp_idunwannadie")) then
			self:ToggleBlindFire(PLUGIN.BLINDFIRE_KYS)
		elseif self:GetOwner():KeyDown(IN_BACK) then
			self:ToggleBlindFire(PLUGIN.BLINDFIRE_NONE)
		end
	elseif (self:GetOwner():KeyDown(IN_ZOOM) or self:GetOwner().TacRPBlindFireDown) and self:GetOwner():GetInfo("tacrp_blindfiremenu") and self:GetOwner():GetCanZoom() then
		self:GetOwner():SetCanZoom(false)
	end
end
