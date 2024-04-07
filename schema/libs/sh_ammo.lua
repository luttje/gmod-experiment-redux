Schema.ammo = Schema.ammo or {}
Schema.ammo.ammoCalibre = Schema.ammo.ammoCalibre or {}
Schema.ammo.lookupCalibre = Schema.ammo.lookupCalibre or {}

function Schema.ammo.RegisterCalibre(ammo, calibre, calibreName)
	ammo = ammo:lower()
    Schema.ammo.ammoCalibre[ammo] = {
        calibre = calibre,
        name = calibreName
    }
    Schema.ammo.lookupCalibre[calibre] = ammo
end

-- Since libs load before items, we must register all calibres here if we want to use them in items.
Schema.ammo.RegisterCalibre("xbowbolt", "5.7x28mm", "5.7x28mm Rounds")
Schema.ammo.RegisterCalibre("smg1", "5.56x45mm", "5.56x45mm Rounds")
Schema.ammo.RegisterCalibre("ar2", "7.62x39mm", "7.62x39mm")
Schema.ammo.RegisterCalibre("357", ".357", ".357 Rounds")
Schema.ammo.RegisterCalibre("ar2altfire", "beanbag", "Beanbag Pellets")
Schema.ammo.RegisterCalibre("pistol", "9x19mm", "9x19mm Rounds")
Schema.ammo.RegisterCalibre("buckshot", "12 Gauge", "12 Gauge Buckshot")
Schema.ammo.RegisterCalibre("alyxgun", ".45 ACP", ".45 ACP Rounds")
Schema.ammo.RegisterCalibre("airboatgun", ".40 S&W", ".40 S&W")

function Schema.ammo.GetCalibreName(calibre)
    local ammo = Schema.ammo.lookupCalibre[calibre]
	local calibreData = Schema.ammo.ammoCalibre[ammo]

	if (not calibreData) then
		error("Attempt to get name of invalid calibre '" .. calibre .. "'.")
	end

	return calibreData.name
end

function Schema.ammo.ConvertToCalibreName(ammo)
    local calibre = Schema.ammo.ammoCalibre[ammo]

    if (not calibre) then
        error("Attempt to convert invalid ammo '" .. ammo .. "' to calibre.")
    end

    return calibre.name
end

function Schema.ammo.ConvertToAmmo(calibre)
	local ammo = Schema.ammo.lookupCalibre[calibre]

	if (not ammo) then
		error("Attempt to convert invalid calibre '" .. calibre .. "' to ammo.")
	end

	return ammo
end

function Schema.ammo.ForceWeaponCalibre(swepClass, calibre)
	local swep = weapons.GetStored(swepClass)
    local ammo = Schema.ammo.ConvertToAmmo(calibre)

    if (not swep) then
        error("Attempt to force calibre on invalid weapon '" .. swepClass .. "'.")
    end

	if (weapons.IsBasedOn(swepClass, "tacrp_base")) then
		swep.Ammo = ammo -- For TacRP
	else
		swep.Primary.Ammo = ammo
	end
end
