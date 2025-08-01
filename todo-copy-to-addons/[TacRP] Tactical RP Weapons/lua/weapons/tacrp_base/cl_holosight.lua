function SWEP:DoHolosight(mdl)
    if TacRP.OverDraw then return end
    -- if self:GetOwner() != LocalPlayer() then return end

    local ref = 64

    render.UpdateScreenEffectTexture()
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)

    render.SetBlend(0)

    render.SetStencilReferenceValue(ref)

    mdl:DrawModel()

    render.SetBlend(1)

    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilCompareFunction(STENCIL_EQUAL)

    -- cam.Start2D()

    -- surface.SetDrawColor(255, 255, 255)
    -- surface.DrawRect(0, 0, ScrW(), ScrH())

    -- render.SetColorMaterial()
    -- render.DrawScreenQuad()

    local img = self:GetValue("Holosight")

    if img then
        local pos = self:GetOwner():EyePos()
        local dir = (self:GetShootDir() + self:GetOwner():GetViewPunchAngles() * 0.5):Forward() -- mdl:GetAngles():Forward()

        pos = pos + dir * 9000

        -- cam.Start3D()

        render.SetMaterial(img)
        render.DrawQuadEasy(pos, -dir, 512, 512, Color(255, 255, 255), 180)

        -- cam.End3D()

        -- local toscreen = pos:ToScreen()

        -- local x = toscreen.x
        -- local y = toscreen.y

        -- local ss = TacRP.SS(32)
        -- local sx = x - (ss / 2)
        -- local sy = y - (ss / 2)

        -- local shakey = math.min(cross * 35, 3)

        -- sx = sx + math.Round(math.Rand(-shakey, shakey))
        -- sy = sy + math.Round(math.Rand(-shakey, shakey))

        -- surface.SetMaterial(img)
        -- surface.SetDrawColor(255, 255, 255, 255)
        -- surface.DrawTexturedRect(sx, sy, ss, ss)

        -- surface.SetDrawColor(0, 0, 0)
        -- surface.DrawRect(0, 0, w, sy)
        -- surface.DrawRect(0, sy + ss, w, h - sy)

        -- surface.DrawRect(0, 0, sx, h)
        -- surface.DrawRect(sx + ss, 0, w - sx, h)
    end
    -- cam.End2D()

    render.SetStencilEnable(false)
end
