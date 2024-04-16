---@class Buff
---@field index number
---@field uniqueID string
---@field name string
---@field backgroundImage string
---@field backgroundColor Color
---@field foregroundImage string
---@field description string
---@field durationInSeconds number
---@field persistThroughDeath boolean
---@field attributeBoosts? table<string, number>
local META = Schema.meta.buff or {}
Schema.meta.buff = META

META.__index = META

function META:__tostring()
    return "buff[" .. self.uniqueID .. "]"
end

---@param client Player
---@param buff ActiveBuff
---@return string
function META:GetName(client, buff)
    return self.name
end

---@param client Player
---@param buff ActiveBuff
---@return string
function META:GetBackgroundImage(client, buff)
	return self.backgroundImage
end

---@param client Player
---@param buff ActiveBuff
---@return Color
function META:GetBackgroundColor(client, buff)
    return self.backgroundColor
end

---@param client Player
---@param buff ActiveBuff
---@return string
function META:GetForegroundImage(client, buff)
	return self.foregroundImage
end

---@param client Player
---@param buff ActiveBuff
---@return string
function META:GetDescription(client, buff)
    return self.description
end

---@param client Player
---@return number
function META:GetDurationInSeconds(client)
    return self.durationInSeconds
end

---@param client Player
---@param buff ActiveBuff
---@return boolean
function META:ShouldPersistThroughDeath(client, buff)
    return self.persistThroughDeath
end

---@param client Player
---@param buff ActiveBuff
---@return table<string, number>?
function META:GetAttributeBoosts(client, buff)
	return self.attributeBoosts
end

---@param client Player
---@param buff ActiveBuff
function META:OnSetup(client, buff)
    local attributeBoosts = self:GetAttributeBoosts(client, buff)

    if (attributeBoosts) then
        local character = client:GetCharacter()

		for attribute, boostAmount in pairs(attributeBoosts) do
			character:AddBoost("buff#"..self.uniqueID, attribute, boostAmount)
		end
	end
end

---@param client Player
---@param buff ActiveBuff
function META:OnLoadout(client, buff)

end

---@param client Player
---@param buff ActiveBuff
---@param expiredThroughDeath boolean
function META:OnExpire(client, buff, expiredThroughDeath)
    local attributeBoosts = self:GetAttributeBoosts(client, buff)

	if (attributeBoosts) then
        local character = client:GetCharacter()

		for attribute, boostAmount in pairs(attributeBoosts) do
			character:RemoveBoost("buff#"..self.uniqueID, attribute)
		end
	end
end
