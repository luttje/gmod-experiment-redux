
local PLUGIN = PLUGIN

PLUGIN.name = "Enhanced Doors"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Doors that can be owned by placing a protector on them."

DOOR_OWNER = 3
DOOR_TENANT = 2
DOOR_GUEST = 1
DOOR_NONE = 0

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sh_commands.lua")

ix.config.Add("doorLockTime", 1, "How long it takes to (un)lock a door.", nil, {
	data = {min = 0, max = 10.0, decimals = 1},
	category = "dConfigName"
})

do
	local entityMeta = FindMetaTable("Entity")

	function entityMeta:GetDoor()
        local door = self

        if (not door:IsDoor()) then
            if (door:GetClass() ~= "exp_door_protector") then
                return false
            end

            door = door.expDoor
        end

		return door
	end

    function entityMeta:CheckDoorAccess(client, access)
        local door = self:GetDoor()

        if (not door) then
			return false
		end

		access = access or DOOR_GUEST

		local parent = door.ixParent

		if (IsValid(parent)) then
			return parent:CheckDoorAccess(client, access)
		end

		if (hook.Run("CanPlayerAccessDoor", client, door, access)) then
			return true
		end

		if (door.ixAccess and (door.ixAccess[client] or 0) >= access) then
			return true
		end

		return false
	end

	if (SERVER) then
		function entityMeta:RemoveDoorAccessData()
			local door = self:GetDoor()

			if (not door) then
				return false
			end

			local receivers = {}

			for k, _ in pairs(door.ixAccess or {}) do
				receivers[#receivers + 1] = k
			end

			if (#receivers > 0) then
				net.Start("expDoorMenu")
				net.Send(receivers)
			end

			door.ixAccess = {}
			door:SetDTEntity(0, nil)

			-- Remove door information on child doors
			PLUGIN:CallOnDoorChildren(door, function(child)
				child:SetDTEntity(0, nil)
			end)
		end
	end
end
