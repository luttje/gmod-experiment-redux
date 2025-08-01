// the 0 is for load order!!!

local conVars = {
    {
        name = "drawhud",
        default = "1",
        client = true
    },
    {
        name = "minhud",
        default = "1",
        client = true
    },
    {
        name = "autoreload",
        default = "1",
        client = true
    },
    {
        name = "autosave",
        default = "1",
        client = true,
        userinfo = true,
    },
    {
        name = "subcats",
        default = "1",
        client = true,
    },
    {
        name = "shutup",
        default = "0",
        client = true,
    },
    {
        name = "togglepeek",
        default = "1",
        client = true,
    },
    {
        name = "bodydamagecancel",
        default = "1",
        replicated = true,
    },
    {
        name = "free_atts",
        default = "1",
        replicated = true,
        notify = true,
    },
    {
        name = "lock_atts",
        default = "1",
        replicated = true,
        notify = true,
    },
    {
        name = "loseattsondie",
        default = "1",
    },
    {
        name = "generateattentities",
        default = "1",
        replicated = true,
    },
    {
        name = "npc_equality",
        default = "0",
    },
    {
        name = "npc_atts",
        default = "1",
    },
    {
        name = "penetration",
        default = "1",
        replicated = true,
        notify = true,
    },
    {
        name = "freeaim",
        default = "1",
        replicated = true,
        notify = true,
    },
    {
        name = "sway",
        default = "1",
        replicated = true,
        notify = true,
    },
    {
        name = "physbullet",
        default = "1",
        replicated = true,
        notify = true,
    },
    {
        name = "resupply_grenades",
        default = "1",
    },
    {
        name = "fixedspread",
        default = "1",
        notify = true,
    },
    {
        name = "pelletspread",
        default = "1",
        notify = true,
    },
    {
        name = "client_damage",
        default = "0",
        replicated = true,
        notify = true,
    },
    {
        name = "rp_requirebench",
        default = "0",
    },
    {
        name = "true_laser",
        default = "1",
        client = true,
    },
    {
        name = "toggletactical",
        default = "1",
        replicated = true,
    },
    {
        name = "rock_funny",
        default = "0.05"
    },
    {
        name = "arcade",
        default = "1",
        replicated = true,
    },
    {
        name = "ammonames",
        default = "1",
        client = true
    },
    {
        name = "font1",
        default = "",
        client = true
    },
    {
        name = "font2",
        default = "",
        client = true
    },
    {
        name = "drawholsters",
        default = "1",
        client = true,
    },
    {
        name = "crosshair",
        default = "0",
        replicated = true,
        notify = true,
    },
    {
        name = "vignette",
        default = "1",
        client = true,
    },
    {
        name = "flash_dark",
        default = "0",
        client = true,
    },
    {
        name = "flash_slow",
        default = "0.4",
        min = 0,
        max = 1,
        replicated = true,
    },
    {
        name = "melee_slow",
        default = "0.4",
        min = 0,
        max = 1,
        replicated = true,
    },
    {
        name = "metricunit",
        default = "0",
        client = true,
    },
    {
        name = "nademenu",
        default = "1",
        client = true,
        userinfo = true,
    },
    {
        name = "nademenu_click",
        default = "1",
        client = true,
    },
    {
        name = "blindfiremenu",
        default = "1",
        client = true,
        userinfo = true,
    },
    {
        name = "blindfiremenu_nocenter",
        default = "0",
        client = true,
        userinfo = true,
    },
    {
        name = "gas_sway",
        default = "6",
        min = 0,
        max = 10,
        replicated = true,
    },
    {
        name = "idunwannadie",
        default = "0",
        client = true,
        userinfo = true,
    },
    {
        name = "aim_cancels_sprint",
        default = "1",
        client = true,
        userinfo = true,
        min = 0,
        max = 1,
    },
    {
        name = "holster",
        default = "1",
        replicated = true,
        notify = true,
    },
    {
        name = "news_majoronly",
        default = "0",
        client = true,
    },
    {
        name = "hud",
        default = "1",
        replicated = true,
        notify = true,
    },
    {
        name = "visibleholster",
        default = "1",
        replicated = true,
        notify = true,
    },
    {
        name = "checknews",
        default = "1",
        replicated = true,
    },
    {
        name = "radar_quiet",
        default = "0",
        client = true,
    },
    {
        name = "toggleaim",
        default = "0",
        client = true,
        userinfo = true,
    },
    {
        name = "toggleholdbreath",
        default = "0",
        client = true,
        userinfo = true,
    },
    {
        name = "flashlight_blind",
        default = "1",
        replicated = true,
        notify = true,
    },
    {
        name = "glint",
        default = "1",
        replicated = true,
        notify = true,
    },
    {
        name = "funny_loudnoises",
        default = "1",
        min = 0,
        max = 2,
        replicated = true,
    },
    {
        name = "balance",
        default = "-1",
        min = -1,
        max = 4,
        replicated = true,
        notify = true,
        callback = function(convar, old, new)
            if old != new and SERVER then
                TacRP.LoadAtts()
                TacRP.InvalidateCache()
                net.Start("tacrp_reloadatts")
                net.Broadcast()
            end
        end,
    },
    {
        name = "sprint_reload",
        default = "1",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
    },
    {
        name = "sprint_counts_midair",
        default = "0",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
    },
    {
        name = "sprint_lower",
        default = "1",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
    },
    {
        name = "reload_sg_cancel",
        default = "1",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
    },
    {
        name = "armorpenetration",
        default = "1",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
    },
    {
        name = "nearwall",
        default = "1",
        client = true,
    },
    {
        name = "hudscale",
        default = "1",
        client = true,
    },
    {
        name = "language",
        default = "",
        replicated = true,
    },
    {
        name = "dev_benchgun",
        default = "0",
        client = true,
        noarchive = true,
    },
    {
        name = "altrecoil",
        default = "1",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
    },
    {
        name = "flashlight_alt",
        default = "0",
        client = true,
    },
    // --------------------------- Hints
    {
        name = "hints",
        default = "1",
        client = true,
    },
    {
        name = "hints_always",
        default = "0",
        client = true,
    },
    {
        name = "hints_altfont",
        default = "0",
        client = true,
    },

    // --------------------------- Movement Penalties

    {
        name = "penalty_move",
        default = "1",
        replicated = true,
        notify = true,
    },

    {
        name = "penalty_firing",
        default = "1",
        replicated = true,
        notify = true,
    },

    {
        name = "penalty_aiming",
        default = "1",
        replicated = true,
        notify = true,
    },

    {
        name = "penalty_reload",
        default = "1",
        replicated = true,
        notify = true,
    },

    {
        name = "penalty_melee",
        default = "1",
        replicated = true,
        notify = true,
    },

    // --------------------------- Ammo
    {
        name = "defaultammo",
        default = "2",
        replicated = true,
        notify = false,
        min = 0,
    },
    {
        name = "infiniteammo",
        default = "0",
        replicated = true,
        notify = true,
    },
    {
        name = "infinitegrenades",
        default = "0",
        replicated = true,
        notify = true,
    },

    // --------------------------- Slots
    {
        name = "slot_hl2",
        default = "0",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
    },
    {
        name = "slot_limit",
        default = "0",
        notify = true,
        min = 0,
    },
    {
        name = "slot_countall",
        default = "0",
        notify = true,
        min = 0,
        max = 1,
    },
    {
        name = "slot_action",
        default = "1",
        notify = true,
        min = 0,
        max = 2,
    },
    {
        name = "max_grenades",
        default = "9999",
        min = 0,
    },

    {
        name = "hud_ammo_number",
        default = "0",
        client = true,
        min = 0,
        max = 1
    },

    // --------------------------- Irons
    {
        name = "irons_lower",
        default = "1",
        replicated = true,
        notify = true,
        min = 0,
        max = 2,
    },
    {
        name = "irons_procedural",
        default = "1",
        notify = true,
        replicated = true,
        min = 0,
        max = 2,
    },

    // --------------------------- Attachments
    {
        name = "att_radartime",
        default = "1.5",
        replicated = true,
        min = 0.5,
    },

    // --------------------------- TTT
    {
        name = "ttt_weapon_include",
        default = "1",
        notify = true,
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "ttt_weapon_replace",
        default = "1", // fraction chance
        notify = true,
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "ttt_atts_random",
        default = "0.5", // fraction chance
        notify = true,
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "ttt_atts_max",
        default = "0", // fraction chance
        notify = true,
        replicated = true,
        min = 0,
    },
    {
        name = "ttt_atts_giveonspawn",
        default = "20",
        notify = true,
        replicated = true,
        min = 0,
    },
    {
        name = "ttt_cust_inno_allow",
        default = "1",
        notify = true,
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "ttt_cust_role_allow",
        default = "1",
        notify = true,
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "ttt_cust_inno_round",
        default = "1",
        notify = true,
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "ttt_cust_role_round",
        default = "1",
        notify = true,
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "ttt_cust_inno_needbench",
        default = "0",
        notify = true,
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "ttt_cust_role_needbench",
        default = "0",
        notify = true,
        replicated = true,
        min = 0,
        max = 1,
    },
    {
        name = "ttt_shortname",
        default = "1",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
    },
    {
        name = "ttt_magazine_dna",
        default = "1",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
    },
    {
        name = "ttt_bench_freeatts",
        default = "1",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
    },

    {
        name = "laser_beam",
        default = "0",
        replicated = true,
        min = 0,
        max = 1,
    },

    {
        name = "cust_legacy",
        default = "0",
        client = true,
        min = 0,
        max = 1,
    },
    {
        name = "muzzlelight",
        default = "1",
        client = true,
        min = 0,
        max = 1
    },
    {
        name = "recoilpattern",
        default = "1",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
    },

    {
        name = "allowdrop",
        default = "1",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
    },
    {
        name = "oldschool",
        default = "0",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
        callback = function(convar, old, new)
            if tonumber(new) == 1 and SERVER then
                TacRP.ConVars["sightsonly"]:SetBool(false)
            end
        end,
    },
    {
        name = "sightsonly",
        default = "0",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
        callback = function(convar, old, new)
            if tonumber(new) == 1 and SERVER then
                TacRP.ConVars["oldschool"]:SetBool(false)
            end
        end,
    },
    {
        name = "deploysafety",
        default = "0",
        replicated = true,
        notify = true,
        min = 0,
        max = 1,
    },


    {
        name = "cust_drop",
        default = "1",
        client = true,
        min = 0,
        max = 1,
    },
    {
        name = "pickup_use",
        default = "1",
        client = true,
        userinfo = true,
        min = 0,
        max = 1,
    },
    {
        name = "phystweak",
        default = "1",
        min = 0,
        max = 1,
        replicated = true,
    },

    // --------------------------- Multipliers
    {
        name = "mult_damage",
        default = "1",
        min = 0.01,
        replicated = true,
    },
    {
        name = "mult_damage_shotgun",
        default = "1",
        min = 0.01,
        replicated = true,
    },
    {
        name = "mult_damage_sniper",
        default = "1",
        min = 0.01,
        replicated = true,
    },
    {
        name = "mult_damage_magnum",
        default = "1",
        min = 0.01,
        replicated = true,
    },
    {
        name = "mult_damage_explosive",
        default = "1",
        min = 0.01,
        replicated = true,
    },
    {
        name = "mult_recoil_kick",
        default = "1",
        min = 0,
        replicated = true,
    },
    {
        name = "mult_recoil_vis",
        default = "1",
        min = 0,
        replicated = true,
    },
    {
        name = "mult_reloadspeed",
        default = "1",
        min = 0.1,
        replicated = true,
    },
    {
        name = "mult_aimdownsights",
        default = "1",
        min = 0.1,
        replicated = true,
    },
    {
        name = "mult_sprinttofire",
        default = "1",
        min = 0.1,
        replicated = true,
    },


    {
        name = "recoilreset",
        default = "0",
        min = 0,
        max = 1,
        replicated = true,
    },
    {
        name = "reload_dump",
        default = "0",
        min = 0,
        max = 1,
        replicated = true,
    },
}

TacRP.ConVars = {}

local prefix = "tacrp_"

local flags = {
    ["replicated"] = FCVAR_REPLICATED,
    ["userinfo"] = FCVAR_USERINFO,
    ["notify"] = FCVAR_NOTIFY
}
for _, var in pairs(conVars) do
    local convar_name = prefix .. var.name

    if var.client and CLIENT then
        TacRP.ConVars[var.name] = CreateClientConVar(convar_name, var.default, !var.noarchive, var.userinfo)
    elseif !var.client then
        local flag = FCVAR_ARCHIVE
        for k, v in pairs(flags) do if var[k] then flag = flag + v end end
        TacRP.ConVars[var.name] = CreateConVar(convar_name, var.default, flag, var.help, var.min, var.max)
    end

    if var.callback then
        cvars.AddChangeCallback(convar_name, var.callback, "tacrp")
    end
end

if CLIENT then

local function reset_cvars()
    for _, cvar in pairs(TacRP.ConVars) do
        if bit.band(cvar:GetFlags(), FCVAR_LUA_CLIENT) != 0 then
            cvar:Revert()
        end
    end
end

local function header(panel, text)
    local ctrl = panel:Help(text)
    ctrl:SetFont("DermaDefaultBold")
    return ctrl
end

local function menu_client_ti(panel)

    local btn_reset = vgui.Create("DButton")
    btn_reset:Dock(TOP)
    btn_reset:SetText("Apply Default Client Settings")
    function btn_reset.DoClick(self)
        Derma_Query(
            "Are you sure you want to reset ALL client settings to default values? This is irreversible!",
            "TacRP",
            "Yes",
            function()
                reset_cvars()
            end,
            "No"
        )
    end
    panel:AddPanel(btn_reset)

    header(panel, "Interface")
    panel:AddControl("checkbox", {
        label = "Show HUD",
        command = "TacRP_drawhud"
    })
    panel:AddControl("checkbox", {
        label = "Show Backup HUD",
        command = "tacrp_minhud"
    })
    panel:AddControl("checkbox", {
        label = "Quickthrow Radial Menu",
        command = "tacrp_nademenu"
    })
    panel:ControlHelp("When enabled, +grenade2 brings up a menu to select grenades. Otherwise it switches between them.")
    panel:AddControl("checkbox", {
        label = "Quickthrow Menu Clicking",
        command = "tacrp_nademenu_click"
    })
    panel:ControlHelp("When enabled, left click and right click in the quickthrow menu performs an overhand and underhand throw of the highlighted grenade.")
    panel:AddControl("checkbox", {
        label = "Blindfire Radial Menu",
        command = "tacrp_blindfiremenu"
    })
    panel:ControlHelp("When enabled, +zoom brings up a menu to change blindfire type. Otherwise it sets blindfire based on movement keys pressed.")
    panel:AddControl("checkbox", {
        label = "Blindfire Menu Empty Center",
        command = "tacrp_blindfiremenu_nocenter"
    })
    panel:ControlHelp("When enabled, center option does nothing, and bottom option will cancel blindfire instead.\nThis will hide the option to shoot yourself.")
    panel:AddControl("checkbox", {
        label = "Use Meters instead of HU",
        command = "tacrp_metricunit"
    })
    panel:AddControl("checkbox", {
        label = "Recoil Vignette",
        command = "tacrp_vignette"
    })
    panel:ControlHelp("Vignette intensity is based on amount of accumulated recoil.")
    panel:AddControl("checkbox", {
        label = "Show \"Drop Weapon\" Button",
        command = "tacrp_cust_drop"
    })
    panel:AddControl("slider", {
        label = "HUD Scale",
        command = "tacrp_hudscale",
        type = "float",
        min = 0.25,
        max = 1.5,
    })
    panel:ControlHelp("HUD is already scaled to screen width; this slider may help ultrawide users or people with a vertical setup.")

    header(panel, "\nHints")
    panel:AddControl("checkbox", {
        label = "Show Control Hints",
        command = "tacrp_hints"
    })
    panel:ControlHelp("Shows your currently available actions regardless of whether the HUD is enabled or not.")
    panel:AddControl("checkbox", {
        label = "Hints Always Active",
        command = "tacrp_hints_always"
    })
    panel:AddControl("checkbox", {
        label = "Hints Use Alternate Font",
        command = "tacrp_hints_altfont"
    })
    panel:AddControl("checkbox", {
        label = "Hide Startup Quickthrow Bind Reminder",
        command = "tacrp_shutup"
    })

    header(panel, "\nPreference")
    panel:AddControl("checkbox", {
        label = "Toggle Aiming",
        command = "tacrp_toggleaim"
    })
    panel:AddControl("checkbox", {
        label = "Toggle Peeking",
        command = "tacrp_togglepeek"
    })
    panel:AddControl("checkbox", {
        label = "Aiming Stops Sprinting",
        command = "tacrp_aim_cancels_sprint"
    })
    panel:ControlHelp("When holding both Sprint and Aim buttons, aim the weapon and prevent sprinting.")
    panel:AddControl("checkbox", {
        label = "Auto-Save Weapon",
        command = "TacRP_autosave"
    })
    panel:AddControl("checkbox", {
        label = "Auto Reload When Empty",
        command = "TacRP_autoreload"
    })
    panel:AddControl("checkbox", {
        label = "Flashbang Dark Mode",
        command = "tacrp_flash_dark"
    })
    panel:ControlHelp("In dark mode, flashbangs turn your screen black instead of white, and mutes audio intead of ringing.")
    panel:AddControl("checkbox", {
        label = "Quiet Radar",
        command = "tacrp_radar_quiet"
    })
    panel:ControlHelp("This mutes your own radar sound for yourself only. Others can still hear your radar, and you can still hear others' radars.")
    panel:AddControl("checkbox", {
        label = "Pickup Requires +USE",
        command = "tacrp_pickup_use"
    })
    panel:ControlHelp("This option only affects TacRP weapons.")
    panel:AddControl("checkbox", {
        label = "Toggle Tactical with +WALK",
        command = "tacrp_flashlight_alt"
    })
    panel:ControlHelp("If disabled, ALT+F toggles HL2 flashlight and F toggles tactical;\nif enabled, F toggles HL2 flashlight and ALT+F toggles tactical.")

    header(panel, "\nMiscellaneous")
    panel:AddControl("checkbox", {
        label = "Muzzle Light",
        command = "tacrp_muzzlelight"
    })
    panel:ControlHelp("Emits a brief projected light when you shoot (but not for others).")
    panel:AddControl("checkbox", {
        label = "Near Walling",
        command = "tacrp_nearwall"
    })
    panel:ControlHelp("Pushes viewmodel back when the point of aim is in front of a wall. Purely visual effect, but may help when blindfiring.")

    panel:AddControl("checkbox", {
        label = "Disable Suicide Mode",
        command = "tacrp_idunwannadie"
    })
    panel:ControlHelp("Hides the option to shoot yourself from the radial menu, and disables the SHIFT+ALT+B key combo.")
    panel:AddControl("checkbox", {
        label = "Draw Holstered Weapons",
        command = "tacrp_drawholsters"
    })
    panel:AddControl("checkbox", {
        label = "True Laser Position",
        command = "tacrp_true_laser"
    })
    panel:AddControl("checkbox", {
        label = "Immersive Ammo Names (Requires map reload)",
        command = "tacrp_ammonames"
    })
    panel:AddControl("checkbox", {
        label = "Spawnmenu Subcategories",
        command = "tacrp_subcats"
    })
    panel:ControlHelp("Separate weapons based on their type (like Sidearm, Assault Rifle, Shotgun). Use ConCommand \"spawnmenu_reload\" to take effect.")
end

local function menu_server_ti(panel)
    header(panel, "Features")
    panel:Help("Settings in this section affect ALL PLAYERS.")
    panel:AddControl("checkbox", {
        label = "Enable Crosshair",
        command = "tacrp_crosshair"
    })
    panel:AddControl("checkbox", {
        label = "Enable HUD (and Minimal HUD)",
        command = "tacrp_hud"
    })
    panel:AddControl("checkbox", {
        label = "Holstered Weapon Models",
        command = "tacrp_visibleholster"
    })
    panel:AddControl("checkbox", {
        label = "Enable Newsletter",
        command = "tacrp_checknews"
    })
    panel:ControlHelp("If turned off, newsletter popup/notification will not happen. Players can still open the newsletter page manually.")
    panel:AddControl("checkbox", {
        label = "Allow Dropping & Swapping",
        command = "tacrp_allowdrop"
    })
    panel:AddControl("checkbox", {
        label = "Enable Safety On Deploy",
        command = "tacrp_deploysafety"
    })

    local cb_irons_procedural, lb_irons_procedural = panel:ComboBox("Use Procedural Ironsights", "tacrp_irons_procedural")
    cb_irons_procedural:AddChoice("0 - Never", "0")
    cb_irons_procedural:AddChoice("1 - With Optic", "1")
    cb_irons_procedural:AddChoice("2 - Always", "2")
    cb_irons_procedural:DockMargin(8, 0, 0, 0)
    lb_irons_procedural:SizeToContents()
    panel:ControlHelp("Applies mostly to pistols. Replaces firing animation while aiming with a much less disruptive procedural effect, making aiming with the weapon's sights easier.")

    local cb_irons_lower, lb_irons_lower = panel:ComboBox("Use Lowered Ironsights", "tacrp_irons_lower")
    cb_irons_lower:AddChoice("0  - Never", "0")
    cb_irons_lower:AddChoice("1 - In TTT", "1")
    cb_irons_lower:AddChoice("2  - Always", "2")
    cb_irons_lower:DockMargin(8, 0, 0, 0)
    lb_irons_lower:SizeToContents()
    panel:ControlHelp("While aiming with ironsights, lower the weapon and draw a dot where the point of aim is (even when Enable Crosshair is off). The dot does not display weapon sway or spread.")

    header(panel, "\nWeapon Slot Restriction")
    panel:ControlHelp("Restrict TacRP weapons for pickup/spawning based on their weapon slot.")
    panel:AddControl("slider", {
        label = "Max Per Slot (0 - no limit)",
        command = "tacrp_slot_limit",
        type = "int",
        min = 0,
        max = 3,
    })
    panel:AddControl("checkbox", {
        label = "Use HL2-style slots",
        command = "tacrp_slot_hl2"
    })
    panel:ControlHelp("Use slot 4 for MGs, shotguns and snipers, slot 5 for explosives.")
    panel:AddControl("checkbox", {
        label = "Count ALL weapons",
        command = "tacrp_slot_countall"
    })
    panel:ControlHelp("WARNING! If set, non-TacRP weapons may be dropped/removed to make room for TacRP weapons! This can have unintended consequences!")

    local cb_slot_action, lb_slot_action = panel:ComboBox("Weapon Spawning Behavior", "tacrp_slot_action")
    cb_slot_action:AddChoice("0 - Fail", "0")
    cb_slot_action:AddChoice("1 - Remove", "1")
    cb_slot_action:AddChoice("2 - Drop", "2")
    cb_slot_action:DockMargin(8, 0, 0, 0)
    lb_slot_action:SizeToContents()

    panel:ControlHelp("Only affects giving weapons with the spawnmenu.")

    header(panel, "\nNPC")
    panel:AddControl("checkbox", {
        label = "NPCs Deal Equal Damage",
        command = "TacRP_npc_equality"
    })
    panel:AddControl("checkbox", {
        label = "NPCs Get Random Attachments",
        command = "TacRP_npc_atts"
    })


    header(panel, "\nMiscellaneous")
    panel:AddControl("checkbox", {
        label = "Supply Boxes Resupply Grenades",
        command = "TacRP_resupply_grenades"
    })
    panel:AddControl("checkbox", {
        label = "Default Body Damage Cancel",
        command = "TacRP_bodydamagecancel"
    })
    panel:ControlHelp("Only disable this if another addon or gamemode is also modifying default hitgroup damage multipliers.")
end

local function menu_balance_ti(panel)
    header(panel, "Damage")
    panel:Help("Adjust weapon attributes to suit your gameplay needs.")
    local cb_balance, lb_balance = panel:ComboBox("Weapon Tiers", "tacrp_balance")
    cb_balance:AddChoice("[Automatic]", "-1")
    cb_balance:AddChoice("0 - Tiered", "0")
    cb_balance:AddChoice("1 - Untiered", "1")
    cb_balance:AddChoice("2 - TTT", "2")
    cb_balance:DockMargin(8, 0, 0, 0)
    lb_balance:SizeToContents()
    panel:Help("Weapon are divided into 4 tiers, with higher tiers having slightly better overall performance.\nDisable to adjust weapon performance to around the same level.")
    panel:Help("TTT option is untiered, and has lower RPM and high time to kill close to vanilla TTT weapons.")
	panel:Help("Weapon tiers, best to worst: \n1 - Elite \n2 - Operator \n3 - Security \n4 - Consumer")

    panel:AddControl("slider", {
        label = "Overall Damage",
        command = "tacrp_mult_damage",
        type = "float",
        min = 0.1,
        max = 3,
    })
    panel:ControlHelp("Only affects bullets. Type-specific damage multipliers takes priority and doesn't stack.")
    panel:AddControl("slider", {
        label = "Shotgun Damage",
        command = "tacrp_mult_damage_shotgun",
        type = "float",
        min = 0.1,
        max = 3,
    })
    panel:AddControl("slider", {
        label = "Sniper Rifle Damage",
        command = "tacrp_mult_damage_sniper",
        type = "float",
        min = 0.1,
        max = 3,
    })
    panel:AddControl("slider", {
        label = "Magnum Pistol Damage",
        command = "tacrp_mult_damage_magnum",
        type = "float",
        min = 0.1,
        max = 3,
    })
    panel:AddControl("slider", {
        label = "Explosive Damage",
        command = "tacrp_mult_damage_explosive",
        type = "float",
        min = 0.1,
        max = 3,
    })

    header(panel, "\nRecoil")
    panel:AddControl("checkbox", {
        label = "Bloom Modifies Recoil",
        command = "tacrp_altrecoil"
    })
    panel:ControlHelp("If enabled, gaining bloom intensifies recoil but does not modify spread.\nIf disabled, gaining bloom increases spread but does not modify recoil kick (old behavior).\nBloom is gained when firing consecutive shots.")
    panel:AddControl("checkbox", {
        label = "Recoil Patterns",
        command = "tacrp_recoilpattern"
    })
    panel:ControlHelp("Recoil follows a weapon-specific pattern, reset when bloom disappears.\nPattern fades away in long bursts, but reduces vertical recoil.")
    panel:AddControl("slider", {
        label = "Recoil Kick",
        command = "tacrp_mult_recoil_kick",
        type = "float",
        min = 0,
        max = 2,
    })
    panel:AddControl("slider", {
        label = "Visual Recoil",
        command = "tacrp_mult_recoil_vis",
        type = "float",
        min = 0,
        max = 2,
    })

    header(panel, "\nAiming")
    panel:AddControl("checkbox", {
        label = "Enable Crosshair",
        command = "tacrp_crosshair"
    })
    panel:AddControl("checkbox", {
        label = "Enable Old School Scopes",
        command = "tacrp_oldschool"
    })
    panel:ControlHelp("Weapons without a scope or holosight cannot aim down sights.\nHip-fire spread is reduced and moving spread is increased based on scope magnification.\nEnabling the crosshair with this enabled is strongly encouraged.")
    panel:AddControl("checkbox", {
        label = "Enable Sway",
        command = "tacrp_sway"
    })
    panel:ControlHelp("Weapon point of aim will move around gently. While aiming, hold sprint key to hold breath and steady aim.")
    panel:AddControl("checkbox", {
        label = "Enable Free Aim",
        command = "tacrp_freeaim"
    })
    panel:ControlHelp("While not aiming, moving around will cause the crosshair to move off center.")
    panel:AddControl("slider", {
        label = "Aim Down Sights Time",
        command = "tacrp_mult_aimdownsights",
        type = "float",
        min = 0.5,
        max = 1.5,
    })
    panel:AddControl("slider", {
        label = "Sprint To Fire Time",
        command = "tacrp_mult_sprinttofire",
        type = "float",
        min = 0.5,
        max = 1.5,
    })


    header(panel, "\nAmmo & Reloading")
    panel:AddControl("checkbox", {
        label = "Infinite Ammo",
        command = "tacrp_infiniteammo"
    })
    panel:ControlHelp("Reloading does not require or consume ammo.")
    panel:AddControl("checkbox", {
        label = "Infinite Grenades",
        command = "tacrp_infinitegrenades"
    })
    panel:AddControl("checkbox", {
        label = "Dump Ammo In Magazines",
        command = "tacrp_reload_dump"
    })
    panel:ControlHelp("Dropping a magazine during a reload will also drop all ammo in the gun. The dropped magazine can be retrieved (unless Infinite Ammo is enabled).")
    panel:AddControl("slider", {
        label = "Default Clip Multiplier",
        command = "tacrp_defaultammo",
        type = "float",
        min = 0,
        max = 10,
    })
    panel:AddControl("slider", {
        label = "Reload Speed",
        command = "tacrp_mult_reloadspeed",
        type = "float",
        min = 0.5,
        max = 1.5,
    })
end

local function menu_mechanics_ti(panel)
    header(panel, "\nBallistics")
    panel:AddControl("checkbox", {
        label = "Enable Penetration",
        command = "TacRP_penetration"
    })
    panel:AddControl("checkbox", {
        label = "Enable Physical Bullets",
        command = "TacRP_physbullet"
    })
    panel:ControlHelp("Bullets will be hitscan up to a certain range depending on muzzle velocity.")
    panel:AddControl("checkbox", {
        label = "Enable Shotgun Patterns",
        command = "tacrp_fixedspread"
    })
    panel:ControlHelp("Shotgun pellets uses a pattern that covers the spread area for more consistency.")
    panel:AddControl("checkbox", {
        label = "Enable Pattern Randomness",
        command = "tacrp_pelletspread"
    })
    panel:ControlHelp("Add random spread onto the pattern. Does not affect total spread. If disabled, shotgun patterns become completely static.")
    panel:AddControl("checkbox", {
        label = "Custom Armor Penetration",
        command = "tacrp_armorpenetration"
    })
    panel:ControlHelp("Use AP stats against players with HL2 suit armor. This generally increases weapon damage against armor.\nCompatible with Danger Zone Entities.")

    header(panel, "\nMovement")
    panel:AddControl("checkbox", {
        label = "Allow Reload while Sprinting",
        command = "tacrp_sprint_reload"
    })
    panel:ControlHelp("If disabled, starting a sprint will cancel an unfinished reload.")
    panel:AddControl("checkbox", {
        label = "Lower Weapon While Sprinting",
        command = "tacrp_sprint_lower"})
    panel:AddControl("checkbox", {
        label = "Lower Weapon While Airborne",
        command = "tacrp_sprint_counts_midair"})
    panel:AddControl("checkbox", {
        label = "Lower Weapon While Not Aiming",
        command = "tacrp_sightsonly"
    })
    panel:ControlHelp("Weapons can only be fired when aiming, like DarkRP weapons. Doesn't affect weapons that cannot aim.\nDisables safety and can't use with Old School Scopes.")

    panel:AddControl("checkbox", {
        label = "Movement Penalty",
        command = "tacrp_penalty_move"
    })
    panel:ControlHelp("Penalty when weapon is up.\nDoes not apply in safety.")
    panel:AddControl("checkbox", {
        label = "Firing Movement Penalty",
        command = "tacrp_penalty_firing"
    })
    panel:ControlHelp("Penalty from firing the weapon.")
    panel:AddControl("checkbox", {
        label = "Aiming Movement Penalty",
        command = "tacrp_penalty_aiming"
    })
    panel:ControlHelp("Penalty while aiming the weapon.")
    panel:AddControl("checkbox", {
        label = "Reload Movement Penalty",
        command = "tacrp_penalty_reload"
    })
    panel:ControlHelp("Penalty while reloading.")
    panel:AddControl("checkbox", {
        label = "Melee Movement Penalty",
        command = "tacrp_penalty_melee"
    })
    panel:ControlHelp("Penalty from melee bashing.")

    header(panel, "\nMiscellaneous")
    panel:AddControl("checkbox", {
        label = "Delayed Holstering",
        command = "tacrp_holster"
    })
    panel:ControlHelp("Play a holster animation before pulling out another weapon. If disabled, holstering is instant.")
    panel:AddControl("checkbox", {
        label = "Shotgun Reload Cancel",
        command = "tacrp_reload_sg_cancel"
    })
    panel:ControlHelp("Instantly fire out of a shotgun reload. If disabled, the finishing part of the animation must play out.")
    panel:AddControl("slider", {
        label = "Flashbang Slow",
        command = "tacrp_flash_slow",
        type = "float",
        min = 0,
        max = 1,
    })
    panel:AddControl("slider", {
        label = "CS Gas Sway",
        command = "tacrp_gas_sway",
        type = "float",
        min = 0,
        max = 10,
    })
end

local function menu_atts_ti(panel)
    header(panel, "Attachment Inventory")
    panel:AddControl("checkbox", {
        label = "Free Attachments",
        command = "TacRP_free_atts"
    })
    panel:AddControl("checkbox", {
        label = "Attachment Locking",
        command = "TacRP_lock_atts"
    })
    panel:ControlHelp("In Locking mode, owning one attachment allows you to use it on multiple weapons, a-la CW2.0.")
    panel:AddControl("checkbox", {
        label = "Lose Attachments On Death",
        command = "TacRP_loseattsondie"
    })
    panel:AddControl("checkbox", {
        label = "Attachment Entities in Spawnmenu",
        command = "TacRP_generateattentities"
    })

    header(panel, "\nAttachment Mechanics")
    panel:AddControl("checkbox", {
        label = "Enable Scope Glint",
        command = "tacrp_glint"
    })
    panel:ControlHelp("Scopes show a visible glint. Glint size is dependent on angle of view, scope magnification and distance, and is bigger when zoomed in.")
    panel:AddControl("checkbox", {
        label = "Enable Blinding Flashlights",
        command = "tacrp_flashlight_blind"
    })
    panel:ControlHelp("Flashlight glare will obscure vision based on distance and viewing angle. Effect is more significant on scopes. If disabled, glare sprite will be visible but not grow in size.")
    panel:AddControl("checkbox", {
        label = "Laser Beam",
        command = "tacrp_laser_beam"
    })
    panel:ControlHelp("If disabled, laser has no beam and only a dot, like Insurgency: Sandstorm. The dot remains static on high RPM weapons to help aiming.")

    header(panel, "\nAttachment Balance")
    panel:AddControl("slider", {
        label = "Smackdown Slow",
        command = "tacrp_melee_slow",
        type = "float",
        min = 0,
        max = 1,
    })
    panel:AddControl("slider", {
        label = "Radar Frequency",
        command = "tacrp_att_radartime",
        type = "float",
        min = 0.5,
        max = 10,
    })
end

local clientmenus_ti = {
    {
        text = "Client", func = menu_client_ti
    },
    {
        text = "Server", func = menu_server_ti
    },
    {
        text = "Mechanics", func = menu_mechanics_ti
    },
    {
        text = "Attachments", func = menu_atts_ti
    },
    {
        text = "Balance", func = menu_balance_ti
    },
}

hook.Add("PopulateToolMenu", "TacRP_MenuOptions", function()
    for smenu, data in pairs(clientmenus_ti) do
        spawnmenu.AddToolMenuOption("Options", "Tactical RP Weapons", "TacRP_" .. tostring(smenu), data.text, "", "", data.func)
    end
end)

end