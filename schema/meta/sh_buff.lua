local META = Schema.meta.buff or {}
Schema.meta.buff = META

META.__index = META

function META:__tostring()
    return "buff[" .. self.uniqueID .. "]"
end

function META:GetUniqueID()
    return self.uniqueID
end

function META:GetName()
    return self.name
end

function META:GetDescription()
    return self.description
end

function META:GetDurationInSeconds()
    return self.durationInSeconds
end

function META:OnSetup(client, activeUntil)
    if (self.attributeBoosts) then
        local character = client:GetCharacter()

		for attribute, boostAmount in pairs(self.attributeBoosts) do
			character:AddBoost("buff#"..self.uniqueID, attribute, boostAmount)
		end
	end
end

function META:OnLoadout(client, activeUntil)

end

function META:OnExpire(client, expiredThroughDeath)
	if (self.attributeBoosts) then
        local character = client:GetCharacter()

		for attribute, boostAmount in pairs(self.attributeBoosts) do
			character:RemoveBoost("buff#"..self.uniqueID, attribute)
		end
	end
end
