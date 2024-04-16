---@class Buff
---@field index number
---@field uniqueID string
---@field name string
---@field stackedName? string
---@field maxStacks? number
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
	local stacks = buff.data and buff.data.stacks or 1

	if (not stacks or not self.stackedName) then
		return self.name
	end

	return string.format(self.stackedName, stacks)
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
---@return boolean? Return false to remove the buff
function META:OnPlayerSecondElapsed(client, buff)

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

--- Gets the current stack count of the buff
---@param client any
---@param buff any
---@return number
function META:GetStacks(client, buff)
	return buff.data and buff.data.stacks or 1
end

--- Stacks the buff if possible
---@param client any
---@param buff any
function META:Stack(client, buff)
	local maxStacks = self.maxStacks or 1
	local currentStacks = self:GetStacks(client, buff)

	if (currentStacks >= maxStacks) then
		return
	end

	buff.data.stacks = math.min(currentStacks + 1, maxStacks)
	buff.activeUntil = CurTime() + self:GetDurationInSeconds(client)
	Schema.buff.Network(client, buff.index, buff)
end
