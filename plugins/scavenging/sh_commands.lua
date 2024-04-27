local PLUGIN = PLUGIN

do
	local COMMAND = {}

	COMMAND.description = "Spawn a scavenging source at your target position."
	COMMAND.arguments = {
		bit.bor(ix.type.string, ix.type.optional),
		bit.bor(ix.type.string, ix.type.optional),
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, inventoryType, model)
		local trace = client:GetEyeTraceNoCursor()
		local entity = ents.Create("exp_scavenging_source")
		entity:SetPos(trace.HitPos + trace.HitNormal + Vector(0, 0, 32))
		entity:Spawn()

		if (inventoryType) then
			if (inventoryType == "medium") then
				inventoryType = "scavenging:medium"
			end

			if (inventoryType ~= "scavenging:base" and inventoryType ~= "scavenging:medium") then
				client:Notify("Invalid inventory type.")
				return
			end
		end

		entity:MakeInventory(inventoryType)

		if (model) then
			if (model == "invisible") then
				entity:SetInvisible(true)
			else
				entity:SetModel(model)
				entity:SetSolid(SOLID_VPHYSICS)
				entity:PhysicsInit(SOLID_VPHYSICS)
			end
		end

        entity:Activate()

		client:Notify("Scavenging source spawned.")
	end

	ix.command.Add("ScavengeSpawn", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Set the name of the scavenging source you're looking at."
	COMMAND.arguments = {
		ix.type.text,
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, name)
		local entity = client:GetEyeTraceNoCursor().Entity

		if (IsValid(entity) and entity:GetClass() == "exp_scavenging_source") then
			entity:SetSourceName(name)
			client:Notify("Scavenging source name set.")
		else
			client:Notify("You must be looking at a scavenging source.")
		end
	end

	ix.command.Add("ScavengeName", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Make the scavenging source you're looking at temporarily visible or invisible again."

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client)
		local entity = client:GetEyeTraceNoCursor().Entity

		if (IsValid(entity) and entity:GetClass() == "exp_scavenging_source") then
			entity:SetNoDraw(not entity:GetNoDraw())

			if (not entity:GetNoDraw()) then
				entity:SetSolid(SOLID_VPHYSICS)
				entity:PhysicsInit(SOLID_VPHYSICS)
			else
				entity:SetSolid(SOLID_BBOX)
				entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
			end

			client:Notify("Scavenging source changed visibility.")
		else
			client:Notify("You must be looking at a scavenging source.")
		end
	end

	ix.command.Add("ScavengeSetNoDraw", COMMAND)
end
