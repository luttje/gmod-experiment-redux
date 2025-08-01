function SWEP:DrawWorldModel(flags)

    if !self.CertainAboutAtts and !self.AskedAboutAtts then
        if !self:GetValue("PrimaryGrenade") and !self:GetValue("PrimaryMelee") then
            self:RequestWeapon()
            -- debugoverlay.Sphere(self:GetPos(), 16, 5, color_white, true)
        end
        self.AskedAboutAtts = true
    end

    -- Ugly workaround: OBS_MODE_IN_EYE spectate seems to call DrawWorldModel but doesn't actually render it?
    if LocalPlayer():GetObserverTarget() != self:GetOwner() or LocalPlayer():GetObserverMode() != OBS_MODE_IN_EYE then
        self:DrawCustomModel(true)
    end

    if self:GetValue("Laser") and self:GetTactical() then
        self:SetRenderBounds(Vector(-16, -16, -16), Vector(16, 16, 15000))
    else
        self:SetRenderBounds(Vector(-16, -16, -16), Vector(16, 16, 16))
    end

    self:DrawModel()
end

hook.Add("PostDrawTranslucentRenderables", "TacRP_TranslucentDraw", function()
    for _, ply in pairs(player.GetAll()) do
        local wep = ply:GetActiveWeapon()
        if ply != LocalPlayer() and IsValid(wep) and wep.ArcticTacRP then
            wep:DrawLasers(true)
            wep:DrawFlashlightsWM()
            wep:DrawFlashlightGlares()
            wep:DoScopeGlint()
        end
    end
end)