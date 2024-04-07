local playerMeta = FindMetaTable("Player")

function playerMeta:IsLeader()
	return self:GetCharacter():GetData("rank") == RANK_GEN
end

function playerMeta:IsCoLeader()
	return self:GetCharacter():GetData("rank") == RANK_COL
end

function playerMeta:GetAllianceRank()
	local rank = self:GetCharacter():GetData("rank")

	return rank
end

function playerMeta:GetAllianceRankString()
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

function playerMeta:GetAllianceCanManageRoster()
	local rank = self:GetAllianceRank()

	return rank >= RANK_LT
end

function playerMeta:GetAlliance()
	local character = self:GetCharacter()

	if (not character) then
		return
	end

	local alliance = character:GetData("alliance")

	return alliance
end
