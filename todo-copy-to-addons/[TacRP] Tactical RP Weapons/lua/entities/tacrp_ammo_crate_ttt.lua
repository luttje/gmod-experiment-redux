if engine.ActiveGamemode() ~= "terrortown" then return end

AddCSLuaFile()

ENT.Type                     = "anim"
ENT.Base                     = "base_entity"
ENT.RenderGroup              = RENDERGROUP_BOTH

ENT.PrintName                = "tacrp_ammocrate_name"

ENT.Model                    = "models/weapons/tacint/ammoboxes/ammo_box-2b.mdl"
ENT.CanHavePrints = true
ENT.CanUseKey = true
ENT.MaxHealth = 250

ENT.MaxStored = 100
ENT.RechargeRate = 1
ENT.RechargeFreq = 2

ENT.AutomaticFrameAdvance = true

ENT.CollisionSoundsHard = {
    "physics/metal/metal_box_impact_hard1.wav",
    "physics/metal/metal_box_impact_hard2.wav",
    "physics/metal/metal_box_impact_hard3.wav",
}

ENT.CollisionSoundsSoft = {
    "physics/metal/metal_box_impact_soft1.wav",
    "physics/metal/metal_box_impact_soft2.wav",
    "physics/metal/metal_box_impact_soft3.wav",
}

ENT.ExplodeSounds = {
    "TacRP/weapons/grenade/frag_explode-1.wav",
    "TacRP/weapons/grenade/frag_explode-2.wav",
    "TacRP/weapons/grenade/frag_explode-3.wav",
}

ENT.AmmoInfo = {
    -- ammo per use, max, cost per use
    ["357"] = {10, nil, 12}, -- 2 to fill
    ["smg1"] = {30, nil, 10}, -- 2 to fill
    ["pistol"] = {20, nil, 5}, -- 3 to fill
    ["alyxgun"] = {12, nil, 6}, -- 3 to fill
    ["buckshot"] = {8, nil, 8}, -- 3 to fill

    ["smg1_grenade"] = {1, 3, 34},
    ["rpg_round"] = {1, 2, 50},
    ["ti_sniper"] = {5, 10, 50},
}

if CLIENT then

    ENT.Icon = "entities/tacrp_ammo_crate.png"

    LANG.AddToLanguage("english", "tacrp_ammocrate_hint", "Press {usekey} to get ammo. Remaining charge: {num}")
    LANG.AddToLanguage("english", "tacrp_ammocrate_broken", "Your Ammo Crate has been destroyed!")
    LANG.AddToLanguage("english", "tacrp_ammocrate_subtitle", "Press {usekey} to receive ammo.")
    LANG.AddToLanguage("english", "tacrp_ammocrate_charge", "Remaining charge: {charge}.")
    LANG.AddToLanguage("english", "tacrp_ammocrate_empty", "No charge left")

    LANG.AddToLanguage("english", "tacrp_ammocrate_short_desc", "The ammo crate recharges over time")

    local TryT = LANG.TryTranslation
    local ParT = LANG.GetParamTranslation

    ENT.TargetIDHint = {
        name = "tacrp_ammocrate_name",
        hint = "tacrp_ammocrate_hint",
        fmt = function(ent, txt)
            return ParT(txt, {
                usekey = Key("+use", "USE"),
                num = ent:GetStoredAmmo() or 0
            })
        end
    }

    local key_params = {
        usekey = Key("+use", "USE")
    }

    -- TTT2 does this
    hook.Add("TTTRenderEntityInfo", "tacrp_ammo_crate", function(tData)
        local client = LocalPlayer()
        local ent = tData:GetEntity()

        if not IsValid(client) or not client:IsTerror() or not client:Alive()
        or not IsValid(ent) or tData:GetEntityDistance() > 100 or ent:GetClass() ~= "tacrp_ammo_crate_ttt" then
            return
        end

        -- enable targetID rendering
        tData:EnableText()
        tData:EnableOutline()
        tData:SetOutlineColor(client:GetRoleColor())

        tData:SetTitle(TryT(ent.PrintName))
        tData:SetSubtitle(ParT("tacrp_ammocrate_subtitle", key_params))
        tData:SetKeyBinding("+use")

        local charge = ent:GetStoredAmmo() or 0

        tData:AddDescriptionLine(TryT("tacrp_ammocrate_short_desc"))

        tData:AddDescriptionLine(
            (charge > 0) and ParT("tacrp_ammocrate_charge", {charge = charge}) or TryT("tacrp_ammocrate_empty"),
            (charge > 0) and roles.DETECTIVE.ltcolor or COLOR_ORANGE
        )
    end)
end

AccessorFuncDT(ENT, "StoredAmmo", "StoredAmmo")
AccessorFunc(ENT, "Placer", "Placer")

function ENT:SetupDataTables()
   self:DTVar("Int", 0, "StoredAmmo")
end

function ENT:AddToStorage(amount)
    self:SetStoredAmmo(math.min(self.MaxStored, self:GetStoredAmmo() + amount))
end

function ENT:TakeFromStorage(amount)
    amount = math.min(amount, self:GetStoredAmmo())
    self:SetStoredAmmo(math.max(0, self:GetStoredAmmo() - amount))
    return amount
end

function ENT:Initialize()
    if SERVER then
        self:SetModel(self.Model)

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        self:SetUseType(CONTINUOUS_USE)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
           phys:SetMass(150)
           phys:Wake()
        end

        if self.MaxHealth > 0 then
            self:SetMaxHealth(self.MaxHealth)
            self:SetHealth(self.MaxHealth)
        end

        self:SetStoredAmmo(self.MaxStored)

        self:SetPlacer(nil)

        self.fingerprints = {}
    end
end

local function ClampedGiveAmmo(ply, ammo, amt, clamp)
    local count = ply:GetAmmoCount(ammo)

    if count >= clamp then
        return 0
    elseif count + amt > clamp then
        amt = math.max(clamp - count, 0)
    end

    return amt
end

function ENT:ApplyAmmo(ply)
    if (self.NextUse or 0) > CurTime() then return end

    local wpn = ply:GetActiveWeapon()

    local ammotype = string.lower(game.GetAmmoName(wpn:GetPrimaryAmmoType()) or "")
    if !self.AmmoInfo[ammotype] then return end

    local max = self.AmmoInfo[ammotype][2] or wpn.Primary.ClipMax
    local amt = self.AmmoInfo[ammotype][1]
    amt = ClampedGiveAmmo(ply, ammotype, amt, max) -- amount we need
    local cost = self.AmmoInfo[ammotype][3] * (amt / self.AmmoInfo[ammotype][1])
    local f = math.min(cost, self:GetStoredAmmo()) / cost -- fraction of cost we can afford

    amt = math.floor(amt * f)

    if amt > 0 then
        self:TakeFromStorage(cost * f)
        ply:GiveAmmo(amt, ammotype)

        if !self.Open then
            local seq = self:LookupSequence("open")
            self:ResetSequence(seq)
            self:EmitSound("items/ammocrate_open.wav")

            self.Open = true
        end

        self.NextUse = CurTime() + 1
    end
end

function ENT:PhysicsCollide(data)
    if data.DeltaTime < 0.1 then return end

    if data.Speed > 25 then
        self:EmitSound(self.CollisionSoundsHard[math.random(#self.CollisionSoundsHard)])
    else
        self:EmitSound(self.CollisionSoundsSoft[math.random(#self.CollisionSoundsSoft)])
    end
end

if SERVER then

    function ENT:Use(ply)
        if !ply:IsPlayer() then return end
        self:ApplyAmmo(ply)
    end
    function ENT:Think()
        if self.Open and (self.NextUse + 0.1) < CurTime() then
            local seq = self:LookupSequence("close")
            self:ResetSequence(seq)
            self:EmitSound("items/ammocrate_close.wav")

            self.Open = false
        end

        if (self.NextCharge or 0) < CurTime() then
            self:AddToStorage(self.RechargeRate)
            self.NextCharge = CurTime() + self.RechargeFreq
        end

        self:NextThink(CurTime())
        return true
    end

elseif CLIENT then

    function ENT:DrawTranslucent()
        self:Draw()
    end

    function ENT:Draw()
        self:DrawModel()
    end

end

function ENT:OnTakeDamage(dmginfo)
    if self.BOOM then return end

    self:TakePhysicsDamage(dmginfo)
    self:SetHealth(self:Health() - dmginfo:GetDamage())
    local att = dmginfo:GetAttacker()
    local placer = self:GetPlacer()

    if IsPlayer(att) then
        DamageLog(Format("DMG: \t %s [%s] damaged ammo crate [%s] for %d dmg", att:Nick(), att:GetRoleString(), IsPlayer(placer) and placer:Nick() or "<disconnected>", dmginfo:GetDamage()))
    end

    if self:Health() < 0 then
        self:Remove()
        util.EquipmentDestroyed(self:GetPos())

        if IsValid(self:GetPlacer()) then
            LANG.Msg(self:GetPlacer(), "tacrp_ammocrate_broken")
        end

        self.BOOM = true

        local dmg = self:GetStoredAmmo() * 2.25 + 75

        util.BlastDamage(self, dmginfo:GetAttacker(), self:GetPos(), 400, dmg)

        local fx = EffectData()
        fx:SetOrigin(self:GetPos())

        if self:WaterLevel() > 0 then
            util.Effect("WaterSurfaceExplosion", fx)
        else
            util.Effect("Explosion", fx)
        end

        self:EmitSound(table.Random(self.ExplodeSounds), 125, 90)
    end
end