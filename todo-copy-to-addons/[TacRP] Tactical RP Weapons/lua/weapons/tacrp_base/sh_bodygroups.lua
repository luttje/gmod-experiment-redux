function SWEP:DoBodygroups(wm, custom_wm)
    if wm == nil then
        wm = false
        self:DoBodygroups(true)
    end
    if !wm and (!IsValid(self:GetOwner()) or self:GetOwner():IsNPC()) then return end

    local dbg = self:GetValue("DefaultBodygroups")

    local mdl

    if wm then
        mdl = custom_wm or self
        dbg = self:GetValue("DefaultWMBodygroups")
    else
        mdl = self:GetVM()
    end

    if !IsValid(mdl) then return end

    mdl:SetBodyGroups(dbg or "")

    local sk = self:GetValue("DefaultSkin")

    local eles = self:GetElements()

    for i, k in ipairs(eles) do
        if wm then
            for _, j in pairs(k.BGs_WM or {}) do
                mdl:SetBodygroup(j[1], j[2] or 0)
            end
            if k.Skin_WM != nil then sk = k.Skin_WM end
        else
            for _, j in pairs(k.BGs_VM or {}) do
                mdl:SetBodygroup(j[1] or 0, j[2] or 0)
            end
            if k.Skin_VM != nil then sk = k.Skin_VM end
        end
    end

    mdl:SetSkin(sk)

    local bbg = self:GetValue("BulletBodygroups")

    if bbg then
        local amt = self:Clip1()

        if self:GetReloading() then
            amt = self:GetLoadedRounds()
        end

        for c, bgs in pairs(bbg) do
            if amt < c then
                mdl:SetBodygroup(bgs[1], bgs[2])
                break
            end
        end
    end

    self:RunHook("Hook_PostDoBodygroups")
end

function SWEP:GetElements(holster)
    if !self.AttachmentElements then return {} end
    local eles = {}

    for i, k in pairs(self.Attachments) do
        if k.Installed then
            table.Add(eles, k.InstalledElements or {})

            local atttbl = TacRP.GetAttTable(k.Installed)

            table.Add(eles, atttbl.InstalledElements or {})
        else
            table.Add(eles, k.UnInstalledElements or {})
        end
    end
    local eleatts = {}

    local foldstock = false
    for i, k in pairs(eles) do
        if self.AttachmentElements[k] then
            table.insert(eleatts, self.AttachmentElements[k])
            foldstock = foldstock or k == "foldstock"
        end
    end

    -- Bipod bodygroup
    if self:GetInBipod() and self.AttachmentElements["bipod"] then
        table.insert(eleatts, self.AttachmentElements["bipod"])
    end

    -- Hack: Always fold stock when weapon is holstered
    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer()
            and self:GetOwner():GetActiveWeapon() != self and !foldstock
            and self.AttachmentElements["foldstock"] then
        table.insert(eleatts, self.AttachmentElements["foldstock"])
    end

    table.sort(eleatts, function(a, b)
        return (a.SortOrder or 1) < (b.SortOrder or 1)
    end)

    return eleatts
end

function SWEP:DoBulletBodygroups()
    self:DoBodygroups(false)
end