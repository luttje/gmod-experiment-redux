ATT.PrintName = "Grenade"
ATT.FullName = "Grenadier"
ATT.Icon = Material("entities/tacrp_att_melee_tech_nade.png", "mips smooth")
ATT.Description = "Always good to have something handy to throw."
ATT.Pros = {"ALT-FIRE: Quickthrow", "Faster Quickthrow", "Throw Rocks"} -- "RELOAD: Toggle Grenade",

ATT.Category = {"melee_tech"}

ATT.SortOrder = 4
ATT.InvAtt = "perk_throw"

ATT.ThrowRocks = true
ATT.Mult_QuickNadeTimeMult = 0.65

ATT.Hook_SecondaryAttack = function(self)
    self.GrenadeDownKey = IN_ATTACK2
    self:PrimeGrenade()
end

--[[]
ATT.Hook_PreReload = function(self)
    self.GrenadeMenuKey = IN_RELOAD
    if game.SinglePlayer() and SERVER then
        self:CallOnClient("Reload")
    end
    return true
end
]]

ATT.Hook_GetHintCapabilities = function(self, tbl)
    tbl["+attack2"] = {so = 0.1, str = "Quickthrow"}
end