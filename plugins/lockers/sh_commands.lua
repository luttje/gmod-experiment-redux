local PLUGIN = PLUGIN

do
	local COMMAND = {}

	COMMAND.description = "Spawn lockers at the location you are looking at."
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client)
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 512
			data.filter = client
		local trace = util.TraceLine(data)

		if (not trace.Hit) then
			client:Notify("You must be looking at a valid surface.")
			return
		end

		local angledTowardsPlayer = (client:GetPos() - trace.HitPos):Angle()
		angledTowardsPlayer.p = 0

		local lockers = ents.Create("exp_lockers")
		lockers:SetPos(trace.HitPos + (trace.HitNormal * 40))
		lockers:SetAngles(angledTowardsPlayer)
		lockers:Spawn()

		client:Notify("You added lockers.")
	end

	ix.command.Add("LockersAdd", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Remove the lockers you are looking at."
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client)
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 128
			data.filter = client
		local trace = util.TraceLine(data)

		if (not trace.Hit) then
			client:Notify("You must be looking at a valid surface.")
			return
		end

		local entity = trace.Entity

		if (IsValid(entity) and entity:GetClass() == "exp_lockers") then
			entity:Remove()
			client:Notify("You removed lockers.")
		else
			client:Notify("You must be looking at lockers.")
		end
	end

	ix.command.Add("LockersRemove", COMMAND)
end
