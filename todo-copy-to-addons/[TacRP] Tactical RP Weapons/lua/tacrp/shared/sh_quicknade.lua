TacRP.QuickNades = {
    ["frag"] = {
        PrintName = "FRAG",
        GrenadeEnt = "tacrp_proj_nade_frag",
        GrenadeWep = "tacrp_nade_frag",
        ThrowForce = 1000,
        Ammo = "grenade",
        AmmoEnt = "tacrp_ammo_frag",
        Model = "models/weapons/tacint/v_quicknade_frag.mdl",
        Spoon = true,
        Icon = Material("TacRP/grenades/frag.png", "mips smooth"),
        -- Texture = "tacrp/grenades/frag",
        CanSetImpact = true,

        FullName = "Frag Grenade",
        DetType = "Timed - 2 seconds",
        Description = "Standard explosive grenade spraying shrapnel in a medium radius.\n\nTypically not lethal by itself, but can wound targets or flush them out of cover.",
        Category = "LETHAL",
        SortOrder = 1,

    },
    ["flashbang"] = {
        PrintName = "FLASH",
        GrenadeEnt = "tacrp_proj_nade_flashbang",
        GrenadeWep = "tacrp_nade_flashbang",
        ThrowForce = 1000,
        Ammo = "ti_flashbang",
        AmmoEnt = "tacrp_ammo_flashbang",
        Model = "models/weapons/tacint/v_quicknade_flashbang.mdl",
        Spoon = true,
        Icon = Material("TacRP/grenades/flashbang.png", "mips smooth"),
        Texture = "tacrp/grenades/flashbang",
        CanSetImpact = true,

        FullName = "Flashbang",
        DetType = "Timed - 1.5 seconds",
        Description = "Emits a bright flash and deafening bang that disorients targets (hence its name).\n\nSlows affected targets, and deals minor damage in a large radius.",
        Category = "UTILITY",
        SortOrder = 4,
    },
    ["smoke"] = {
        PrintName = "SMOKE",
        GrenadeEnt = "tacrp_proj_nade_smoke",
        GrenadeWep = "tacrp_nade_smoke",
        ThrowForce = 1000,
        Ammo = "ti_smoke",
        AmmoEnt = "tacrp_ammo_smoke",
        Model = "models/weapons/tacint/v_quicknade_smoke.mdl",
        Spoon = true,
        Icon = Material("TacRP/grenades/smoke.png", "mips smooth"),
        Texture = "tacrp/grenades/smoke",
        CanSetImpact = true,

        FullName = "Smoke Grenade",
        DetType = "Timed - 2 seconds",
        Description = "Emits a concealing cloud of smoke that lasts about 20 seconds.\n\nDeals no damage whatsoever, and is commonly used to cover an advance or to obscure a line of sight.",
        Category = "UTILITY",
        SortOrder = 5,
    },
    ["gas"] = {
        PrintName = "GAS",
        GrenadeEnt = "tacrp_proj_nade_gas",
        GrenadeWep = "tacrp_nade_gas",
        ThrowForce = 1000,
        Ammo = "ti_gas",
        AmmoEnt = "tacrp_ammo_gas",
        Model = "models/weapons/tacint/v_quicknade_smoke.mdl",
        Spoon = true,
        Material = "models/tacint/weapons/v_models/smoke/gas-1",
        Icon = Material("TacRP/grenades/gas.png", "mips smooth"),
        Texture = "tacrp/grenades/gas",
        CanSetImpact = true,

        FullName = "CS Gas Grenade",
        DetType = "Timed - 2 seconds",
        Description = "Emits a cloud of tear gas that lasts about 15 seconds.\n\nAnyone caught within will take non-lethal lingering damage and have trouble keeping their weapon steady.\n\nIt is a chemical weapon banned by the Geneva Convention and is ABSOLUTELY NOT FART GAS.",
        Category = "UTILITY",
        SortOrder = 6,
    },
    ["thermite"] = {
        PrintName = "FIRE",
        GrenadeEnt = "tacrp_proj_nade_thermite",
        GrenadeWep = "tacrp_nade_thermite",
        ThrowForce = 1000,
        Ammo = "ti_thermite",
        AmmoEnt = "tacrp_ammo_fire",
        Model = "models/weapons/tacint/v_quicknade_smoke.mdl",
        Spoon = true,
        Material = "models/tacint/weapons/v_models/smoke/thermite-1",
        Icon = Material("TacRP/grenades/thermite.png", "mips smooth"),
        Texture = "tacrp/grenades/thermite",
        CanSetImpact = true,

        FullName = "Thermite Grenade",
        DetType = "Timed - 2 seconds",
        Description = "Burns intensely for about 8 seconds, dealing damage within a small radius.\n\nWhile thermite is typically used to burn through materiel, it is also useful for area denial.",
        Category = "LETHAL",
        SortOrder = 2,
    },
    ["c4"] = {
        PrintName = "C4",
        GrenadeEnt = "tacrp_proj_nade_c4",
        ThrowForce = 2000,
        ThrowSpeed = 0.75,
        Ammo = "ti_c4",
        AmmoEnt = "tacrp_ammo_c4",
        Model = "models/weapons/tacint/v_quicknade_c4.mdl",
        OverhandOnly = true,
        Spoon = false,
        Secret = true,
        SecretWeapon = "tacrp_c4_detonator",
        Icon = Material("TacRP/grenades/c4.png", "mips smooth"),
        Texture = "tacrp/grenades/c4",

        FullName = "C4 Charge",
        DetType = "Remote",
        Description = "A brick of powerful explosives that can be touched off by a detonator remotely.\n\nC4 is remarkably inert, but the signalling device can be removed or destroyed, defusing the charge.",
        Category = "SPECIAL",
        SortOrder = 8,
    },
    ["nuke"] = {
        PrintName = "NUKE",
        GrenadeEnt = "tacrp_proj_nade_nuke",
        ThrowForce = 200,
        ThrowSpeed = 0.6,
        Ammo = "ti_nuke",
        AmmoEnt = "tacrp_ammo_nuke",
        Model = "models/weapons/tacint/v_quicknade_nuke.mdl",
        Spoon = false,
        Secret = true,
        AdminOnly = true,
        Icon = Material("TacRP/grenades/nuke.png", "mips smooth"),
        Texture = "tacrp/grenades/nuke",

        NoSounds = false,
        PullSound = "tacrp/weapons/grenade/deploy-1.wav",

        FullName = "Nuclear Device",
        DetType = "Remote",
        Description = "Briefcase-sized micro nuclear bomb that can be touched off by a detonator remotely.\n\nIts explosive outcome needs no description.",
        Category = "SPECIAL",
        SortOrder = 9,
    },
    ["charge"] = {
        PrintName = "BREACH",
        GrenadeEnt = "tacrp_proj_nade_charge",
        GrenadeWep = "tacrp_nade_charge",
        ThrowForce = 2000,
        ThrowSpeed = 0.75,
        Ammo = "ti_charge",
        AmmoEnt = "tacrp_ammo_charge",
        Model = "models/weapons/tacint/v_quicknade_door_charge.mdl",
        OverhandOnly = true,
        Spoon = false,
        Icon = Material("TacRP/grenades/breach.png", "mips smooth"),
        Texture = "tacrp/grenades/breach",

        FullName = "Breaching Charge",
        DetType = "Timed - 2 seconds OR Remote",
        Description = "Shaped charge made to bust through doors and weak walls.\n\nSmall blast radius, but will destroy any door it is attached to and hurt targets on the other side with its shockwave.\n\nWhen holding a detonator, the charge is configured to detonate remotely.",
        Category = "LETHAL",
        SortOrder = 3,
    },
    ["rock"] = {
        PrintName = "ROCK",
        GrenadeEnt = "tacrp_proj_nade_rock",
        ThrowForce = 3000,
        ThrowSpeed = 1.1,
        Ammo = nil,
        UnderhandSpecial = true,
        Model = "models/weapons/tacint_extras/v_quicknade_rock.mdl",
        Spoon = false,
        NoSounds = true,
        Icon = Material("TacRP/grenades/rock.png", "mips smooth"),
        Texture = "tacrp/grenades/rock",
        RequireStat = "ThrowRocks",

        FullName = "Rock",
        DetType = "Blunt Trauma",
        Description = "Possibly the first weapon ever used by humans.\n\nUse as last resort, for ancient capital punishments, or for violent pranks.\n\nResourceful as you are, there's no telling what else you can pull out of your pants in a pinch...",
        Category = "SPECIAL",
        SortOrder = 7,
    },

    ["dz_bumpmine"] = {
        PrintName = "BUMP",
        GrenadeEnt = "dz_proj_bumpmine",
        GrenadeWep = "weapon_dz_bumpmine",
        ThrowForce = 2000,
        ThrowSpeed = 0.9,
        Ammo = "dz_bumpmine",
        Model = "models/weapons/dz_ents/c_bumpmine.mdl",
        Spoon = false,
        Icon = Material("entities/weapon_dz_bumpmine.png", "mips smooth"),
        OverhandOnly = true,
        Secret = true,
        SecretWeapon = "weapon_dz_bumpmine",
        NoSounds = false,
        PullSound = "DZ_Ents.HEGrenade.Draw",
        ThrowSound = "DZ_Ents.BumpMine.Throw",

        FullName = "Bump Mine",
        DetType = "Pressure Plate",
        Description = "Magnetized mine that sticks to surfaces.\n\nCreates a harmless explosion that pushes everything away, hurting targets by sending them into walls or floors.\n\nCan be used to launch yourself very far, but remember to bring a parachute.",
        Category = "Danger Zone",
        SortOrder = 8,
    },

    ["ttt_smoke"] = {
        PrintName = "T-SMK",
        GrenadeEnt = "ttt_smokegrenade_proj",
        GrenadeWep = "weapon_ttt_smokegrenade",
        ThrowForce = 4000,
        Model = "models/weapons/tacint/v_quicknade_smoke.mdl",
        Spoon = false,
        Icon = Material("TacRP/grenades/smoke.png", "mips smooth"),
        Texture = "tacrp/grenades/smoke",

        Singleton = true,
        TTTTimer = 2,

        FullName = "Smoke Grenade",
        DetType = "Timed - 2 seconds",
        Description = "Terrorist issue smoke grenade.\n\nCreates a smokescreen.",
        Category = "TTT",
        SortOrder = 0,
    },
    ["ttt_conf"] = {
        PrintName = "T-DCB",
        GrenadeEnt = "ttt_confgrenade_proj",
        GrenadeWep = "weapon_ttt_confgrenade",
        ThrowForce = 4000,
        Model = "models/weapons/tacint/v_quicknade_frag.mdl",
        Spoon = false,
        Icon = Material("TacRP/grenades/frag.png", "mips smooth"),
        Texture = "tacrp/grenades/frag",

        Singleton = true,
        TTTTimer = 3,

        FullName = "Discombobulator",
        DetType = "Timed - 3 seconds",
        Description = "Terrorist issue concussion grenade.\n\nDoes no damage, but creates a blast that pulls props in and pulls players out.",
        Category = "TTT",
        SortOrder = 0,
    },
    ["ttt_fire"] = {
        PrintName = "T-INC",
        GrenadeEnt = "ttt_firegrenade_proj",
        GrenadeWep = "weapon_zm_molotov",
        ThrowForce = 4000,
        Model = "models/weapons/tacint/v_quicknade_smoke.mdl",
        Material = "models/tacint/weapons/v_models/smoke/thermite-1",
        Spoon = false,
        Icon = Material("TacRP/grenades/thermite.png", "mips smooth"),
        Texture = "tacrp/grenades/thermite",

        Singleton = true,
        TTTTimer = 3,

        FullName = "Incendiary Grenade",
        DetType = "Timed - 3 seconds",
        Description = "Terrorist issue incendiary grenade.\n\nExplodes with minor damage, and starts fires in an area.",
        Category = "TTT",
        SortOrder = 0,
    },
}

TacRP.QuickNades_Index = {}
TacRP.QuickNades_EntLookup = {}

TacRP.QuickNades_Count = 0
for i, k in SortedPairsByMemberValue(TacRP.QuickNades, "SortOrder") do
    TacRP.QuickNades_Count = TacRP.QuickNades_Count + 1

    TacRP.QuickNades_Index[TacRP.QuickNades_Count] = i
    TacRP.QuickNades_EntLookup[k.GrenadeEnt] = i
    k.Index = TacRP.QuickNades_Count
end
TacRP.QuickNades_Bits = math.min(math.ceil(math.log(TacRP.QuickNades_Count + 1, 2)), 32)

function TacRP.IsGrenadeInfiniteAmmo(i)
    local nade = i
    if isstring(i) then
        nade = TacRP.QuickNades[i]
    elseif isnumber(i) then
        nade = TacRP.QuickNades[TacRP.QuickNades_Index[i]]
    end

    if !istable(nade) then return false end

    -- ttt grenades do not use ammo
    if nade.Singleton then return false end

    -- no ammo type means infinite ammo
    if !nade.Ammo then return true end

    -- non-admin nades are affected by infinite grenades cvar
    if !nade.AdminOnly and TacRP.ConVars["infinitegrenades"]:GetBool() then return true end

    return false
end