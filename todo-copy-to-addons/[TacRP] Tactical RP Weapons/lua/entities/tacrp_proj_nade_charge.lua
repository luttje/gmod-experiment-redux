AddCSLuaFile()

ENT.Base                     = "tacrp_proj_base"
ENT.PrintName                = "C4"
ENT.Spawnable                = false

ENT.Model                    = "models/weapons/tacint/door_charge-1.mdl"

ENT.Sticky = true

ENT.IsRocket = false // projectile has a booster and will not drop.

ENT.InstantFuse = false // projectile is armed immediately after firing.
ENT.RemoteFuse = false // allow this projectile to be triggered by remote detonator.
ENT.ImpactFuse = false // projectile explodes on impact.
ENT.StickyFuse = true

ENT.ExplodeOnDamage = false // projectile explodes when it takes damage.
ENT.ExplodeUnderwater = false

ENT.Defusable = false
ENT.DefuseOnDamage = true

ENT.Delay = 2

ENT.PickupAmmo = "ti_charge"

ENT.ExplodeSounds = {
    "TacRP/weapons/breaching_charge-1.wav"
}

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Weapon")
    self:NetworkVar("Bool", 0, "Remote")
    self:NetworkVar("Float", 0, "ArmTime")
end

DEFINE_BASECLASS(ENT.Base)

function ENT:Initialize()
    if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and IsValid(self:GetOwner():GetActiveWeapon()) and self:GetOwner():GetActiveWeapon():GetClass() == "tacrp_c4_detonator" then
        self.StickyFuse = false
        self.RemoteFuse = true
        self.Delay = 0.5
        self.Defusable = true
        self:SetRemote(true)
    end

    BaseClass.Initialize(self)
end

function ENT:Detonate()
    local attacker = IsValid(self.Attacker) and self.Attacker or self:GetOwner()

    util.BlastDamage(self, attacker, self:GetPos(), 200,
            500 * TacRP.ConVars["mult_damage_explosive"]:GetFloat())

    local fx = EffectData()
    fx:SetOrigin(self:GetPos())
    fx:SetNormal(self:GetForward())

    if self:WaterLevel() > 0 then
        util.Effect("WaterSurfaceExplosion", fx)
    else
        util.Effect("HelicopterMegaBomb", fx)
    end

    self:EmitSound(table.Random(self.ExplodeSounds), 110)

    local door = self:GetParent()
    self:SetParent(NULL)

    if IsValid(door) and string.find(door:GetClass(), "door") then
        local vel = self:GetForward() * -50000
        for _, otherDoor in pairs(ents.FindInSphere(door:GetPos(), 72)) do
            if door != otherDoor and otherDoor:GetClass() == door:GetClass() then
                TacRP.DoorBust(otherDoor, vel, attacker)
                break
            end
        end
        TacRP.DoorBust(door, vel, attacker)
    end

    self:Remove()
end

function ENT:Stuck()
    self:SetArmTime(CurTime())
    if !self:GetRemote() then
        local ttt = TacRP.GetBalanceMode() == TacRP.BALANCE_TTT
        self:EmitSound("weapons/c4/c4_beep1.wav", ttt and 60 or 80, 110)
        timer.Create("breachbeep_" .. self:EntIndex(), 0.25, 7, function()
            if !IsValid(self) then return end
            self:EmitSound("weapons/c4/c4_beep1.wav", ttt and 60 or 80, 110)
        end)
    end

    // you are already dead
    if IsValid(self:GetParent()) and self:GetParent():IsPlayer() and !IsValid(self:GetParent().nadescream) then
        self:GetParent().nadescream = self
        if self:GetRemote() then
            self:GetParent():EmitSound("vo/npc/male01/ohno.wav")
        else
            self:GetParent():EmitSound("vo/npc/male01/no0" .. math.random(1, 2) .. ".wav")
        end
    end

    if VJ then
        self.Zombies = {}
        for _, x in ipairs(ents.FindInSphere(self:GetPos(), 512)) do
            if x:IsNPC() and string.find(x:GetClass(),"npc_vj_l4d_com_") and x.Zombie_CanHearPipe == true and x.Zombie_NextPipBombT < CurTime() then
                x.Zombie_NextPipBombT = CurTime() + 3
                table.insert(x.VJ_AddCertainEntityAsEnemy,self)
                x:AddEntityRelationship(self, D_HT, 99)
                x.MyEnemy = self
                x:SetEnemy(self)
                table.insert(self.Zombies, x)
            end
        end
    end
end

function ENT:OnThink()
    if VJ and self.Zombies then
        for _, v in ipairs(self.Zombies) do
            if IsValid(v) then
                v:SetLastPosition(self:GetPos())
                v:VJ_TASK_GOTO_LASTPOS()
            end
        end
    end
end

local clr_timed = Color(255, 0, 0)
local clr_remote = Color(0, 255, 0)

local mat = Material("sprites/light_glow02_add")
function ENT:Draw()
    self:DrawModel()

    if (self:GetRemote() or self:GetArmTime() > 0) and math.ceil((CurTime() - self:GetArmTime()) * (self:GetRemote() and 2 or 8)) % 2 == 1 then
        render.SetMaterial(mat)
        render.DrawSprite(self:GetPos() + self:GetAngles():Up() * 7.5 + self:GetAngles():Right() * -4.5 + self:GetAngles():Forward() * 2, 8, 8, self:GetRemote() and clr_remote or clr_timed)
    end
end