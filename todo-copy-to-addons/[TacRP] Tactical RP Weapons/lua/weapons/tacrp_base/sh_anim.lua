function SWEP:PlayAnimation(seq, mult, lock, doidle)
    mult = mult or 1
    lock = lock or false
    local anim = self:TranslateSequence(seq)
    doidle = doidle or false
    local reverse = false

    if mult < 0 then
        reverse = true
        mult = -mult
    end

    local vm = self:GetVM()

    if !IsValid(vm) then return end

    if isstring(anim) then
        seq = vm:LookupSequence(anim)
    end

    if seq == -1 then return end

    self.CurrentAnimation = anim
    self.CurrentSeqeunce = seq

    local time = vm:SequenceDuration(seq)

    time = time * mult

    vm:SendViewModelMatchingSequence(seq)

    if reverse then
        vm:SetCycle(1)
        vm:SetPlaybackRate(-1 / mult)
    else
        vm:SetCycle(0)
        vm:SetPlaybackRate(1 / mult)
    end

    if lock then
        self:SetAnimLockTime(CurTime() + time)
        -- self:SetNextSecondaryFire(CurTime() + time)
    else
        self:SetAnimLockTime(0)
        -- self:SetNextSecondaryFire(0)
    end

    if doidle and !self.NoIdle then
        self:SetNextIdle(CurTime() + time)
    else
        self:SetNextIdle(math.huge)
    end

    self:SetLastProceduralFireTime(0)

    return time
end

function SWEP:IdleAtEndOfAnimation()
    local vm = self:GetVM()
    local cyc = vm:GetCycle()
    local duration = vm:SequenceDuration()
    local rate = vm:GetPlaybackRate()

    local time = (1 - cyc) * (duration / rate)

    self:SetNextIdle(CurTime() + time)
end

function SWEP:Idle()
    if self:GetPrimedGrenade() then return end

    if self:GetBlindFire() then
        if self:Clip1() == 0 then
            self:PlayAnimation("blind_dryfire", 0, false, false)
        else
            self:PlayAnimation("blind_idle")
        end
    else
        if self:Clip1() == 0 then
            self:PlayAnimation("dryfire", 0, false, false)
        else
            self:PlayAnimation("idle")
        end
    end

    self:SetReady(true)
end