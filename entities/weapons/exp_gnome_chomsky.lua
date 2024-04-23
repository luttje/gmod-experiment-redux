if (SERVER) then
	AddCSLuaFile()
end

DEFINE_BASECLASS("exp_base_holder")

SWEP.Base = "exp_base_holder"
SWEP.PrintName = "Gnome Chomsky"
SWEP.Instructions = "Hold and cherish, not much else."

SWEP.Primary.Delay = 1

SWEP.HoldingModel = "models/props_junk/gnome.mdl"
SWEP.HoldingAttachmentBone = "ValveBiped.Bip01_R_Hand"
SWEP.HoldingAttachmentOffset = Vector(5, 5, 1.5)
SWEP.HoldingAttachmentAngle = Angle(90, -120, 90)
SWEP.HoldingAttachmentScale = 0.6

SWEP.ViewModel = Model("models/weapons/c_grenade.mdl")
SWEP.HoldType = "grenade"
SWEP.HiddenBones = {
	"ValveBiped.Bip01_L_Clavicle",
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_L_Finger4",
	"ValveBiped.Bip01_L_Finger41",
	"ValveBiped.Bip01_L_Finger42",
	"ValveBiped.Bip01_L_Finger3",
	"ValveBiped.Bip01_L_Finger31",
	"ValveBiped.Bip01_L_Finger32",
	"ValveBiped.Bip01_L_Finger2",
	"ValveBiped.Bip01_L_Finger21",
	"ValveBiped.Bip01_L_Finger22",
	"ValveBiped.Bip01_L_Finger1",
	"ValveBiped.Bip01_L_Finger11",
	"ValveBiped.Bip01_L_Finger12",
	"ValveBiped.Bip01_L_Finger0",
	"ValveBiped.Bip01_L_Finger01",
	"ValveBiped.Bip01_L_Finger02",
    "ValveBiped.Grenade_body",
    "ValveBiped.Pin",
}

function SWEP:DoHitEffects()
    local trace = self.Owner:GetEyeTraceNoCursor()


	self:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
	timer.Simple(0.1, function()
        if (not IsValid(self)) then
            return
        end

        self:SendWeaponAnim(ACT_VM_THROW)
    end)
	timer.Simple(0.2, function()
        if (not IsValid(self)) then
            return
        end

        self:SendWeaponAnim(ACT_VM_IDLE)
    end)

    if (((trace.Hit or trace.HitWorld) and self.Owner:GetShootPos():Distance(trace.HitPos) <= 64)) then
        self:EmitSound("weapons/crossbow/hitbod2.wav")
    else
        self:EmitSound("npc/vort/claw_swing2.wav")
    end

    self.Owner:ViewPunch(Angle(5, 5, 0))
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self.Owner:SetAnimation(PLAYER_ATTACK1)

	self:DoHitEffects()

	if (not SERVER) then
		return
	end

	local client = self:GetOwner()

    if (not IsValid(client)) then
        return
    end

    if (self.Owner.LagCompensation) then
        self.Owner:LagCompensation(true)
    end

    local trace = client:GetEyeTraceNoCursor()
    local entity = trace.Entity

    if (IsValid(entity)) then
        if (entity:IsPlayer() and entity:Alive()) then
            local damageInfo = DamageInfo()
            damageInfo:SetAttacker(client)
            damageInfo:SetInflictor(self)
            damageInfo:SetDamage(6)
            damageInfo:SetDamageType(DMG_CLUB)
            damageInfo:SetDamageForce(client:GetAimVector() * 1000)
			damageInfo:SetDamagePosition(trace.HitPos)
            entity:TakeDamageInfo(damageInfo)
        end
    else
        client:FireBullets({
            Spread = Vector(0, 0, 0),
            Damage = 1,
            Tracer = 0,
            Force = 1,
            Num = 1,
            Src = client:GetShootPos(),
            Dir = client:GetAimVector()
        })
    end

	if (self.Owner.LagCompensation) then
		self.Owner:LagCompensation(false)
	end
end

function SWEP:SecondaryAttack() end
