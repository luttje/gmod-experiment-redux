local ATT = {}

ATT = {}

ATT.PrintName = "Level Up"
ATT.Icon = Material("entities/tacrp_att_melee_boost_all.png", "mips smooth")
ATT.Description = "Small boost to all attributes."
ATT.Pros = {"stat.meleeperkstr", "stat.meleeperkagi", "stat.meleeperkint"}

ATT.Category = "melee_boost"

ATT.SortOrder = 1

ATT.Add_MeleePerkStr = 0.03
ATT.Add_MeleePerkAgi = 0.03
ATT.Add_MeleePerkInt = 0.03

TacRP.LoadAtt(ATT, "melee_boost_all")

ATT = {}
ATT.PrintName = "Bulk Up"
ATT.Icon = Material("entities/tacrp_att_melee_boost_str.png", "mips smooth")
ATT.Description = "Increase Brawn significantly at the cost of other attributes."
ATT.Pros = {"stat.meleeperkstr"}
ATT.Cons = {"stat.meleeperkagi", "stat.meleeperkint"}

ATT.Category = "melee_boost"

ATT.SortOrder = 2

ATT.Add_MeleePerkStr = 0.2
ATT.Add_MeleePerkAgi = -0.05
ATT.Add_MeleePerkInt = -0.05

TacRP.LoadAtt(ATT, "melee_boost_str")

ATT = {}
ATT.PrintName = "Catch Up"
ATT.Icon = Material("entities/tacrp_att_melee_boost_agi.png", "mips smooth")
ATT.Description = "Increase Dexterity significantly at the cost of other attributes."
ATT.Pros = {"stat.meleeperkagi"}
ATT.Cons = {"stat.meleeperkstr", "stat.meleeperkint"}

ATT.Category = "melee_boost"

ATT.SortOrder = 3

ATT.Add_MeleePerkAgi = 0.2
ATT.Add_MeleePerkStr = -0.05
ATT.Add_MeleePerkInt = -0.05

TacRP.LoadAtt(ATT, "melee_boost_agi")

ATT = {}
ATT.PrintName = "Wise Up"
ATT.Icon = Material("entities/tacrp_att_melee_boost_int.png", "mips smooth")
ATT.Description = "Increase Strategy significantly at the cost of other attributes."
ATT.Pros = {"stat.meleeperkint"}
ATT.Cons = {"stat.meleeperkstr", "stat.meleeperkagi"}

ATT.Category = "melee_boost"

ATT.SortOrder = 4

ATT.Add_MeleePerkInt = 0.2
ATT.Add_MeleePerkStr = -0.05
ATT.Add_MeleePerkAgi = -0.05

TacRP.LoadAtt(ATT, "melee_boost_int")


ATT = {}
ATT.PrintName = "Lifestealer"
ATT.Icon = Material("entities/tacrp_att_melee_boost_lifesteal.png", "mips smooth")
ATT.Description = "Restore health by dealing damage."
ATT.Pros = {"stat.lifesteal"}
ATT.Cons = {"stat.meleeperkstr", "stat.meleeperkagi"}

ATT.Category = "melee_boost"

ATT.SortOrder = 10

ATT.Add_Lifesteal = 0.3
ATT.Add_MeleePerkStr = -0.05
ATT.Add_MeleePerkAgi = -0.05

TacRP.LoadAtt(ATT, "melee_boost_lifesteal")

ATT = {}
ATT.PrintName = "Momentum"
ATT.Icon = Material("entities/tacrp_att_melee_boost_momentum.png", "mips smooth")
ATT.Description = "Restore perk charge by dealing damage."
ATT.Pros = {"stat.damagecharge"}
ATT.Cons = {"stat.meleeperkint"}

ATT.Category = "melee_boost"

ATT.SortOrder = 11

ATT.Add_DamageCharge = 0.01
ATT.Add_MeleePerkInt = -0.08

TacRP.LoadAtt(ATT, "melee_boost_momentum")

ATT = {}
ATT.PrintName = "Afterimage"
ATT.Icon = Material("entities/tacrp_att_melee_boost_afterimage.png", "mips smooth")
ATT.Description = "Swing your weapon in a flash, landing the attack instantly."
ATT.Pros = {"stat.meleedelay"}
ATT.Cons = {"stat.meleeattackmisstime"}

ATT.Category = "melee_boost"

ATT.SortOrder = 12

ATT.Override_MeleeDelay = 0
ATT.Mult_MeleeAttackMissTime = 1.15

TacRP.LoadAtt(ATT, "melee_boost_afterimage")

ATT = {}
ATT.PrintName = "Shock Trooper"
ATT.FullName = "Shock Trooper"
ATT.Icon = Material("entities/tacrp_att_acc_shock.png", "mips smooth")
ATT.Description = "Reduce impact of impairing effects while weapon is held."
ATT.Pros = {"att.procon.gasimmune", "att.procon.flashresist", "att.procon.stunresist"}

ATT.Category = "melee_boost"
ATT.InvAtt = "perk_shock"

ATT.SortOrder = 12

ATT.GasImmunity = true
ATT.StunResist = true

TacRP.LoadAtt(ATT, "melee_boost_shock")