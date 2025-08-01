function SWEP:NPC_PrimaryAttack()
    if !IsValid(self:GetOwner()) then return end

    local enemy = self:GetOwner():GetEnemy()

    local aps = self:GetValue("AmmoPerShot")

    if self:Clip1() < aps then
        if !IsValid(enemy) or !IsValid(enemy:GetActiveWeapon()) or table.HasValue({"weapon_crowbar", "weapon_stunstick"}, enemy:GetActiveWeapon():GetClass()) then
            // do not attempt to find cover if enemy does not have a ranged weapon
            self:GetOwner():SetSchedule(SCHED_RELOAD)
        else
            self:GetOwner():SetSchedule(SCHED_HIDE_AND_RELOAD)
        end
        return
    end

    self:SetBaseSettings()
    self:SetShouldHoldType()

    self.Primary.Automatic = true

    local pvar = self:GetValue("ShootPitchVariance")

    local sshoot = self:GetValue("Sound_Shoot")

    if self:GetValue("Silencer") then
        sshoot = self:GetValue("Sound_Shoot_Silenced")
    end

    if istable(sshoot) then
        sshoot = table.Random(sshoot)
    end

    self:EmitSound(sshoot, self:GetValue("Vol_Shoot"), self:GetValue("Pitch_Shoot") + math.Rand(-pvar, pvar), 1, CHAN_WEAPON)

    self:SetClip1(self:Clip1() - aps)

    local delay = 60 / self:GetValue("RPM")
    self:SetNextPrimaryFire(CurTime() + delay)
    if delay < 0.1 then
        self:GetOwner():NextThink(CurTime() + delay) // they will only attempt to fire once per think
    end

    local spread = self:GetNPCSpread()

    local dir = self:GetOwner():GetAimVector()

    if self:GetValue("ShootEnt") then
        if IsValid(enemy) then
            dir = (enemy:WorldSpaceCenter() - self:GetOwner():GetShootPos()):GetNormalized():Angle()
            dir = dir + ((spread + (0.1 / self:GetOwner():GetCurrentWeaponProficiency())) * AngleRand() / 3.6)
        end
        self:ShootRocket(dir)
    else
        self:GetOwner():FireBullets({
            Damage = self:GetValue("Damage_Max"),
            Force = 8,
            TracerName = "tacrp_tracer",
            Tracer = self:GetValue("TracerNum"),
            Num = self:GetValue("Num"),
            Dir = dir,
            Src = self:GetOwner():GetShootPos(),
            Spread = Vector(spread, spread, spread),
            Callback = function(att, btr, dmg)
                local range = (btr.HitPos - btr.StartPos):Length()

                self:AfterShotFunction(btr, dmg, range, 0, {}) // self:GetValue("Penetration")

                if GetConVar("developer"):GetBool() then
                    if SERVER then
                        debugoverlay.Cross(btr.HitPos, 4, 5, Color(255, 0, 0), false)
                    else
                        debugoverlay.Cross(btr.HitPos, 4, 5, Color(255, 255, 255), false)
                    end
                end
            end
        })
    end

    self:DoEffects()
    self:DoEject()
end

function SWEP:GetNPCBulletSpread(prof)
    local mode = self:GetCurrentFiremode()

    if mode < 0 then
        return 10 / (prof + 1)
    elseif mode == 1 then
        if math.Rand(0, 100) < (prof + 5) * 5 then
            return 2 / (prof + 1)
        else
            return 20 / (prof + 1)
        end
    elseif mode > 1 then
        if math.Rand(0, 100) < (prof + 5) * 2 then
            return 5 / (prof + 1)
        else
            return 30 / (prof + 1)
        end

    end

    return 15
end

function SWEP:GetNPCSpread()
    return self:GetValue("Spread")
end

function SWEP:GetNPCBurstSettings()
    local mode = self:GetCurrentFiremode()

    local delay = 60 / self:GetValue("RPM")

    if !mode then return 1, 1, delay end

    if mode < 0 then
        return -mode, -mode, delay
    elseif mode == 0 then
        return 0, 0, delay
    elseif mode == 1 then
        local c = self:GetCapacity()
        return math.ceil(c * 0.075), math.max(1, math.floor(c * math.Rand(0.15, 0.3))), delay + math.Rand(0.1, 0.2)
    elseif mode >= 2 then
        return math.min(self:Clip1(), 1 + math.floor(0.5 / delay)), math.min(self:Clip1(), 1 + math.floor(2 / delay)), delay
    end
end

function SWEP:GetNPCRestTimes()
    local mode = self:GetCurrentFiremode()
    local postburst = self:GetValue("PostBurstDelay") or 0
    local m = self:GetValue("RecoilKick")
    local delay = 60 / self:GetValue("RPM")

    if !mode then return delay + 0.3, delay + 0.6 end

    local o = m > 1 and math.sqrt(m) or m
    if delay <= 60 / 90 then
        return delay + 0.1 * o, delay + 0.2 * o
    elseif mode < 0 then
        o = delay + o * 0.5 + postburst
    end

    return delay + 0.4 * o, delay + 0.6 * o
end

function SWEP:CanBePickedUpByNPCs()
    return self.NPCUsable
end

function SWEP:NPC_Reload()
    self:DropMagazine()
end

function SWEP:NPC_Initialize()
    if CLIENT then return end
    // auto attachment

    if TacRP.ConVars["npc_atts"]:GetBool() then
        for i, slot in pairs(self.Attachments) do
            local atts = TacRP.GetAttsForCats(slot.Category or "")

            local ind = math.random(0, #atts)

            if ind > 0 and math.random() <= 0.75 then
                slot.Installed = atts[ind]
            end
        end

        self:InvalidateCache()
    end

    timer.Simple(0.25, function()
        if !IsValid(self) then return end
        self:NetworkWeapon()
    end)

    self:SetBaseSettings()

    self:SetClip1(self:GetCapacity())

    if math.random() <= 0.5 then
        self:SetFiremode(math.random(1, self:GetFiremodeAmount()))
    end
end