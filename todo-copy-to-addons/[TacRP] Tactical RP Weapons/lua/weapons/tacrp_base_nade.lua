AddCSLuaFile()

SWEP.Base = "tacrp_base"

// spawnable
SWEP.Spawnable = false
SWEP.AdminOnly = false

// names and stuff
SWEP.PrintName = "Arctic's Tactical RP Base Grenade"
SWEP.Category = "Tactical RP"

SWEP.SubCatTier = "9Special"
SWEP.SubCatType = "9Throwable"

SWEP.Description = ""

SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_fraggrenade.mdl"

SWEP.ViewModelFOV = 65

SWEP.NoRanger = true
SWEP.NoStatBox = true
SWEP.NPCUsable = false

SWEP.Slot = 4

SWEP.FreeAim = false

SWEP.DrawCrosshair = true
SWEP.DrawCrosshairInSprint = true
SWEP.CrosshairStatic = true

SWEP.Scope = false
SWEP.CanBlindFire = false
SWEP.CanQuickNade = false
SWEP.CanMeleeAttack = false

SWEP.Firemode = 0

SWEP.Ammo = ""
SWEP.PrimaryGrenade = ""

SWEP.Sway = 0

SWEP.QuickNadeTimeMult = 0.6

function SWEP:Equip(newowner)
    local wep = self:GetOwner():GetActiveWeapon()
    if self:GetOwner():IsPlayer() and wep != self and wep.ArcticTacRP and !wep:CheckGrenade(nil, true) then
        self:GetOwner():SetNWInt("ti_nade", TacRP.QuickNades[self.PrimaryGrenade].Index)
    end

    if engine.ActiveGamemode() == "terrortown" and SERVER then
        if self:IsOnFire() then
            self:Extinguish()
        end

        self.fingerprints = self.fingerprints or {}

        if !table.HasValue(self.fingerprints, newowner) then
            table.insert(self.fingerprints, newowner)
        end

        if self:HasSpawnFlags(SF_WEAPON_START_CONSTRAINED) then
            local flags = self:GetSpawnFlags()
            local newflags = bit.band(flags, bit.bnot(SF_WEAPON_START_CONSTRAINED))
            self:SetKeyValue("spawnflags", newflags)
        end
    end

    if engine.ActiveGamemode() == "terrortown" and SERVER and IsValid(newowner) and (self.StoredAmmo or 0) > 0 and self.Primary.Ammo != "none" then
        newowner:GiveAmmo(self.StoredAmmo, self.Primary.Ammo)
        self.StoredAmmo = 0
    end
end

function SWEP:ThinkSprint()
end

function SWEP:ThinkSights()
end

function SWEP:ThinkGrenade()
    if self:GetPrimedGrenade() and self:GetAnimLockTime() < CurTime() then
        if !self:GetOwner():KeyDown(self.GrenadeDownKey) then
            self:ThrowGrenade()
            self:SetPrimedGrenade(false)
        elseif SERVER and self.GrenadeDownKey == IN_ATTACK then
            self.GrenadeThrowCharge = math.Clamp(CurTime() - self:GetAnimLockTime(), 0, 0.25) * 2
        end
    elseif !self:GetPrimedGrenade() then
        local nade = TacRP.QuickNades[self:GetValue("PrimaryGrenade")]
        if !TacRP.IsGrenadeInfiniteAmmo(nade) and self:GetOwner():GetAmmoCount(nade.Ammo) == 0 then
            if SERVER then
                self:Remove()
            elseif CLIENT and IsValid(self:GetOwner():GetPreviousWeapon()) and self:GetOwner():GetPreviousWeapon():IsWeapon() then
                input.SelectWeapon(self:GetOwner():GetPreviousWeapon())
            end
        end
    end
end

function SWEP:PrimaryAttack()

    if engine.ActiveGamemode() == "terrortown" and GetRoundState() == ROUND_PREP and
    ((TTT2 and !GetConVar("ttt_nade_throw_during_prep"):GetBool()) or (!TTT2 and GetConVar("ttt_no_nade_throw_during_prep"):GetBool())) then
        return
    end

    self.Primary.Automatic = false
    self.Secondary.Automatic = false
    self.GrenadeDownKey = IN_ATTACK
    self.GrenadeThrowOverride = false
    self.GrenadeThrowCharge = 0

    if self:GetValue("Melee") and self:GetOwner():KeyDown(IN_USE) then
        self:Melee()
        return
    end

    if self:StillWaiting() then
        return
    end

    self:SetBaseSettings()

    local stop = self:RunHook("Hook_PreShoot")
    if stop then return end

    self:PrimeGrenade()
    self:SetNextPrimaryFire(self:GetAnimLockTime())
    self:SetNextSecondaryFire(self:GetAnimLockTime())

    self:RunHook("Hook_PostShoot")

    if game.SinglePlayer() and SERVER then self:CallOnClient("PrimaryAttack") end
end

function SWEP:SecondaryAttack()

    if engine.ActiveGamemode() == "terrortown" and GetRoundState() == ROUND_PREP and GetConVar("ttt_no_nade_throw_during_prep"):GetBool() then
        return
    end

    self.Primary.Automatic = false
    self.Secondary.Automatic = false
    self.GrenadeDownKey = IN_ATTACK2
    self.GrenadeThrowOverride = true

    if self:StillWaiting() then
        return
    end

    self:SetBaseSettings()

    local stop = self:RunHook("Hook_PreShoot")
    if stop then return end

    self:PrimeGrenade()
    self:SetNextPrimaryFire(self:GetAnimLockTime())
    self:SetNextSecondaryFire(self:GetAnimLockTime())

    self:RunHook("Hook_PostShoot")

    if game.SinglePlayer() and SERVER then self:CallOnClient("SecondaryAttack") end
end

function SWEP:Reload()
end

function SWEP:PreDrop()
    if SERVER and IsValid(self:GetOwner()) and self.Primary.Ammo != "" and self.Primary.Ammo != "none" then
        local ammo = self:Ammo1()
        if ammo > 0 then
            self.StoredAmmo = 1
            self:GetOwner():RemoveAmmo(1, self.Primary.Ammo)
        end
    end
end