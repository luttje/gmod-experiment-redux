function SWEP:DoDeployAnimation()
    if self:GetReloading() and self:GetValue("MidReload") and !self:GetValue("ShotgunReload") and self:HasSequence("midreload") then
        local t = self:PlayAnimation("midreload", self:GetValue("ReloadTimeMult"), true, true)

        self:SetReloadFinishTime(CurTime() + t)
    else
        self:SetReloading(false)
        if self:GetValue("TryUnholster") then
            self:PlayAnimation("unholster", self:GetValue("DeployTimeMult") * self:GetValue("UnholsterTimeMult"), true, true)
        else
            -- if self:GetReady() then
            --     self:PlayAnimation("unholster", self:GetValue("DeployTimeMult"), true, true)
            -- else
            --     self:PlayAnimation("deploy", self:GetValue("DeployTimeMult"), true, true)
            -- end
            self:PlayAnimation("deploy", self:GetValue("DeployTimeMult"), true, true)
        end
    end
end

function SWEP:Deploy()
    if self:GetOwner():IsNPC() or self:GetOwner():IsNextBot() then
        if SERVER then
            self:NetworkWeapon()
        end
        if CLIENT then
            self:SetupModel(true)
        end
        return
    end

    self:SetBaseSettings()

    -- self:SetNextPrimaryFire(0)
    self:SetNextSecondaryFire(0)
    self:SetAnimLockTime(0)
    self:SetSprintLockTime(0)
    self:SetLastMeleeTime(0)
    self:SetRecoilAmount(0)
    self:SetLastScopeTime(0)
    self:SetPrimedGrenade(false)
    self:SetBlindFireFinishTime(0)
    self:SetJammed(false)
    self:SetCharge(false)

    self:SetBurstCount(0)
    self:SetScopeLevel(0)
    self:SetLoadedRounds(self:Clip1())
    self:SetCustomize(false)

    self.PreviousZoom = self:GetOwner():GetCanZoom()
    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        self:GetOwner():SetCanZoom(false)
    end

    self:DoDeployAnimation()

    self:GetOwner():DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE)

    if CLIENT then
        self:SetupModel(true)
        self:SetupModel(false)
        self.LastHintLife = CurTime()
    elseif !game.SinglePlayer() then
        self:DoBodygroups(true) -- Not sure why this is necessary
        self:DoBodygroups(false)
    end

    if (game.SinglePlayer() or CLIENT) and !TacRP.NewsPopup and TacRP.ConVars["checknews"]:GetBool() then
        TacRP.NewsPopup = true
        RunConsoleCommand("tacrp_news_check")
    end

    self:ToggleBlindFire(TacRP.BLINDFIRE_NONE)

    if TacRP.ConVars["deploysafety"]:GetBool() then
        self:ToggleSafety(true)
    end

    self:SetShouldHoldType()

    if self:GetValue("PrimaryGrenade") then
        local nade = TacRP.QuickNades[self:GetValue("PrimaryGrenade")]
        if !TacRP.IsGrenadeInfiniteAmmo(nade) and self:GetOwner():GetAmmoCount(nade.Ammo) == 0 then
            if SERVER then self:Remove() end
            return true
        end
    elseif !self:CheckGrenade() then
        self:SelectGrenade()
        return
    end

    return true
end

local v0 = Vector(0, 0, 0)
local v1 = Vector(1, 1, 1)
local a0 = Angle(0, 0, 0)

function SWEP:ClientHolster()
    if game.SinglePlayer() then
        self:CallOnClient("ClientHolster")
    end

    local vm = self:GetVM()
    if IsValid(vm) then
        vm:SetSubMaterial()
        vm:SetMaterial()

        for i = 0, vm:GetBoneCount() do
            vm:ManipulateBoneScale(i, v1)
            vm:ManipulateBoneAngles(i, a0)
            vm:ManipulateBonePosition(i, v0)
        end
    end
end

function SWEP:Holster(wep)
    if game.SinglePlayer() and CLIENT then return end

    if CLIENT and self:GetOwner() != LocalPlayer() then return end

    if self:GetOwner():IsNPC() then
        return
    end

    self:SetCustomize(false)

    if self:GetReloading() then
        if self:GetValue("ShotgunReload") then
            self:SetEndReload(false)
            self:SetReloading(false)
            self:KillTimer("ShotgunRestoreClip")
        else
            self:CancelReload(false)
        end
    end


    if self:GetHolsterTime() > CurTime() then return false end -- or self:GetPrimedGrenade()

    if !TacRP.ConVars["holster"]:GetBool() or (self:GetHolsterTime() != 0 and self:GetHolsterTime() <= CurTime()) or !IsValid(wep) then
        -- Do the final holster request
        -- Picking up props try to switch to NULL, by the way
        self:SetHolsterTime(0)
        self:SetHolsterEntity(NULL)
        self:SetReloadFinishTime(0)

        local holster = self:GetValue("HolsterVisible")
        if SERVER and holster then
            net.Start("TacRP_updateholster")
                net.WriteEntity(self:GetOwner())
                net.WriteEntity(self)
            net.Broadcast()
        end

        if game.SinglePlayer() then
            self:CallOnClient("KillModel")
        else
            if CLIENT then
                self:RemoveCustomizeHUD()
                self:KillModel()
            end
        end

        if self.PreviousZoom then
            self:GetOwner():SetCanZoom(true)
        end

        self:ClientHolster()

        return true
    else
        local reverse = 1
        local anim = "holster"

        if self:GetValue("NoHolsterAnimation") then
            anim = "deploy"
            reverse = -1
        end

        local animation = self:PlayAnimation(anim, self:GetValue("HolsterTimeMult") * reverse, true, true)
        self:SetHolsterTime(CurTime() + (animation or 0))
        self:SetHolsterEntity(wep)

        self:SetScopeLevel(0)
        self:KillTimers()
        self:ToggleBlindFire(TacRP.BLINDFIRE_NONE)
        self:GetOwner():SetFOV(0, 0.1)
        self:SetLastProceduralFireTime(0)

    end
end

local holsteranticrash = false

hook.Add("StartCommand", "TacRP_Holster", function(ply, ucmd)
    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and wep.ArcticTacRP and wep:GetHolsterTime() != 0 and wep:GetHolsterTime() - wep:GetPingOffsetScale() <= CurTime() and IsValid(wep:GetHolsterEntity()) then
        wep:SetHolsterTime(-math.huge) -- Pretty much force it to work
        if !holsteranticrash then
            holsteranticrash = true
            ucmd:SelectWeapon(wep:GetHolsterEntity()) -- Call the final holster request
            holsteranticrash = false
        end
    end
end)

function SWEP:Initialize()
    self:SetShouldHoldType()

    self:SetBaseSettings()

    self:SetLastMeleeTime(0)
    self:SetNthShot(0)

    if self:GetOwner():IsNPC() then
        self:NPC_Initialize()
        return
    end

    if self:GetOwner():IsNextBot() then
        return
    end

    self.m_WeaponDeploySpeed = 4

    if engine.ActiveGamemode() == "terrortown" then
        self:TTT_Init()
    end

    self:ClientInitialize()

    if SERVER and engine.ActiveGamemode() != "terrortown" then
        -- If we have any pre-existing attachments, network it
        local empty = true
        for slot, slottbl in pairs(self.Attachments) do
            if slottbl.Installed then empty = false break end
        end
        if !empty then
            self:NetworkWeapon()
        end
    end
end

function SWEP:ClientInitialize()
    if SERVER then return end

    if game.SinglePlayer() and SERVER and IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        self:CallOnClient("ClientInitialize")
    end

    if !LocalPlayer().TacRPGreet and !TacRP.ConVars["shutup"]:GetBool() then
        LocalPlayer().TacRPGreet = true
        -- LocalPlayer():PrintMessage(HUD_PRINTTALK, "Check Q menu -> Options/Tactical RP/Control Guide to see the controls!")
        if !input.LookupBinding("grenade1") and !input.LookupBinding("grenade2") then
            LocalPlayer():PrintMessage(HUD_PRINTTALK, "Bind +grenade1 and +grenade2 to use TacRP quick grenades!")
        end
    end

    -- local mat = Material("entities/" .. self:GetClass() .. ".png")

    -- local tex = mat:GetTexture("$basetexture")

    -- killicon.Add(self:GetClass(), tex:GetName(), Color( 255, 255, 255, 255 ) )
end

function SWEP:SetBaseSettings()
    if game.SinglePlayer() and SERVER and IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
        self:CallOnClient("SetBaseSettings")
    end

    local fm = self:GetCurrentFiremode()
    if fm != 1 then
        if self:GetValue("RunawayBurst") and fm < 0 and !self:GetValue("AutoBurst") then
            self.Primary.Automatic = false
        else
            self.Primary.Automatic = true
        end
    else
        self.Primary.Automatic = false
    end

    if self.PrimaryGrenade then
        self.Primary.ClipSize = -1
        self.Primary.Ammo = TacRP.QuickNades[self.PrimaryGrenade].Ammo or ""
        self.Primary.DefaultClip = 1
    else
        self.Primary.ClipSize = self:GetCapacity()
        self.Primary.Ammo = self:GetValue("Ammo")
        self.Primary.DefaultClip = math.ceil(self.Primary.ClipSize * TacRP.ConVars["defaultammo"]:GetFloat())
    end

    if self:GetValue("CanQuickNade") then
        self.Secondary.Ammo = self:GetGrenade().Ammo or "grenade"
    else
        self.Secondary.Ammo = "none"
    end

    if SERVER and IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and self:GetCapacity() > 0 and self:Clip1() > self:GetCapacity() then
        self:GetOwner():GiveAmmo(self:Clip1() - self:GetCapacity(), self:GetValue("Ammo"))
        self:SetClip1(self:GetCapacity())
    end
end

function SWEP:SetShouldHoldType()
    if self:GetOwner():IsNPC() then
        self:SetHoldType(self:GetValue("HoldTypeNPC") or self:GetValue("HoldType"))
        return
    end

    if self:GetIsSprinting() or self:GetSafe() and self:GetValue("HoldTypeSprint") then
        self:SetHoldType(self:GetValue("HoldTypeSprint"))
        return
    end

    if self:GetBlindFire() then
        if self:GetBlindFireMode() == TacRP.BLINDFIRE_KYS and self:GetValue("HoldTypeSuicide") then
            self:SetHoldType(self:GetValue("HoldTypeSuicide"))
            return
        elseif self:GetValue("HoldTypeBlindFire") then
            self:SetHoldType(self:GetValue("HoldTypeBlindFire"))
            return
        end
    elseif self:GetScopeLevel() > 0 and TacRP.HoldTypeSightedLookup[self:GetValue("HoldType")] then
        self:SetHoldType(TacRP.HoldTypeSightedLookup[self:GetValue("HoldType")])
        return
    end

    if self:GetCustomize() and self:GetValue("HoldTypeCustomize") then
        self:SetHoldType(self:GetValue("HoldTypeCustomize"))
        return
    end

    self:SetHoldType(self:GetValue("HoldType"))
end

function SWEP:OnRemove()
    if IsValid(self:GetOwner()) then
        self:ToggleBoneMods(TacRP.BLINDFIRE_NONE)
    end
    if CLIENT and (self:GetCustomize() or (self.GrenadeMenuAlpha or 0) > 0 or (self.BlindFireMenuAlpha or 0) > 0) then
        gui.EnableScreenClicker(false)
        TacRP.CursorEnabled = false
    end
end

function SWEP:EquipAmmo(ply)
    local ammotype = self.Primary.Ammo
    if ammotype == "" then return end

    local supplyamount = self.GaveDefaultAmmo and self:Clip1() or math.ceil(math.max(1, self.Primary.ClipSize) * TacRP.ConVars["defaultammo"]:GetFloat())
    ply:GiveAmmo(supplyamount, ammotype)
end