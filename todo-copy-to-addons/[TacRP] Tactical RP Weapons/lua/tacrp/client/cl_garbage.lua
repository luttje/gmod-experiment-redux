TacRP.CSModelPile    = {} -- { {Model = NULL, Weapon = NULL} }
TacRP.FlashlightPile = {}

function TacRP.CollectGarbage()
    local removed = 0

    local newpile = {}

    for _, k in pairs(TacRP.CSModelPile) do
        if IsValid(k.Weapon) then
            table.insert(newpile, k)

            continue
        end

        SafeRemoveEntity(k.Model)

        removed = removed + 1
    end

    TacRP.CSModelPile = newpile

    if GetConVar("developer"):GetBool() and removed > 0 then
        print("Removed " .. tostring(removed) .. " CSModels")
    end
end

hook.Add("PostCleanupMap", "TacRP.CleanGarbage", function()
    TacRP.CollectGarbage()
end)

timer.Create("TacRP CSModel Garbage Collector", 5, 0, TacRP.CollectGarbage)

hook.Add("PostDrawEffects", "TacRP_CleanFlashlights", function()
    local newflashlightpile = {}

    for _, k in pairs(TacRP.FlashlightPile) do
        if IsValid(k.Weapon) and k.Weapon == LocalPlayer():GetActiveWeapon() then
            table.insert(newflashlightpile, k)

            continue
        end

        if k.ProjectedTexture and k.ProjectedTexture:IsValid() then
            k.ProjectedTexture:Remove()
        end
    end

    TacRP.FlashlightPile = newflashlightpile

    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn then return end
    if !IsValid(wpn) then return end
    if !wpn.ArcticTacRP then return end

    if GetViewEntity() == LocalPlayer() then return end

    wpn:KillFlashlightsVM()
end)