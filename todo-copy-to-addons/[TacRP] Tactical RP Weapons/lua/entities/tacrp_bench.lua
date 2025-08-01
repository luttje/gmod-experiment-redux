AddCSLuaFile()

ENT.Type                     = "anim"
ENT.RenderGroup              = RENDERGROUP_BOTH

ENT.PrintName                = "Customization Bench"
ENT.Category                 = "Tactical RP"

ENT.Spawnable                = true
ENT.Model                    = "models/props_canal/winch02.mdl"

function ENT:Initialize()
    local model = self.Model

    self:SetModel(model)

    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        self:SetUseType(SIMPLE_USE)
        self:PhysWake()
    end

    -- removal is handled when checking position
    table.insert(TacRP.Benches, self)
end

local font = "TacRP_Myriad_Pro_24_Unscaled"

function ENT:DrawTranslucent()

    local distsqr = (EyePos() - self:WorldSpaceCenter()):LengthSqr()
    if distsqr <= 262144 then -- 512^2
        local a = 1 --math.Clamp(1 - (distsqr - 196608) / 65536, 0, 1)
        local ang = self:GetAngles()

        ang:RotateAroundAxis(ang:Forward(), 180)
        ang:RotateAroundAxis(ang:Right(), 90)
        ang:RotateAroundAxis(ang:Up(), 90)

        local pos = self:GetPos()

        pos = pos + ang:Forward() * 2.75
        pos = pos + ang:Up() * 9
        pos = pos + ang:Right() * -33

        cam.Start3D2D(pos, ang, 0.075)
            surface.SetFont(font)
            local w = surface.GetTextSize(self.PrintName)
            surface.SetTextPos(-w / 2, 0)
            surface.SetTextColor(255, 255, 255)
            surface.DrawText(self.PrintName)
            if distsqr <= 16384 then
                local t2 = "READY"
                local w2 = surface.GetTextSize(t2)
                surface.SetTextPos(-w2 / 2, 30)
                surface.SetTextColor(100, 255, 100)
                surface.DrawText(t2)
            end
        cam.End3D2D()
    end
end

function ENT:Draw()
    self:DrawModel()
end