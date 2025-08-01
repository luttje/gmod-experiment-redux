SWEP.Flashlights = {} -- tracks projectedlights
-- {{att = int, light = ProjectedTexture}}

function SWEP:GetHasFlashlights()
    for i, k in pairs(self.Attachments) do
        if !k.Installed then continue end

        local atttbl = TacRP.GetAttTable(k.Installed)

        if atttbl.Flashlight then return true end
    end

    return false
end

function SWEP:CreateFlashlights()
    self:KillFlashlights()
    self.Flashlights = {}

    local total_lights = 0

    for i, k in pairs(self.Attachments) do
        if !k.Installed then continue end

        local atttbl = TacRP.GetAttTable(k.Installed)

        if atttbl.Flashlight then
            local newlight = {
                att = i,
                light = ProjectedTexture(),
                col = Color(255, 255, 255),
                br = 4,
            }
            total_lights = total_lights + 1

            local l = newlight.light
            if !IsValid(l) then continue end

            table.insert(self.Flashlights, newlight)

            l:SetFOV(60)

            l:SetFarZ(1024)
            l:SetNearZ(4)

            l:SetQuadraticAttenuation(100)

            l:SetColor(Color(255, 255, 255))
            l:SetTexture("effects/flashlight001")
            l:SetBrightness(4)
            l:SetEnableShadows(true)
            l:Update()

            local g_light = {
                Weapon = self,
                ProjectedTexture = l
            }

            table.insert(TacRP.FlashlightPile, g_light)
        end
    end

    if total_lights > 2 then -- you are a madman
        for i, k in pairs(self.Flashlights) do
            if k.light:IsValid() then k.light:SetEnableShadows(false) end
        end
    end
end

function SWEP:KillFlashlights()
    self:KillFlashlightsVM()
    -- self:KillFlashlightsWM()
end

function SWEP:KillFlashlightsVM()
    if !self.Flashlights then return end

    for i, k in pairs(self.Flashlights) do
        if k.light and k.light:IsValid() then
            k.light:Remove()
        end
    end

    self.Flashlights = nil
end

function SWEP:DrawFlashlightsVM()

    if !self:GetTactical() then
        self:KillFlashlights()
        return
    end

    if !self.Flashlights then
        self:CreateFlashlights()
    end

    for i, k in pairs(self.Flashlights) do
        local model = self.Attachments[k.att].VModel

        local pos, ang

        if !IsValid(model) then
            pos = self:GetOwner():EyePos()
            ang = self:GetOwner():EyeAngles()
        else
            pos = model:GetPos()
            ang = model:GetAngles()
        end

        local tr = util.TraceLine({
            start = self:GetOwner():EyePos(),
            endpos = self:GetOwner():EyePos() - -ang:Forward() * 128,
            mask = MASK_OPAQUE,
            filter = LocalPlayer(),
        })
        if tr.Fraction < 1 then -- We need to push the flashlight back
            local tr2 = util.TraceLine({
                start = self:GetOwner():EyePos(),
                endpos = self:GetOwner():EyePos() + -ang:Forward() * 128,
                mask = MASK_OPAQUE,
                filter = LocalPlayer(),
            })
            -- push it as back as the area behind us allows
            pos = pos + -ang:Forward() * 128 * math.min(1 - tr.Fraction, tr2.Fraction)
        end

        -- ang:RotateAroundAxis(ang:Up(), 90)

        k.light:SetPos(pos)
        k.light:SetAngles(ang)
        k.light:Update()

        -- local col = k.col

        -- local dl = DynamicLight(self:EntIndex())

        -- if dl then
        --     dl.pos = pos
        --     dl.r = col.r
        --     dl.g = col.g
        --     dl.b = col.b
        --     dl.brightness = k.br or 2
        --     -- print(z / maxz)
        --     dl.Decay = 1000 / 0.1
        --     dl.dietime = CurTime() + 0.1
        --     dl.size = (k.br or 2) * 64
        -- end
    end
end

function SWEP:DrawFlashlightsWM()
    if self:GetOwner() != LocalPlayer() then return end

    if !self.Flashlights then
        self:CreateFlashlights()
    end

    for i, k in ipairs(self.Flashlights) do
        local model = (k.slottbl or {}).WModel

        if !IsValid(model) then continue end

        local pos, ang

        if !model then
            pos = self:GetOwner():EyePos()
            ang = self:GetOwner():EyeAngles()
        else
            pos = model:GetPos()
            ang = model:GetAngles()
        end

        -- ang:RotateAroundAxis(ang:Up(), 90)

        local tr = util.TraceLine({
            start = pos,
            endpos = pos + ang:Forward() * 16,
            mask = MASK_OPAQUE,
            filter = LocalPlayer(),
        })
        if tr.Fraction < 1 then -- We need to push the flashlight back
            local tr2 = util.TraceLine({
                start = pos,
                endpos = pos - ang:Forward() * 16,
                mask = MASK_OPAQUE,
                filter = LocalPlayer(),
            })
            -- push it as back as the area behind us allows
            pos = pos + -ang:Forward() * 16 * math.min(1 - tr.Fraction, tr2.Fraction)
        else
            pos = tr.HitPos
        end

        k.light:SetPos(pos)
        k.light:SetAngles(ang)
        k.light:Update()
    end
end

local flaremat = Material("tacrp/particle_flare")
function SWEP:DrawFlashlightGlare(pos, ang, strength, dot)
    strength = strength or 1

    local diff = EyePos() - pos
    local wep = LocalPlayer():GetActiveWeapon()
    --local dot = math.Clamp((-ang:Forward():Dot(EyeAngles():Forward()) - 0.707) / (1 - 0.707), 0, 1) ^ 2
    if TacRP.ConVars["flashlight_blind"]:GetBool() then
        dot = dot ^ 4
        local tr = util.QuickTrace(pos, diff, {self:GetOwner(), LocalPlayer()})
        local s = math.Clamp(1 - diff:Length() / 328, 0, 1) ^ 1 * dot * 2000 * math.Rand(0.95, 1.05)
        if IsValid(wep) and wep.ArcticTacRP and wep:IsInScope() and wep:GetValue("ScopeOverlay") then
            s = s + math.Clamp(1 - diff:Length() / 4096, 0, 1) ^ 1.2 * wep:GetSightAmount() * dot * 3000 * math.Rand(0.95, 1.05)
        end
        if tr.Fraction == 1 then
            s = TacRP.SS(s)
            local toscreen = pos:ToScreen()
            cam.Start2D()
                surface.SetMaterial(flaremat)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(toscreen.x - s / 2, toscreen.y - s / 2, s, s)
            cam.End2D()
        end
    end

    local rad = math.Rand(0.9, 1.1) * 128 * strength
    local a = 50 + strength * 205

    pos = pos + ang:Forward() * 2
    pos = pos + diff:GetNormalized() * (2 + 14 * strength)

    render.SetMaterial(flaremat)
    render.DrawSprite(pos, rad, rad, Color(255, 255, 255, a))
end

function SWEP:DrawFlashlightGlares()
    if !self:GetOwner():IsPlayer() then return end
    for i, k in pairs(self.Attachments) do
        if !k.Installed then continue end

        local atttbl = TacRP.GetAttTable(k.Installed)

        local src, dir
        if atttbl.Flashlight and self:GetTactical() then
            if IsValid(k.WModel) then
                src, dir = k.WModel:GetPos(), self:GetShootDir()
            else
                src, dir = self:GetTracerOrigin(), self:GetShootDir()
            end
        else
            continue
        end

        local power = 1
        local dot = -dir:Forward():Dot(EyeAngles():Forward())
        local dot2 = dir:Forward():Dot((EyePos() - src):GetNormalized())
        dot = (dot + dot2) / 2
        if dot < 0 then continue end

        power = power * math.Clamp(dot * 2 - 1, 0, 1)
        local distsqr = (src - EyePos()):LengthSqr()
        power = power * ((1 - math.Clamp(distsqr / 4194304, 0, 1)) ^ 1.25)

        self:DrawFlashlightGlare(src, dir, power, dot)
    end
end

local glintmat = Material("effects/blueflare1")
local glintmat2 = Material("tacrp/scope_flare")
function SWEP:DoScopeGlint()
    --if self:GetOwner() == LocalPlayer() then return end
    if !TacRP.ConVars["glint"]:GetBool() then return end
    if !self:GetValue("ScopeOverlay") then return end
    local src, dir = self:GetTracerOrigin(), self:GetShootDir()

    local diff = EyePos() - src

    local dot = -dir:Forward():Dot(EyeAngles():Forward())
    local dot2 = dir:Forward():Dot(diff:GetNormalized())
    dot = math.max(0, (dot + dot2) / 2) ^ 1.5

    local strength = dot * math.Clamp((diff:Length() - 1024) / 3072, 0, 3) * math.Clamp(90 / self:GetValue("ScopeFOV") / 10, 0, 1)

    local rad = strength * 128 * (self:GetSightAmount() * 0.5 + 0.5)

    src = src + dir:Up() * 4 + diff:GetNormalized() * math.Clamp(diff:Length() / 2048, 0, 1) * 16

    local a = math.min(255, strength * 200 + 100)

    render.SetMaterial(glintmat)
    render.DrawSprite(src, rad, rad, Color(a, a, a))

    -- if self:GetSightAmount() > 0 then
        render.SetMaterial(glintmat2)
        render.DrawSprite(src, rad * 2, rad * 2, color_white)
    -- end
end

function SWEP:DoMuzzleLight()
    if (!IsFirstTimePredicted() and !game.SinglePlayer()) or !TacRP.ConVars["muzzlelight"]:GetBool() then return end

    if IsValid(self.MuzzleLight) then self.MuzzleLight:Remove() end

    local lamp = ProjectedTexture()
    lamp:SetTexture("tacrp/muzzleflash_light")
    local val1, val2
    if self:GetValue("Silencer") then
        val1, val2 = math.Rand(0.2, 0.4), math.Rand(100, 105)
        lamp:SetBrightness(val1)
        lamp:SetFOV(val2)
    else
        val1, val2 = math.Rand(2, 3), math.Rand(115, 120)
        lamp:SetBrightness(val1)
        lamp:SetFOV(val2)
    end

    lamp:SetFarZ(600)
    lamp:SetPos(self:GetMuzzleOrigin() + self:GetShootDir():Forward() * 8)
    lamp:SetAngles(self:GetShootDir() + Angle(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(0, 360)))
    lamp:Update()

    self.MuzzleLight = lamp
    self.MuzzleLightStart = UnPredictedCurTime()
    self.MuzzleLightEnd = UnPredictedCurTime() + 0.06
    self.MuzzleLightBrightness = val1
    self.MuzzleLightFOV = val2

    -- In multiplayer the timer will last longer than intended - sh_think should kill the light first.
    -- This is a failsafe for when the weapon stops thinking before light is killed (holstered, removed etc.).
    timer.Simple(0.06, function()
        if IsValid(lamp) then lamp:Remove() end
    end)
end