local META = FindMetaTable("Entity")

if (SERVER) then
    util.AddNetworkString("PlayerBodyGroupChanged")
    util.AddNetworkString("PlayerBodyGroupsChanged")

	META.expSetBodygroup = META.expSetBodygroup or META.SetBodygroup
	META.expSetBodyGroups = META.expSetBodyGroups or META.SetBodyGroups

	--[[
		Override the bodygroup functions to call hooks
	--]]

	--- @param index number
	--- @param value number
    function META:SetBodygroup(index, value)
        if (self:IsPlayer()) then
            local oldValue = self:GetBodygroup(index)
            hook.Run("PlayerBodyGroupChanged", self, index, value, oldValue)

            net.Start("PlayerBodyGroupChanged")
            net.WriteEntity(self)
            net.WriteUInt(index, 32)
            net.WriteUInt(value, 32)
            net.WriteUInt(oldValue, 32)
            net.Broadcast()
        end

        self:expSetBodygroup(index, value)
    end

	--- @param index number
	--- @param value number
	function META:SetBodyGroup(index, value)
		self:SetBodygroup(index, value)
	end

	--- @param bodygroups string # Body groups to set. Each character in the string represents a separate bodygroup. (0 to 9, a to z being (10 to 35))
    function META:SetBodyGroups(bodygroups)
        if (self:IsPlayer()) then
            local oldBodygroups = ""

            for i = 1, 9 do
                local bodygroup = self:GetBodygroup(i)
                oldBodygroups = oldBodygroups .. bodygroup
            end

            hook.Run("PlayerBodyGroupsChanged", self, bodygroups, oldBodygroups)

            net.Start("PlayerBodyGroupsChanged")
            net.WriteEntity(self)
            net.WriteString(bodygroups)
            net.WriteString(oldBodygroups)
            net.Broadcast()
        end

        self:expSetBodyGroups(bodygroups)
    end
else
	net.Receive("PlayerBodyGroupChanged", function()
		local player = net.ReadEntity()
		local index = net.ReadUInt(32)
		local value = net.ReadUInt(32)
		local oldValue = net.ReadUInt(32)

		hook.Run("PlayerBodyGroupChanged", player, index, value, oldValue)
    end)

	net.Receive("PlayerBodyGroupsChanged", function()
		local player = net.ReadEntity()
		local bodygroups = net.ReadString()
		local oldBodygroups = net.ReadString()

		hook.Run("PlayerBodyGroupsChanged", player, bodygroups, oldBodygroups)
	end)
end

-- Override the default IsDoor logic to not include entities that are not doors. We call a hook to check.
function META:IsDoor()
	local class = self:GetClass()
    local baseIsDoor = (class and class:find("door") ~= nil)

    if (not baseIsDoor) then
        return false
    end

	return hook.Run("EntityIsDoor", self) ~= false
end

if (SERVER) then
	function META:RemoveWithEffect()
		Schema.ImpactEffect(self:GetPos(), 8, true)
		self:Remove()
	end
end
