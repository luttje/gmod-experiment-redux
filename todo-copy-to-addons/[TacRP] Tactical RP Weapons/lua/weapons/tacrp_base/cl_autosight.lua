SWEP.AutoSightSlot = nil

SWEP.AutoSightPos = nil
SWEP.AutoSightAng = nil

SWEP.ClientProxyModel = nil

function SWEP:GenerateAutoSight()
    local slot

    self.AutoSightPos = nil
    self.AutoSightAng = nil

    for i, k in ipairs(self.Attachments) do
        if !k.Installed then continue end
        local atttbl = TacRP.GetAttTable(k.Installed)

        if atttbl.SightPos and atttbl.SightAng then
            slot = i
            break
        end
    end

    if !slot then return end

    local slottbl = self.Attachments[slot]

    if !slottbl.Installed then return end

    local bone = slottbl.Bone

    if !bone then return end

    local atttbl = TacRP.GetAttTable(slottbl.Installed)

    local mdl = ClientsideModel(self.ViewModel)
    mdl:SetPos(Vector(0, 0, 0))
    mdl:SetAngles(Angle(0, 0, 0))
    mdl:SetNoDraw(true)

    local anim = self:TranslateSequence("idle")
    local seq = mdl:LookupSequence(anim)

    mdl:ResetSequence(seq)

    mdl:SetupBones()

    if !IsValid(mdl) then return end

    local boneid = mdl:LookupBone(bone)

    local bpos = mdl:GetBoneMatrix(boneid):GetTranslation()
    local bang = self.CorrectiveBoneAng and Angle(self.CorrectiveBoneAng) or mdl:GetBoneMatrix(boneid):GetAngles()

    SafeRemoveEntity(mdl)

    local offset_pos = slottbl.Pos_VM
    local offset_ang = slottbl.Ang_VM

    for _, ele in ipairs(self:GetElements()) do
        if !ele.AttPosMods or !ele.AttPosMods[slot] then continue end
        if wm then
            if ele.AttPosMods[slot].Pos_WM then
                offset_pos = ele.AttPosMods[slot].Pos_WM
            end
            if ele.AttPosMods[slot].Ang_WM then
                offset_ang = ele.AttPosMods[slot].Ang_WM
            end
        else
            if ele.AttPosMods[slot].Pos_VM then
                offset_pos = ele.AttPosMods[slot].Pos_VM
            end
            if ele.AttPosMods[slot].Ang_VM then
                offset_ang = ele.AttPosMods[slot].Ang_VM
            end
        end
    end

    local apos, aang = bpos, bang

    apos:Add(bang:Forward() * offset_pos.x)
    apos:Add(bang:Right() * offset_pos.y)
    apos:Add(bang:Up() * offset_pos.z)

    aang:RotateAroundAxis(aang:Right(), offset_ang.p)
    aang:RotateAroundAxis(aang:Up(), offset_ang.y)
    aang:RotateAroundAxis(aang:Forward(), offset_ang.r)

    local moffset = (atttbl.ModelOffset or Vector(0, 0, 0)) * (slottbl.VMScale or 1)

    apos:Add(aang:Forward() * moffset.x)
    apos:Add(aang:Right() * moffset.y)
    apos:Add(aang:Up() * moffset.z)

    local vpos, vang = WorldToLocal(apos, aang, Vector(0, 0, 0), Angle(0, 0, 0))

    local x = vpos.x
    local y = vpos.y
    local z = vpos.z

    vpos.x = -y
    vpos.y = x
    vpos.z = z

    vpos = vpos + (self.CorrectivePos or Vector(0, 0, 0))
    vang = vang + (self.CorrectiveAng or Angle(0, 0, 0))

    self.AutoSightPos, self.AutoSightAng = -vpos, -vang
end

function SWEP:GetSightPositions()
    local apos, aang = self.AutoSightPos, self.AutoSightAng

    if apos and aang then
        return apos, aang
    elseif self:GetOwner() != LocalPlayer() then
        self:GenerateAutoSight() -- Not generated for spectators so must be done here
        return self.AutoSightPos or self.SightPos, self.AutoSightAng or self.SightAng
    else
        return self.SightPos, self.SightAng
    end
end

function SWEP:GetExtraSightPosition()
    local epos
    local eang

    local scale = 1

    for i, k in ipairs(self.Attachments) do
        if !k.Installed then continue end
        local atttbl = TacRP.GetAttTable(k.Installed)

        if atttbl.SightPos and atttbl.SightAng then
            epos = atttbl.SightPos
            eang = atttbl.SightAng
            scale = k.VMScale or 1
            break
        end
    end

    local pos = Vector(0, 0, 0)
    local ang = Angle(0, 0, 0)

    if epos then
        pos:Set(epos)
    end

    if eang then
        ang:Set(eang)
    end

    pos = pos * scale

    return pos, ang
end