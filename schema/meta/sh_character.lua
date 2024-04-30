local META = ix.meta.character

--- ! Overrides the default Helix recognition plugin DoesRecognize to override when a skull mask is equipped.
--- ! Sadly we cant just hook with IsCharacterRecognized, because the recognition plugin incorrectly checks
--- ! for 'true', meaning the plugin handles the recognition logic, before we get a chance to override it.
--- ! The recognition plugin should check for ~= false, so we can override it. But alas, it does not.
function META:DoesRecognize(id)
	if (!isnumber(id) and id.GetID) then
		id = id:GetID()
	end

	local character = ix.char.loaded[id]
	local client = character and character:GetPlayer() or nil

	if (not IsValid(client)) then
		return false
	end

	local hasSkullMask = client:GetCharacterNetVar("expSkullMask", false)

	if (hasSkullMask) then
		return false
	end

	return hook.Run("IsCharacterRecognized", self, id)
end
