-- perk.lua

local ATT = {}

------------------------------
-- #region perk_aim
------------------------------
ATT = {}

ATT.PrintName = "Deadeye"
ATT.Icon = Material("entities/tacrp_att_acc_aim.png", "mips smooth")
ATT.Description = "Zooms in your aim and makes it easier to fire while sighted."
ATT.Pros = {"stat.zoom", "stat.scopedsway", "stat.quickscope", "stat.movespread"}

ATT.Category = "perk_shooting"

ATT.SortOrder = 2

ATT.Mult_ScopeFOV = 0.75
ATT.Mult_ScopedSway = 0.5
ATT.Mult_QuickScopeSpreadPenalty = 0.66667
ATT.Mult_MoveSpreadPenalty = 0.75

TacRP.LoadAtt(ATT, "perk_aim")
-- #endregion

------------------------------
-- #region perk_blindfire
------------------------------
ATT = {}

ATT.PrintName = "Point Shoot"
ATT.FullName = "Point Shooter"
ATT.Icon = Material("entities/tacrp_att_acc_blindfire.png", "mips smooth")
ATT.Description = "Improves blindfire and peeking."
ATT.Pros = {"stat.peekpenalty", "stat.blindfiresway", "stat.freeaimangle"}

ATT.Category = {"perk"}

ATT.SortOrder = 7

ATT.Mult_BlindFireSway = 0.25
ATT.Mult_PeekPenaltyFraction = 0.66667
ATT.Mult_FreeAimMaxAngle = 0.75

TacRP.LoadAtt(ATT, "perk_blindfire")
-- #endregion

------------------------------
-- #region perk_hipfire
------------------------------
ATT = {}

ATT.PrintName = "Rambo"
ATT.Icon = Material("entities/tacrp_att_acc_hipfire.png", "mips smooth")
ATT.Description = "Improves weapon accuracy while not aiming."
ATT.Pros = {"stat.sway", "stat.hipfirespread", "stat.midairspread"}

ATT.Category = "perk"

ATT.SortOrder = 2

ATT.Mult_MidAirSpreadPenalty = 0.75
ATT.Mult_HipFireSpreadPenalty = 0.75
ATT.Mult_Sway = 0.75

TacRP.LoadAtt(ATT, "perk_hipfire")
-- #endregion

------------------------------
-- #region perk_melee
------------------------------
ATT = {}

ATT.PrintName = "Smackdown"
ATT.Icon = Material("entities/tacrp_att_acc_melee.png", "mips smooth")
ATT.Description = "Improves melee damage, and slows struck targets."
ATT.Pros = {"stat.meleedamage", "att.procon.meleeslow"}

ATT.Category = "perk_melee"

ATT.SortOrder = 2

ATT.Mult_MeleeDamage = 35 / 25
ATT.MeleeSlow = true

TacRP.LoadAtt(ATT, "perk_melee")
-- #endregion

------------------------------
-- #region perk_reload
------------------------------
ATT = {}

ATT.PrintName = "Quickload"
ATT.Icon = Material("entities/tacrp_att_acc_reload.png", "mips smooth")
ATT.Description = "Improves reloading speed."
ATT.Pros = {"stat.reloadtime"}

ATT.Category = "perk_reload"

ATT.SortOrder = 2

ATT.Mult_ReloadTimeMult = 0.88

TacRP.LoadAtt(ATT, "perk_reload")
-- #endregion

------------------------------
-- #region perk_shock
------------------------------
ATT = {}

ATT.PrintName = "Shock Trooper"
ATT.FullName = "Shock Trooper"
ATT.Icon = Material("entities/tacrp_att_acc_shock.png", "mips smooth")
ATT.Description = "Reduce impact of impairing effects while weapon is held."
ATT.Pros = {"att.procon.gasimmune", "att.procon.flashresist", "att.procon.stunresist"}

ATT.Category = {"perk", "perk_passive"}

ATT.SortOrder = 8

ATT.GasImmunity = true
ATT.StunResist = true

TacRP.LoadAtt(ATT, "perk_shock")
-- #endregion

------------------------------
-- #region perk_speed
------------------------------
ATT = {}

ATT.PrintName = "Agility"
ATT.Icon = Material("entities/tacrp_att_acc_speed.png", "mips smooth")
ATT.Description = "Improves weapon mobility, especially while reloading."
ATT.Pros = {"stat.movespeed", "stat.reloadspeed"}

ATT.Category = "perk"

ATT.SortOrder = 2

ATT.Add_MoveSpeedMult = 0.1
ATT.Add_ReloadSpeedMult = 0.15

TacRP.LoadAtt(ATT, "perk_speed")
-- #endregion

------------------------------
-- #region perk_throw
------------------------------
ATT = {}

ATT.PrintName = "Grenadier"
ATT.Icon = Material("entities/tacrp_att_acc_grenade.png", "mips smooth")
ATT.Description = "Improves quickthrow, and adds the option to throw rocks."
ATT.Pros = {"att.procon.quickthrow", "att.procon.throwrocks"}

ATT.Category = {"perk", "perk_throw"}

ATT.SortOrder = 6

ATT.ThrowRocks = true
ATT.Mult_QuickNadeTimeMult = 0.65

TacRP.LoadAtt(ATT, "perk_throw")
-- #endregion

