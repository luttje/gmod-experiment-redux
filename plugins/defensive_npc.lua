local PLUGIN = PLUGIN

PLUGIN.name = "Defensive NPC's"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Let super admins spawn defensive NPC's."

if (not SERVER) then
	return
end

local TURRET_FLAGS = {
    NEVER_RETIRE = 128,
	OUT_OF_AMMO = 256,
}

PLUGIN.turretTypes = {
	["npc_turret_ceiling"] = true,
	["npc_turret_ground"] = true,
}

function PLUGIN:SpawnTurret(type, position, angles)
    if (not self.turretTypes[type]) then
        ix.util.SchemaErrorNoHalt("Invalid turret type: " .. type)
        return
    end

    local entity = ents.Create(type)
    entity:SetPos(position)
    entity:SetAngles(angles)
    entity:SetKeyValue("spawnflags", bit.bor(TURRET_FLAGS.NEVER_RETIRE))
    entity:Spawn()
    entity:Activate()

    -- Make it deploy
    entity:Fire("Enable")

	self:SetAllPlayerRelationships(entity, D_NU)

    return entity
end

function PLUGIN:SetAllPlayerRelationships(entity, relationship)
	for _, client in ipairs(player.GetAll()) do
		entity:AddEntityRelationship(client, relationship)
	end
end

function PLUGIN:LoadData()
	local npcs = self:GetData()

	for _, npcData in pairs(npcs) do
		self:SpawnTurret(npcData.type, npcData.pos, npcData.ang)
	end
end

function PLUGIN:SaveData()
    local npcs = {}

    for _, entity in ipairs(ents.GetAll()) do
        if (not self.turretTypes[entity:GetClass()]) then
            continue
        end

        table.insert(npcs, {
            type = entity:GetClass(),
            pos = entity:GetPos(),
            ang = entity:GetAngles()
        })
    end

	self:SetData(npcs)
end

do
	local COMMAND = {}

	COMMAND.description = "Spawn a defensive NPC."
	COMMAND.arguments = {
		ix.type.string,
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, type)
		local entity = self.plugin:SpawnTurret(type, client:GetEyeTraceNoCursor().HitPos, client:EyeAngles())

		if (IsValid(entity)) then
			client:Notify("You have spawned a defensive NPC.")
		else
			client:Notify("Invalid turret type.")
		end
	end

	ix.command.Add("DefensiveNpcSpawn", COMMAND)
end
