--- @class Buff
--- @field index number
--- @field uniqueID string
--- @field name string
--- @field stackedName? string
--- @field isNegative? boolean
--- @field maxStacks? number
--- @field backgroundImage string
--- @field backgroundColor Color
--- @field foregroundImage string
--- @field description string
--- @field durationInSeconds number
--- @field persistThroughDeath? boolean
--- @field attributeBoosts? table<string, number>
--- @field resetOnDuplicate? boolean
local META = Schema.meta.buff or {}
Schema.meta.buff = META

META.__index = META

function META:__tostring()
    return "buff[" .. self.uniqueID .. "]"
end

--- @param client Player
--- @param buff ActiveBuff
--- @return string
function META:GetName(client, buff)
    local stacks = buff.data and buff.data.stacks or 1

    if (not stacks or stacks == 1) then
        return self.name or "Unknown"
    end

	local stackedName = self.stackedName or (self.name .. " (x%d)")

    return string.format(stackedName, stacks)
end

--- @param client Player
--- @param buff ActiveBuff
--- @return boolean
function META:IsNegative(client, buff)
	return self.isNegative or false
end

--- @param client Player
--- @param buff ActiveBuff
--- @return string
function META:GetBackgroundImage(client, buff)
	return self.backgroundImage or "experiment-redux/symbol_background"
end

--- @param client Player
--- @param buff ActiveBuff
--- @return Color
function META:GetBackgroundColor(client, buff)
    return self.backgroundColor or (
        self:IsNegative(client, buff)
        and Color(124, 48, 55, 255)
		or Color(48, 93, 124, 255)
	)
end

--- @param client Player
--- @param buff ActiveBuff
--- @return string|table
function META:GetForegroundImage(client, buff)
	return self.foregroundImage
end

--- @param client Player
--- @param buff ActiveBuff
--- @return string
function META:GetDescription(client, buff)
    return self.description or ""
end

--- @param client Player
--- @return number
function META:GetDurationInSeconds(client)
    return self.durationInSeconds or 60
end

--- @param client Player
--- @param buff ActiveBuff
--- @return boolean
function META:ShouldPersistThroughDeath(client, buff)
    return self.persistThroughDeath or false
end

--- @param client Player
--- @param buff ActiveBuff
--- @return table<string, number>?
function META:GetAttributeBoosts(client, buff)
    return self.attributeBoosts
end

--- @param client Player
--- @return boolean
function META:ShouldResetOnDuplicate(client)
	return self.resetOnDuplicate or false
end

--- @param client Player
--- @param buff ActiveBuff
function META:OnSetup(client, buff)
    local attributeBoosts = self:GetAttributeBoosts(client, buff)

    if (attributeBoosts) then
        local character = client:GetCharacter()

		for attribute, boostAmount in pairs(attributeBoosts) do
			character:AddBoost("buff#"..self.uniqueID, attribute, boostAmount)
		end
	end
end

--- @param client Player
--- @param buff ActiveBuff
--- @return boolean? # Return true to remove the buff
function META:OnShouldExpire(client, buff)

end

--- @param client Player
--- @param buff ActiveBuff
function META:OnExpire(client, buff)
    local attributeBoosts = self:GetAttributeBoosts(client, buff)

	if (attributeBoosts) then
        local character = client:GetCharacter()

		for attribute, boostAmount in pairs(attributeBoosts) do
			character:RemoveBoost("buff#"..self.uniqueID, attribute)
		end
	end
end

--- Gets the current stack count of the buff
--- @param client any
--- @param buff any
--- @return number
function META:GetStacks(client, buff)
	return buff.data and buff.data.stacks or 1
end

--- Stacks the buff if it has not reached the maximum stack count
--- @param client any
--- @param buff any
function META:Stack(client, buff)
	local maxStacks = self.maxStacks or 1
	local currentStacks = self:GetStacks(client, buff)

    if (currentStacks >= maxStacks) then
        return
    end

	buff.data = buff.data or {}
	buff.data.stacks = math.min(currentStacks + 1, maxStacks)
	buff.activeUntil = CurTime() + self:GetDurationInSeconds(client)
	Schema.buff.Network(client, buff.index, buff)
end
