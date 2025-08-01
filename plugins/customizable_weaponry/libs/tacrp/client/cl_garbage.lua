local PLUGIN = PLUGIN
PLUGIN.CSModelPile    = {} -- { {Model = NULL, Weapon = NULL} }
PLUGIN.FlashlightPile = {}

function PLUGIN.CollectGarbage()
	local removed = 0

	local newpile = {}

	for _, k in pairs(PLUGIN.CSModelPile) do
		if IsValid(k.Weapon) then
			table.insert(newpile, k)

			continue
		end

		SafeRemoveEntity(k.Model)

		removed = removed + 1
	end

	PLUGIN.CSModelPile = newpile

	if GetConVar("developer"):GetBool() and removed > 0 then
		print("Removed " .. tostring(removed) .. " CSModels")
	end
end

hook.Add("PostCleanupMap", "PLUGIN.CleanGarbage", function()
	PLUGIN.CollectGarbage()
end)

timer.Create("TacRP CSModel Garbage Collector", 5, 0, PLUGIN.CollectGarbage)

hook.Add("PostDrawEffects", "TacRP_CleanFlashlights", function()
	local newflashlightpile = {}

	for _, k in pairs(PLUGIN.FlashlightPile) do
		if IsValid(k.Weapon) and k.Weapon == LocalPlayer():GetActiveWeapon() then
			table.insert(newflashlightpile, k)

			continue
		end

		if k.ProjectedTexture and k.ProjectedTexture:IsValid() then
			k.ProjectedTexture:Remove()
		end
	end

	PLUGIN.FlashlightPile = newflashlightpile

	local wpn = LocalPlayer():GetActiveWeapon()

	if not wpn then return end
	if not IsValid(wpn) then return end
	if not wpn.ArcticTacRP then return end

	if GetViewEntity() == LocalPlayer() then return end

	wpn:KillFlashlightsVM()
end)
