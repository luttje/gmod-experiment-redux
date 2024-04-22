local META = FindMetaTable("Player")

function META:IsLeader()
	return self:GetCharacter():GetData("rank") == RANK_GEN
end

function META:IsCoLeader()
	return self:GetCharacter():GetData("rank") == RANK_COL
end

function META:GetAllianceRank()
	local rank = self:GetCharacter():GetData("rank")

	return rank
end

function META:GetAllianceRankString()
	local rank = self:GetAllianceRank()

	if (rank == RANK_PVT) then
		return "Pvt"
	elseif (rank == RANK_SGT) then
		return "Sgt"
	elseif (rank == RANK_LT) then
		return "Lt"
	elseif (rank == RANK_CPT) then
		return "Cpt"
	elseif (rank == RANK_MAJ) then
		return "Maj"
	elseif (rank == RANK_COL) then
		return "Col"
	elseif (rank == RANK_GEN) then
		return "Gen"
	else
		return "Rct"
	end
end

function META:GetAllianceCanManageRoster()
	local rank = self:GetAllianceRank()

	return rank >= RANK_LT
end

function META:GetAlliance()
	local character = self:GetCharacter()

	if (not character) then
		return
	end

	local alliance = character:GetData("alliance")

	return alliance
end

if (SERVER) then
    function META:PruneInvalidObjects()
		local character = self:GetCharacter()

        if (not character) then
            return false
        end

        local limitedObjects = character:GetVar("limitedObjects", {})
        local invalidObjects = {}

        for objectType, objects in pairs(limitedObjects) do
            for k, object in ipairs(objects) do
                if (not IsValid(object)) then
                    invalidObjects[#invalidObjects + 1] = {
                        type = objectType,
                        index = k
                    }
                end
            end
        end

        for _, data in ipairs(invalidObjects) do
            table.remove(limitedObjects[data.type], data.index)
        end

        character:SetVar("limitedObjects", limitedObjects)
    end

	hook.Add("PlayerSecondElapsed", "expPruneInvalidObjects", function(client)
		client:PruneInvalidObjects()
	end)

	function META:AddLimitedObject(objectType, object)
		local character = self:GetCharacter()
		local limitedObjects = character:GetVar("limitedObjects", {})
		local objects = limitedObjects[objectType] or {}

		objects[#objects + 1] = object
		limitedObjects[objectType] = objects

		character:SetVar("limitedObjects", limitedObjects)
	end
end

function META:IsObjectLimited(objectType, limit)
	local character = self:GetCharacter()

	if (not character) then
		return false
	end

	local limitedObjects = character:GetVar("limitedObjects", {})
	local objects = limitedObjects[objectType] or {}

	return #objects >= limit
end

function META:TryTraceInteractAtDistance(distance)
    local trace = self:GetEyeTraceNoCursor()
	distance = ix.config.Get("maxInteractionDistance", distance)

	if (trace.HitPos:Distance(trace.StartPos) > distance) then
		return false, "You can not do that this far away!"
	end

    if (trace.HitNonWorld) then
        return false, "You can not do that here!"
    end

	return true, "You can do that here.", trace
end

-- Helpers to ensure networked variables are only set for the specified character.
-- The networked vars will be set to their default values when the character changes
function META:SetCharacterNetVar(key, value)
	local character = self:GetCharacter()

	if (not character) then
		error("Attempted to set networked var for player without a character.")
		return
	end

	local cleanupList = self.expCleanupList or {}
	self.expCleanupList = cleanupList

	-- Store the original value, so we can restore it when the character changes
	if (not cleanupList[key]) then
		cleanupList[key] = self:GetNetVar(key)
	end

	self:SetNetVar(key, value)
end

function META:GetCharacterNetVar(key, default)
	local character = self:GetCharacter()

	if (not character) then
		return default
	end

	return self:GetNetVar(key, default)
end

hook.Add("PlayerLoadedCharacter", "expCleanupCharacterNetVars", function(client, character, currentChar)
	if (client.expCleanupList) then
		for key, value in pairs(client.expCleanupList) do
			client:SetCharacterNetVar(key, value)
		end
	end

	client.expCleanupList = {}
end)
