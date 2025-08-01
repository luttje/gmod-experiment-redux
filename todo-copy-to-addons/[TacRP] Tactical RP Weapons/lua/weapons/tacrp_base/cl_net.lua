function SWEP:ReceiveWeapon(ids)
    for slot, slottbl in pairs(self.Attachments) do
        local attid = ids and ids[slot] or net.ReadUInt(TacRP.Attachments_Bits)

        if attid == 0 then
            slottbl.Installed = nil
        else
            slottbl.Installed = TacRP.Attachments_Index[attid]
        end
    end

    self:InvalidateCache()

    self:SetupModel(true)
    self:SetupModel(false)

    self.CertainAboutAtts = true
end

function SWEP:UpdateHolster()
    local ply = self:GetOwner()
    if IsValid(ply) and ply:IsPlayer() and ply:GetActiveWeapon() != self then
        local visible = self:GetValue("HolsterVisible")
        local slot = self:GetValue("HolsterSlot")

        if visible and slot then
            ply.TacRP_Holster = ply.TacRP_Holster or {}
            ply.TacRP_Holster[slot] = self
        end
    end
end

function SWEP:RequestWeapon()
    net.Start("tacrp_networkweapon")
    net.WriteEntity(self)
    net.SendToServer()
end