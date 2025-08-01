function SWEP:SwitchFiremode()
    local fm = self:GetFiremode()

    fm = fm + 1

    if fm > #self:GetValue("Firemodes") then
        fm = 1
    end

    -- Since pattern is firemode dependent, it has to be reset when firemode switchs
    self.RecoilPatternCache = {}

    self:SetFiremode(fm)
end

function SWEP:GetFiremodeAmount()
    if istable(self:GetValue("Firemodes")) then
        return #self:GetValue("Firemodes")
    elseif self:GetValue("Firemode") == 0 then
        return 0
    else
        return 1
    end
end

function SWEP:GetNextFiremode()
    if self:GetFiremodeAmount() == 0 then return 1 end
    if self:GetValue("Firemodes") then
        local fm = self:GetFiremode()

        fm = fm + 1

        if fm > #self:GetValue("Firemodes") then
            fm = 1
        end

        return self:GetValue("Firemodes")[fm]
    else
        return self:GetValue("Firemode")
    end
end

function SWEP:GetCurrentFiremode()
    if self:GetValue("Firemodes") then
        return self:GetValue("Firemodes")[self:GetFiremode()] or self:GetValue("Firemode") or 0
    else
        return self:GetValue("Firemode")
    end
end

function SWEP:ToggleSafety(onoff)
    if self:GetValue("Firemode") == 0 then return end
    onoff = onoff or !self:GetSafe()

    if onoff and self:DoForceSightsBehavior() then return end

    self:SetSafe(onoff)

    if onoff == true then
        self:ToggleBlindFire(TacRP.BLINDFIRE_NONE)
        self:ScopeToggle(0)
    end

    if CLIENT then self.LastHintLife = CurTime() end
end

local mat_1 = Material("tacrp/hud/firemode_1.png", "mips smooth")
local mat_2 = Material("tacrp/hud/firemode_2.png", "mips smooth")
local mat_3 = Material("tacrp/hud/firemode_3.png", "mips smooth")
local mat_a = Material("tacrp/hud/firemode_a.png", "mips smooth")
local mat_s = Material("tacrp/hud/firemode_s.png", "mips smooth")

function SWEP:GetFiremodeMat(mode)
    if mode == 0 then
        return mat_s
    elseif mode == 1 then
        return mat_1
    elseif mode == 2 then
        return mat_a
    elseif mode == -2 then
        return mat_2
    elseif mode == -3 then
        return mat_3
    else
        return mat_1 // epic fail
    end
end

function SWEP:HasFiremode(mode, base)
    local valfunc = base and self.GetBaseValue or self.GetValue

    if valfunc(self, "Firemodes") then
        for _, v in pairs(valfunc(self, "Firemodes")) do
            if v == mode or (mode < 0 and v < 0) then return true end
        end
        return false
    else
        return valfunc(self, "Firemode") == mode or (mode < 0 and valfunc(self, "Firemode") < 0)
    end
end