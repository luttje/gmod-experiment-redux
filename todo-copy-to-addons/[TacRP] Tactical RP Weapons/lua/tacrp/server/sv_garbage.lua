TacRP.ShieldPropPile    = {} -- { {Model = NULL, Weapon = NULL} }

local function SV_TacRP_CollectGarbage()
    local removed = 0

    local newpile = {}

    for _, k in pairs(TacRP.ShieldPropPile) do
        if IsValid(k.Weapon) then
            table.insert(newpile, k)

            continue
        end

        SafeRemoveEntity(k.Model)

        removed = removed + 1
    end

    TacRP.ShieldPropPile = newpile

    if GetConVar("developer"):GetBool() and removed > 0 then
        print("Removed " .. tostring(removed) .. " Shield Models")
    end
end

timer.Create("TacRP Shield Model Garbage Collector", 5, 0, SV_TacRP_CollectGarbage)

hook.Add("PlayerDeath", "TacRP_DeathCleanup", function(ply, inflictor, attacker)
    ply:SetNWFloat("TacRPGasEnd", 0)
    ply:SetNWFloat("TacRPStunStart", 0)
    ply:SetNWFloat("TacRPStunDur", 0)

    local timername = "tacrp_gas_" .. ply:EntIndex()
    if timer.Exists(timername) then
        timer.Remove(timername)
    end
end)