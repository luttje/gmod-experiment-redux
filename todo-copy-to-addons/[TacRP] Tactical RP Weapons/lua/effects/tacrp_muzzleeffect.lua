function EFFECT:Init(data)
    local wpn = data:GetEntity()

    if !IsValid(wpn) then self:Remove() return end

    if wpn:GetOwner() == LocalPlayer() and wpn:GetValue("ScopeHideWeapon") and wpn:IsInScope() then
        self:Remove()
        return
    end

    local muzzle = TacRP.MuzzleEffects[data:GetFlags() or 1] or "muzzleflash_pistol"
    if wpn.GetValue then
        muzzle = wpn:GetValue("MuzzleEffect")
    end

    local att = data:GetAttachment() or 1

    local wm = false

    if (LocalPlayer():ShouldDrawLocalPlayer() or wpn.Owner != LocalPlayer()) then
        wm = true
        att = data:GetHitBox()
    end

    local parent = wpn

    if !wm then
        parent = LocalPlayer():GetViewModel()
    end

    if wpn.GetMuzzleDevice then
        parent = wpn:GetMuzzleDevice(wm)
    else
        parent = self
    end

    -- if !IsValid(parent) then return end

    if muzzle then
        ParticleEffectAttach(muzzle, PATTACH_POINT_FOLLOW, parent, att)
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
    return false
end