-- bolt_trigger.lua

local ATT = {}

------------------------------
-- #region bolt_fine
------------------------------
ATT = {}

ATT.PrintName = "Refined"
ATT.FullName = "Refined Bolt"
ATT.Icon = Material("entities/tacrp_att_bolt_fine.png", "mips smooth")
ATT.Description = "A delicate bolt suitable for short bursts."
ATT.Pros = {"stat.recoildissipation"}
ATT.Cons = {"stat.recoilpershot"}

ATT.Category = "bolt_automatic"

ATT.SortOrder = 3

ATT.Mult_RecoilDissipationRate = 1.25
-- ATT.Mult_RecoilSpreadPenalty = 1.175
ATT.Mult_RecoilPerShot = 1.1

TacRP.LoadAtt(ATT, "bolt_fine")
-- #endregion

------------------------------
-- #region bolt_greased
------------------------------
ATT = {}

ATT.PrintName = "Greased"
ATT.FullName = "Greased Bolt"
ATT.Icon = Material("entities/tacrp_att_bolt_greased.png", "mips smooth")
ATT.Description = "Faster cycle speed but handling is worse."
ATT.Pros = {"stat.rpm"}
ATT.Cons = {"rating.mobility", "stat.recoil", "stat.muzzlevelocity"}

ATT.Category = "bolt_manual"

ATT.SortOrder = 1

ATT.Mult_RPM = 1.15
ATT.Mult_ShootTimeMult = 1 / 1.15

ATT.Mult_RecoilKick = 1.25
ATT.Add_ShootingSpeedMult = -0.1
ATT.Add_SightedSpeedMult = -0.05

ATT.Mult_MuzzleVelocity = 0.85

TacRP.LoadAtt(ATT, "bolt_greased")
-- #endregion

------------------------------
-- #region bolt_heavy
------------------------------
ATT = {}

ATT.PrintName = "Heavy"
ATT.FullName = "Heavy Bolt"
ATT.Icon = Material("entities/tacrp_att_bolt_heavy.png", "mips smooth")
ATT.Description = "Reduce recoil at the cost of fire rate."
ATT.Pros = {"stat.recoilkick", "stat.bloomintensity"}
ATT.Cons = {"stat.rpm"}

ATT.Category = "bolt_automatic"

ATT.SortOrder = 2

ATT.Mult_RPM = 0.85
ATT.Mult_RecoilKick = 0.7
ATT.Mult_RecoilSpreadPenalty = 0.9

TacRP.LoadAtt(ATT, "bolt_heavy")
-- #endregion

------------------------------
-- #region bolt_light
------------------------------
ATT = {}

ATT.PrintName = "Light"
ATT.FullName = "Light Bolt"
ATT.Icon = Material("entities/tacrp_att_bolt_light.png", "mips smooth")
ATT.Description = "Increase fire rate at the cost of recoil."
ATT.Pros = {"stat.rpm"}
ATT.Cons = {"stat.recoilkick", "stat.bloomintensity"}

ATT.Category = "bolt_automatic"

ATT.SortOrder = 1

ATT.Mult_RPM = 1.15
ATT.Mult_RecoilKick = 1.25
ATT.Mult_RecoilSpreadPenalty = 1.1

TacRP.LoadAtt(ATT, "bolt_light")
-- #endregion

------------------------------
-- #region bolt_rough
------------------------------
ATT = {}

ATT.PrintName = "Rugged"
ATT.FullName = "Rugged Bolt"
ATT.Icon = Material("entities/tacrp_att_bolt_rough.png", "mips smooth")
ATT.Description = "A durable bolt suitable for long bursts."
ATT.Pros = {"stat.recoilpershot"}
ATT.Cons = {"stat.recoildissipation"}

ATT.Category = "bolt_automatic"

ATT.SortOrder = 4

ATT.Mult_RecoilDissipationRate = 0.75
-- ATT.Mult_RecoilSpreadPenalty = 0.825
ATT.Mult_RecoilPerShot = 0.9

TacRP.LoadAtt(ATT, "bolt_rough")
-- #endregion

------------------------------
-- #region bolt_surplus
------------------------------
ATT = {}

ATT.PrintName = "Surplus"
ATT.FullName = "Surplus Bolt"
ATT.Icon = Material("entities/tacrp_att_bolt_surplus.png", "mips smooth")
ATT.Description = "Rust has eaten most of it away, but it still kinda works."
ATT.Pros = {"att.procon.surplusboost1", "stat.recoil"}
ATT.Cons = {"att.procon.surplusboost2", "att.procon.unreliable"}

ATT.Category = {"bolt_automatic"}

ATT.SortOrder = 999

ATT.Mult_RecoilSpreadPenalty = 0.8
ATT.Mult_RecoilKick = 0.75

ATT.Add_JamFactor = 0.4
-- ATT.Mult_ShootChance = 0.96

ATT.Hook_PostShoot = function(wep)
    if CLIENT then return end
    if (wep.TacRP_NextSurplusBoost or 0) < CurTime() and math.random() <= 0.5 then
        wep:SetNWFloat("TacRP_SurplusBoost", CurTime() + math.Rand(0.15, 0.4))
        wep.TacRP_NextSurplusBoost = CurTime() + math.Rand(0.5, 2)
    end
end

ATT.Hook_PostJam = function(wep)
    wep:SetNWFloat("TacRP_SurplusBoost", 0)
end

ATT.Hook_PostThink = function(wep)
    if wep:GetCurrentFiremode() != 1 and wep:GetNWFloat("TacRP_SurplusBoost", 0) >= CurTime() then
        wep:PrimaryAttack()
    end
end

hook.Add("TacRP_Stat_RPM", "bolt_surplus", function(wep, data)
    if wep:GetNWFloat("TacRP_SurplusBoost", 0) >= CurTime() then
        data.mul = data.mul * 1.15
    end
end)

hook.Add("TacRP_Stat_Pitch_Shoot", "bolt_surplus", function(wep, data)
    if wep:GetNWFloat("TacRP_SurplusBoost", 0) >= CurTime() then
        data.add = data.add + 7.5
    end
end)

TacRP.LoadAtt(ATT, "bolt_surplus")
-- #endregion

------------------------------
-- #region bolt_tactical
------------------------------
ATT = {}

ATT.PrintName = "Tactical"
ATT.FullName = "Tactical Bolt"
ATT.Icon = Material("entities/tacrp_att_bolt_tactical.png", "mips smooth")
ATT.Description = "Slower bolt speed but improve overall handling."
ATT.Pros = {"rating.mobility", "stat.recoil", "stat.muzzlevelocity"}
ATT.Cons = {"stat.rpm"}

ATT.Category = "bolt_manual"

ATT.SortOrder = 2

ATT.Mult_RPM = 0.85
ATT.Mult_ShootTimeMult = 1 / 0.85

ATT.Add_ShootingSpeedMult = 0.15
ATT.Add_SightedSpeedMult = 0.05
ATT.Mult_RecoilKick = 0.6

ATT.Mult_MuzzleVelocity = 1.15

TacRP.LoadAtt(ATT, "bolt_tactical")
-- #endregion

------------------------------
-- #region trigger_akimbo
------------------------------
ATT = {}

ATT.PrintName = "Akimbo"
ATT.FullName = "Akimbo Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_akimbo.png", "mips smooth")
ATT.Description = "Let'em have it!"
ATT.Pros = {"att.procon.auto", "stat.recoilkick"}
ATT.Cons = {"stat.rpm"}

ATT.Free = true
ATT.Ignore = true

ATT.Category = "trigger_akimbo"

ATT.SortOrder = 0.5

ATT.Override_Firemodes = {2}
ATT.Mult_RPM = 0.9
ATT.Mult_RecoilKick = 0.75

TacRP.LoadAtt(ATT, "trigger_akimbo")
-- #endregion

------------------------------
-- #region trigger_burst
------------------------------
ATT = {}

ATT.PrintName = "Burst"
ATT.FullName = "Burst Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_burst.png", "mips smooth")
ATT.Description = "Trigger that sacrfices automatic fire for stability."
ATT.Pros = {"stat.rpm", "rating.control"}
ATT.Cons = {"att.procon.burst"}

ATT.Category = {"trigger_auto"}

ATT.SortOrder = 1.1

ATT.Add_PostBurstDelay = 0.15
ATT.Add_RPMMultBurst = 0.25
ATT.Override_Firemodes = {-3, 1}
ATT.Override_RunawayBurst = true

ATT.Mult_RecoilSpreadPenalty = 0.75
ATT.Mult_RecoilVisualKick = 0.85
ATT.Mult_RecoilKick = 0.75

ATT.Mult_RecoilStability = 1.25

TacRP.LoadAtt(ATT, "trigger_burst")
-- #endregion

------------------------------
-- #region trigger_burst2
------------------------------
ATT = {}

ATT.PrintName = "Burst"
ATT.FullName = "Burst Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_burst.png", "mips smooth")
ATT.Description = "Trigger that emulates burst fire."
ATT.Pros = {"att.procon.burst"}
ATT.Cons = {"stat.recoilkick", "stat.recoilstability"}

ATT.InvAtt = "trigger_burst"

ATT.Category = {"trigger_semi"}

ATT.SortOrder = 1.1

ATT.Override_Firemodes = {-3, 1}
ATT.Add_RPMMultBurst = 0.3
ATT.Override_RunawayBurst = true
ATT.Add_PostBurstDelay = 0.22

ATT.Mult_RecoilKick = 1.25
ATT.Mult_RecoilStability = 0.75

TacRP.LoadAtt(ATT, "trigger_burst2")
-- #endregion

------------------------------
-- #region trigger_burstauto
------------------------------
ATT = {}

ATT.PrintName = "Auto-Burst"
ATT.FullName = "Auto-Burst Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_burstauto.png", "mips smooth")
ATT.Description = "Trigger that allows continuous burst fire while held."
ATT.Pros = {"att.procon.autoburst"}
ATT.Cons = {}

ATT.Category = {"trigger_burst", "trigger_burstauto", "trigger_4pos"}

ATT.SortOrder = 4

ATT.AutoBurst = true
-- ATT.Add_PostBurstDelay = 0.025
-- ATT.Add_RecoilResetTime = 0.03

TacRP.LoadAtt(ATT, "trigger_burstauto")
-- #endregion

------------------------------
-- #region trigger_comp
------------------------------
ATT = {}

ATT.PrintName = "Competition"
ATT.FullName = "Competition Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_comp.png", "mips smooth")
ATT.Description = "Lightweight trigger for sports shooting."
ATT.Pros = {"stat.recoilfirstshot", "stat.recoilstability"}
ATT.Cons = {"stat.recoilmaximum"}

ATT.Category = {"trigger_semi", "trigger_auto", "trigger_burst", "trigger_akimbo", "trigger_revolver", "trigger", "trigger_4pos"}

ATT.SortOrder = 2

ATT.Mult_RecoilFirstShotMult = 0.75
ATT.Mult_RecoilMaximum = 1.5
ATT.Add_RecoilStability = 0.1

TacRP.LoadAtt(ATT, "trigger_comp")
-- #endregion

------------------------------
-- #region trigger_comp2
------------------------------
ATT = {}

ATT.PrintName = "Competition"
ATT.FullName = "Competition Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_comp.png", "mips smooth")
ATT.Description = "Lightweight trigger that recovers from accuracy faster."
ATT.Pros = {"stat.recoildissipation", "stat.recoilstability"}
ATT.Cons = {"stat.shootingspeed"}

ATT.InvAtt = "trigger_comp"

ATT.Category = {"trigger_manual"}

ATT.SortOrder = 2

ATT.Mult_RecoilDissipationRate = 1.25
ATT.Mult_ShootingSpeedMult = 0.75
ATT.Add_RecoilStability = 0.15

TacRP.LoadAtt(ATT, "trigger_comp2")
-- #endregion

------------------------------
-- #region trigger_frcd
------------------------------
ATT = {}

ATT.PrintName = "Forced Reset"
ATT.FullName = "Forced Reset Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_frcd.png", "mips smooth")
ATT.Description = "Trigger that emulates automatic fire but with poor performance."
ATT.Pros = {"att.procon.auto"}
ATT.Cons = {"stat.recoilkick", "stat.bloomintensity", "stat.recoilstability"}

ATT.Category = "trigger_semi"

ATT.SortOrder = 1

ATT.Override_Firemodes = {2}
ATT.Override_Firemode = 2
ATT.Mult_RecoilKick = 1.25
ATT.Mult_RecoilSpreadPenalty = 1.15
ATT.Mult_RecoilStability = 0.5

TacRP.LoadAtt(ATT, "trigger_frcd")
-- #endregion

------------------------------
-- #region trigger_frcd2
------------------------------
ATT = {}

ATT.PrintName = "Forced Reset"
ATT.FullName = "Forced Reset Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_frcd.png", "mips smooth")
ATT.Description = "Trigger that emulates automatic fire but with poor performance."
ATT.Pros = {"att.procon.auto"}
ATT.Cons = {"stat.recoilkick", "stat.bloomintensity", "stat.recoilstability"}

ATT.InvAtt = "trigger_frcd"

ATT.Category = "trigger_burst"

ATT.SortOrder = 1

ATT.Override_Firemodes = {2}
ATT.Override_Firemode = 2
ATT.Mult_RecoilKick = 1.25
ATT.Mult_RecoilSpreadPenalty = 1.15
ATT.Mult_RecoilStability = 0.75

TacRP.LoadAtt(ATT, "trigger_frcd2")
-- #endregion

------------------------------
-- #region trigger_hair
------------------------------
ATT = {}

ATT.PrintName = "Feather"
ATT.FullName = "Feather Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_hair.png", "mips smooth")
ATT.Description = "Very sensitive trigger for rapid semi-automatic fire."
ATT.Pros = {"stat.rpm"}
ATT.Cons = {"stat.recoilmaximum", "stat.recoilstability", "stat.hipfirespread"}

ATT.Category = {"trigger_semi", "trigger_akimbo", "trigger_revolver"}

ATT.SortOrder = 4

ATT.Mult_RPMMultSemi = 1.2
ATT.Mult_RecoilMaximum = 1.25
ATT.Mult_RecoilStability = 0.5
ATT.Mult_HipFireSpreadPenalty = 1.15

TacRP.LoadAtt(ATT, "trigger_hair")
-- #endregion

------------------------------
-- #region trigger_heavy
------------------------------
ATT = {}

ATT.PrintName = "Weighted"
ATT.FullName = "Weighted Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_heavy.png", "mips smooth")
ATT.Description = "Heavy trigger for sustained fire."
ATT.Pros = {"stat.recoilmaximum"}
ATT.Cons = {"stat.recoilfirstshot", "stat.recoilstability"}

ATT.Category = {"trigger_semi", "trigger_auto", "trigger_burst", "trigger_akimbo", "trigger_revolver", "trigger", "trigger_4pos"}

ATT.SortOrder = 3

ATT.Mult_RecoilFirstShotMult = 1.5
ATT.Mult_RecoilMaximum = 0.85
ATT.Add_RecoilStability = -0.1

TacRP.LoadAtt(ATT, "trigger_heavy")
-- #endregion

------------------------------
-- #region trigger_heavy2
------------------------------
ATT = {}

ATT.PrintName = "Weighted"
ATT.FullName = "Weighted Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_heavy.png", "mips smooth")
ATT.Description = "Heavy trigger that reduces mobility impact from shooting."
ATT.Pros = {"stat.shootingspeed"}
ATT.Cons = {"stat.recoildissipation", "stat.recoilstability"}

ATT.InvAtt = "trigger_heavy"

ATT.Category = {"trigger_manual"}

ATT.SortOrder = 3

ATT.Mult_RecoilDissipationRate = 0.85
ATT.Mult_ShootingSpeedMult = 1.25
ATT.Add_RecoilStability = -0.15

TacRP.LoadAtt(ATT, "trigger_heavy2")
-- #endregion

------------------------------
-- #region trigger_semi
------------------------------
ATT = {}

ATT.PrintName = "Marksman"
ATT.FullName = "Marksman Trigger"

ATT.Icon = Material("entities/tacrp_att_trigger_semi.png", "mips smooth")
ATT.Description = "Trigger that sacrfices automatic fire for precision."
ATT.Pros = {"stat.spread", "stat.recoil"}
ATT.Cons = {"att.procon.semi"}

ATT.Category = {"trigger_auto", "trigger_burst", "trigger_4pos"}

ATT.SortOrder = 1

ATT.Override_Firemodes = {1}
ATT.Mult_Spread = 0.5
ATT.Mult_RecoilSpreadPenalty = 0.75
ATT.Mult_RecoilKick = 0.6
ATT.Mult_RecoilVisualKick = 0.5
ATT.Mult_RecoilStability = 1.25
ATT.Mult_RPMMultSemi = 1.2

TacRP.LoadAtt(ATT, "trigger_semi")
-- #endregion

------------------------------
-- #region trigger_slam
------------------------------
ATT = {}

ATT.PrintName = "Slamfire"
ATT.FullName = "Slamfire Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_frcd.png", "mips smooth")
ATT.Description = "Trigger that emulates automatic fire but with poor performance."
ATT.Pros = {"stat.rpm", "att.procon.auto"}
ATT.Cons = {"stat.spread", "rating.mobility"}

ATT.Category = "trigger_pump"

ATT.SortOrder = 1

ATT.Override_Firemodes = {2}
ATT.Mult_RecoilKick = 1.25
ATT.Mult_RecoilSpreadPenalty = 1.25
ATT.Add_RecoilMaximum = 0.5

ATT.Mult_RPM = 1.15
ATT.Mult_ShootTimeMult = 1.25
ATT.Mult_ShootingSpeedMult = 0.75

TacRP.LoadAtt(ATT, "trigger_slam")
-- #endregion

------------------------------
-- #region trigger_slam2
------------------------------
ATT = {}

ATT.PrintName = "Slamfire"
ATT.FullName = "Slamfire Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_frcd.png", "mips smooth")
ATT.Description = "Trigger that emulates automatic fire but with poor performance."
ATT.Pros = {"stat.rpm", "att.procon.auto"}
ATT.Cons = {"stat.spread", "rating.mobility"}

ATT.Category = "trigger_pump2"
ATT.InvAtt = "trigger_slam"

ATT.SortOrder = 1

ATT.Override_Firemodes = {2}
ATT.Mult_RecoilKick = 1.25
ATT.Mult_RecoilSpreadPenalty = 1.25
ATT.Add_RecoilMaximum = 0.5

ATT.Mult_RPM = 1.15
ATT.Mult_ShootTimeMult = 1.4
ATT.Mult_ShootingSpeedMult = 0.75

TacRP.LoadAtt(ATT, "trigger_slam2")
-- #endregion

------------------------------
-- #region trigger_straight
------------------------------
ATT = {}

ATT.PrintName = "Straight"
ATT.FullName = "Straight Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_straight.png", "mips smooth")
ATT.Description = "Narrow trigger with superior recoil performance."
ATT.Pros = {"stat.bloomintensity", "stat.recoildissipation"}
ATT.Cons = {"stat.recoilresettime", "stat.shootingspeed"}

ATT.Category = {"trigger_auto", "trigger_straight", "trigger_4pos"}

ATT.SortOrder = 5.5

ATT.Mult_RecoilDissipationRate = 1.15
ATT.Mult_RecoilSpreadPenalty = 0.85

ATT.Add_RecoilResetTime = 0.075
ATT.Add_ShootingSpeedMult = -0.08

TacRP.LoadAtt(ATT, "trigger_straight")
-- #endregion

------------------------------
-- #region trigger_wide
------------------------------
ATT = {}

ATT.PrintName = "Wide"
ATT.FullName = "Wide Trigger"
ATT.Icon = Material("entities/tacrp_att_trigger_wide.png", "mips smooth")
ATT.Description = "Large trigger assembly, easy to hold even in awkward positions."
ATT.Pros = {"stat.quickscope", "stat.peekpenalty", "stat.freeaimangle"}
ATT.Cons = {"stat.aimdownsights"}

ATT.Category = {"trigger_revolver", "trigger_manual"}

ATT.SortOrder = 5

ATT.Mult_PeekPenaltyFraction = 0.75
ATT.Mult_QuickScopeSpreadPenalty = 0.75
ATT.Mult_FreeAimMaxAngle = 0.85
-- ATT.Mult_HipFireSpreadPenalty = 0.75

ATT.Add_AimDownSightsTime = 0.03

TacRP.LoadAtt(ATT, "trigger_wide")
-- #endregion

