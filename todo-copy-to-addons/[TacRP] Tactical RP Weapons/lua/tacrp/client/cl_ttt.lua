if engine.ActiveGamemode() != "terrortown" then return end

if !TTT2 then
    hook.Add("TTTSettingsTabs", "TacRP", function(dtabs)

        local padding = dtabs:GetPadding() * 2

        local panellist = vgui.Create("DPanelList", dtabs)
        panellist:StretchToParent(0,0,padding,0)
        panellist:EnableVerticalScrollbar(true)
        panellist:SetPadding(10)
        panellist:SetSpacing(10)

        local dgui_pref = vgui.Create("DForm", panellist)
        dgui_pref:SetName("Client - Preference")
        dgui_pref:CheckBox("Toggle Aiming", "tacrp_toggleaim")
        dgui_pref:CheckBox("Toggle Peeking", "tacrp_togglepeek")
        dgui_pref:CheckBox("Auto Reload When Empty", "TacRP_autoreload")
        dgui_pref:CheckBox("Flashbang Dark Mode", "tacrp_flash_dark")
        dgui_pref:Help("In dark mode, flashbangs turn your screen black instead of white, and mutes audio intead of ringing.")
        dgui_pref:CheckBox("Quiet Radar", "tacrp_radar_quiet")
        dgui_pref:Help("This mutes your own radar sound for yourself only. Others can still hear your radar, and you can still hear others' radars.")
        dgui_pref:NumSlider("HUD Scale", "tacrp_hudscale", 0.5, 1.5, 2)
        dgui_pref:Help("HUD is already scaled to screen width; this slider may help ultrawide users or people with a vertical setup.")

        panellist:AddItem(dgui_pref)

        local dgui_ui = vgui.Create("DForm", panellist)
        dgui_ui:SetName("Client - Interface")
        dgui_ui:CheckBox("Quickthrow Radial Menu", "tacrp_nademenu")
        dgui_ui:Help("When enabled, +grenade2 brings up a menu to select grenades. Otherwise it switches between them.")
        dgui_ui:CheckBox("Quickthrow Menu Clicking", "tacrp_nademenu_click")
        dgui_ui:Help("When enabled, left click and right click in the quickthrow menu performs an overhand and underhand throw of the highlighted grenade.")
        dgui_ui:CheckBox("Blindfire Radial Menu", "tacrp_blindfiremenu")
        dgui_ui:Help("When enabled, +zoom brings up a menu to change blindfire type. Otherwise it sets blindfire based on movement keys pressed.")
        dgui_ui:CheckBox("Use Meters instead of HU", "tacrp_metricunit")
        dgui_ui:CheckBox("Recoil Vignette", "tacrp_vignette")
        dgui_ui:Help("Vignette intensity is based on amount of accumulated recoil.")
        dgui_ui:CheckBox("Show Backup HUD", "tacrp_minhud")
        dgui_ui:CheckBox("Show Control Hints", "tacrp_hints")
        dgui_ui:CheckBox("Hints Always Active", "tacrp_hints_always")
        panellist:AddItem(dgui_ui)

        local dgui_cl = vgui.Create("DForm", panellist)
        dgui_cl:SetName("Client - Misc.")
        dgui_cl:CheckBox("Near Walling", "tacrp_nearwall")
        dgui_cl:Help("Pushes viewmodel back when the point of aim is in front of a wall. Purely visual effect, but may help when blindfiring.")
        dgui_cl:CheckBox("Disable Suicide Mode", "tacrp_idunwannadie")
        dgui_cl:Help("Hides the option to shoot yourself from the radial menu, and disables the SHIFT+ALT+B key combo.")
        dgui_cl:CheckBox("Draw Holstered Weapons", "tacrp_drawholsters")
        dgui_cl:CheckBox("True Laser Position", "tacrp_true_laser")
        panellist:AddItem(dgui_cl)

        local dgui1 = vgui.Create("DForm", panellist)
        dgui1:SetName("Server - Main")
        dgui1:Help("This menu only works if you are the host of a listen server.")

        dgui1:CheckBox("Free Attachments", "tacrp_free_atts")
        dgui1:CheckBox("Infinite Ammo", "tacrp_infiniteammo")
        dgui1:CheckBox("Infinite Grenades", "tacrp_infinitegrenades")
        dgui1:CheckBox("Magazines Leave DNA", "tacrp_ttt_magazine_dna")
        dgui1:Help("Dropped magazines and grenade spoons don't disappear and contain user's DNA.")

        panellist:AddItem(dgui1)

        local dgui2 = vgui.Create("DForm", panellist)
        dgui2:SetName("Server - Weapons & Attachments")
        dgui2:Help("This menu only works if you are the host of a listen server.")

        dgui2:CheckBox("Free Attachments", "tacrp_free_atts")
        dgui2:CheckBox("Unlocking Attachments", "tacrp_lock_atts")
        dgui2:Help("Attachments aren't consumed on equip, like CW2.0.")
        dgui2:CheckBox("Lose Attachments On Death", "tacrp_loseattsondie")

        dgui2:CheckBox("Replace Vanilla TTT Weapons", "tacrp_ttt_weapon_include")
        dgui2:NumSlider("Replace Chance", "tacrp_ttt_weapon_replace", 0, 1, 2)
        dgui2:NumSlider("Maximum Atts. On Weapon", "tacrp_ttt_atts_max", 0, 10, 0)
        dgui2:NumSlider("Attachment Chance", "tacrp_ttt_atts_random", 0, 1, 2)
        dgui2:NumSlider("Give Atts. On Spawn", "tacrp_ttt_atts_max", 0, 100, 0)

        dgui2:CheckBox("Allow Innocents Customization", "tacrp_ttt_cust_inno_allow")
        dgui2:CheckBox("Allow Non-Innocents Customization", "tacrp_ttt_cust_role_allow")
        dgui2:Help("If disabled, the respective roles cannot customize for any reason.")

        dgui2:CheckBox("Innocents Customization During Round", "tacrp_ttt_cust_inno_round")
        dgui2:CheckBox("Non-Innocents Customization During Round", "tacrp_ttt_cust_role_round")
        dgui2:Help("If disabled, customization is only allowed in pregame/postgame.")

        dgui2:CheckBox("Innocents Must Use Customization Bench", "tacrp_ttt_cust_inno_needbench")
        dgui2:CheckBox("Non-Innocents Must Use Customization Bench", "tacrp_ttt_cust_role_needbench")
        dgui2:Help("If set, customiation is only allowed when near a customization bench bought by Detectives/Traitors.")

        panellist:AddItem(dgui2)

        local dgui3 = vgui.Create("DForm", panellist)
        dgui3:SetName("Server - Mechanics")
        dgui1:CheckBox("Magazines Leave DNA", "tacrp_ttt_magazine_dna")
        dgui1:Help("Dropped magazines and grenade spoons don't disappear and contain user's DNA.")
        dgui3:CheckBox("Enable Sway", "tacrp_sway")
        dgui3:CheckBox("Enable Free Aim", "tacrp_freeaim")
        dgui3:CheckBox("Enable Penetration", "tacrp_penetration")
        dgui3:CheckBox("Enable Physical Bullets", "tacrp_physbullet")
        dgui3:Help("Bullets will be hitscan up to a certain range depending on muzzle velocity.")
        dgui3:CheckBox("Enable Holstering", "tacrp_holster")
        dgui3:Help("Play a holster animation before pulling out another weapon. If disabled, holstering is instant.")
        dgui3:CheckBox("Enable Shotgun Patterns", "tacrp_fixedspread")
        dgui3:Help("Shotgun pellets uses a pattern that covers the spread area for more consistency.")
        dgui3:CheckBox("Enable Pattern Randomness", "tacrp_pelletspread")
        dgui3:Help("Add random spread onto the pattern. Does not affect total spread. If disabled, shotgun patterns become completely static.")
        dgui3:CheckBox("Enable Pattern Randomness", "tacrp_pelletspread")
        dgui3:CheckBox("Custom Armor Penetration", "tacrp_armorpenetration")
        dgui3:Help("Weapons use defined piercing and shredding stats to calculate damage when hitting players with HL2 suit armor, instead of using the standard 20% damage. This generally increases the weapons' effectiveness against armor.\nCompatible with Danger Zone Entities' armor.")
        dgui3:CheckBox("Enable Scope Glint", "tacrp_glint")
        dgui3:Help("Scopes show a visible glint. Glint size is dependent on angle of view, scope magnification and distance, and is bigger when zoomed in.")
        dgui3:CheckBox("Enable Blinding Flashlights", "tacrp_flashlight_blind")
        dgui3:Help("Flashlight glare will obscure vision based on distance and viewing angle. Effect is more significant on scopes. If disabled, glare sprite will be visible but not grow in size.")
        dgui3:CheckBox("Allow Reload while Sprinting", "tacrp_sprint_reload")

        dgui3:CheckBox("Movement Penalty", "tacrp_penalty_move")
        dgui3:ControlHelp("Penalty when weapon is up.\nDoes not apply in safety.")
        dgui3:CheckBox("Firing Movement Penalty", "tacrp_penalty_firing")
        dgui3:ControlHelp("Penalty from firing the weapon.")
        dgui3:CheckBox("Aiming Movement Penalty", "tacrp_penalty_aiming")
        dgui3:ControlHelp("Penalty while aiming the weapon.")
        dgui3:CheckBox("Reload Movement Penalty", "tacrp_penalty_reload")
        dgui3:ControlHelp("Penalty while reloading.")
        dgui3:CheckBox("Melee Movement Penalty", "tacrp_penalty_melee")
        dgui3:ControlHelp("Penalty from melee bashing.")

        panellist:AddItem(dgui3)

        dtabs:AddSheet("TacRP", panellist, "icon16/gun.png", false, false, "TacRP")
    end)
end

hook.Add("TTTRenderEntityInfo", "TacRP_TTT", function(tData)
    local client = LocalPlayer()
    local ent = tData:GetEntity()


    if !IsValid(client) or !client:IsTerror() or !client:Alive()
    or !IsValid(ent) or tData:GetEntityDistance() > 100 or !ent:IsWeapon()
    or !ent.ArcticTacRP or ent.PrimaryGrenade then
        return
    end

    if tData:GetAmountDescriptionLines() > 0 then
        tData:AddDescriptionLine()
    end

    if ent.Attachments and ent:CountAttachments() > 0 then
        tData:AddDescriptionLine(tostring(ent:CountAttachments()) .. " Attachments:", nil)
        for i, v in pairs(ent.Attachments) do
            local attName = v.Installed
            local attTbl = TacRP.GetAttTable(attName)
            if attTbl and v.PrintName and attTbl.PrintName then
                local printName = TacRP:GetAttName(attName)
                tData:AddDescriptionLine(printName, nil, {attTbl.Icon})
            end
        end
    end
end)

hook.Add("TTTBodySearchPopulate", "TacRP", function(processed, raw)
    if (weapons.Get(raw.wep or "") or {}).ArcticTacRP and bit.band(raw.dmg or 0, DMG_BUCKSHOT) != 0 then
        processed.dmg.text = LANG.GetTranslation("tacrp_search_dmg_buckshot")
        processed.dmg.img = "tacrp/ttt/kill_buckshot.png"
    end
end)