local PLUGIN = PLUGIN

function SWEP:NetworkWeapon(sendto)
  net.Start("TacRP_networkweapon")
  net.WriteEntity(self)

  for slot, slottbl in pairs(self.Attachments) do
    if not slottbl.Installed then
      net.WriteUInt(0, PLUGIN.Attachments_Bits)
      continue
    end

    local atttbl = PLUGIN.GetAttTable(slottbl.Installed)

    net.WriteUInt(atttbl.ID, PLUGIN.Attachments_Bits)
  end

  if sendto then
    net.Send(sendto)
  else
    net.SendPVS(self:GetPos())
  end

  self:InvalidateCache()

  self:DoBodygroups(true)
  self:DoBodygroups(false)
end

function SWEP:ReceivePreset()
  for slot, slottbl in pairs(self.Attachments) do
    local attid = net.ReadUInt(PLUGIN.Attachments_Bits)

    if attid == 0 then
      if slottbl.Installed then
        self:Detach(slot, true)
      end
    else
      local att = PLUGIN.Attachments_Index[attid]
      local atttbl = PLUGIN.GetAttTable(att)

      if not atttbl then continue end

      if slottbl.Installed then
        self:Detach(slot, true)
      end

      self:Attach(slot, att, true, true)
    end
  end

  self:NetworkWeapon()
  PLUGIN:PlayerSendAttInv(self:GetOwner())

  self:InvalidateCache()
  self:SetBaseSettings()

  if self:GetValue("TryUnholster") then
    self:DoDeployAnimation()
  end

  self:RestoreClip(self.Primary.ClipSize)
end
