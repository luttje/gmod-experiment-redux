function SWEP:Think()
    local owner = self:GetOwner()

    local stop = self:RunHook("Hook_PreThink")
    if stop then return end

    local cfm = self:GetCurrentFiremode()
    if self:GetValue("RunawayBurst") and cfm < 0 then
        if self:GetBurstCount() >= -cfm then
            self:SetBurstCount(0)
            self:SetNextPrimaryFire(CurTime() + self:GetValue("PostBurstDelay"))
        elseif self:GetBurstCount() > 0 and self:GetBurstCount() < -cfm then
            self:PrimaryAttack()
        end
    else
        if (owner:KeyReleased(IN_ATTACK) or (cfm < 0 and self:GetBurstCount() >= -cfm)) then
            if cfm < 0 and self:GetBurstCount() > 1 then
                if !self:GetValue("AutoBurst") then
                    self.Primary.Automatic = false
                end
                local add = 0
                if self:GetBurstCount() >= -cfm then
                    add = 60 / self:GetValue("RPM")
                end
                self:SetNextPrimaryFire(CurTime() + self:GetValue("PostBurstDelay") + add)
            end
            self:SetBurstCount(0)
        end
    end

    if self:GetPatternCount() > 0 and (self:GetRecoilAmount() == 0 or self:GetReloading()) then
        self:SetPatternCount(0)
    end

    self:ThinkRecoil()

    self:ThinkSprint()

    self:ThinkGrenade()

    self:ThinkReload()

    self:ThinkSights()

    self:ThinkFreeAim()

    self:ThinkBlindFire()

    self:ProcessTimers()

    self:ThinkHoldBreath()

    if self:GetValue("Melee") and self:GetOwner():KeyPressed(TacRP.IN_MELEE) then
        self:Melee()
        return
    end

    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and self:GetValue("TacticalThink") and self:GetTactical() then
        self:GetValue("TacticalThink")(self)
    end

    -- if IsValid(self:GetOwner()) and self:GetTactical() and self:GetValue("Minimap") and (SERVER and !game.SinglePlayer()) and (self.NextRadarBeep or 0) < CurTime() then
    --     self.NextRadarBeep = CurTime() + 1.5
    --     local f = RecipientFilter()
    --     f:AddPVS(self:GetPos())
    --     f:RemovePlayer(self:GetOwner())
    --     local s = CreateSound(self, "plats/elevbell1.wav", f)
    --     s:SetSoundLevel(75)
    --     s:PlayEx(0.25, 105)
    -- end

    if self:GetJammed() and !self:StillWaiting() then
        self:PlayAnimation("jam", 0.75, true, true)
        self:SetJammed(false)
    end

    if self:GetNextIdle() < CurTime() then
        self:Idle()
    end

    if self:GetValue("Bipod") and self:GetInBipod() and !self:CanBipod() then
        self:ExitBipod()
    end

    if CLIENT and (IsFirstTimePredicted() or game.SinglePlayer()) then

        self:ThinkNearWall()

        if IsValid(self.MuzzleLight) then
            if (self.MuzzleLightEnd or 0) < UnPredictedCurTime() then
                self.MuzzleLight:Remove()
                self.MuzzleLight = nil
            else
                self.MuzzleLight:SetBrightness( math.Remap( UnPredictedCurTime(), self.MuzzleLightStart, self.MuzzleLightEnd, self.MuzzleLightBrightness, 0 ) )
                self.MuzzleLight:SetFOV( math.Remap( UnPredictedCurTime(), self.MuzzleLightStart, self.MuzzleLightEnd, self.MuzzleLightFOV, 60 ) )
                self.MuzzleLight:Update()
            end
        end

        if !self.LoadedPreset then
            self.LoadedPreset = true

            if TacRP.ConVars["autosave"]:GetBool() and TacRP.ConVars["free_atts"]:GetBool() then
                self:LoadPreset()
                -- self:DoDeployAnimation()
            end
        end

        self:CanBipod()
    end

    self:RunHook("Hook_PostThink")
end