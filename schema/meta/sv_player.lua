util.AddNetworkString("AllianceRankSet")
util.AddNetworkString("AllianceMemberLeft")

local playerMeta = FindMetaTable("Player")

function playerMeta:IsLeader()
	return self:GetCharacter():GetData("rank") == RANK_GEN
end

function playerMeta:IsCoLeader()
	return self:GetCharacter():GetData("rank") == RANK_COL
end

function playerMeta:SetAllianceRank(rank)
	local character = self:GetCharacter()
	local alliance = character:GetData("alliance")
	character:SetData("rank", rank)

	net.Start("AllianceRankSet")
	net.WriteUInt(character:GetID(), 32)
	net.WriteString(character:GetName())
	net.WriteUInt(rank, 8)
	net.Send(Schema.alliance.GetOnlineMembers(alliance.id))
end

function playerMeta:SetAlliance(alliance)
	local isValidAlliance = type(alliance) == "table" and alliance.id ~= nil and alliance.name ~= nil

	if (alliance ~= nil and not isValidAlliance) then
		error("Alliance must be a table with an `id` and `name` property.")
	end

	local character = self:GetCharacter()
	local oldAlliance = character:GetData("alliance")

	if (oldAlliance ~= nil) then
		net.Start("AllianceMemberLeft")
		net.WriteUInt(character:GetID(), 32)
		net.WriteString(character:GetName())
		net.WriteBool(false)
		net.Send(Schema.alliance.GetOnlineMembers(oldAlliance.id))
	end

	character:SetData("alliance", alliance)
end

function playerMeta:GetAlliance()
	local character = self:GetCharacter()

	if (not character) then
		return
	end

	local alliance = character:GetData("alliance")

	return alliance
end

function playerMeta:QueueBoostRemove(boostID, attribID, delay)
    local character = self:GetCharacter()

    if (not character) then
        return
    end

    local boostsToRemove = character:GetVar("boostsToRemove", {})

    boostsToRemove[boostID] = boostsToRemove[boostID] or {}
    boostsToRemove[boostID][attribID] = CurTime() + delay

    character:SetVar("boostsToRemove", boostsToRemove)
end

function playerMeta:CheckQueuedBoostRemovals()
	local character = self:GetCharacter()

	if (not character) then
		return
	end

	local boostsToRemove = character:GetVar("boostsToRemove", {})
	local curTime = CurTime()

    for boostID, attributes in pairs(boostsToRemove) do
        for attribID, removeTime in pairs(attributes) do
            if (curTime >= removeTime) then
                character:RemoveBoost(boostID, attribID)
                boostsToRemove[boostID][attribID] = nil
            end
        end
    end

	character:SetVar("boostsToRemove", boostsToRemove)
end
