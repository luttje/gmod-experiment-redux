function SWEP:Reload()
    if self:GetOwner():IsNPC() then
        self:NPC_Reload()
        return
    end

    if self:GetValue("Firemodes") and self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyPressed(IN_RELOAD) and self:GetFiremodeAmount() > 1 and !self:GetSafe() then
        self:SwitchFiremode()
        self:EmitSound("tacrp/weapons/pdw/fire_select-1.wav", 75, 100, 1, CHAN_ITEM)
        return
    end

    local stop = self:RunHook("Hook_PreReload")
    if stop then return end

    if !self:GetOwner():KeyPressed(IN_RELOAD) then
        return
    end

    if self:StillWaiting(true) then return end
    if !self:CanReloadInSprint() and self:GetIsSprinting() then return end
    if self:GetCapacity() <= 0 then return end
    if self:Clip1() >= self:GetCapacity() then return end
    if self:Ammo1() <= 0 and !self:GetInfiniteAmmo() then return end

    self:ToggleBlindFire(TacRP.BLINDFIRE_NONE)

    local mult = self:GetValue("ReloadTimeMult") / TacRP.ConVars["mult_reloadspeed"]:GetFloat()

    local anim = "reload"

    if self:GetValue("ShotgunReload") then
        anim = "reload_start"
    else
        self:SetTimer(self:GetValue("LoadInTime") * mult, function()
            self:SetLoadedRounds(math.min(self:GetCapacity(), self:Clip1() + self:Ammo1()))
            self:DoBulletBodygroups()
        end, "SetLoadedRounds")
        if self.ReloadUpInTime then
            self:SetTimer(self.ReloadUpInTime * mult, function()
                self:RestoreClip(self:GetCapacity())
                self:SetNthShot(0)
                self:SetEndReload(true)
            end, "ReloadUpIn")
        end
    end

    local t = self:PlayAnimation(anim, mult, true, true)

    self:GetOwner():DoAnimationEvent(self:GetValue("GestureReload"))

    if SERVER then
        self:SetTimer(self.DropMagazineTime * mult, function()
            self:DropMagazine()
        end, "DropMagazine")
    end

    self:SetLoadedRounds(self:Clip1())

    self:SetReloading(true)
    self:SetEndReload(false)

    self:DoBulletBodygroups()

    self:RunHook("Hook_StartReload")

    self:SetReloadFinishTime(CurTime() + (t * 0.95))
end

function SWEP:DropMagazine()
    -- if !IsFirstTimePredicted() and !game.SinglePlayer() then return end
    if self:GetValue("DropMagazineModel") then
        local dropamt = math.floor(self:Clip1() / self:GetValue("DropMagazineAmount"))
        local clip1 = self:Clip1()
        for i = 1, self:GetValue("DropMagazineAmount") do
            local mag = ents.Create("TacRP_droppedmag")

            if IsValid(mag) then
                local bone = "ValveBiped.Bip01_R_Hand"
                if i == 2 then bone = "ValveBiped.Bip01_L_Hand" end
                local matrix = self:GetOwner():GetBoneMatrix(self:GetOwner():LookupBone(bone) or -1)
                local pos, ang
                if matrix then
                    pos = matrix:GetTranslation()
                    ang = matrix:GetAngles()
                else
                    pos = self:GetOwner():EyePos() - (self:GetOwner():EyeAngles():Up() * 8)
                    ang = self:GetOwner():EyeAngles()
                end

                mag:SetPos(pos)
                mag:SetAngles(ang)
                mag.Model = self:GetValue("DropMagazineModel")
                mag.ImpactType = self:GetValue("DropMagazineImpact")
                mag:SetOwner(self:GetOwner())
                if clip1 > 0 and TacRP.ConVars["reload_dump"]:GetBool() then
                    local amt = (i == self:GetValue("DropMagazineAmount") and clip1) or dropamt
                    clip1 = clip1 - amt

                    if !self:GetInfiniteAmmo() then
                        mag.AmmoType = self:GetValue("Ammo")
                        mag.AmmoCount = amt
                    end
                end
                mag:Spawn()

                local phys = mag:GetPhysicsObject()

                if IsValid(phys) then
                    phys:AddAngleVelocity(Vector(math.Rand(-300, 300), math.Rand(-300, 300), math.Rand(-300, 300)))
                end
            end
        end
        self:SetClip1(clip1)
    end
end

function SWEP:RestoreClip(amt)
    local reserve = self:GetInfiniteAmmo() and math.huge or (self:Clip1() + self:Ammo1())

    local lastclip1 = self:Clip1()

    self:SetClip1(math.min(math.min(self:Clip1() + amt, self:GetCapacity()), reserve))

    if !self:GetInfiniteAmmo() then
        reserve = reserve - self:Clip1()
        self:GetOwner():SetAmmo(reserve, self.Primary.Ammo)
    end

    return self:Clip1() - lastclip1
end

function SWEP:Unload(ammotype)
    self:GetOwner():GiveAmmo(self:Clip1(), ammotype or self.Primary.Ammo)
    self:SetClip1(0)
end

function SWEP:EndReload()
    if self:GetValue("ShotgunReload") then
        local mult = self:GetValue("ReloadTimeMult") / TacRP.ConVars["mult_reloadspeed"]:GetFloat()
        if self:Clip1() >= self:GetCapacity() or (!self:GetInfiniteAmmo() and self:Ammo1() == 0) or self:GetEndReload() then
            if self:Clip1() == self:GetLoadedRounds() then
                self:PlayAnimation("reload_start", -0.75 * mult, true, true)
            else
                self:PlayAnimation("reload_finish", mult, true, true)
            end

            self:SetReloading(false)

            self:SetNthShot(0)

            self:DoBulletBodygroups()
        else
            local t = self:PlayAnimation("reload", mult, true)

            local res = self:GetValue("ShotgunThreeload") and
                    math.min(math.min(3, self:GetCapacity() - self:Clip1()), self:GetInfiniteAmmo() and math.huge or self:Ammo1())
                    or 1

            local delay = 0.9
            for i = 1, res do
                self:SetTimer(t * delay * ((i - 1) / 3) + 0.22, function()
                    self:RestoreClip(1)
                end, "ShotgunRestoreClip")
            end

            self:SetTimer(t * delay * (res / 3) + 0.22, function()
                self:SetLoadedRounds(self:GetLoadedRounds() + res)
                self:DoBulletBodygroups()
            end, "SetLoadedRounds")

            self:SetReloadFinishTime(CurTime() + (t * delay * (res / 3)) + 0.05)

            self:DoBulletBodygroups()
        end
    else
        if !self.ReloadUpInTime then
            self:RestoreClip(self:GetCapacity())
            self:SetNthShot(0)
        end
        self:SetReloading(false)
        self:SetEndReload(false)
    end

    self:RunHook("Hook_EndReload")
end

function SWEP:CancelReload(doanims, keeptime)
    if self:GetReloading() then

        local stop = false

        if doanims then
            if self:GetValue("ShotgunReload") then
                local mult = self:GetValue("ReloadTimeMult") / TacRP.ConVars["mult_reloadspeed"]:GetFloat()

                if self.CurrentAnimation == "reload_start" and self.ShotgunReloadCompleteStart then
                    self:SetEndReload(true)
                elseif self:Clip1() == self:GetLoadedRounds() then
                    self:PlayAnimation("reload_start", -0.75 * mult, true, true)
                    stop = true
                else
                    self:PlayAnimation("reload_finish", mult, true, true)
                    stop = true
                end
            else
                self:Idle()
                stop = true
            end
        else
            stop = true
        end

        if stop then
            self:KillTimer("SetLoadedRounds")
            self:KillTimer("ShotgunRestoreClip")
            self:KillTimer("ReloadUpIn")
            self:KillTimer("DropMagazine")
            self:SetReloading(false)
            self:SetEndReload(false)
            self:SetNthShot(0)
            self:DoBulletBodygroups()
            if !keeptime then
                self:SetReloadFinishTime(0)
            end
        end
    end
end

function SWEP:ThinkReload()
    if self:GetReloading() and self:GetReloadFinishTime() < CurTime() then
        self:EndReload()
    end
end

function SWEP:GetInfiniteAmmo()
    return TacRP.ConVars["infiniteammo"]:GetBool() or self:GetValue("InfiniteAmmo")
end

function SWEP:GetCapacity(base)
    if base then
        return self:GetBaseValue("ClipSize")
    else
        return self:GetValue("ClipSize")
    end
end

-- Override to disable auto-reload for one reason or another.
function SWEP:ShouldAutoReload()
    return true
end