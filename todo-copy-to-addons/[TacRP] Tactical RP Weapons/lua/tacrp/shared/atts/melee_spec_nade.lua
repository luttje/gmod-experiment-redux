ATT.PrintName = "Bomber"
ATT.FullName = "Bombardier"
ATT.Icon = Material("entities/tacrp_att_melee_spec_nade.png", "mips smooth")
ATT.Description = "Use jury rigged impact grenades to ruin someone's day."
ATT.Pros = {"RELOAD: Toggle Grenade", "Grenades explode on impact"}
ATT.Cons = {"Slower Quickthrow", "Grenade Damage"}

ATT.Category = {"melee_spec"}
ATT.Free = true

ATT.SortOrder = 4

ATT.Hook_PreReload = function(self)
    self.GrenadeMenuKey = IN_RELOAD
    if game.SinglePlayer() and SERVER then
        self:CallOnClient("Reload")
    end
    return true
end

ATT.Hook_GetHintCapabilities = function(self, tbl)
    tbl["+reload"] = {so = 0.4, str = "Quickthrow Menu"}
end

ATT.QuickNadeTryImpact = true
-- ATT.Mult_QuickNadeTimeMult = 1.5