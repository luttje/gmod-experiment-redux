-- affects how much armor is reduced from damage
local armorbonus = 1.0
-- affects what fraction of damage is converted to armor damage (1 means none)
-- local armorratio = 0.2

-- Simulate armor calculation
-- https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/mp/src/game/server/player.cpp#L1061
local function calcarmor(dmginfo, armor, flBonus, flRatio)
    local old = GetConVar("player_old_armor"):GetBool()
    if !flBonus then
        flBonus = old and 0.5 or 1
    end
    flRatio = flRatio or 0.2

    local dmg = dmginfo:GetDamage()
    local origdmg = dmg
    -- if dmginfo:IsDamageType(DMG_BLAST) and !game.SinglePlayer() then
    --     flBonus = flBonus * 2
    -- end
    if armor > 0 then
        local flNew = dmg * flRatio
        local flArmor = math.max(0, dmg - flNew) * flBonus

        if !old and flArmor == 0 then
            flArmor = 1
            -- flArmor = math.max(1, flArmor)
        end

        if flArmor > armor then
            flArmor = armor * (1 / flBonus)
            flNew = dmg - flArmor
            -- m_DmgSave = armor -- ?
            armor = 0
        else
            -- m_DmgSave = flArmor
            armor = math.max(0, armor - flArmor)
        end

        dmg = flNew

        if dmg > origdmg and armor > 0 then
            armor = math.max(0, armor - (dmg - origdmg) * flBonus)
            dmg = origdmg
        end
    end
    return dmg, armor
end

local bitflags_blockable = DMG_BULLET + DMG_BUCKSHOT + DMG_BLAST
hook.Add("EntityTakeDamage", "Z_TacRP", function(ply, dmginfo)
    if !TacRP.ConVars["armorpenetration"]:GetBool() then return end
    if isfunction(GAMEMODE.HandlePlayerArmorReduction) then return end -- in dev branch right now
    if !ply:IsPlayer() or dmginfo:IsFallDamage() or dmginfo:GetDamage() < 1 then return end

    -- if danger zone armor wants to handle it, don't do it
    if DZ_ENTS and ply:Armor() > 0 and (GetConVar("dzents_armor_enabled"):GetInt() == 2 or (GetConVar("dzents_armor_enabled"):GetInt() == 1 and ply:DZ_ENTS_HasArmor())) then
        return
    end

    local wep = dmginfo:GetInflictor()
    if wep:IsPlayer() then wep = wep:GetActiveWeapon() end

    if !IsValid(wep) or !wep.ArcticTacRP then return end

    -- do we even have armor?
    if (engine.ActiveGamemode() == "terrortown" and !ply:HasEquipmentItem(EQUIP_ARMOR))
            or (engine.ActiveGamemode() ~= "terrortown" and ply:Armor() <= 0) then
        return
    end

    -- only handle these damage types
    if bit.band(dmginfo:GetDamageType(), bitflags_blockable) == 0 then
        return
    end

    local ap = wep:GetValue("ArmorPenetration")
    local ab = wep:GetValue("ArmorBonus")

    local healthdmg, newarmor = calcarmor(dmginfo, ply:Armor(), armorbonus * ab, ap)
    -- print("WANT", ply:Health() - healthdmg, newarmor, "(" .. healthdmg .. " dmg, " .. (ply:Armor() - newarmor) .. " armor)")
    ply.TacRPPendingArmor = newarmor
    ply:SetArmor(0) -- don't let engine do armor calculation
    dmginfo:SetDamage(healthdmg)
end)

hook.Add("PostEntityTakeDamage", "TacRP", function(ply, dmginfo, took)
    if !TacRP.ConVars["armorpenetration"]:GetBool() then return end
    if isfunction(GAMEMODE.HandlePlayerArmorReduction) then return end
    if !ply:IsPlayer() then return end
    if ply.TacRPPendingArmor then
        ply:SetArmor(ply.TacRPPendingArmor)
        -- print("SET", ply:Armor())
        -- timer.Simple(0, function()
        --     print("POST", ply:Health(), ply:Armor())
        -- end)
    end
    ply.TacRPPendingArmor = nil
end)

hook.Add("DoPlayerDeath", "TacRP_DropGrenade", function(ply, attacker, dmginfo)
    local wep = ply:GetActiveWeapon()
    if !IsValid(wep) or !wep.ArcticTacRP or !wep:GetPrimedGrenade() then return end
    local nade = wep:GetValue("PrimaryGrenade") and TacRP.QuickNades[wep:GetValue("PrimaryGrenade")] or wep:GetGrenade()
    if nade then
        local ent = nade.GrenadeEnt
        local src = ply:EyePos()
        local ang = ply:EyeAngles()
        local rocket = ents.Create(ent or "")

        if !IsValid(rocket) then return end

        rocket:SetPos(src)
        rocket:SetOwner(ply)
        rocket:SetAngles(ang)
        rocket:Spawn()
        rocket:SetPhysicsAttacker(ply, 10)

        if TacRP.IsGrenadeInfiniteAmmo(nade) then
            rocket.PickupAmmo = nil
            rocket.WeaponClass = nil -- dz ents
        end

        if wep:GetValue("QuickNadeTryImpact") and nade.CanSetImpact then
            rocket.InstantFuse = false
            rocket.Delay = 0
            rocket.Armed = false
            rocket.ImpactFuse = true
        end

        if nade.TTTTimer then
            rocket:SetGravity(0.4)
            rocket:SetFriction(0.2)
            rocket:SetElasticity(0.45)
            rocket:SetDetonateExact(CurTime() + nade.TTTTimer)
            rocket:SetThrower(ply)
        end

        local phys = rocket:GetPhysicsObject()

        if phys:IsValid() then
            phys:ApplyForceCenter(ply:GetVelocity() + VectorRand() * 50 + Vector(0, 0, math.Rand(25, 50)))
            phys:AddAngleVelocity(VectorRand() * 500)
        end

        if nade.Spoon then
            local mag = ents.Create("TacRP_droppedmag")

            if mag then
                mag:SetPos(src)
                mag:SetAngles(ang)
                mag.Model = "models/weapons/tacint/flashbang_spoon.mdl"
                mag.ImpactType = "spoon"
                mag:SetOwner(ply)
                mag:Spawn()

                local phys2 = mag:GetPhysicsObject()

                if IsValid(phys2) then
                    phys2:ApplyForceCenter(VectorRand() * 25)
                    phys2:AddAngleVelocity(Vector(math.Rand(-300, 300), math.Rand(-300, 300), math.Rand(-300, 300)))
                end
            end
        end
    end
end)

hook.Add("HandlePlayerArmorReduction", "TacRP", function(ply, dmginfo)
    if !TacRP.ConVars["armorpenetration"]:GetBool() then return end
    if dmginfo:IsFallDamage() or dmginfo:GetDamage() < 1 then return end

    if DZ_ENTS and ply:Armor() > 0 and (GetConVar("dzents_armor_enabled"):GetInt() == 2 or (GetConVar("dzents_armor_enabled"):GetInt() == 1 and ply:DZ_ENTS_HasArmor())) then
        return
    end

    local wep = dmginfo:GetInflictor()
    if wep:IsPlayer() then wep = wep:GetActiveWeapon() end
    if !IsValid(wep) or !wep.ArcticTacRP then return end

    if ply:Armor() <= 0 or bit.band(dmginfo:GetDamageType(), DMG_FALL + DMG_DROWN + DMG_POISON + DMG_RADIATION) ~= 0 then return end
    local flBonus = 1.0 * wep:GetValue("ArmorBonus")
    local flRatio = wep:GetValue("ArmorPenetration")

    if GetConVar("player_old_armor"):GetBool() then
        flBonus = 0.5 * wep:GetValue("ArmorBonus")
    end

    local flNew = dmginfo:GetDamage() * flRatio
    local flArmor = (dmginfo:GetDamage() - flNew) * flBonus

    if !GetConVar("player_old_armor"):GetBool() then
        if flArmor < 1.0 then
            flArmor = 1.0
        end
    end

    if flArmor > ply:Armor() then
        flArmor = ply:Armor() * (1 / flBonus)
        flNew = dmginfo:GetDamage() - flArmor
        ply:SetArmor(0)
    else
        ply:SetArmor(ply:Armor() - flArmor)
    end

    dmginfo:SetDamage(flNew)

    return true
end)