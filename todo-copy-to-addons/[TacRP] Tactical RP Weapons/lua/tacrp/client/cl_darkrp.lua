local hold_tbl = {}
net.Receive("tacrp_spawnedwepatts", function()
    local ent_index = net.ReadUInt(12)
    hold_tbl[ent_index] = {}
    local count = net.ReadUInt(4)
    for i = 1, count do
        hold_tbl[ent_index][net.ReadUInt(4)] = net.ReadUInt(TacRP.Attachments_Bits)
    end

    if IsValid(Entity(ent_index)) then
        Entity(ent_index).Attachments = hold_tbl[ent_index]
    end
end)

local function makeattmdl(self, atttbl, slottbl)
    local model = atttbl.Model

    if atttbl.WorldModel then
        model = atttbl.WorldModel
    end

    local csmodel = ClientsideModel(model)

    if !IsValid(csmodel) then return end

    local scale = Matrix()
    local vec = Vector(1, 1, 1) * (atttbl.Scale or 1) * (slottbl.WMScale or 1)
    scale:Scale(vec)
    csmodel:EnableMatrix("RenderMultiply", scale)
    csmodel:SetNoDraw(true)

    local tbl = {
        Model = csmodel,
        Weapon = self
    }

    table.insert(TacRP.CSModelPile, tbl)

    return csmodel
end

hook.Add("onDrawSpawnedWeapon", "TacRP", function(ent)
    local wep_tbl = weapons.Get(ent:GetWeaponClass())
    if !wep_tbl or !wep_tbl.ArcticTacRP then return end

    ent:DrawModel()

    if !ent.Attachments and hold_tbl[ent:EntIndex()] then
        ent.Attachments = table.Copy(hold_tbl[ent:EntIndex()])
        hold_tbl[ent:EntIndex()] = nil
    end

    local count = table.Count(ent.Attachments or {})

    if count > 0 then
        ent.TacRP_CSAttModels = ent.TacRP_CSAttModels or {}
        for k, v in pairs(ent.Attachments) do
            local atttbl = TacRP.Attachments[TacRP.Attachments_Index[v]]
            local slottbl = wep_tbl.Attachments[k]
            if !atttbl or !atttbl.Model then continue end
            if !IsValid(ent.TacRP_CSAttModels[k]) then
                ent.TacRP_CSAttModels[k] = makeattmdl(ent, atttbl, slottbl)
            end
            local model = ent.TacRP_CSAttModels[k]

            local offset_pos = slottbl.Pos_WM
            local offset_ang = slottbl.Ang_WM
            local bone = slottbl.WMBone or "ValveBiped.Bip01_R_Hand"

            if !bone then continue end

            local boneindex = ent:LookupBone(bone)
            if !boneindex then continue end

            local bonemat = ent:GetBoneMatrix(boneindex)
            if bonemat then
                bpos = bonemat:GetTranslation()
                bang = bonemat:GetAngles()
            end

            local apos, aang

            apos = bpos + bang:Forward() * offset_pos.x
            apos = apos + bang:Right() * offset_pos.y
            apos = apos + bang:Up() * offset_pos.z

            aang = Angle()
            aang:Set(bang)

            aang:RotateAroundAxis(aang:Right(), offset_ang.p)
            aang:RotateAroundAxis(aang:Up(), offset_ang.y)
            aang:RotateAroundAxis(aang:Forward(), offset_ang.r)

            local moffset = (atttbl.ModelOffset or Vector(0, 0, 0)) * (slottbl.VMScale or 1)

            apos = apos + aang:Forward() * moffset.x
            apos = apos + aang:Right() * moffset.y
            apos = apos + aang:Up() * moffset.z

            model:SetPos(apos)
            model:SetAngles(aang)
            model:SetRenderOrigin(apos)
            model:SetRenderAngles(aang)

            model:DrawModel()
        end
    end

    if (EyePos() - ent:GetPos()):LengthSqr() <= 262144 then -- 512^2
        local ang = LocalPlayer():EyeAngles()

        ang:RotateAroundAxis(ang:Forward(), 180)
        ang:RotateAroundAxis(ang:Right(), 90)
        ang:RotateAroundAxis(ang:Up(), 90)

        cam.Start3D2D(ent:WorldSpaceCenter() + Vector(0, 0, (ent:OBBMaxs().z - ent:OBBMins().z) * 0.5 + 8) , ang, 0.1)
            -- surface.SetFont("TacRP_LondonBetween_32_Unscaled")
            surface.SetFont("TacRP_Myriad_Pro_32_Unscaled")

            local name = wep_tbl.PrintName .. (ent:Getamount() > 1 and (" ×" .. ent:Getamount()) or "")
            local w = surface.GetTextSize(name)
            surface.SetTextPos(-w / 2, 0)
            surface.SetTextColor(255, 255, 255, 255)
            surface.DrawText(name)
            if count > 0 then
                local str = count .. " Attachments"
                local w2 = surface.GetTextSize(str)
                surface.SetTextPos(-w2 / 2, 32)
                surface.SetTextColor(255, 255, 255, 255)
                surface.DrawText(str)
            end
        cam.End3D2D()
    end

    return true
end)