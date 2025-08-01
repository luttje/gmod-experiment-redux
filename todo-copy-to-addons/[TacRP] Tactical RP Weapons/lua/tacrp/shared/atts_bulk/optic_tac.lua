-- optic_tac.lua

local ATT = {}

------------------------------
-- #region optic_8x
------------------------------
ATT = {}

ATT.PrintName = "Telescopic"
ATT.Icon = Material("entities/tacrp_att_optic_8x.png", "mips smooth")
ATT.Description = "Long-range sniper optic."
ATT.Pros = {"att.zoom.8"}

ATT.Model = "models/weapons/tacint/addons/8x.mdl"
ATT.Scale = 1
ATT.ModelOffset = Vector(-1, 0, -0.35)

ATT.Category = "optic_sniper"

ATT.SortOrder = 8

ATT.Override_Scope = true
ATT.Override_ScopeOverlay = Material("tacrp/scopes/sniper.png", "mips smooth")
ATT.Override_ScopeFOV = 90 / 8
ATT.Override_ScopeLevels = 1
ATT.Override_ScopeHideWeapon = true

ATT.Override_ScopeOverlaySize = 0.8

TacRP.LoadAtt(ATT, "optic_8x")
-- #endregion

------------------------------
-- #region optic_acog
------------------------------
ATT = {}

ATT.PrintName = "ACOG"
ATT.Icon = Material("entities/tacrp_att_optic_acog.png", "mips smooth")
ATT.Description = "Medium range combat scope."
ATT.Pros = {"att.zoom.4"}

ATT.Model = "models/weapons/tacint/addons/acog.mdl"
ATT.Scale = 0.3
ATT.ModelOffset = Vector(-1, 0, 0.5)

ATT.Category = "optic_medium"

ATT.SortOrder = 4

ATT.Override_Scope = true
ATT.Override_ScopeOverlay = Material("tacrp/scopes/acog.png", "mips smooth")
-- ATT.Override_ScopeOverlay = false
ATT.Override_ScopeFOV = 90 / 4
ATT.Override_ScopeLevels = 1
ATT.Override_ScopeHideWeapon = true
ATT.Override_ScopeOverlaySize = 0.85

ATT.SightPos = Vector(0, -10, 1.01611)
ATT.SightAng = Angle(0, 0, 0)

TacRP.LoadAtt(ATT, "optic_acog")
-- #endregion

------------------------------
-- #region optic_elcan
------------------------------
ATT = {}

ATT.PrintName = "ELCAN"
ATT.Icon = Material("entities/tacrp_att_optic_elcan.png", "mips smooth")
ATT.Description = "Low power combat scope."
ATT.Pros = {"att.zoom.3.4"}

-- model: https://gamebanana.com/mods/210646
-- scope texture: ins2
ATT.Model = "models/weapons/tacint_extras/addons/elcan.mdl"
ATT.Scale = 1
ATT.ModelOffset = Vector(-0.5, 0, -0.4)

ATT.Category = "optic_medium"

ATT.SortOrder = 3.4

ATT.Override_Scope = true
ATT.Override_ScopeOverlay = Material("tacrp/scopes/elcan.png", "mips smooth")
-- ATT.Override_ScopeOverlay = false
ATT.Override_ScopeFOV = 90 / 3.4
ATT.Override_ScopeLevels = 1
ATT.Override_ScopeHideWeapon = true

ATT.SightPos = Vector(0, -10, 1.01611)
ATT.SightAng = Angle(0, 0, 0)

TacRP.LoadAtt(ATT, "optic_elcan")
-- #endregion

------------------------------
-- #region optic_holographic
------------------------------
ATT = {}

ATT.PrintName = "Holographic"
ATT.Icon = Material("entities/tacrp_att_optic_holographic.png", "mips smooth")
ATT.Description = "Boxy optic that helps to improve mid-range aim."
ATT.Pros = {"att.sight.1.5"}

ATT.Model = "models/weapons/tacint/addons/holosight_hq.mdl"
ATT.Scale = 0.35
ATT.ModelOffset = Vector(0, 0.05, 0)

ATT.Category = "optic_cqb"

ATT.SortOrder = 1.5

ATT.Override_Scope = true
ATT.Override_ScopeOverlay = false
ATT.Override_ScopeFOV = 90 / 1.5
ATT.Override_ScopeLevels = 1
ATT.Override_ScopeHideWeapon = false

ATT.SightPos = Vector(-0.05, -15, 1.1)
ATT.SightAng = Angle(0, 0, 0)

ATT.Holosight = Material("tacrp/hud/eotech.png", "additive")

ATT.Holosight:SetInt("$flags", 128)

TacRP.LoadAtt(ATT, "optic_holographic")
-- #endregion

------------------------------
-- #region optic_irons
------------------------------
ATT = {}

ATT.PrintName = "Iron Sights"
ATT.Icon = Material("entities/tacrp_att_optic_irons.png", "mips smooth")
ATT.Description = "Basic sights for added mobility."
ATT.Pros = {"rating.handling"}
ATT.Cons = {"att.procon.noscope"}

ATT.Free = true

ATT.InstalledElements = {"irons"}

ATT.Category = "ironsights"

ATT.SortOrder = 0

ATT.Override_ScopeHideWeapon = false
ATT.Override_ScopeOverlay = false
ATT.Override_ScopeFOV = 90 / 1.1
ATT.Override_ScopeLevels = 1

ATT.Add_AimDownSightsTime = -0.03
ATT.Add_SprintToFireTime = -0.03

TacRP.LoadAtt(ATT, "optic_irons")
-- #endregion

------------------------------
-- #region optic_irons_sniper
------------------------------
ATT = {}

ATT.PrintName = "Iron Sights"
ATT.Icon = Material("entities/tacrp_att_optic_irons.png", "mips smooth")
ATT.Description = "Replace default scope for faster aim and better mobility."
ATT.Pros = {"rating.handling", "rating.mobility"}
ATT.Cons = {"att.procon.noscope"}

ATT.Free = true

ATT.InstalledElements = {"irons"}

ATT.Category = "ironsights_sniper"

ATT.SortOrder = 0

ATT.Override_ScopeHideWeapon = false
ATT.Override_ScopeOverlay = false
ATT.Override_ScopeFOV = 90 / 1.1
ATT.Override_ScopeLevels = 1

ATT.Add_AimDownSightsTime = -0.05
ATT.Add_SprintToFireTime = -0.05
ATT.Add_SightedSpeedMult = 0.1
ATT.Add_ShootingSpeedMult = 0.05
ATT.Mult_HipFireSpreadPenalty = 0.75

TacRP.LoadAtt(ATT, "optic_irons_sniper")
-- #endregion

------------------------------
-- #region optic_okp7
------------------------------
ATT = {}

ATT.PrintName = "OKP-7"
ATT.Icon = Material("entities/tacrp_att_optic_okp7.png", "mips smooth")
ATT.Description = "Low profile reflex sight with minimal zoom."
ATT.Pros = {"att.sight.1.25"}

ATT.Model = "models/weapons/tacint/addons/okp7.mdl"

ATT.Category = "optic_cqb"
ATT.Scale = 1.1
ATT.ModelOffset = Vector(-2, 0, -0.55)

ATT.SortOrder = 1.25

ATT.Override_Scope = true
ATT.Override_ScopeOverlay = false
ATT.Override_ScopeFOV = 90 / 1.25
ATT.Override_ScopeLevels = 1
ATT.Override_ScopeHideWeapon = false

ATT.SightPos = Vector(0, -15, 1)
ATT.SightAng = Angle(0, 0, 0)

ATT.Holosight = Material("tacrp/hud/okp7.png", "smooth")

ATT.Holosight:SetInt("$flags", 128)

TacRP.LoadAtt(ATT, "optic_okp7")
-- #endregion

------------------------------
-- #region optic_rds
------------------------------
ATT = {}

ATT.PrintName = "Red Dot"
ATT.Icon = Material("entities/tacrp_att_optic_rds.png", "mips smooth")
ATT.Description = "Tube optic that helps to improve mid-range aim."
ATT.Pros = {"att.sight.1.75"}

ATT.Model = "models/weapons/tacint/addons/reddot_hq.mdl"
ATT.Scale = 0.35
ATT.ModelOffset = Vector(0, 0, 1)

ATT.Category = "optic_cqb"

ATT.SortOrder = 1.75

ATT.Override_Scope = true
ATT.Override_ScopeOverlay = false
ATT.Override_ScopeFOV = 90 / 1.75
ATT.Override_ScopeLevels = 1
ATT.Override_ScopeHideWeapon = false

ATT.SightPos = Vector(0, -15, 0.1)
ATT.SightAng = Angle(0, 0, 0)

ATT.Holosight = Material("tacrp/hud/rds.png", "additive")

ATT.Holosight:SetInt("$flags", 128)

TacRP.LoadAtt(ATT, "optic_rds")
-- #endregion

------------------------------
-- #region optic_rmr
------------------------------
ATT = {}

ATT.PrintName = "RMR"
ATT.Icon = Material("entities/tacrp_att_optic_rmr.png", "mips smooth")
ATT.Description = "Low profile optic sight for pistols."
ATT.Pros = {"att.sight.1"}

ATT.Model = "models/weapons/tacint/addons/optic_rmr_hq.mdl"
ATT.Scale =  1

ATT.Category = "optic_pistol"

ATT.SortOrder = 1

ATT.Override_Scope = true
ATT.Override_ScopeOverlay = false
ATT.Override_ScopeFOV = 90 / 1.1
ATT.Override_ScopeLevels = 1
ATT.Override_ScopeHideWeapon = false

ATT.SightPos = Vector(0, -10, 0.520837)
ATT.SightAng = Angle(0, 0, 0)

ATT.Holosight = Material("tacrp/hud/rds.png", "additive")

ATT.Holosight:SetInt("$flags", 128)

TacRP.LoadAtt(ATT, "optic_rmr")
-- #endregion

------------------------------
-- #region optic_shortdot
------------------------------
ATT = {}

ATT.PrintName = "Short Dot"
ATT.Icon = Material("entities/tacrp_att_optic_shortdot.png", "mips smooth")
ATT.Description = "Compact optic scope with decent magnification."
ATT.Pros = {"att.zoom.5"}

-- model: gamebanana
-- scope texture: ins2
ATT.Model = "models/weapons/tacint_extras/addons/schd.mdl"
ATT.Scale = 1.15
ATT.ModelOffset = Vector(-1, 0, -0.45)

ATT.Category = "optic_medium"

ATT.SortOrder = 5

ATT.Override_Scope = true
ATT.Override_ScopeOverlay = Material("tacrp/scopes/shortdot.png", "mips smooth")
-- ATT.Override_ScopeOverlay = false
ATT.Override_ScopeFOV = 90 / 5
ATT.Override_ScopeLevels = 1
ATT.Override_ScopeHideWeapon = true

ATT.SightPos = Vector(0, -10, 1.01611)
ATT.SightAng = Angle(0, 0, 0)

TacRP.LoadAtt(ATT, "optic_shortdot")
-- #endregion

------------------------------
-- #region tac_cornershot
------------------------------
ATT = {}

ATT.PrintName = "Corner-Cam"
ATT.Icon = Material("entities/tacrp_att_tac_cornershot.png", "mips smooth")
ATT.Description = "Displays point of aim while blindfiring."
ATT.Pros = {"att.procon.cornershot"}

ATT.Model = "models/weapons/tacint/addons/cornershot_mounted.mdl"
ATT.Scale = 1

ATT.Category = "tactical"

ATT.BlindFireCamera = true

TacRP.LoadAtt(ATT, "tac_cornershot")
-- #endregion

------------------------------
-- #region tac_dmic
------------------------------
ATT = {}

ATT.PrintName = "Radar"
ATT.Icon = Material("entities/tacrp_att_tac_dmic.png", "mips smooth")
ATT.Description = "Detects the position of nearby targets, but emits sound."
ATT.Pros = {"att.procon.dmic"}
ATT.Cons = {"att.procon.audible"}

ATT.Model = "models/weapons/tacint/addons/dmic_mounted.mdl"
ATT.Scale = 1

ATT.Category = "tactical"

ATT.Minimap = true
ATT.CanToggle = true

ATT.TacticalName = "Radar"

local scantime = TacRP.ConVars["att_radartime"]
local lastradar = 0
local cache_lastradarpositions
local mat_radar = Material("tacrp/hud/radar.png", "smooth")
local mat_radar_active = Material("tacrp/hud/radar_active.png", "mips smooth")
local mat_dot = Material("tacrp/hud/dot.png", "mips smooth")
local mat_tri = Material("tacrp/hud/triangle.png", "mips smooth")
function ATT.TacticalDraw(self)
    local scrw = ScrW()
    local scrh = ScrH()

    local w = TacRP.SS(100)
    local h = TacRP.SS(100)

    local x = (scrw - w) / 2
    local y = (scrh - h) * 0.99

    surface.SetMaterial(mat_radar)
    surface.SetDrawColor(255, 255, 255, 100)
    surface.DrawTexturedRect(x, y, w, h)

    local radarpositions = {}

    if lastradar + scantime:GetFloat() > CurTime() then
        radarpositions = cache_lastradarpositions
    else
        local tbl = ents.FindInSphere(self:GetOwner():GetPos(), 50 / TacRP.HUToM)

        local i = 0
        for _, ent in ipairs(tbl) do
            if !((ent:IsPlayer() and ent:Alive()) or (ent:IsNPC() and ent:Health() > 0) or ent:IsNextBot()) then continue end
            if ent == self:GetOwner() then continue end

            local ang = self:GetOwner():EyeAngles()

            ang.y = ang.y + 90
            ang.p = 0
            ang.r = 0

            local relpos = WorldToLocal(ent:GetPos(), Angle(0, 0, 0), self:GetOwner():GetPos(), ang)

            local read = {
                x = -relpos.x,
                y = relpos.y,
                z = relpos.z,
            }

            table.insert(radarpositions, read)
            i = i + 1
        end

        lastradar = CurTime()
        cache_lastradarpositions = radarpositions

        if !TacRP.ConVars["radar_quiet"]:GetBool() then
            LocalPlayer():EmitSound("plats/elevbell1.wav", 60, 95 + math.min(i, 3) * 5, 0.1 + math.min(i, 3) * 0.05)
        end
    end

    surface.SetDrawColor(0, 0, 0, 255 * 2 * (1 - ((CurTime() - lastradar) / scantime:GetFloat())))
    surface.SetMaterial(mat_radar_active)
    surface.DrawTexturedRect(x, y, w, h)
    -- surface.SetDrawColor(255, 255, 255, 255)

    local ds = TacRP.SS(4)

    for _, dot in ipairs(radarpositions) do
        local dx = x + (dot.x * TacRP.HUToM * w * (36 / 40) / 100) + (w / 2)
        local dy = y + (dot.y * TacRP.HUToM * h * (36 / 40) / 100) + (h / 2)

        local gs = TacRP.SS(8)

        dx = math.Round(dx / (w / gs)) * (w / gs)
        dy = math.Round(dy / (h / gs)) * (h / gs)

        dx = dx - TacRP.SS(0.5)
        dy = dy - TacRP.SS(0.5)

        if math.abs(dot.z) > 128 then
            surface.SetMaterial(mat_tri)
            surface.DrawTexturedRectRotated(dx, dy, ds, ds, dot.z > 0 and 0 or 180)
        else
            surface.SetMaterial(mat_dot)
            surface.DrawTexturedRect(dx - (ds / 2), dy - (ds / 2), ds, ds)
        end
    end
end

function ATT.TacticalThink(self)
    if IsValid(self:GetOwner()) and self:GetTactical() and (SERVER and !game.SinglePlayer()) and (self.NextRadarBeep or 0) < CurTime() then
        self.NextRadarBeep = CurTime() + scantime:GetFloat()
        local f = RecipientFilter()
        f:AddPAS(self:GetPos())
        f:RemovePlayer(self:GetOwner())
        local s = CreateSound(self, "plats/elevbell1.wav", f)
        s:SetSoundLevel(80)
        s:PlayEx(0.2, 105)
    end
end

TacRP.LoadAtt(ATT, "tac_dmic")
-- #endregion

------------------------------
-- #region tac_flashlight
------------------------------
ATT = {}

ATT.PrintName = "Flashlight"
ATT.Icon = Material("entities/tacrp_att_tac_flashlight.png", "mips smooth")
ATT.Description = "Emits a strong beam of light, blinding anyone staring into it."
ATT.Pros = {"att.procon.flashlight", "att.procon.blind"}
ATT.Cons = {"att.procon.visible"}

ATT.Model = "models/weapons/tacint/addons/flashlight_mounted.mdl"
ATT.Scale = 1

ATT.Category = "tactical"

ATT.SortOrder = 1

ATT.Flashlight = true
ATT.CanToggle = true

ATT.TacticalName = "Flashlight"

TacRP.LoadAtt(ATT, "tac_flashlight")
-- #endregion

------------------------------
-- #region tac_laser
------------------------------
ATT = {}

ATT.PrintName = "Laser"
ATT.Icon = Material("entities/tacrp_att_tac_laser.png", "mips smooth")
ATT.Description = "Emits a narrow red beam and dot, indicating where the gun is pointed at."
ATT.Pros = {"att.procon.laser"}
ATT.Cons = {"att.procon.visible"}

ATT.Model = "models/weapons/tacint/addons/laser_mounted.mdl"
ATT.Scale = 1

ATT.Category = "tactical"

ATT.SortOrder = 1

ATT.Laser = true
ATT.CanToggle = true

ATT.TacticalName = "Laser"

TacRP.LoadAtt(ATT, "tac_laser")
-- #endregion

------------------------------
-- #region tac_rangefinder
------------------------------
ATT = {}

ATT.PrintName = "Rangefinder"
ATT.Icon = Material("entities/tacrp_att_tac_rangefinder.png", "mips smooth")
ATT.Description = "Measures ballistic performance of the weapon."
ATT.Pros = {"att.procon.rf1", "att.procon.rf2"}

ATT.Model = "models/weapons/tacint/addons/rangefinder_mounted.mdl"
ATT.Scale = 1

ATT.Category = "tactical"

ATT.Rangefinder = true
ATT.CanToggle = true

ATT.TacticalName = "Ranger"

local lastrangefinder = 0
local rftime = 1 / 10
local rawdist = 0
local mat_rf = Material("tacrp/hud/rangefinder.png", "mips smooth")
function ATT.TacticalDraw(self)
    local txt = "NO RTN"
    local txt2 = ""
    local txt3 = ""
    local txt4 = ""

    if lastrangefinder + rftime < CurTime() then
        local tr = util.TraceLine({
            start = self:GetMuzzleOrigin(),
            endpos = self:GetMuzzleOrigin() + (self:GetShootDir():Forward() * 50000),
            mask = MASK_SHOT,
            filter = self:GetOwner()
        })

        rawdist = (tr.HitPos - tr.StartPos):Length()
        local dist
        if TacRP.ConVars["metricunit"]:GetBool() then
            dist = math.min(math.Round(rawdist * TacRP.HUToM, 0), 99999)
            txt = tostring(dist) .. "m"
        else
            dist = math.min(math.Round(rawdist, 0), 99999)
            txt = tostring(dist) .. "HU"
        end

        if TacRP.ConVars["physbullet"]:GetBool() then
            -- Not totally accurate due to hitscan kicking in up close
            local t = math.Round(rawdist / self:GetValue("MuzzleVelocity"), 2)
            txt2 = tostring(math.Round(rawdist / self:GetValue("MuzzleVelocity"), 2)) .. "s"
            if t > 0 and t < 1 then txt2 = string.sub(txt2, 2) end
        else
            -- Not totally accurate due to hitscan kicking in up close
            if !TacRP.ConVars["metricunit"]:GetBool() then
                txt2 = tostring(math.min(math.Round(rawdist * TacRP.HUToM, 0), 99999)) .. "m"
            else
                txt2 = tostring(math.min(math.Round(rawdist, 0), 99999)) .. "HU"
            end
        end

        local edmg = self:GetDamageAtRange(rawdist)
        edmg = math.ceil(edmg)

        txt3 = tostring(edmg) .. "DMG"

        for _ = 0, 12 - string.len(txt3) - string.len(txt) do
            txt = txt .. " "
        end

        txt = txt .. txt3

        local mult = self:GetBodyDamageMultipliers() --self:GetValue("BodyDamageMultipliers")
        local min = math.min(unpack(mult))

        if edmg * min >= 100 then
            txt4 = "LETHAL"
        elseif edmg * mult[HITGROUP_LEFTLEG] >= 100 then
            txt4 = "LEGS"
        elseif edmg * mult[HITGROUP_LEFTARM] >= 100 then
            txt4 = "ARMS"
        elseif edmg * mult[HITGROUP_STOMACH] >= 100 then
            txt4 = "STMCH"
        elseif edmg * mult[HITGROUP_CHEST] >= 100 then
            txt4 = "CHEST"
        elseif edmg * mult[HITGROUP_HEAD] >= 100 then
            txt4 = "HEAD"
        else
            txt4 = tostring(math.ceil(100 / edmg)) .. (self:GetValue("Num") > 1 and "PTK" or "STK")
        end

        for _ = 0, 12 - string.len(txt4) - string.len(txt2) do
            txt2 = txt2 .. " "
        end

        txt2 = txt2 .. txt4

        cached_txt = txt
        cached_txt2 = txt2
        lastrangefinder = CurTime()
    else
        txt = cached_txt
        txt2 = cached_txt2
    end

    local scrw = ScrW()
    local scrh = ScrH()

    local w = TacRP.SS(100)
    local h = TacRP.SS(50)

    local x = (scrw - w) / 2
    local y = (scrh - h) * 5 / 6

    surface.SetMaterial(mat_rf)
    surface.SetDrawColor(255, 255, 255, 100)
    surface.DrawTexturedRect(x, y, w, h)

    surface.SetFont("TacRP_HD44780A00_5x8_10")
    -- local tw = surface.GetTextSize(txt)
    surface.SetTextPos(x + TacRP.SS(3), y + TacRP.SS(12))
    surface.SetTextColor(0, 0, 0)
    surface.DrawText(txt)

    -- local tw2 = surface.GetTextSize(txt2)
    surface.SetTextPos(x + TacRP.SS(3), y + TacRP.SS(22))
    surface.SetTextColor(0, 0, 0)
    surface.DrawText(txt2)
end

local last_laze_time = 0
-- local last_laze_dist = 0
local laze_interval = 0.2
local ccip_v = 0
local dropalpha = 0
local dropalpha2 = 0
local frac = 0
function ATT.TacticalCrosshair(self, x, y, spread, sway)

    if self:GetNextPrimaryFire() + 0.1 > CurTime() then
        dropalpha2 = 0
    end

    if self:IsInScope() and (self:GetValue("ScopeOverlay") or !self:GetReloading()) then
        dropalpha = math.Approach(dropalpha, self:GetSightAmount() ^ 2, FrameTime() * 1)
        dropalpha2 = math.Approach(dropalpha2, dropalpha, FrameTime() * 1)
    else
        dropalpha = math.Approach(dropalpha, 0, FrameTime() * 10)
        dropalpha2 = dropalpha
    end
    if dropalpha == 0 then return end

    frac = math.Clamp((rawdist - self:GetValue("Range_Min")) / (self:GetValue("Range_Max") - self:GetValue("Range_Min")), 0, 1)
    if self:GetValue("Damage_Min") <= self:GetValue("Damage_Max") then frac = 1 - frac end

    surface.DrawCircle(x, y, 16, 255, 255, 255, dropalpha * 80)
    surface.SetDrawColor(255, 255, 255, dropalpha * 60 * frac + 20)
    surface.DrawLine(x - 16, y, x + 16, y)
    surface.DrawLine(x, y + 16, x, y - 16)

    if !TacRP.ConVars["physbullet"]:GetBool() then return end

    if last_laze_time + laze_interval <= CurTime() then
        last_laze_time = CurTime()
        local ccip = self:GetCCIP()

        if !ccip then
            ccip_v = 0
        else
            cam.Start3D(nil, nil, self.ViewModelFOV)
            ccip_v = (ccip.HitPos:ToScreen().y - (ScrH() / 2)) * self:GetCorVal()
            -- local localhp = mdl:WorldToLocal(ccip.HitPos)
            -- local localpos = mdl:WorldToLocal(pos)
            -- ccip_v = (localpos.z - localhp.z)
            cam.End3D()
            -- last_laze_dist = ccip.HitPos:Distance(self:GetMuzzleOrigin())
        end
    end

    for i = 1, math.Round((ccip_v - 4) / 4) do
        surface.DrawCircle(x, y + i * 4, 1, 255, 255, 255, dropalpha2 * 75)
    end

    -- surface.DrawCircle(x, y + ccip_v, 6, 255, 255, 255, dropalpha * 120)
    -- surface.DrawCircle(x, y + ccip_v, 8, 255, 255, 255, dropalpha * 120)
    surface.SetDrawColor(255, 255, 255, dropalpha2 * 150)
    surface.DrawLine(x - 7, y - 7 + ccip_v, x + 7, y + 7 + ccip_v)
    surface.DrawLine(x - 7, y + 7 + ccip_v, x + 7, y - 7 + ccip_v)

    -- surface.DrawCircle(x, y, spread - 1, 255, 255, 255, circlealpha * 75)
    -- surface.DrawCircle(x, y, spread + 1, 255, 255, 255, circlealpha * 75)
end

ATT.TacticalCrosshairTruePos = true

TacRP.LoadAtt(ATT, "tac_rangefinder")
-- #endregion

------------------------------
-- #region tac_spreadgauge
------------------------------
ATT = {}

ATT.PrintName = "Spread Gauge"
ATT.Icon = Material("entities/tacrp_att_tac_rangefinder.png", "mips smooth")
ATT.Description = "Measures weapon stability from sway and bloom."
ATT.Pros = {"att.procon.gauge1", "att.procon.gauge2"}

ATT.Model = "models/weapons/tacint/addons/rangefinder_mounted.mdl"
ATT.Scale = 1

ATT.Category = "tactical"

ATT.SpreadGauge = true
ATT.CanToggle = true

ATT.TacticalName = "Gauge"

local mat_spread = Material("tacrp/hud/spreadgauge.png", "smooth")
local mat_spread_fire = Material("tacrp/hud/spreadgauge_fire.png", "")
local mat_spread_gauge = Material("tacrp/hud/spreadgauge_gauge.png", "")
local mat_spread_text = Material("tacrp/hud/spreadgauge_text.png", "")
local mat_cone = Material("tacrp/hud/cone.png", "smooth")
local mat_cone_text = Material("tacrp/hud/cone_text.png", "")
function ATT.TacticalDraw(self)
    local scrw = ScrW()
    local scrh = ScrH()

    local w = TacRP.SS(60)
    local h = TacRP.SS(30)

    local x = (scrw - w) / 2
    local y = (scrh - h) * 5.5 / 6

    -- if self:GetSightDelta() > 0 then
    --     y = y - self:GetSightDelta() ^ 0.5 * TacRP.SS(24)
    -- end

    surface.SetMaterial(mat_spread)
    surface.SetDrawColor(255, 255, 255, 100)
    surface.DrawTexturedRect(x, y, w, h)

    local spread = math.Clamp(math.deg(self:GetSpread()) * 60, 0, 999.9)
    local spread1 = math.floor(spread)
    local spread2 = math.floor((spread - spread1) * 10)
    local spread_txt1 = tostring(spread1)
    surface.SetFont("TacRP_HD44780A00_5x8_6")
    surface.SetTextColor(0, 0, 0)
    surface.SetTextPos(x + TacRP.SS(22), y + TacRP.SS(2.5))
    if spread < 10 then
        surface.SetTextColor(0, 0, 0, 100)
        surface.DrawText("00")
        surface.SetTextColor(0, 0, 0)
    elseif spread < 100 then
        surface.SetTextColor(0, 0, 0, 100)
        surface.DrawText("0")
        surface.SetTextColor(0, 0, 0)
    end
    surface.DrawText(spread_txt1)
    surface.DrawText(".")
    surface.DrawText(spread2)

    local recoil = self:GetRecoilAmount()
    local recoil_pct = math.Round( recoil, 2 )
    local recoil_per = recoil / self:GetValue("RecoilMaximum")
    surface.SetTextPos(x + TacRP.SS(22), y + TacRP.SS(11.5))
    surface.SetTextColor(0, 0, 0)

    if recoil_pct < 10 then
        surface.SetTextColor(0, 0, 0, 100)
        surface.DrawText("0")
        surface.SetTextColor(0, 0, 0)
    elseif recoil_per == 1 and math.sin(SysTime() * 60) > 0 then
        surface.SetTextColor(0, 0, 0, 150)
    end
    surface.DrawText(recoil_pct)

    local bleh = math.ceil(recoil_pct) - recoil_pct
    bleh = tostring(bleh)
    if (recoil_per == 1 and math.sin(SysTime() * 60) > 0) then
        surface.SetTextColor(0, 0, 0, 150)
    else
        surface.SetTextColor(0, 0, 0)
    end
    if #bleh == 1 then
        surface.DrawText(".00")
    elseif #bleh == 3 then
        surface.SetTextColor(0, 0, 0)
        surface.DrawText("0")
    end

    local last_fire = math.Clamp((self:GetNextPrimaryFire() - CurTime()) / (60 / self:GetValue("RPM")), 0, 1)
    surface.SetDrawColor(255, 255, 255, last_fire * 255)
    surface.SetMaterial(mat_spread_fire)
    surface.DrawTexturedRect(x, y, w, h)

    surface.SetDrawColor(255, 255, 255, math.abs(math.sin(SysTime())) * 200)
    surface.SetMaterial(mat_spread_gauge)
    surface.DrawTexturedRect(x, y, w, h)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(mat_spread_text)
    surface.DrawTexturedRect(x, y, w, h)

    local w_cone = TacRP.SS(40)
    local x2 = (scrw - w_cone) / 2
    local y2 = y - w_cone - TacRP.SS(4)

    surface.SetMaterial(mat_cone)
    surface.SetDrawColor(255, 255, 255, 100)
    surface.DrawTexturedRect(x2, y2, w_cone, w_cone)
    surface.SetMaterial(mat_cone_text)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(x2, y2, w_cone, w_cone)

    local acc_size = math.ceil(spread * 0.125) --math.max(TacRP.GetFOVAcc(self), 1)
    local a = math.Clamp(1 - (acc_size - TacRP.SS(15)) / TacRP.SS(5), 0.05, 1) ^ 0.5
    surface.DrawCircle(x2 + w_cone / 2, y2 + w_cone / 2, math.min(TacRP.SS(16), acc_size), 0, 0, 0, a * 150)
    surface.DrawCircle(x2 + w_cone / 2, y2 + w_cone / 2, math.min(TacRP.SS(16), acc_size) + 0.5, 0, 0, 0, a * 200)
    surface.DrawCircle(x2 + w_cone / 2, y2 + w_cone / 2, math.min(TacRP.SS(16), acc_size) + 1, 0, 0, 0, a * 150)

    if spread < 101 then
        acc_size = math.ceil(spread * 0.625)
        surface.DrawCircle(x2 + w_cone / 2, y2 + w_cone / 2, acc_size, 0, 0, 0, a * 200)
    end

    local fov_mult = LocalPlayer():GetFOV() / math.max(self.TacRPLastFOV or 90, 0.00001)
    local fov_mult1 = math.floor(fov_mult)
    local fov_mult2 = math.Round(fov_mult - math.floor(fov_mult), 1) * 10
    if fov_mult2 == 10 then fov_mult1 = fov_mult1 + 1 fov_mult2 = 0 end

    surface.SetFont("TacRP_HD44780A00_5x8_6")
    surface.SetTextColor(0, 0, 0)
    surface.SetTextPos(x2 + TacRP.SS(17), y2 + TacRP.SS(2))
    surface.DrawText(fov_mult1 .. "." .. fov_mult2 .. "x")
    local sway_pct = math.Clamp(math.Round((self:IsSwayEnabled() and self:GetSwayAmount() or self:GetForcedSwayAmount()) * 100), 0, 999)
    local sway_txt = sway_pct .. "%"
    local sway_w = surface.GetTextSize("100%") -- same width per char so its ok
    surface.SetTextPos(x2 + TacRP.SS(23) - sway_w, y2 + w_cone - TacRP.SS(8.5))
    if sway_pct < 10 then
        surface.SetTextColor(0, 0, 0, 100)
        surface.DrawText("00")
        surface.SetTextColor(0, 0, 0)
    elseif sway_pct < 100 then
        surface.SetTextColor(0, 0, 0, 100)
        surface.DrawText("0")
        surface.SetTextColor(0, 0, 0)
    end
    surface.DrawText(sway_txt)
end

local circlealpha = 0
function ATT.TacticalCrosshair(self, x, y, spread, sway)
    if self:IsInScope() and !self:GetReloading() then
        circlealpha = math.Approach(circlealpha, self:GetSightAmount() ^ 2, FrameTime() * 2)
    else
        circlealpha = math.Approach(circlealpha, 0, FrameTime() * 10)
    end
    if circlealpha == 0 then return end

    surface.DrawCircle(x, y, spread - 1, 255, 255, 255, circlealpha * 100)
    surface.DrawCircle(x, y, spread + 1, 255, 255, 255, circlealpha * 100)
end

ATT.TacticalCrosshairTruePos = true

TacRP.LoadAtt(ATT, "tac_spreadgauge")
-- #endregion

