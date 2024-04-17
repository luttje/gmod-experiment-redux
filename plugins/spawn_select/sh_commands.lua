local PLUGIN = PLUGIN

do
	local COMMAND = {}

	COMMAND.description = "Make where you are standing (and the way you are looking) a spawn location, providing information on where it's located on the 2D map."
	COMMAND.arguments = {
		ix.type.string,
	}

	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, name)
        local position = client:GetPos()
		local angles = client:EyeAngles()

		PLUGIN.spawns[#PLUGIN.spawns + 1] = {
			name = name,
			position = position,
			angles = angles,
		}
		PLUGIN:SaveData()

		client:Notify("You added a spawn point.")
	end

	ix.command.Add("SpawnAdd", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Remove the spawn point closest to where you are looking."
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client)
		local position = client:GetPos()
		local closestSpawn
		local closestDistance = math.huge
		local maxDistance = 256

		for k, v in ipairs(PLUGIN.spawns) do
			local distance = v.position:Distance(position)

			if (distance > maxDistance) then
				continue
			end

			if (distance < closestDistance) then
				closestDistance = distance
				closestSpawn = k
			end
		end

		if (closestSpawn) then
			table.remove(PLUGIN.spawns, closestSpawn)
			PLUGIN:SaveData()

			client:Notify("You removed a spawn point.")
		else
			client:Notify("No spawn points found.")
		end
	end

	ix.command.Add("SpawnRemove", COMMAND)
end
