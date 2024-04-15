if (SERVER) then
	AddCSLuaFile()
end

if (CLIENT) then
	SWEP.Slot = 4
	SWEP.SlotPos = 2
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.PrintName = "Grenade"
SWEP.Instructions = "Primary Fire: Throw."
SWEP.Purpose = ""
SWEP.Contact = ""
SWEP.Author	= ""

SWEP.WorldModel = "models/weapons/w_grenade.mdl"
SWEP.ViewModel = "models/weapons/cstrike/c_eq_smokegrenade.mdl"
SWEP.UseHands = true

SWEP.AdminSpawnable = false
SWEP.Spawnable = false

SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 0
SWEP.Primary.Delay = 1
SWEP.Primary.Ammo = "grenade"

SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 1
SWEP.Secondary.Ammo = ""

SWEP.TimeBeforeDetonate = 3
SWEP.MinimumThrowGrace = 0.2
SWEP.MaximumThrowPower = 10
SWEP.ThrowPowerMultiplier = 40

function SWEP:Think()
	local curTime = CurTime()

	if (self.pinPulledButNotThrown and not self.Owner:KeyDown(IN_ATTACK)) then
        if (curTime < self.pinPulledButNotThrown) then
            return
        end

		self.pinPulledButNotThrown = nil
		self.timeBeforeCleanupAfterThrowing = curTime + (self.Primary.Delay / 2)
		self.Raised = curTime + self.Primary.Delay + 2

		self:EmitSound("WeaponFrag.Throw")

		self:SendWeaponAnim(ACT_VM_THROW)
		self:SetNextPrimaryFire(curTime + self.Primary.Delay)

        if (SERVER) then
            local throwPower = math.Clamp(curTime - self.pinPullTime, 0, self.MaximumThrowPower)
			throwPower = throwPower * self.ThrowPowerMultiplier

            self:CreateGrenade(throwPower)
		end

		self.Owner:SetAnimation(PLAYER_ATTACK1)
	elseif (type(self.timeBeforeCleanupAfterThrowing) == "number") then
        if (curTime < self.timeBeforeCleanupAfterThrowing) then
            return
        end

		self.timeBeforeCleanupAfterThrowing = nil

		self:SendWeaponAnim(ACT_VM_DRAW)

		if (SERVER) then
            Schema.grenade.HandleRemoveItem(self.Owner, self)

			self.Owner:RemoveAmmo(1, "grenade")

			if (self.Owner:GetAmmoCount("grenade") == 0) then
				self.Owner:StripWeapon(self:GetClass())
			end
		end
	end
end

function SWEP:Deploy()
	if (SERVER) then
		self:SetWeaponHoldType("grenade")
	end

	self:SendWeaponAnim(ACT_VM_DRAW)

	self.pinPulledButNotThrown = nil
	self.timeBeforeCleanupAfterThrowing = nil
end

function SWEP:Holster(switchingTo)
	self:SendWeaponAnim(ACT_VM_HOLSTER)

	self.pinPulledButNotThrown = nil
	self.timeBeforeCleanupAfterThrowing = nil

	return true
end

function SWEP:GetRaised()
	local curTime = CurTime()

	if (self.timeBeforeCleanupAfterThrowing or (self.Raised and self.Raised > curTime)) then
		return true
	end
end

function SWEP:Initialize()
	if (SERVER) then
		self:SetWeaponHoldType("grenade")
	end
end

-- Override this in the child weapons to dictate what happens when the thrown grenade detonates.
-- Note the 'dot' after SWEP. Since this function is called after the grenade has been thrown,
-- the SWEP weapon may have already been removed and invalid. This is why we don't allow the use
-- of 'self' in this function.
function SWEP.CreateEffectAtGrenadeEntity(entity, client)
    -- Entity is always valid, or this function won't be called
	-- However client may be nil if the thrower disconnected
	-- local position = entity:GetPos()
	-- local angles = entity:GetAngles()

	-- You'll likely want an explosion
    -- Schema.MakeExplosion(position, 1)

	-- Make smoke
	-- Schema.grenade.SpawnSmoke(position, 0.2)

	-- Probably fade the grenade entity out after a whil
	-- Schema.DecayEntity(entity, 30)
end

function SWEP:CreateGrenade(power)
    if (not SERVER) then
        return
    end

	local client = self.Owner
    local entity = Schema.grenade.CreateGrenadeEntity(client, power)
	local effectFunction = self.CreateEffectAtGrenadeEntity

    timer.Simple(self.TimeBeforeDetonate, function()
        if (not IsValid(entity)) then
            return
        end

		effectFunction(entity, client)
	end)
end

function SWEP:PrimaryAttack()
	local curTime = CurTime()

	if (not self.timeBeforeCleanupAfterThrowing) then
		self:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)

		self.pinPulledButNotThrown = curTime + self.MinimumThrowGrace
		self.pinPullTime = curTime
		self.timeBeforeCleanupAfterThrowing = true
	end

	return false
end

function SWEP:SecondaryAttack() end
