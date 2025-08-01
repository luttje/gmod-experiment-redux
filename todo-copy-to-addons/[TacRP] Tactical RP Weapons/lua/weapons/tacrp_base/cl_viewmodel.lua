function SWEP:ViewModelDrawn()
    if IsValid(self.QuickNadeModel) then
        self.QuickNadeModel:DrawModel()
    end

    self:DrawCustomModel(false)
    self:DrawLasers()

    local newactiveeffects = {}
    for _, effect in ipairs(self.ActiveEffects) do
        if !IsValid(effect) then continue end
        if !effect.VMContext then continue end

        effect:DrawModel()

        table.insert(newactiveeffects, effect)
    end

    self.ActiveEffects = newactiveeffects
end

function SWEP:DrawCustomModel(wm, custom_wm)

    if !wm and !IsValid(self:GetOwner()) then return end
    if !wm and self:GetOwner():IsNPC() then return end

    local mdl = self.VModel

    if wm then
        mdl = self.WModel
    end

    if !mdl then
        self:SetupModel(wm, custom_wm)

        mdl = self.VModel

        if wm then
            mdl = self.WModel
        end
    end

    local parentmdl = self

    if !wm then
        parentmdl = self:GetVM()
    elseif custom_wm then
        parentmdl = custom_wm
    end

    if !mdl then return end

    for _, model in pairs(mdl) do
        if !IsValid(model) then continue end
        local offset_pos = model.Pos
        local offset_ang = model.Ang
        local bone = model.Bone
        local atttbl = {}
        local slottbl = {}

        if model.WMBase then
            parentmdl = self:GetOwner()
        end

        parentmdl:SetupBones()
        parentmdl:InvalidateBoneCache()

        if !offset_pos or !offset_ang then
            local slot = model.Slot
            slottbl = self.Attachments[slot]
            atttbl = TacRP.GetAttTable(self.Attachments[slot].Installed)

            bone = slottbl.Bone

            if wm then
                bone = slottbl.WMBone or "ValveBiped.Bip01_R_Hand"
            end

            offset_pos = slottbl.Pos_VM
            offset_ang = slottbl.Ang_VM

            if wm then
                offset_pos = slottbl.Pos_WM
                offset_ang = slottbl.Ang_WM
            end

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
        end

        if !bone then continue end

        local boneindex = parentmdl:LookupBone(bone)
        if !boneindex then continue end

        local bonemat = parentmdl:GetBoneMatrix(boneindex)
        if !bonemat then continue end

        local bpos, bang
        bpos = bonemat:GetTranslation()
        bang = bonemat:GetAngles()

        local apos, aang = bpos, bang

        if offset_pos then
            apos:Add(bang:Forward() * offset_pos.x)
            apos:Add(bang:Right() * offset_pos.y)
            apos:Add(bang:Up() * offset_pos.z)
        end

        if offset_ang then
            aang:RotateAroundAxis(aang:Right(), offset_ang.p)
            aang:RotateAroundAxis(aang:Up(), offset_ang.y)
            aang:RotateAroundAxis(aang:Forward(), offset_ang.r)
        end

        local moffset = (atttbl.ModelOffset or Vector(0, 0, 0))
        if wm then
            moffset = moffset * (slottbl.WMScale or 1)
        else
            moffset = moffset * (slottbl.VMScale or 1)
        end

        apos:Add(aang:Forward() * moffset.x)
        apos:Add(aang:Right() * moffset.y)
        apos:Add(aang:Up() * moffset.z)

        model:SetPos(apos)
        model:SetAngles(aang)
        model:SetRenderOrigin(apos)
        model:SetRenderAngles(aang)

        if model.IsHolosight and !wm then
            cam.Start3D(EyePos(), EyeAngles(), self.ViewModelFOV, 0, 0, nil, nil, 1, 10000)
            cam.IgnoreZ(true)
            self:DoHolosight(model)
            cam.End3D()
            cam.IgnoreZ(true)
        end

        if !model.NoDraw then
            model:DrawModel()
        end
    end

    if !wm then
        self:DrawFlashlightsVM()
    end
end

function SWEP:PreDrawViewModel()
    if self:GetValue("ScopeHideWeapon") and self:IsInScope() then
        render.SetBlend(0)
    end

    -- Apparently setting this will fix the viewmodel position and angle going all over the place in benchgun.
    if TacRP.ConVars["dev_benchgun"]:GetBool() then
        if self.OriginalViewModelFOV == nil then
            self.OriginalViewModelFOV = self.ViewModelFOV
        end
        self.ViewModelFOV = self:GetOwner():GetFOV()
    elseif self.OriginalViewModelFOV then
        self.ViewModelFOV = self.OriginalViewModelFOV
        self.OriginalViewModelFOV = nil
    end
    -- self.ViewModelFOV = self:GetViewModelFOV()

    cam.IgnoreZ(true)
end

function SWEP:PostDrawViewModel()
    cam.IgnoreZ(false)

    if self:GetValue("ScopeHideWeapon") and self:IsInScope() then
        render.SetBlend(1)
    end
end

--[[
SWEP.SmoothedViewModelFOV = nil
function SWEP:GetViewModelFOV()
    local target = self.ViewModelFOV

    if TacRP.ConVars["dev_benchgun"]:GetBool() then
        target = self:GetOwner():GetFOV()
    end

    self.SmoothedViewModelFOV = self.SmoothedViewModelFOV or target
    local diff = math.abs(target - self.SmoothedViewModelFOV)
    self.SmoothedViewModelFOV = math.Approach(self.SmoothedViewModelFOV, target, diff * FrameTime() / 0.25)

    return self.SmoothedViewModelFOV
end
]]