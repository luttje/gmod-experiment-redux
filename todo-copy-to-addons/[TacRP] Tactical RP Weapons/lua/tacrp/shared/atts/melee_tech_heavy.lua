ATT.PrintName = "Heavy"
ATT.FullName = "Heavy-handed"
ATT.Icon = Material("entities/tacrp_att_melee_tech_heavy.png", "mips smooth")
ATT.Description = "A classic counter-terrorist technique: Just smack them real hard."
ATT.Pros = {"ALT-FIRE: Heavy Attack", "Backstab Damage"}

ATT.Category = {"melee_tech"}

ATT.SortOrder = 1

ATT.HeavyAttack = true

ATT.MeleeBackstab = true
ATT.MeleeBackstabMult = 2

ATT.Hook_SecondaryAttack = function(self)
    self:Melee(true)
    return true
end

ATT.Hook_GetHintCapabilities = function(self, tbl)
    tbl["+attack"] = {so = 0, str = "Light Melee"}
    tbl["+attack2"] = {so = 0.1, str = "Heavy Melee"}
end