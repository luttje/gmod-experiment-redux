util.AddNetworkString("AllianceRequestCreate")
util.AddNetworkString("AllianceRequestInviteMember")
util.AddNetworkString("AllianceMemberInvitation")
util.AddNetworkString("AllianceRequestInviteAccept")
util.AddNetworkString("AllianceRequestInviteDecline")
util.AddNetworkString("AllianceInviteDeclined")
util.AddNetworkString("AllianceRequestUpdateMembers")
util.AddNetworkString("AllianceRequestUpdateMembersDeclined")
util.AddNetworkString("AllianceForceUpdate")
util.AddNetworkString("AllianceUpdateMembers")
util.AddNetworkString("AllianceRequestSetRank")
util.AddNetworkString("AllianceRequestKick")

Schema.alliance = Schema.alliance or {}

function Schema.alliance.LoadTables()
	local query

	query = mysql:Create("exp_alliances")
	query:Create("alliance_id", "INT(11) UNSIGNED NOT NULL AUTO_INCREMENT")
	query:Create("name", "VARCHAR(32) NOT NULL")
	query:Create("members", "TEXT NOT NULL")
	query:Create("created", "INT(11) UNSIGNED NOT NULL")
	query:PrimaryKey("alliance_id")
	query:Execute()
end

hook.Add("DatabaseConnected", "expDatabaseConnected_AllianceLoadTables", function()
	Schema.alliance.LoadTables()
end)

function Schema.alliance.WipeTables()
	local query

	query = mysql:Drop("exp_alliances")
	query:Execute()
end

hook.Add("OnWipeTables", "expWipeTables_AllianceWipeTables", function()
	Schema.alliance.WipeTables()
end)

function Schema.alliance.Create(client, allianceName, callback)
	local character = client:GetCharacter()
    local ownerId = character:GetID()
	local rank = RANK_GEN
    local query

	local members = {
		{
			id = ownerId,
			rank = rank,
			name = character:GetName(),
		}
	}

	query = mysql:Insert("exp_alliances")
	query:Insert("name", allianceName)
	query:Insert("members", util.TableToJSON(members))
	query:Insert("created", os.time())
	query:Callback(function(result, status, lastID)
		if (not IsValid(client)) then
			return
		end

		if (status == false) then
			ix.log.Add(client, "schemaDebug", "CreateAlliance",
				"Failed to create alliance with result " .. tostring(result) .. " and lastID " .. tostring(lastID) .. ".")
			return
		end

		character:SetData("rank", rank)
		callback(lastID, members)
	end)
	query:Execute()
end

function Schema.alliance.GetOnlineMembers(allianceId)
	local members = {}

	for _, v in ipairs(player.GetAll()) do
		local alliance = v:GetAlliance()

		if (not alliance or alliance.id ~= allianceId) then
			continue
		end

		table.insert(members, v)
	end

	return members
end

function Schema.alliance.AddMember(allianceId, memberId, memberName, memberRank, callback)
	return Schema.util.RunSingleWithinScope("AllyModifyMembers", function(release)
		local query

		query = mysql:Select("exp_alliances")
		query:Select("members")
		query:Where("alliance_id", allianceId)
		query:Callback(function(result)
			if (not result or #result < 1) then
				release()
				callback(false, "Alliance does not exist.")
				return
			end

			local members = util.JSONToTable(result[1].members) or {}

			table.insert(members, {
				id = memberId,
				rank = memberRank,
				name = memberName,
			})

			query = mysql:Update("exp_alliances")
			query:Update("members", util.TableToJSON(members))
			query:Where("alliance_id", allianceId)
			query:Callback(function(result, status)
				if (status == false) then
					release()
					callback(false, "Failed to add member.")
					return
				end

				release()
				callback(true)
			end)
			query:Execute()
		end)
		query:Execute()
	end)
end

function Schema.alliance.RemoveMember(allianceId, memberId, callback)
	return Schema.util.RunSingleWithinScope("AllyModifyMembers", function(release)
		local query

		query = mysql:Select("exp_alliances")
		query:Select("members")
		query:Where("alliance_id", allianceId)
		query:Callback(function(result)
			if (not result or #result < 1) then
				release()
				callback(false, "Alliance does not exist.")
				return
			end

			local members = util.JSONToTable(result[1].members) or {}
			local found = false

			for k, v in ipairs(members) do
				if (v.id == memberId) then
					table.remove(members, k)
					found = true
					break
				end
			end

			if (not found) then
				release()
				callback(false, "Member does not exist.")
				return
			end

			if (#members == 0) then
				query = mysql:Delete("exp_alliances")
				query:Where("alliance_id", allianceId)
				query:Callback(function(result, status)
					if (status == false) then
						release()
						callback(false, "Failed to remove alliance.")
						return
					end

					release()
					callback(true)
				end)
				query:Execute()

				return
			else
				query = mysql:Update("exp_alliances")
				query:Update("members", util.TableToJSON(members))
				query:Where("alliance_id", allianceId)
				query:Callback(function(result, status)
					if (status == false) then
						release()
						callback(false, "Failed to remove member.")
						return
					end

					release()
					callback(true)
				end)
				query:Execute()
			end
		end)
		query:Execute()
	end)
end

function Schema.alliance.SetMemberRank(allianceId, memberId, memberRank, callback)
	return Schema.util.RunSingleWithinScope("AllyModifyMembers", function(release)
		local query

		query = mysql:Select("exp_alliances")
		query:Select("members")
		query:Where("alliance_id", allianceId)
		query:Callback(function(result)
			if (not result or #result < 1) then
				release()
				callback(false, "Alliance does not exist.")
				return
			end

			local members = util.JSONToTable(result[1].members) or {}
			local found = false

			for k, v in ipairs(members) do
				if (v.id == memberId) then
					v.rank = memberRank
					found = true
					break
				end
			end

			if (not found) then
				release()
				callback(false, "Member does not exist.")
				return
			end

			query = mysql:Update("exp_alliances")
			query:Update("members", util.TableToJSON(members))
			query:Where("alliance_id", allianceId)
			query:Callback(function(result, status)
				if (status == false) then
					release()
					callback(false, "Failed to set member rank.")
					return
				end

				release()
				callback(true)
			end)
			query:Execute()
		end)
		query:Execute()
	end)
end

function Schema.alliance.RequestCreate(client, allianceName)
	if (Schema.util.Throttle("RequestCreate", 15, client)) then
		ix.util.Notify("Please wait before trying to create an alliance again.", client)

		return
	end

	local canRun = Schema.util.RunSingleWithinScope("RequestCreate", function(release)
		if (type(allianceName) ~= "string" or allianceName:len() < 1) then
			ix.util.Notify("You entered an invalid alliance name!", client)

			release()
			return
		end

		local allianceCost = ix.config.Get("allianceCost")
		local character = client:GetCharacter()

		if (not character:HasMoney(allianceCost)) then
			ix.util.Notify("You need another " ..
				ix.currency.Get(allianceCost - character:GetMoney(), nil, true) .. "!", client)

			release()
			return
		end

		local query

		query = mysql:Select("exp_alliances")
		query:Select("alliance_id")
		query:Where("name", allianceName)
		query:Callback(function(result)
			if (not IsValid(client)) then
				release()
				return
			end

			if (client:GetCharacter() ~= character) then
				ix.util.Notify("You switched characters before the alliance creation process could finish.", client)
				release()
				return
			end

			if (result and #result > 0) then
				ix.util.Notify("An alliance with the name '" .. allianceName .. "' already exists!", client)
				release()
				return
			end

			Schema.alliance.Create(client, allianceName, function(allianceId, members)
				if (not IsValid(client)) then
					release()
					return
				end

				if (client:GetCharacter() ~= character) then
					ix.util.Notify("You switched characters before the alliance creation process could finish.", client)
					release()
					return
				end

				client:SetAlliance({
					id = allianceId,
					name = allianceName,
				})
				character:TakeMoney(allianceCost, "creating an alliance")

				ix.util.Notify("You have created the '" .. allianceName .. "' alliance.", client)
                ix.log.Add(client, "allianceCreated", allianceName)

				net.Start("AllianceForceUpdate")
				net.Send(client)

				release()
			end)
		end)
		query:Execute()
	end)

	if (not canRun) then
		ix.util.Notify("You are already creating an alliance!", client)

		return
	end
end

net.Receive("AllianceRequestCreate", function(len, client)
	local allianceName = net.ReadString()

	Schema.alliance.RequestCreate(client, allianceName)
end)

function Schema.alliance.RequestKick(client, member)
	if (Schema.util.Throttle("RequestKick", 5, client)) then
		ix.util.Notify("Please wait before trying to kick a member again.", client)

		return
	end

	if (not client:GetAllianceCanManageRoster()) then
		ix.util.Notify("You are not allowed to kick members from the alliance!", client)
		return
	end

    if (member:GetAllianceRank() == client:GetAllianceRank()) then
        client:Notify("You cannot kick this member as they have the same rank as you.")
        return
    end

    if (member:GetAllianceRank() > client:GetAllianceRank()) then
		client:Notify("You cannot kick this member as they have a higher rank than you.")
		return
	end

	local alliance = client:GetAlliance()
	local memberAlliance = member:GetAlliance()

	if (not memberAlliance or memberAlliance.id ~= alliance.id) then
		ix.util.Notify(member:Name() .. " is not in your alliance!", client)
		return
	end

	local memberCharacter = member:GetCharacter()

	if (not memberCharacter) then
		ix.util.Notify("This player is not valid!", client)
		return
	end

	local canRun = Schema.alliance.RemoveMember(alliance.id, memberCharacter:GetID(), function(success, reason)
		if (not IsValid(client)) then
			return
		end

		if (not success) then
			ix.util.Notify("Failed to kick member: " .. reason, client)
			return
		end

		if (not IsValid(member)) then
			ix.util.Notify("The member you tried to kick is no longer valid.", client)
			return
		end

		ix.util.Notify("You have kicked " .. member:Name() .. " from the '" .. alliance.name .. "' alliance.", client)
		ix.util.Notify("You have been kicked from the '" .. alliance.name .. "' alliance.", member)
		ix.log.Add(client, "allianceKicked", member, alliance.name)

		member:SetAlliance(nil)
		Schema.alliance.RequestSendMembersToAlliance(alliance.id)
	end)

	if (not canRun) then
		ix.util.Notify("Somebody is already modifying the alliance members. Please wait a moment and try again.", client)
	end
end

net.Receive("AllianceRequestKick", function(len, client)
	local member = net.ReadEntity()

	Schema.alliance.RequestKick(client, member)
end)

function Schema.alliance.RequestSetRank(client, member, rank)
	if (Schema.util.Throttle("RequestSetRank", 5, client)) then
		ix.util.Notify("Please wait before trying to change a member's rank.", client)

		return
	end

	local alliance = client:GetAlliance()
	local memberAlliance = member:GetAlliance()

	if (not memberAlliance or memberAlliance.id ~= alliance.id) then
		ix.util.Notify(member:Name() .. " is not in your alliance!", client)
		return
	end

    if (not rank or rank < RANK_RCT or rank > RANK_GEN) then
        ix.util.Notify("You entered an invalid rank!", client)
        return
    end

    local clientRank = client:GetAllianceRank()
    local rankIsLower = rank < member:GetAllianceRank()
	local canSetRank = (clientRank >= RANK_LT and rankIsLower) or (clientRank == RANK_GEN)

    if (not canSetRank) then
        ix.util.Notify("You cannot set this rank!", client)
        return
    end

    -- If the leader tries to demote themselves, reject it
	if (clientRank == RANK_GEN and member == client) then
		ix.util.Notify("You cannot demote yourself!", client)
		return
	end

	local canRun = Schema.alliance.SetMemberRank(alliance.id, member:GetCharacter():GetID(), rank,
		function(success, reason)
			if (not IsValid(client)) then
				return
			end

			if (not success) then
				ix.util.Notify("Failed to change member rank: " .. reason, client)
				return
			end

			if (not IsValid(member)) then
				ix.util.Notify("The member you tried to modify is no longer valid.", client)
				return
			end

			ix.util.Notify("You have set " .. member:Name() .. " to the rank of " .. RANKS[rank] .. " in the '" .. alliance.name .. "' alliance.",
				client)
			ix.util.Notify("You have been set to the rank of " .. RANKS[rank] .. " in the '" .. alliance.name .. "' alliance.", member)
			ix.log.Add(client, "allianceRankSet", member, RANKS[rank], alliance.name)

			member:SetAllianceRank(rank)
			Schema.alliance.RequestSendMembersToAlliance(alliance.id)
		end)

	if (not canRun) then
		ix.util.Notify("Somebody is already modifying the alliance members. Please wait a moment and try again.", client)
	end
end

net.Receive("AllianceRequestSetRank", function(len, client)
	local member = net.ReadEntity()
    local rank = net.ReadUInt(8)

	Schema.alliance.RequestSetRank(client, member, rank)
end)

function Schema.alliance.GetAllMembers(allianceId, callback)
	-- TODO: Cache this data in memory instead of doing a query every time
	local query

	query = mysql:Select("exp_alliances")
	query:Select("members")
	query:Where("alliance_id", allianceId)
	query:Callback(function(result)
		if (not result or #result < 1) then
			callback({})
			return
		end

        local members = util.JSONToTable(result[1].members) or {}
		callback(members)
	end)
	query:Execute()
end

function Schema.alliance.RequestSendMembers(client)
    if (Schema.util.Throttle("RequestSendMembers", 5, client)) then
        net.Start("AllianceRequestUpdateMembersDeclined")
		net.Send(client)
		return
	end

	local alliance = client:GetAlliance()

	if (not alliance) then
		-- Happens when they leave the alliance while a request is ongoing
		return
	end

	Schema.alliance.GetAllMembers(alliance.id, function(members)
		if (not IsValid(client)) then
			return
		end

		if (#members == 0) then
			ix.util.Notify("Your alliance does not exist anymore!", client)
			return
		end

		net.Start("AllianceUpdateMembers")
		net.WriteTable(members)
		net.Send(client)
	end)
end

net.Receive("AllianceRequestUpdateMembers", function(len, client)
	Schema.alliance.RequestSendMembers(client)
end)

--- Inform all alliance members of the current members in the alliance.
function Schema.alliance.RequestSendMembersToAlliance(allianceId)
	Schema.alliance.GetAllMembers(allianceId, function(members)
        local onlineMembers = Schema.alliance.GetOnlineMembers(allianceId)

		if (#members == 0) then
			return
		end

		net.Start("AllianceUpdateMembers")
		net.WriteTable(members)
		net.Send(onlineMembers)
	end)
end

function Schema.alliance.RequestInviteMember(client, member)
	if (Schema.util.Throttle("RequestInviteMember", 5, client)) then
		ix.util.Notify("Please wait before trying to invite a member again.", client)

		return
	end

	local alliance = client:GetAlliance()

	if (not alliance) then
		ix.util.Notify("You are not in an alliance!", client)
		return
	end

	if (not client:GetAllianceCanManageRoster()) then
		ix.util.Notify("You are not allowed to invite members to the alliance!", client)
		return
	end

	local memberCharacter = member:GetCharacter()

	if (not memberCharacter) then
		ix.util.Notify("This player is not valid!", client)
		return
	end

	local memberAlliance = member:GetAlliance()

	if (memberAlliance) then
		ix.util.Notify(member:Name() .. " is already in an alliance!", client)
		return
	end

	member.expAllianceInvites = member.expAllianceInvites or {}
	member.expAllianceInvites[alliance.id] = client

	ix.util.Notify("You have invited " .. member:Name() .. " to the '" .. alliance.name .. "' alliance.", client)
	ix.util.Notify(client:Name() .. " has invited you to the '" .. alliance.name .. "' alliance. Go to the alliance panel to accept.", member)
	ix.log.Add(client, "allianceInvited", member, alliance.name)

	net.Start("AllianceMemberInvitation")
	net.WriteUInt(alliance.id, 32)
	net.WriteString(alliance.name)
	net.Send(member)
end

net.Receive("AllianceRequestInviteMember", function(len, client)
	local member = net.ReadEntity()

	Schema.alliance.RequestInviteMember(client, member)
end)

function Schema.alliance.RequestInviteAccept(client, allianceId)
	if (Schema.util.Throttle("RequestInviteAccept", 5, client)) then
		ix.util.Notify("Please wait before trying to accept an alliance invite again.", client)

		return
	end

	client.expAllianceInvites = client.expAllianceInvites or {}

	if (not client.expAllianceInvites[allianceId]) then
		ix.util.Notify("You do not have an invite to this alliance!", client)
		return
	end

	local alliance = client:GetAlliance()

	if (alliance) then
		ix.util.Notify("You are already in an alliance!", client)
		return
	end

	local canRun = Schema.alliance.AddMember(allianceId, client:GetCharacter():GetID(), client:GetCharacter():GetName(), RANK_RCT,
		function(success, reason)
			if (not IsValid(client)) then
				return
			end

			if (not success) then
				ix.util.Notify("Failed to join alliance: " .. reason, client)
				return
			end

			local inviter = client.expAllianceInvites[allianceId]

			if (IsValid(inviter)) then
				Schema.achievement.Progress("the_don", inviter, client:SteamID64())
				Schema.achievement.Progress("alliance_architect", inviter, client:SteamID64())
				ix.util.Notify(client:Name() .. " has accepted your invitation to join the '" .. inviter:GetAlliance().name .. "' alliance.", inviter)
			end

			client:SetAlliance({
				id = allianceId,
				name = allianceName,
			})
			client:SetAllianceRank(RANK_RCT)

			ix.util.Notify("You have joined the '" .. allianceName .. "' alliance.", client)
			ix.log.Add(client, "allianceJoined", allianceName)
			Schema.alliance.RequestSendMembersToAlliance(allianceId)
		end)

	if (not canRun) then
		ix.util.Notify("Somebody is already modifying the alliance members. Please wait a moment and try again.", client)
	end
end

net.Receive("AllianceRequestInviteAccept", function(length, client)
	local allianceId = net.ReadUInt(32)

	Schema.alliance.RequestInviteAccept(client, allianceId)
end)

function Schema.alliance.RequestInviteDecline(client, allianceId)
	if (Schema.util.Throttle("RequestInviteDecline", 5, client)) then
		ix.util.Notify("Please wait before trying to decline an alliance invite again.", client)

		return
	end

	client.expAllianceInvites = client.expAllianceInvites or {}

	if (not client.expAllianceInvites[allianceId]) then
		ix.util.Notify("You do not have an invite to this alliance!", client)
		return
	end

	local inviter = client.expAllianceInvites[allianceId]

	if (IsValid(inviter)) then
		ix.util.Notify(client:Name() .. " has declined your invitation to join the '" .. inviter:GetAlliance().name .. "' alliance.", inviter)
	end

	client.expAllianceInvites[allianceId] = nil

	ix.util.Notify("You have declined the invite to the alliance.", client)
	net.Start("AllianceInviteDeclined")
	net.WriteUInt(allianceId, 32)
	net.Send(client)
end

net.Receive("AllianceRequestInviteDecline", function(length, client)
	local allianceId = net.ReadUInt(32)

	Schema.alliance.RequestInviteDecline(client, allianceId)
end)

function Schema.alliance.RequestLeave(client)
	if (Schema.util.Throttle("RequestLeave", 5, client)) then
		ix.util.Notify("Please wait before trying to leave an alliance again.", client)

		return
	end

	local alliance = client:GetAlliance()

	if (not alliance) then
		ix.util.Notify("You are not in an alliance!", client)
		return
	end

	local canRun = Schema.alliance.RemoveMember(alliance.id, client:GetCharacter():GetID(), function(success, reason)
		if (not success) then
			ix.util.Notify("Failed to leave alliance: " .. reason, client)
			return
		end

		client:SetAlliance(nil)

		ix.util.Notify("You have left the '" .. alliance.name .. "' alliance.", client)
		ix.log.Add(client, "allianceLeft", alliance.name)
		Schema.alliance.RequestSendMembersToAlliance(alliance.id)
	end)

	if (not canRun) then
		ix.util.Notify("Somebody is already modifying the alliance members. Please wait a moment and try again.", client)
	end
end
