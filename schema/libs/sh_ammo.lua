Schema.ammo = Schema.ammo or {}
Schema.ammo.ammoCalibre = Schema.ammo.ammoCalibre or {}
Schema.ammo.lookupCalibre = Schema.ammo.lookupCalibre or {}

function Schema.ammo.RegisterCalibre(ammo, calibre, calibreName)
	local ammoName = (isstring(ammo) and ammo or ammo.name):lower()
	Schema.ammo.ammoCalibre[ammoName] = {
		calibre = calibre,
		name = calibreName,
		ammo = istable(ammo) and ammo or nil,
	}
	Schema.ammo.lookupCalibre[calibre] = ammoName
end

local function createCustomAmmoType(name)
	return {
		name = name,
		dmgtype = DMG_BULLET,
		force = 700,
		maxcarry = "sk_max_smg1",
		maxsplash = 8,
		minsplash = 4,
		flags = 0,
		npcdmg = "sk_npc_dmg_smg1",
		plydmg = "sk_plr_dmg_smg1",
		tracer = TRACER_LINE_AND_WHIZ,
	}
end

-- Since libs load before items, we must register all calibres here if we want to use them in items.
Schema.ammo.RegisterCalibre(createCustomAmmoType("5.7x28mm"), "5.7x28mm", "5.7x28mm Rounds")
Schema.ammo.RegisterCalibre(createCustomAmmoType("5.56x45mm"), "5.56x45mm", "5.56x45mm Rounds")
Schema.ammo.RegisterCalibre(createCustomAmmoType("7.62x39mm"), "7.62x39mm", "7.62x39mm Rounds")
Schema.ammo.RegisterCalibre(createCustomAmmoType("6x35mm"), "6x35mm", "6mm Whisper Rounds") -- TODO: Make item
Schema.ammo.RegisterCalibre(createCustomAmmoType("7.62x51mm"), "7.62x51mm", "7.62x51mm Rounds") -- TODO: Make item
Schema.ammo.RegisterCalibre(createCustomAmmoType(".223 Remington"), ".223 Remington", ".223 Remington Rounds") -- TODO: Make item
Schema.ammo.RegisterCalibre(createCustomAmmoType(".308 Winchester"), ".308 Winchester", ".308 Winchester Rounds") -- TODO: Make item
Schema.ammo.RegisterCalibre(createCustomAmmoType("12.7x99mm"), "12.7x99mm", ".50 BMG Rounds") -- TODO: Make item

Schema.ammo.RegisterCalibre(createCustomAmmoType("beanbag"), "beanbag", "Beanbag Pellets")
Schema.ammo.RegisterCalibre("buckshot", "12 Gauge", "12 Gauge Shells")
Schema.ammo.RegisterCalibre(createCustomAmmoType("16 Gauge"), "16 Gauge", "16 Gauge Shells") -- TODO: Make item
Schema.ammo.RegisterCalibre(createCustomAmmoType("23x75mmR"), "23x75mmR", "23x75mmR Shells") -- TODO: Make item

Schema.ammo.RegisterCalibre("357", ".357", ".357 Rounds")
Schema.ammo.RegisterCalibre(createCustomAmmoType(".357 SIG"), ".357 SIG", ".357 SIG Rounds")  -- TODO: Make item
Schema.ammo.RegisterCalibre("pistol", "9x19mm", "9x19mm Rounds")
Schema.ammo.RegisterCalibre(createCustomAmmoType(".32 ACP"), ".32 ACP", ".32 ACP Rounds")  -- TODO: Make item
Schema.ammo.RegisterCalibre(createCustomAmmoType(".45 ACP"), ".45 ACP", ".45 ACP Rounds")
Schema.ammo.RegisterCalibre(createCustomAmmoType(".40 S&W"), ".40 S&W", ".40 S&W")

Schema.ammo.RegisterCalibre(createCustomAmmoType("4.6x30mm"), "4.6x30mm", "4.6x30mm Rounds")  -- TODO: Make item

function Schema.ammo.GetCalibreName(calibre)
    local ammo = Schema.ammo.lookupCalibre[calibre]

	if (not ammo) then
		error("Attempt to get name of invalid calibre '" .. calibre .. "'. Ammo not found!")
	end

	if (istable(ammo)) then
		ammo = ammo.name:lower()
	end

	local calibreData = Schema.ammo.ammoCalibre[ammo]

	if (not calibreData) then
		error("Attempt to get name of invalid calibre '" .. calibre .. "'.")
	end

	return calibreData.name
end

function Schema.ammo.ConvertToCalibreName(ammo)
    local calibre = Schema.ammo.ammoCalibre[ammo:lower()]

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

-- Only call this in InitializedPlugins on custom ammo (because that must be registered in GM:Initialize)
function Schema.ammo.ForceWeaponCalibre(swepClass, calibre)
	local swep = weapons.GetStored(swepClass)
	local ammoName = Schema.ammo.lookupCalibre[calibre]

	if (not Schema.ammo.ammoCalibre[ammoName]) then
		error("Attempt to force invalid calibre '" .. calibre .. "' on weapon '" .. swepClass .. "'. You should add this type of ammo to the schema first (don't forget to also make an item!)")
	end

	local ammo = Schema.ammo.ammoCalibre[ammoName].ammo

	if (ammo and istable(ammo)) then
		local ammoData = game.GetAmmoID(ammo.name)

		if (ammoData == -1) then
			game.AddAmmoType(ammo)
		end

		ammoName = ammo.name
	end

	if (not swep) then
		error("Attempt to force calibre on invalid weapon '" .. swepClass .. "'.")
	end

	if (weapons.IsBasedOn(swepClass, "tacrp_base")) then
		swep.Ammo = ammoName -- For TacRP
	else
		swep.Primary.Ammo = ammoName
	end
end
