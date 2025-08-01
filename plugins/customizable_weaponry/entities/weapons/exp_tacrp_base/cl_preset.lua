local PLUGIN = PLUGIN

function SWEP:SavePreset(filename)
  if LocalPlayer() ~= self:GetOwner() then return end

  filename = filename or "autosave"

  local str = ""
  for i, k in pairs(self.Attachments) do
    if k.Installed then
      str = str .. k.Installed
    end

    str = str .. "\n"
  end

  filename = PLUGIN.PresetPath .. self:GetClass() .. "/" .. filename .. ".txt"

  file.CreateDir(PLUGIN.PresetPath .. self:GetClass())
  file.Write(filename, str)
end

function SWEP:LoadPreset(filename)
  if LocalPlayer() ~= self:GetOwner() then return end

  filename = PLUGIN.PresetPath .. self:GetClass() .. "/" .. "autosave" .. ".txt"

  if not file.Exists(filename, "DATA") then return end

  local f = file.Open(filename, "r", "DATA")
  if not f then return end

  local presetTbl = {}

  for i = 1, table.Count(self.Attachments) do
    local line = f:ReadLine()
    if not line then continue end
    presetTbl[i] = string.Trim(line, "\n")
  end

  local anyinstalled = false

  for i = 1, table.Count(self.Attachments) do
    if not self.Attachments[i] then continue end

    local att = presetTbl[i]
    if att == "" then
      self.Attachments[i].Installed = nil
      continue
    end


    if att == self.Attachments[i].Installed then continue end
    if not PLUGIN.GetAttTable(att) then continue end

    self.Attachments[i].Installed = att

    anyinstalled = true
  end

  f:Close()

  if not anyinstalled then return end

  net.Start("TacRP_receivepreset")
  net.WriteEntity(self)
  for i, k in pairs(self.Attachments) do
    if not k.Installed then
      net.WriteUInt(0, PLUGIN.Attachments_Bits)
    else
      local atttbl = PLUGIN.GetAttTable(k.Installed)
      net.WriteUInt(atttbl.ID or 0, PLUGIN.Attachments_Bits)
    end
  end
  net.SendToServer()

  self:SetupModel(false)
  self:SetupModel(true)

  self:InvalidateCache()

  self:SetBaseSettings()
end
