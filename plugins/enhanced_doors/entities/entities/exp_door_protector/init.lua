local PLUGIN = PLUGIN

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_combine/breenlight.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetHealth(25)
	self:SetMaxHealth(25)
end

function ENT:SetupDoorProtector(client, door)
    self.expClient = client
    self.expDoor = door
    door.expProtector = self

	door = IsValid(door.ixParent) and door.ixParent or door

	-- Set the door to be owned by this player.
	door:SetDTEntity(0, client)
	door.ixAccess = {
		[client] = DOOR_OWNER
	}

	PLUGIN:CallOnDoorChildren(door, function(child)
		child:SetDTEntity(0, client)
	end)

	local character = client:GetCharacter()
	local doors = character:GetVar("doors") or {}
	doors[#doors + 1] = door
	character:SetVar("doors", doors, true)

	ix.log.Add(client, "buydoor")

	self:SetPos(door:GetPos() + Vector(-1.0313, 41.8047, -8.1611))
    self:SetParent(door)
end

function ENT:OnTakeDamage(damageInfo)
    self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))

	local damageColor = math.max((self:Health() / self:GetMaxHealth()) * 255, 30)
    self:SetColor(Color(damageColor, damageColor, damageColor, 255))

    if (self:Health() <= 0) then
        self:RemoveWithEffect()
    end
end

function ENT:OnRemove()
    if (IsValid(self.expDoor)) then
        self.expDoor.expProtector = nil
    end

    self.expDoor:RemoveDoorAccessData()

	if (not IsValid(self.expClient)) then
		return
	end

    local character = self.expClient:GetCharacter()

	if (not character) then
		return
	end

	local doors = character:GetVar("doors") or {}

	for k, v in ipairs(doors) do
		if (v == self) then
			table.remove(doors, k)
		end
	end

	character:SetVar("doors", doors, true)

	ix.log.Add(self.expClient, "selldoor")
end

-- Forwards use commands to the door so the protector doesn't get in the way
function ENT:Use(client)
    if (not IsValid(client) or not client:IsPlayer() or not IsValid(self.expDoor)) then
        return
    end

	if (Schema.util.Throttle("doorProtectorOpen", 1, client)) then
		return
	end

	local origin = client:GetShootPos()

	self.expDoor:OpenDoorAwayFrom(origin, true)
end
