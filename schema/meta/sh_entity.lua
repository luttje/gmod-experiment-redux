local meta = FindMetaTable("Entity")

-- Override the default IsDoor logic to not include entities that are not doors. We call a hook to check.
function meta:IsDoor()
	local class = self:GetClass()
    local baseIsDoor = (class and class:find("door") ~= nil)

    if (not baseIsDoor) then
        return false
    end

	return hook.Run("EntityIsDoor", self) ~= false
end

if (SERVER) then
	function meta:RemoveWithEffect()
		Schema.ImpactEffect(self:GetPos(), 8, true)
		self:Remove()
	end
end
