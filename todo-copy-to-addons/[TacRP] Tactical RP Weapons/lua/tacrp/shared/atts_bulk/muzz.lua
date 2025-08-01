-- muzz.lua

local ATT = {}

------------------------------
-- #region muzz_comp_mac10
------------------------------
ATT = {}

ATT.PrintName = "att.muzz_pistol_comp.name"
ATT.Icon = Material("entities/tacrp_att_muzz_pistol_comp.png", "mips smooth")
ATT.Description = "att.muzz_pistol_comp.desc"
ATT.Pros = {"stat.recoil", "stat.spread", "stat.range"}
ATT.Cons = {"stat.rpm"}

ATT.Category = "comp_mac10"
ATT.InvAtt = "muzz_pistol_comp"
ATT.SortOrder = 1

ATT.Mult_RecoilKick = 0.75
ATT.Mult_RPM = 0.8
ATT.Mult_RecoilSpreadPenalty = 0.65
ATT.Mult_Spread = 0.5
ATT.Mult_Range_Max = 1.5
ATT.Mult_Range_Min = 1.5

ATT.InstalledElements = {"pistol_comp"}

TacRP.LoadAtt(ATT, "muzz_comp_mac10")
-- #endregion

------------------------------
-- #region muzz_comp_usp
------------------------------
ATT = {}

ATT.PrintName = "att.muzz_pistol_comp.name"
ATT.Icon = Material("entities/tacrp_att_muzz_pistol_comp.png", "mips smooth")
ATT.Description = "att.muzz_pistol_comp.desc"
ATT.Pros = {"stat.recoil", "stat.spread", "stat.range_min"}
ATT.Cons = {"stat.rpm"}

ATT.Category = "comp_usp"
ATT.InvAtt = "muzz_pistol_comp"
ATT.SortOrder = 1

ATT.Mult_RecoilKick = 0.5
ATT.Mult_RPM = 0.9
ATT.Mult_Spread = 0.75
ATT.Mult_Range_Min = 1.5

ATT.InstalledElements = {"pistol_comp"}

TacRP.LoadAtt(ATT, "muzz_comp_usp")
-- #endregion

------------------------------
-- #region muzz_hbar
------------------------------
ATT = {}

ATT.PrintName = "Heavy Barrel"
ATT.Icon = Material("entities/tacrp_att_muzz_hbar.png", "mips smooth")
ATT.Description = "Sturdy barrel with improved sway and recoil performance."
ATT.Pros = {"stat.sway", "stat.recoil", "stat.range_min"}
ATT.Cons = {"stat.spread", "stat.range_max"}

ATT.Category = {"silencer", "barrel"}

ATT.SortOrder = 1

ATT.Mult_Spread = 1.25
ATT.Mult_Range_Min = 1.25
ATT.Mult_Range_Max = 0.75
ATT.Mult_MuzzleVelocity = 0.8
ATT.Mult_RecoilKick = 0.6
ATT.Mult_Sway = 0.75
ATT.Mult_ScopedSway = 0.5
ATT.Mult_RecoilSpreadPenalty = 1.1

TacRP.LoadAtt(ATT, "muzz_hbar")
-- #endregion

------------------------------
-- #region muzz_lbar
------------------------------
ATT = {}

ATT.PrintName = "Light Barrel"
ATT.Icon = Material("entities/tacrp_att_muzz_lbar.png", "mips smooth")
ATT.Description = "Lightweight barrel more accurate and effective at long range."
ATT.Pros = {"stat.spread", "stat.range_max"}
ATT.Cons = {"stat.sway", "stat.recoil", "stat.range_min"}

ATT.Category = {"silencer", "barrel"}

ATT.SortOrder = 1

ATT.Mult_Spread = 0.5
ATT.Mult_RecoilSpreadPenalty = 0.85
ATT.Mult_Range_Min = 0.75
ATT.Mult_Range_Max = 1.25
ATT.Mult_MuzzleVelocity = 1.25
ATT.Mult_RecoilKick = 1.25
ATT.Mult_Sway = 1.25
ATT.Mult_ScopedSway = 1.5

TacRP.LoadAtt(ATT, "muzz_lbar")
-- #endregion

------------------------------
-- #region muzz_pistol_comp
------------------------------
ATT = {}

ATT.PrintName = "att.muzz_pistol_comp.name"
ATT.Icon = Material("entities/tacrp_att_muzz_pistol_comp.png", "mips smooth")
ATT.Description = "att.muzz_pistol_comp.desc"
ATT.Pros = {"stat.recoil", "stat.spread", "stat.range_min"}
ATT.Cons = {"stat.rpm"}

ATT.Model = "models/weapons/tacint/addons/pistol_comp.mdl"
ATT.Scale = 2
ATT.ModelOffset = Vector(-17.75, 0, -3.5)

ATT.Category = "pistol_muzzle"

ATT.SortOrder = 1

ATT.Mult_RecoilKick = 0.5
ATT.Mult_RPM = 0.9
ATT.Mult_Spread = 0.75
ATT.Mult_Range_Min = 1.5

TacRP.LoadAtt(ATT, "muzz_pistol_comp")
-- #endregion

------------------------------
-- #region muzz_silencer
------------------------------
ATT = {}

ATT.PrintName = "T. Suppressor"
ATT.FullName = "Tactical Suppressor"
ATT.Icon = Material("entities/tacrp_att_muzz_silencer.png", "mips smooth")
ATT.Description = "Balanced suppressor that reduces recoil and effective range."
ATT.Pros = {"stat.vol_shoot", "stat.recoil"}
ATT.Cons = {"stat.range", "stat.muzzlevelocity"}

ATT.Model = "models/weapons/tacint/addons/silencer.mdl"
ATT.Scale = 0.35

ATT.Category = "silencer"

ATT.SortOrder = 4

ATT.Add_Vol_Shoot = -25
ATT.Mult_RecoilKick = 0.9
ATT.Mult_RecoilSpreadPenalty = 0.95
ATT.Mult_Range_Max = 0.8
ATT.Mult_Range_Min = 0.8
ATT.Mult_MuzzleVelocity = 0.85

ATT.Silencer = true
ATT.Override_MuzzleEffect = "muzzleflash_suppressed"

TacRP.LoadAtt(ATT, "muzz_silencer")
-- #endregion

------------------------------
-- #region muzz_supp_compact
------------------------------
ATT = {}

ATT.PrintName = "C. Suppressor"
ATT.FullName = "Compact Suppressor"
ATT.Icon = Material("entities/tacrp_att_muzz_supp_compact.png", "mips smooth")
ATT.Description = "Short suppressor improving accuracy with low impact to effective range."
ATT.Pros = {"stat.vol_shoot", "stat.spread"}
ATT.Cons = {"stat.range", "stat.muzzlevelocity"}

ATT.Model = "models/weapons/tacint_extras/addons/suppressor.mdl"
ATT.Scale = 1.4

ATT.ModelOffset = Vector(-0.05, 0, 0.05)

ATT.Category = "silencer"

ATT.SortOrder = 5

ATT.Add_Vol_Shoot = -20
ATT.Mult_Spread = 0.8
ATT.Mult_Range_Max = 0.9
ATT.Mult_Range_Min = 0.9
ATT.Mult_MuzzleVelocity = 0.9

ATT.Add_Pitch_Shoot = 7.5

ATT.Silencer = true
ATT.Override_MuzzleEffect = "muzzleflash_suppressed"

TacRP.LoadAtt(ATT, "muzz_supp_compact")
-- #endregion

------------------------------
-- #region muzz_supp_weighted
------------------------------
ATT = {}

ATT.PrintName = "W. Suppressor"
ATT.FullName = "Weighted Suppressor"
ATT.Icon = Material("entities/tacrp_att_muzz_supp_weighted.png", "mips smooth")
ATT.Description = "Heavy suppressor with superior ballistics but worse handling."
ATT.Pros = {"stat.vol_shoot", "stat.range", "stat.recoil"}
ATT.Cons = {"rating.handling", "rating.maneuvering"}

ATT.Model = "models/weapons/tacint_extras/addons/suppressor_salvo.mdl"
ATT.Scale = 1.5

ATT.ModelOffset = Vector(0.4, 0, -0.05)

ATT.Category = "silencer"

ATT.SortOrder = 6

ATT.Add_Vol_Shoot = -30
ATT.Mult_RecoilKick = 0.75
ATT.Mult_RecoilSpreadPenalty = 0.9

ATT.Mult_Range_Max = 1.15
ATT.Mult_Range_Min = 1.15

ATT.Add_SprintToFireTime = 0.02
ATT.Add_AimDownSightsTime = 0.03

ATT.Add_FreeAimMaxAngle = 0.5
ATT.Add_Sway = 0.1
ATT.Add_ScopedSway = 0.05

ATT.Add_Pitch_Shoot = -7.5

ATT.Silencer = true
ATT.Override_MuzzleEffect = "muzzleflash_suppressed"

TacRP.LoadAtt(ATT, "muzz_supp_weighted")
-- #endregion

