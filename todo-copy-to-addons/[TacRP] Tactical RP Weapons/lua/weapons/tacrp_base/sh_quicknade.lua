SWEP.GrenadeDownKey = IN_GRENADE1
SWEP.GrenadeMenuKey = IN_GRENADE2

function SWEP:PrimeGrenade()
    self.Primary.Automatic = true

    if !self:GetValue("CanQuickNade") and !self:GetValue("PrimaryGrenade") then return end
    if self:StillWaiting(nil, true) then return end
    if self:GetPrimedGrenade() then return end

    if engine.ActiveGamemode() == "terrortown" then
        if GetRoundState() == ROUND_PREP and
        ((TTT2 and !GetConVar("ttt_nade_throw_during_prep"):GetBool()) or (!TTT2 and GetConVar("ttt_no_nade_throw_during_prep"):GetBool())) then
            return
        end
        if !self:GetValue("PrimaryGrenade") and !self:CheckGrenade(nil, true) then
            self:SelectGrenade(nil, true)
        end
    end

    -- if self:SprintLock() then return end

    self:CancelReload()

    local nade = self:GetValue("PrimaryGrenade") and TacRP.QuickNades[self:GetValue("PrimaryGrenade")] or self:GetGrenade()

    if nade.Singleton then
        if !self:GetOwner():HasWeapon(nade.GrenadeWep) then return end
    elseif !TacRP.IsGrenadeInfiniteAmmo(nade) then
        local ammo = self:GetOwner():GetAmmoCount(nade.Ammo)
        if ammo < 1 then return end

        -- self:GetOwner():SetAmmo(ammo - 1, nade.Ammo)
    end

    local rate = self:GetValue("QuickNadeTimeMult") / (nade.ThrowSpeed or 1)
    if self:GetValue("QuickNadeTryImpact") and nade.CanSetImpact then
        rate = rate * 1.5
    end

    local t = self:PlayAnimation("prime_grenade", rate, true)

    self:SetPrimedGrenade(true)
    self:ToggleBlindFire(TacRP.BLINDFIRE_NONE)
    self:ScopeToggle(0)

    local ct = CurTime()

    self:SetStartPrimedGrenadeTime(ct)
    self:SetAnimLockTime(ct + (t * 0.75))
    self:SetNextPrimaryFire(ct + (t * 1.1))

    self:GetOwner():DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_THROW)

    if !nade.NoSounds then
        self:EmitSound(nade.PullSound or ("TacRP/weapons/grenade/pullpin-" .. math.random(1, 2) .. ".wav"), 65)
    end

    if CLIENT then return end

    self.CurrentGrenade = self:GetGrenade()
end

function SWEP:ThrowGrenade()
    local nade = self:GetValue("PrimaryGrenade") and TacRP.QuickNades[self:GetValue("PrimaryGrenade")] or self.CurrentGrenade or self:GetGrenade()

    local force = nade.ThrowForce
    local ent = nade.GrenadeEnt

    local src = self:GetOwner():EyePos()
    local ang = self:GetOwner():EyeAngles()
    local spread = 0

    local amount = 1

    local t = 0

    if !nade.OverhandOnly and (self.GrenadeThrowOverride == true or (self.GrenadeThrowOverride == nil and !self:GetOwner():KeyDown(self.GrenadeDownKey))) then
        t = self:PlayAnimation("throw_grenade_underhand", self:GetValue("QuickNadeTimeMult"), true, true)

        force = force / 2
        ang:RotateAroundAxis(ang:Right(), 20)
        if nade.UnderhandSpecial then
            force = force * 0.75
            ang:RotateAroundAxis(ang:Right(), -10)
            amount = math.random(2, 4)
            spread = 0.15
        end
    else
        ang:RotateAroundAxis(ang:Right(), 5)
        t = self:PlayAnimation("throw_grenade", self:GetValue("QuickNadeTimeMult"), true, true)
    end

    self.GrenadeThrowOverride = nil
    self.GrenadeDownKey = IN_GRENADE1

    if SERVER then
        if (self.GrenadeThrowCharge or 0) > 0 then
            force = force * (1 + self.GrenadeThrowCharge)
        end
        self.GrenadeThrowCharge = nil

        for i = 1, amount do

            local rocket = ents.Create(ent or "")

            if !IsValid(rocket) then return end

            local dispersion = Angle(math.Rand(-1, 1), math.Rand(-1, 1), 0)
            dispersion = dispersion * spread * 36

            rocket:SetPos(src)
            rocket:SetOwner(self:GetOwner())
            rocket:SetAngles(ang + dispersion)
            rocket:Spawn()
            rocket:SetPhysicsAttacker(self:GetOwner(), 10)

            if TacRP.IsGrenadeInfiniteAmmo(nade) then
                rocket.PickupAmmo = nil
                rocket.WeaponClass = nil -- dz ents
            end

            if self:GetValue("QuickNadeTryImpact") and nade.CanSetImpact then
                rocket.InstantFuse = false
                rocket.Delay = 0
                rocket.Armed = false
                rocket.ImpactFuse = true
            end

            if nade.TTTTimer then
                rocket:SetGravity(0.4)
                rocket:SetFriction(0.2)
                rocket:SetElasticity(0.45)
                rocket:SetDetonateExact(CurTime() + nade.TTTTimer)
                rocket:SetThrower(self:GetOwner())
            end

            local phys = rocket:GetPhysicsObject()

            if phys:IsValid() then
                phys:ApplyForceCenter((ang + dispersion):Forward() * force + self:GetOwner():GetVelocity())
                phys:AddAngleVelocity(VectorRand() * 1000)
            end

            if nade.Spoon then
                local mag = ents.Create("TacRP_droppedmag")

                if mag then
                    mag:SetPos(src)
                    mag:SetAngles(ang)
                    mag.Model = "models/weapons/tacint/flashbang_spoon.mdl"
                    mag.ImpactType = "spoon"
                    mag:SetOwner(self:GetOwner())
                    mag:Spawn()

                    local phys2 = mag:GetPhysicsObject()

                    if IsValid(phys2) then
                        phys2:ApplyForceCenter(ang:Forward() * force * 0.25 + VectorRand() * 25)
                        phys2:AddAngleVelocity(Vector(math.Rand(-300, 300), math.Rand(-300, 300), math.Rand(-300, 300)))
                    end
                end
            end
        end

        if !nade.NoSounds then
            self:EmitSound(nade.ThrowSound or ("tacrp/weapons/grenade/throw-" .. math.random(1, 2) .. ".wav"), 65)
        end

        if !nade.Singleton and !TacRP.IsGrenadeInfiniteAmmo(nade) then
            self:GetOwner():RemoveAmmo(1, nade.Ammo)
        end
    end

    if self:GetValue("PrimaryGrenade") then
        if !TacRP.IsGrenadeInfiniteAmmo(nade) and self:GetOwner():GetAmmoCount(nade.Ammo) == 0 then
            if SERVER then
                self:Remove()
            end
        else
            self:SetTimer(t, function()
                self:PlayAnimation("deploy", self:GetValue("DeployTimeMult"), true, true)
            end)
        end
    elseif nade.Singleton and self:GetOwner():HasWeapon(nade.GrenadeWep) then
        local nadewep = self:GetOwner():GetWeapon(nade.GrenadeWep)
        nadewep.OnRemove = nil -- TTT wants to switch to unarmed when the nade wep is removed - DON'T.
        if SERVER then
            nadewep:Remove()
        end
    elseif nade.GrenadeWep and self:GetOwner():HasWeapon(nade.GrenadeWep) and !TacRP.IsGrenadeInfiniteAmmo(nade) and self:GetOwner():GetAmmoCount(nade.Ammo) == 0 then
        if SERVER then
            self:GetOwner():GetWeapon(nade.GrenadeWep):Remove()
        end
    end
end

function SWEP:GetGrenade(index)
    index = index or self:GetGrenadeIndex()

    return TacRP.QuickNades[TacRP.QuickNades_Index[index]]
end

function SWEP:GetGrenadeIndex()
    return IsValid(self:GetOwner()) and self:GetOwner():GetNWInt("ti_nade", 1) or 1
end

function SWEP:GetNextGrenade(ind)
    ind = ind or self:GetGrenadeIndex()

    ind = ind + 1

    if ind > TacRP.QuickNades_Count then
        ind = 1
    elseif ind < 1 then
        ind = TacRP.QuickNades_Count
    end

    if !self:CheckGrenade(ind) then
        return self:GetNextGrenade(ind)
    end

    return self:GetGrenade(ind)
end

function SWEP:SelectGrenade(index, requireammo)
    if !self:GetValue("CanQuickNade") then return end
    if !IsFirstTimePredicted() then return end
    if self:GetPrimedGrenade() then return end

    local ind = self:GetOwner():GetNWInt("ti_nade", 1)

    if index then
        ind = index
    else
        if self:GetOwner():KeyDown(IN_WALK) then
            ind = ind - 1
        else
            ind = ind + 1
        end
    end

    if ind > TacRP.QuickNades_Count then
        ind = 1
    elseif ind < 1 then
        ind = TacRP.QuickNades_Count
    end

    if !self:CheckGrenade(ind, requireammo) then
        local nades = self:GetAvailableGrenades(requireammo)
        if #nades > 0 then
            ind = nades[1].Index
        end
    end

    self:GetOwner():SetNWInt("ti_nade", ind)
    self.Secondary.Ammo = self:GetGrenade().Ammo or "none"
end

function SWEP:CheckGrenade(index, checkammo)
    index = index or (self:GetValue("PrimaryGrenade") and TacRP.QuickNades_Index[self:GetValue("PrimaryGrenade")] or self:GetOwner():GetNWInt("ti_nade", 1))
    local nade = self:GetGrenade(index)
    if nade.Singleton then
        return self:GetOwner():HasWeapon(nade.GrenadeWep)
    end
    local hasammo = (nade.Ammo == nil or self:GetOwner():GetAmmoCount(nade.Ammo) > 0)
    if (nade.Secret and !hasammo and (!nade.SecretWeapon or !self:GetOwner():HasWeapon(nade.SecretWeapon))) or (nade.RequireStat and !self:GetValue(nade.RequireStat)) then
        return false
    end
    if checkammo and !TacRP.IsGrenadeInfiniteAmmo(index) and !hasammo then
        return false
    end
    return true
end

function SWEP:GetAvailableGrenades(checkammo)
    local nades = {}

    for i = 1, TacRP.QuickNades_Count do
        if self:CheckGrenade(i, checkammo) then
            table.insert(nades, self:GetGrenade(i))
        end
    end

    return nades
end

if CLIENT then

SWEP.QuickNadeModel = nil

end

function SWEP:ThinkGrenade()
    if !self:GetValue("CanQuickNade") then return end

    if CLIENT then
        if self:GetPrimedGrenade() and !IsValid(self.QuickNadeModel) and self:GetStartPrimedGrenadeTime() + 0.2 < CurTime() and self:GetGrenade().Model then
            local nade = self:GetGrenade()
            local vm = self:GetVM()

            local model = ClientsideModel(nade.Model or "models/weapons/tacint/v_quicknade_frag.mdl")

            if !IsValid(model) then return end

            model:SetParent(vm)
            model:AddEffects(EF_BONEMERGE)
            model:SetNoDraw(true)

            if nade.Material then
                model:SetMaterial(nade.Material)
            end

            self.QuickNadeModel = model

            local tbl = {
                Model = model,
                Weapon = self
            }

            table.insert(TacRP.CSModelPile, tbl)
        elseif !self:GetPrimedGrenade() and self.QuickNadeModel then
            SafeRemoveEntity(self.QuickNadeModel)
            self.QuickNadeModel = nil
        end
    end

    if self:GetOwner():KeyPressed(IN_GRENADE1) then
        self:PrimeGrenade()
    elseif !tobool(self:GetOwner():GetInfo("tacrp_nademenu")) and self:GetOwner():KeyPressed(self.GrenadeMenuKey) then
        self:SelectGrenade()
    elseif tobool(self:GetOwner():GetInfo("tacrp_nademenu")) and self.GrenadeMenuKey != IN_GRENADE2 and !self:GetOwner():KeyDown(self.GrenadeMenuKey) then
        self.GrenadeMenuKey = IN_GRENADE2
    end

    if CLIENT and self.GrenadeWaitSelect and self:GetOwner():HasWeapon(self.GrenadeWaitSelect) then
        input.SelectWeapon(self:GetOwner():GetWeapon(self.GrenadeWaitSelect))
        self.GrenadeWaitSelect = nil
    end

    if self:GetPrimedGrenade() and self:GetAnimLockTime() < CurTime() then
        self:ThrowGrenade()
        self:SetPrimedGrenade(false)
    end
end