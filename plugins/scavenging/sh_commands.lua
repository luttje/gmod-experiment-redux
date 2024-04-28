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
        if (inventoryType) then
            if (inventoryType == "medium") then
                inventoryType = "scavenging:medium"
            elseif (inventoryType == "base") then
                inventoryType = "scavenging:base"
            end

            if (inventoryType ~= "scavenging:base" and inventoryType ~= "scavenging:medium") then
                client:Notify("Invalid inventory type.")
                return
            end
        end

        local trace = client:GetEyeTraceNoCursor()
        local entity = ents.Create("exp_scavenging_source")
        entity:SetPos(trace.HitPos + trace.HitNormal + Vector(0, 0, 32))
        entity:Spawn()
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

	COMMAND.description = "Change the inventory type of the scavenging source you're looking at."
	COMMAND.arguments = {
		ix.type.text,
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, inventoryType)
        local entity = client:GetEyeTraceNoCursor().Entity

        if (not IsValid(entity) or entity:GetClass() ~= "exp_scavenging_source") then
            client:Notify("You must be looking at a scavenging source.")
            return
        end

		local index = entity:GetID()

		-- Remove the old inventory.
		if (index) then
			local query = mysql:Delete("ix_items")
				query:Where("inventory_id", index)
			query:Execute()

			query = mysql:Delete("ix_inventories")
				query:Where("inventory_id", index)
			query:Execute()
		end

		entity:MakeInventory(inventoryType)
		client:Notify("Scavenging source inventory type changed.")
	end

	ix.command.Add("ScavengeSetInventory", COMMAND)
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

	ix.command.Add("ScavengeSetName", COMMAND)
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

	ix.command.Add("ScavengeToggleNoDraw", COMMAND)
end
