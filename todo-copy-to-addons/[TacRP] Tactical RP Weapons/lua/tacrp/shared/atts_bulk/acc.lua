-- acc.lua

local ATT = {}

------------------------------
-- #region acc_bipod
------------------------------
ATT = {}
ATT.Ignore = true

ATT.PrintName = "Bipod"
ATT.Icon = Material("entities/tacrp_att_acc_bipod.png", "mips smooth")
ATT.Description = "Foldable support that stabilizes the weapon when deployed."
ATT.Pros = {"stat.recoilcrouch", "stat.swaycrouch"}

ATT.Category = "acc_bipod"


ATT.SortOrder = 5.5

ATT.Mult_RecoilCrouchMult = 0.2
ATT.Mult_SwayCrouchMult = 0.15

ATT.InstalledElements = {"bipod"}

TacRP.LoadAtt(ATT, "acc_bipod")
-- #endregion

------------------------------
-- #region acc_brace
------------------------------
ATT = {}

ATT.PrintName = "Pistol Brace"
ATT.Icon = Material("entities/tacrp_att_acc_brace.png", "mips smooth")
ATT.Description = "Turns your pistol into a rifle. The ATF is gonna get your ass."
ATT.Pros = {"rating.control", "rating.stability"}
ATT.Cons = {"rating.handling", "rating.maneuvering"}

ATT.Category = "acc_brace"

ATT.SortOrder = 3

ATT.Mult_RecoilKick = 0.3
ATT.Mult_RecoilSpreadPenalty = 0.75

ATT.Mult_Sway = 0.75
ATT.Add_ScopedSway = -0.2
ATT.Mult_ScopedSway = 0.75

ATT.Add_AimDownSightsTime = 0.06
ATT.Add_SprintToFireTime = 0.1

ATT.Add_HipFireSpreadPenalty = 0.0075
ATT.Add_FreeAimMaxAngle = 0.75

ATT.Mult_DeployTimeMult = 1.5
ATT.Mult_HolsterTimeMult = 1.5

TacRP.LoadAtt(ATT, "acc_brace")
-- #endregion

------------------------------
-- #region acc_cheekrest
------------------------------
ATT = {}

ATT.PrintName = "Cheek Rest"
ATT.Icon = Material("entities/tacrp_att_acc_cheekrest.png", "mips smooth")
ATT.Description = "Stabilizes your head while aiming down sights, reducing sway."
ATT.Pros = {"stat.scopedsway", "stat.bloomintensity"}

ATT.Category = "acc_sling"

ATT.SortOrder = 7

ATT.Mult_ScopedSway = 0.5
ATT.Mult_RecoilSpreadPenalty = 0.95

TacRP.LoadAtt(ATT, "acc_cheekrest")
-- #endregion

------------------------------
-- #region acc_conceal
------------------------------
ATT = {}

ATT.PrintName = "Concealment"
ATT.Icon = Material("entities/tacrp_att_acc_conceal.png", "mips smooth")
ATT.Description = "Carry the weapon discretely, hiding it from view when not held."
ATT.Pros = {"att.procon.conceal"}

ATT.Category = "acc_holster"

ATT.SortOrder = 8

ATT.Override_HolsterVisible = false

ATT.Ignore = false -- engine.ActiveGamemode() != "terrortown"

TacRP.LoadAtt(ATT, "acc_conceal")
-- #endregion

------------------------------
-- #region acc_dual_ergo
------------------------------
ATT = {}

ATT.PrintName = "Ergo Grip"
ATT.FullName = "Ergonomic Grip"
ATT.Icon = Material("entities/tacrp_att_acc_ergo.png", "mips smooth")
ATT.Description = "Grooved grip makes it easier to move while shooting two guns."

ATT.Category = "acc_dual"
ATT.InvAtt = "acc_ergo"

ATT.SortOrder = 2

ATT.Pros = {"stat.shootingspeed"}
ATT.Add_ShootingSpeedMult = 0.08

TacRP.LoadAtt(ATT, "acc_dual_ergo")
-- #endregion

------------------------------
-- #region acc_dual_quickdraw
------------------------------
ATT = {}

ATT.PrintName = "Quickdraw"
ATT.FullName = "Quickdraw Holster"
ATT.Icon = Material("entities/tacrp_att_acc_quickdraw.png", "mips smooth")
ATT.Description = "A pair of strapless holster to quickly draw the weapons and hasten loading."
ATT.Pros = {"stat.deploytime", "stat.reloadtime"}

ATT.Category = "acc_dual"
ATT.InvAtt = "acc_quickdraw"

ATT.SortOrder = 4

ATT.Mult_DeployTimeMult = 0.75
ATT.Mult_HolsterTimeMult = 0.5

ATT.Mult_ReloadTimeMult = 0.95

ATT.TryUnholster = true

TacRP.LoadAtt(ATT, "acc_dual_quickdraw")
-- #endregion

------------------------------
-- #region acc_dual_skel
------------------------------
ATT = {}

ATT.PrintName = "Light Grip"
ATT.FullName = "Lightweight Grip"
ATT.Icon = Material("entities/tacrp_att_acc_skel.png", "mips smooth")
ATT.Description = "Skeletonized grip makes the guns lighter and easier to move around with."

ATT.Category = "acc_dual"
ATT.InvAtt = "acc_skel"

ATT.SortOrder = 2.1

ATT.Pros = {"stat.movespeed", "stat.reloadspeed"}
ATT.Add_MoveSpeedMult = 0.08
ATT.Add_ReloadSpeedMult = 0.1

TacRP.LoadAtt(ATT, "acc_dual_skel")
-- #endregion

------------------------------
-- #region acc_duffelbag
------------------------------
ATT = {}

ATT.PrintName = "Gun Bag"
ATT.Icon = Material("entities/tacrp_dufflebag.png", "mips smooth")
ATT.Description = "Hide the gun in a bag so you don't cause mass panic."
ATT.Pros = {"Conceal weapon in bag"}

ATT.Category = "acc_duffle"

ATT.SortOrder = 8

ATT.Override_HolsterVisible = true
ATT.HolsterModel = "models/jessev92/payday2/item_bag_loot.mdl"
ATT.HolsterSlot = TacRP.HOLSTER_SLOT_BACK
ATT.HolsterPos = Vector(7, -2, 0)
ATT.HolsterAng = Angle(10, 90, 90)

ATT.Ignore = true

TacRP.LoadAtt(ATT, "acc_duffelbag")
-- #endregion

------------------------------
-- #region acc_ergo
------------------------------
ATT = {}

ATT.PrintName = "Ergo Grip"
ATT.FullName = "Ergonomic Grip"
ATT.Icon = Material("entities/tacrp_att_acc_ergo.png", "mips smooth")
ATT.Description = "Grooved grip makes aiming faster and moving while shooting easier."

ATT.Category = "acc"

ATT.SortOrder = 2

if engine.ActiveGamemode() == "terrortown" then
    ATT.Pros = {"stat.shootingspeed"}

    ATT.Add_ShootingSpeedMult = 0.15
else
    ATT.Pros = {"stat.shootingspeed", "stat.aimdownsights"}

    ATT.Add_ShootingSpeedMult = 0.08
    ATT.Mult_AimDownSightsTime = 0.85
end

TacRP.LoadAtt(ATT, "acc_ergo")
-- #endregion

------------------------------
-- #region acc_extendedbelt
------------------------------
ATT = {}

ATT.PrintName = "Box Extender"
ATT.Icon = Material("entities/tacrp_att_acc_extendedbelt.png", "mips smooth")
ATT.Description = "Increase ammo capacity for machine guns significantly."
ATT.Pros = {"stat.clipsize"}
ATT.Cons = {"stat.reloadtime"}

ATT.Category = "extendedbelt"

ATT.SortOrder = 1

ATT.Add_ClipSize = 25
ATT.Mult_ReloadTimeMult = 1.05

TacRP.LoadAtt(ATT, "acc_extendedbelt")
-- #endregion

------------------------------
-- #region acc_extmag_dual
------------------------------
ATT = {}

ATT.PrintName = "att.acc_extmag.name"
ATT.FullName = "att.acc_extmag.name.full"
ATT.Icon = Material("entities/tacrp_att_acc_extmag_dual.png", "mips smooth")
ATT.Description = "att.acc_extmag.desc"
ATT.Pros = {"stat.clipsize"}

ATT.Category = "acc_extmag_dual"

ATT.InvAtt = "acc_extmag_rifle"

ATT.SortOrder = 1

ATT.Add_ClipSize = 4

TacRP.LoadAtt(ATT, "acc_extmag_dual")
-- #endregion

------------------------------
-- #region acc_extmag_dual2
------------------------------
ATT = {}

ATT.PrintName = "att.acc_extmag.name"
ATT.FullName = "att.acc_extmag.name.full"
ATT.Icon = Material("entities/tacrp_att_acc_extmag_dual.png", "mips smooth")
ATT.Description = "att.acc_extmag.desc"
ATT.Pros = {"stat.clipsize"}

ATT.Category = "acc_extmag_dual2"

ATT.InvAtt = "acc_extmag_rifle"

ATT.SortOrder = 1

ATT.Add_ClipSize = 2

TacRP.LoadAtt(ATT, "acc_extmag_dual2")
-- #endregion

------------------------------
-- #region acc_extmag_dualsmg
------------------------------
ATT = {}

ATT.PrintName = "att.acc_extmag.name"
ATT.FullName = "att.acc_extmag.name.full"
ATT.Icon = Material("entities/tacrp_att_acc_extmag_dual.png", "mips smooth")
ATT.Description = "att.acc_extmag.desc"
ATT.Pros = {"stat.clipsize"}
ATT.Cons = {"stat.reloadtime"}

ATT.Category = "acc_extmag_dualsmg"

ATT.InvAtt = "acc_extmag_rifle"

ATT.SortOrder = 1

ATT.Add_ClipSize = 8
ATT.Mult_ReloadTimeMult = 1.05

TacRP.LoadAtt(ATT, "acc_extmag_dualsmg")
-- #endregion

------------------------------
-- #region acc_extmag_pistol
------------------------------
ATT = {}

ATT.PrintName = "att.acc_extmag.name"
ATT.FullName = "att.acc_extmag.name.full"
ATT.Icon = Material("entities/tacrp_att_acc_extmag_pistol.png", "mips smooth")
ATT.Description = "att.acc_extmag.desc"
ATT.Pros = {"stat.clipsize"}
ATT.Cons = {"stat.reloadtime"}

ATT.Category = "acc_extmag_pistol"

ATT.InvAtt = "acc_extmag_rifle"

ATT.SortOrder = 1

ATT.Add_ClipSize = 3

ATT.Mult_ReloadTimeMult = 1.03

TacRP.LoadAtt(ATT, "acc_extmag_pistol")
-- #endregion

------------------------------
-- #region acc_extmag_pistol2
------------------------------
ATT = {}

ATT.PrintName = "att.acc_extmag.name"
ATT.FullName = "att.acc_extmag.name.full"
ATT.Icon = Material("entities/tacrp_att_acc_extmag_pistol.png", "mips smooth")
ATT.Description = "att.acc_extmag.desc"
ATT.Pros = {"stat.clipsize"}
ATT.Cons = {"stat.reloadtime"}

ATT.Category = "acc_extmag_pistol2"

ATT.InvAtt = "acc_extmag_rifle"

ATT.SortOrder = 1

ATT.Add_ClipSize = 2

ATT.Mult_ReloadTimeMult = 1.03

TacRP.LoadAtt(ATT, "acc_extmag_pistol2")
-- #endregion

------------------------------
-- #region acc_extmag_rifle
------------------------------
ATT = {}

ATT.PrintName = "att.acc_extmag.name"
ATT.FullName = "att.acc_extmag.name.full"
ATT.Icon = Material("entities/tacrp_att_acc_extmag_rifle.png", "mips smooth")
ATT.Description = "att.acc_extmag.desc"
ATT.Pros = {"stat.clipsize"}
ATT.Cons = {"stat.reloadtime"}

ATT.Category = "perk_extendedmag"

ATT.SortOrder = 1

ATT.Add_ClipSize = 5

ATT.Mult_ReloadTimeMult = 1.05

TacRP.LoadAtt(ATT, "acc_extmag_rifle")
-- #endregion

------------------------------
-- #region acc_extmag_rifle2
------------------------------
ATT = {}

ATT.PrintName = "att.acc_extmag.name"
ATT.FullName = "att.acc_extmag.name.full"
ATT.Icon = Material("entities/tacrp_att_acc_extmag_rifle2.png", "mips smooth")
ATT.Description = "att.acc_extmag.desc"
ATT.Pros = {"stat.clipsize"}
ATT.Cons = {"stat.reloadtime"}

ATT.Category = "acc_extmag_rifle2"

ATT.InvAtt = "acc_extmag_rifle"

ATT.SortOrder = 1

ATT.Add_ClipSize = 4

ATT.Mult_ReloadTimeMult = 1.05

TacRP.LoadAtt(ATT, "acc_extmag_rifle2")
-- #endregion

------------------------------
-- #region acc_extmag_shotgun
------------------------------
ATT = {}

ATT.PrintName = "att.acc_extmag.name"
ATT.FullName = "att.acc_extmag.name.full"
ATT.Icon = Material("entities/tacrp_att_acc_extmag_shotgun.png", "mips smooth")
ATT.Description = "att.acc_extmag.desc"
ATT.Pros = {"stat.clipsize"}
ATT.Cons = {"stat.reloadtime"}

ATT.Category = "acc_extmag_shotgun"

ATT.InvAtt = "acc_extmag_rifle"

ATT.SortOrder = 1

ATT.Add_ClipSize = 2

ATT.Mult_ReloadTimeMult = 1.03

TacRP.LoadAtt(ATT, "acc_extmag_shotgun")
-- #endregion

------------------------------
-- #region acc_extmag_smg
------------------------------
ATT = {}

ATT.PrintName = "att.acc_extmag.name"
ATT.FullName = "att.acc_extmag.name.full"
ATT.Icon = Material("entities/tacrp_att_acc_extmag_smg.png", "mips smooth")
ATT.Description = "att.acc_extmag.desc"
ATT.Pros = {"stat.clipsize"}
ATT.Cons = {"stat.reloadtime"}

ATT.Category = "acc_extmag_smg"

ATT.InvAtt = "acc_extmag_rifle"

ATT.SortOrder = 1

ATT.Add_ClipSize = 5

ATT.Mult_ReloadTimeMult = 1.05

TacRP.LoadAtt(ATT, "acc_extmag_smg")
-- #endregion

------------------------------
-- #region acc_extmag_sniper
------------------------------
ATT = {}

ATT.PrintName = "att.acc_extmag.name"
ATT.FullName = "att.acc_extmag.name.full"
ATT.Icon = Material("entities/tacrp_att_acc_extmag_sniper.png", "mips smooth")
ATT.Description = "att.acc_extmag.desc"
ATT.Pros = {"stat.clipsize"}
ATT.Cons = {"stat.reloadtime"}

ATT.Category = "acc_extmag_sniper"

ATT.InvAtt = "acc_extmag_rifle"

ATT.SortOrder = 1

ATT.Add_ClipSize = 2

ATT.Mult_ReloadTimeMult = 1.03

TacRP.LoadAtt(ATT, "acc_extmag_sniper")
-- #endregion

------------------------------
-- #region acc_foldstock
------------------------------
ATT = {}

ATT.PrintName = "Fold Stock"
ATT.Icon = Material("entities/tacrp_att_acc_foldstock.png", "mips smooth")
ATT.Description = "Keep stock folded, improving handling significantly at the cost of recoil."
ATT.Pros = {"rating.handling", "rating.maneuvering"}
ATT.Cons = {"stat.recoilkick", "stat.scopedsway"}

ATT.Free = true

ATT.Category = "acc_foldstock"

ATT.SortOrder = 0.5

ATT.Mult_VisualRecoilKick = 2

ATT.Mult_SightedSpeedMult = 1.25
ATT.Mult_HipFireSpreadPenalty = 0.7

ATT.Add_RecoilKick = 1
ATT.Mult_RecoilKick = 1.5

-- ATT.Mult_SprintToFireTime = 0.75
-- ATT.Mult_AimDownSightsTime = 0.75
ATT.Add_SprintToFireTime = -0.08
ATT.Add_AimDownSightsTime = -0.08

ATT.Add_ScopedSway = 0.1
ATT.Mult_ScopedSway = 2
ATT.Mult_Sway = 0.8
ATT.Add_FreeAimMaxAngle = -1

ATT.InstalledElements = {"foldstock"}

ATT.TryUnholster = true
ATT.Mult_HolsterTimeMult = 0.5

TacRP.LoadAtt(ATT, "acc_foldstock")
-- #endregion

------------------------------
-- #region acc_foldstock2
------------------------------
ATT = {}

ATT.PrintName = "Adjust Stock"
ATT.Icon = Material("entities/tacrp_att_acc_foldstock.png", "mips smooth")
ATT.Description = "Shorten stock to improve handling somewhat at the cost of recoil."
ATT.Pros = {"rating.handling", "rating.maneuvering"}
ATT.Cons = {"stat.recoilkick", "stat.scopedsway"}

ATT.Free = true

ATT.Category = "acc_foldstock2"

ATT.SortOrder = 0.5

ATT.Mult_VisualRecoilKick = 1.65
ATT.Mult_SightedSpeedMult = 1.125
ATT.Mult_HipFireSpreadPenalty = 0.85

ATT.Add_RecoilKick = 0.5
ATT.Mult_RecoilKick = 1.25

-- ATT.Mult_SprintToFireTime = 0.85
-- ATT.Mult_AimDownSightsTime = 0.85
ATT.Add_SprintToFireTime = -0.04
ATT.Add_AimDownSightsTime = -0.04

ATT.Add_ScopedSway = 0.1
ATT.Mult_Sway = 0.9
ATT.Add_FreeAimMaxAngle = -0.5

ATT.InstalledElements = {"foldstock"}

ATT.TryUnholster = true
ATT.Mult_HolsterTimeMult = 0.75

TacRP.LoadAtt(ATT, "acc_foldstock2")
-- #endregion

------------------------------
-- #region acc_pad
------------------------------
ATT = {}

ATT.PrintName = "Recoil Pad"
ATT.Icon = Material("entities/tacrp_att_acc_pad.png", "mips smooth")
ATT.Description = "Rubber pad attached to the end of the stock."
ATT.Pros = {"stat.recoilkick"}

ATT.Category = "acc_sling"

ATT.SortOrder = 6

ATT.Mult_VisualRecoilKick = 0.9

ATT.Add_RecoilKick = -0.5
ATT.Mult_RecoilKick = 0.95

TacRP.LoadAtt(ATT, "acc_pad")
-- #endregion

------------------------------
-- #region acc_quickdraw
------------------------------
ATT = {}

ATT.PrintName = "Quickdraw"
ATT.FullName = "Quickdraw Holster"
ATT.Icon = Material("entities/tacrp_att_acc_quickdraw.png", "mips smooth")
ATT.Description = "Strapless holster with magazine pouches for quick drawing and loading."
ATT.Pros = {"stat.deploytime", "stat.reloadtime"}

ATT.Category = "acc_holster"

ATT.SortOrder = 4

--ATT.Mult_DeployTimeMult = 0.6
ATT.Mult_HolsterTimeMult = 0.5
ATT.Mult_ReloadTimeMult = 0.925

ATT.TryUnholster = true

TacRP.LoadAtt(ATT, "acc_quickdraw")
-- #endregion

------------------------------
-- #region acc_skel
------------------------------
ATT = {}

ATT.PrintName = "Light Grip"
ATT.FullName = "Lightweight Grip"
ATT.Icon = Material("entities/tacrp_att_acc_skel.png", "mips smooth")
ATT.Description = "Skeletonized grip makes the weapon faster to raise and keep raised."
ATT.Pros = {"Sighted Speed", "Sprint To Fire Time"}

ATT.Category = "acc"

ATT.SortOrder = 2.1



if engine.ActiveGamemode() == "terrortown" then
    ATT.Pros = {"stat.sightedspeed"}

    ATT.Add_SightedSpeedMult = 0.12
else
    ATT.Pros = {"stat.sightedspeed", "stat.sprinttofire"}

    ATT.Add_SightedSpeedMult = 0.08
    ATT.Mult_SprintToFireTime = 0.85
end

TacRP.LoadAtt(ATT, "acc_skel")
-- #endregion

------------------------------
-- #region acc_sling
------------------------------
ATT = {}

ATT.PrintName = "Sling"
ATT.Icon = Material("entities/tacrp_att_acc_sling.png", "mips smooth")
ATT.Description = "Attach a strap to the weapon, making it easier to draw and reload."
ATT.Pros = {"stat.deploytime", "stat.reloadtime"}

ATT.Category = "acc_sling"

ATT.SortOrder = 5

ATT.Mult_DeployTimeMult = 0.75
ATT.Mult_HolsterTimeMult = 0.75
ATT.Mult_ReloadTimeMult = 0.925

TacRP.LoadAtt(ATT, "acc_sling")
-- #endregion

