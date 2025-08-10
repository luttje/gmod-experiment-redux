local PLUGIN = PLUGIN

-- In-memory storage for pending stats updates (will get commited to db on SaveData)
PLUGIN.pendingStats = PLUGIN.pendingStats or {}

-- Configuration for chunked data transmission
PLUGIN.ChunkMaxSizeHitStats = 50 -- Maximum number of stats entries per chunk
PLUGIN.ChunkDelayHitStats = 0.05 -- Delay between chunks in seconds

function PLUGIN:CheckHasDependantTables()
	if (self.isCheckingDependantTables) then
		return
	end

	self.isCheckingDependantTables = true

	local dependantTables = table.Copy(self.dependantTables)

	for i = 1, #dependantTables do
		dependantTables[i] = "'" .. dependantTables[i] .. "'"
	end

	local tablesConcat = table.concat(dependantTables, ", ")
	local query

	if (mysql.module == "mysqloo") then
		query = [[
			SELECT table_name
			FROM information_schema.tables
			WHERE table_name IN (]] .. tablesConcat .. [[);
		]]
	elseif (mysql.module == "sqlite") then
		query = [[
			SELECT name AS table_name
			FROM sqlite_master
			WHERE type='table' AND name IN (]] .. tablesConcat .. [[);
		]]
	else
		ix.util.SchemaError("Unsupported module \"%s\"!\n", mysql.module)
	end

	mysql:RawQuery(query, function(data)
		self.isCheckingDependantTables = nil

		if (not data) then
			ix.util.SchemaErrorNoHaltWithStack("Failed to check if dependant tables exist.")
			return
		end

		local count = 0

		for _, row in ipairs(data) do
			count = count + 1
		end

		self.hasDependantTables = count == #self.dependantTables
	end)
end

function PLUGIN:InitializePendingStats(characterID)
	if (not self.pendingStats[characterID]) then
		self.pendingStats[characterID] = {
			hits = {}
		}
	end
end

function PLUGIN:IncrementPendingStat(client, statType, value)
	local character = client:GetCharacter()

	if (not character) then
		return
	end

	local characterID = character:GetID()
	self:InitializePendingStats(characterID)

	if (not self.pendingStats[characterID][statType]) then
		self.pendingStats[characterID][statType] = 0
	end

	self.pendingStats[characterID][statType] = self.pendingStats[characterID][statType] + value
end

function PLUGIN:IncrementPendingHit(client, hitgroup)
	local character = client:GetCharacter()
	if (not character) then
		return
	end

	local characterID = character:GetID()
	self:InitializePendingStats(characterID)

	if (not self.pendingStats[characterID].hits[hitgroup]) then
		self.pendingStats[characterID].hits[hitgroup] = 0
	end

	self.pendingStats[characterID].hits[hitgroup] = self.pendingStats[characterID].hits[hitgroup] + 1
end

-- Helper function to get pending stats for a specific character by steam ID
function PLUGIN:GetPendingStatsBySteamID(steamID)
	for characterID, pendingStats in pairs(self.pendingStats) do
		local character = ix.char.loaded[characterID]
		if (character and character:GetPlayer():SteamID64() == steamID) then
			return pendingStats
		end
	end
	return nil
end

-- Helper function to merge pending stats into database results
function PLUGIN:MergePendingStats(dbStats, pendingStats)
	if (not pendingStats) then
		return dbStats
	end

	-- Merge basic stats
	if (pendingStats.shots_fired) then
		dbStats.total_shots = (dbStats.total_shots or 0) + pendingStats.shots_fired
	end

	if (pendingStats.kills) then
		dbStats.kills = (dbStats.kills or 0) + pendingStats.kills
	end

	if (pendingStats.deaths) then
		dbStats.deaths = (dbStats.deaths or 0) + pendingStats.deaths
	end

	if (pendingStats.headshot_kills) then
		dbStats.headshot_kills = (dbStats.headshot_kills or 0) + pendingStats.headshot_kills
	end

	-- Merge hitgroup stats
	if (pendingStats.hits) then
		for hitgroupID, count in pairs(pendingStats.hits) do
			local hitgroupName = self.hitgroupNames[hitgroupID]
			if (hitgroupName) then
				local columnName = "hits_" .. string.lower(string.gsub(hitgroupName, " ", ""))
				dbStats[columnName] = (dbStats[columnName] or 0) + count
			end
		end
	end

	return dbStats
end

--- Helper function to convert stats to array format for chunking
function PLUGIN:ConvertStatsToArray(stats)
	local statsArray = {}

	-- Add basic stats
	table.insert(statsArray, {
		type = "totals",
		data = stats.totals or {}
	})

	table.insert(statsArray, {
		type = "accuracy",
		data = stats.accuracy or {}
	})

	-- Add hitgroup data
	for hitgroup, data in pairs(stats.hitgroups or {}) do
		table.insert(statsArray, {
			type = "hitgroup",
			hitgroup = hitgroup,
			data = data
		})
	end

	return statsArray
end

function PLUGIN:Think()
	if (not self.hasDependantTables) then
		self:CheckHasDependantTables()
		return
	end
end

-- Get player statistics for admin review
function PLUGIN:GetPlayerStats(steamID, callback)
	if (not self.hasDependantTables) then
		return false
	end

	local query = [[
		SELECT
			ps.character_id,
			ps.steam_id,
			ps.total_shots,
			ps.hits_generic,
			ps.hits_head,
			ps.hits_chest,
			ps.hits_stomach,
			ps.hits_leftarm,
			ps.hits_rightarm,
			ps.hits_leftleg,
			ps.hits_rightleg,
			ps.hits_gear,
			ps.kills,
			ps.deaths,
			ps.headshot_kills
		FROM exp_player_hit_stats ps
		WHERE ps.steam_id = ']] .. steamID .. [['
	]]

	mysql:RawQuery(query, function(result)
		local dbRow = {}

		if (result and #result > 0) then
			dbRow = result[1]
		end

		-- Get pending stats for this player
		local pendingStats = self:GetPendingStatsBySteamID(steamID)

		-- Merge pending stats with database stats
		local mergedRow = self:MergePendingStats(dbRow, pendingStats)

		-- Calculate totals
		local totalShots = tonumber(mergedRow.total_shots) or 0
		local totalHits = 0
		local headshotHits = tonumber(mergedRow.hits_head) or 0
		local kills = tonumber(mergedRow.kills) or 0
		local deaths = tonumber(mergedRow.deaths) or 0
		local headshotKills = tonumber(mergedRow.headshot_kills) or 0

		-- Sum all hitgroup hits for total hits
		for hitgroupID, hitgroupName in pairs(self.hitgroupNames) do
			local columnName = "hits_" .. string.lower(string.gsub(hitgroupName, " ", ""))
			local hits = tonumber(mergedRow[columnName]) or 0
			totalHits = totalHits + hits
		end

		-- Build hitgroups data
		local hitgroups = {}
		for hitgroupID, hitgroupName in pairs(self.hitgroupNames) do
			local columnName = "hits_" .. string.lower(string.gsub(hitgroupName, " ", ""))
			local hits = tonumber(mergedRow[columnName]) or 0

			if (hits > 0) then
				hitgroups[hitgroupName] = {
					hits = hits,
					avg_damage = 0, -- No longer tracking individual hit damage
					avg_distance = 0 -- No longer tracking individual hit distance
				}
			end
		end

		-- Calculate accuracy percentages
		local hitRate = 0
		local headshotRate = 0
		local kdRatio = 0

		if (totalShots > 0) then
			hitRate = (totalHits / totalShots) * 100
		end

		if (totalHits > 0) then
			headshotRate = (headshotHits / totalHits) * 100
		end

		if (deaths > 0) then
			kdRatio = kills / deaths
		else
			kdRatio = kills
		end

		local stats = {
			accuracy = {
				hit_rate = hitRate,
				headshot_rate = headshotRate
			},
			hitgroups = hitgroups,
			totals = {
				shots_fired = totalShots,
				total_hits = totalHits,
				headshot_hits = headshotHits,
				kills = kills,
				deaths = deaths,
				headshot_kills = headshotKills,
				kd_ratio = kdRatio
			}
		}

		callback(stats)
	end)

	return true
end

-- Get suspicious players based on configurable thresholds
function PLUGIN:GetSuspiciousPlayers(callback, thresholds)
	if (not self.hasDependantTables) then
		return false
	end

	thresholds = thresholds or {}
	thresholds.min_shots = thresholds.min_shots or 100
	thresholds.max_accuracy = thresholds.max_accuracy or 85
	thresholds.max_headshot_rate = thresholds.max_headshot_rate or 60

	local query = [[
		SELECT
			ps.steam_id,
			p.steam_name,
			ps.total_shots,
			(ps.hits_generic + ps.hits_head + ps.hits_chest + ps.hits_stomach +
			 ps.hits_leftarm + ps.hits_rightarm + ps.hits_leftleg + ps.hits_rightleg + ps.hits_gear) as total_hits,
			ps.hits_head as headshot_hits
		FROM exp_player_hit_stats ps
		LEFT JOIN ix_players p ON ps.steam_id = p.steamid
		WHERE ps.total_shots >= 0
		ORDER BY (total_hits * 100.0 / GREATEST(ps.total_shots, 1)) DESC
	]]

	mysql:RawQuery(query, function(result)
		if (not result) then
			ix.util.SchemaErrorNoHaltWithStack("Failed to get suspicious players.")
			callback({})
			return
		end

		local suspiciousPlayers = {}

		-- Process database results
		for _, row in ipairs(result) do
			local steamID = row.steam_id
			local pendingStats = self:GetPendingStatsBySteamID(steamID)
			local mergedRow = self:MergePendingStats(row, pendingStats)

			local totalShots = tonumber(mergedRow.total_shots) or 0
			local totalHits = tonumber(mergedRow.total_hits) or 0
			local headshotHits = tonumber(mergedRow.headshot_hits) or 0

			-- Recalculate total hits from individual hitgroups to account for pending stats
			if (pendingStats and pendingStats.hits) then
				totalHits = 0
				for hitgroupID, hitgroupName in pairs(self.hitgroupNames) do
					local columnName = "hits_" .. string.lower(string.gsub(hitgroupName, " ", ""))
					local hits = tonumber(mergedRow[columnName]) or 0
					totalHits = totalHits + hits
				end
			end

			if (totalShots >= thresholds.min_shots) then
				local accuracy = (totalHits / totalShots) * 100
				local headshotRate = totalHits > 0 and (headshotHits / totalHits) * 100 or 0

				local suspicionReasons = {}

				if (accuracy > thresholds.max_accuracy) then
					table.insert(suspicionReasons, string.format("High accuracy: %.1f%%", accuracy))
				end

				if (headshotRate > thresholds.max_headshot_rate) then
					table.insert(suspicionReasons, string.format("High headshot rate: %.1f%%", headshotRate))
				end

				if (#suspicionReasons > 0) then
					table.insert(suspiciousPlayers, {
						steam_id = steamID,
						steam_name = row.steam_name or "Unknown",
						accuracy = accuracy,
						headshot_rate = headshotRate,
						total_shots = totalShots,
						total_hits = totalHits,
						reasons = suspicionReasons
					})
				end
			end
		end

		-- Also check players who only have pending stats (no database records yet)
		for characterID, pendingStats in pairs(self.pendingStats) do
			local character = ix.char.loaded[characterID]
			if (character) then
				local client = character:GetPlayer()
				local steamID = client:SteamID64()

				-- Skip if this player was already processed from database
				local foundInDb = false
				for _, row in ipairs(result) do
					if (row.steam_id == steamID) then
						foundInDb = true
						break
					end
				end

				if (not foundInDb) then
					local totalShots = pendingStats.shots_fired or 0
					local totalHits = 0
					local headshotHits = 0

					if (pendingStats.hits) then
						for hitgroupID, hits in pairs(pendingStats.hits) do
							totalHits = totalHits + hits
							if (hitgroupID == HITGROUP_HEAD) then
								headshotHits = hits
							end
						end
					end

					if (totalShots >= thresholds.min_shots) then
						local accuracy = (totalHits / totalShots) * 100
						local headshotRate = totalHits > 0 and (headshotHits / totalHits) * 100 or 0

						local suspicionReasons = {}

						if (accuracy > thresholds.max_accuracy) then
							table.insert(suspicionReasons, string.format("High accuracy: %.1f%%", accuracy))
						end

						if (headshotRate > thresholds.max_headshot_rate) then
							table.insert(suspicionReasons, string.format("High headshot rate: %.1f%%", headshotRate))
						end

						if (#suspicionReasons > 0) then
							table.insert(suspiciousPlayers, {
								steam_id = steamID,
								steam_name = client:Name() or "Unknown",
								accuracy = accuracy,
								headshot_rate = headshotRate,
								total_shots = totalShots,
								total_hits = totalHits,
								reasons = suspicionReasons
							})
						end
					end
				end
			end
		end

		callback(suspiciousPlayers)
	end)

	return true
end

-- Get basic overview stats for all players
function PLUGIN:GetPlayersOverview(callback)
	if (not self.hasDependantTables) then
		return false
	end

	local query = [[
		SELECT
			ps.steam_id,
			p.steam_name,
			ps.total_shots,
			(ps.hits_generic + ps.hits_head + ps.hits_chest + ps.hits_stomach +
			 ps.hits_leftarm + ps.hits_rightarm + ps.hits_leftleg + ps.hits_rightleg + ps.hits_gear) as total_hits,
			ps.hits_head as headshot_hits,
			ps.kills,
			ps.deaths,
			ps.headshot_kills
		FROM exp_player_hit_stats ps
		LEFT JOIN ix_players p ON ps.steam_id = p.steamid
		WHERE ps.total_shots >= 0
		ORDER BY ps.total_shots DESC
	]]

	mysql:RawQuery(query, function(result)
		if (not result) then
			ix.util.SchemaErrorNoHaltWithStack("Failed to get players overview.")
			callback({})
			return
		end

		local playersStats = {}

		-- Process database results
		for _, row in ipairs(result) do
			local steamID = row.steam_id
			local pendingStats = self:GetPendingStatsBySteamID(steamID)
			local mergedRow = self:MergePendingStats(row, pendingStats)

			local totalShots = tonumber(mergedRow.total_shots) or 0
			local totalHits = tonumber(mergedRow.total_hits) or 0
			local headshotHits = tonumber(mergedRow.headshot_hits) or 0
			local kills = tonumber(mergedRow.kills) or 0
			local deaths = tonumber(mergedRow.deaths) or 0
			local headshotKills = tonumber(mergedRow.headshot_kills) or 0

			-- Recalculate total hits from individual hitgroups to account for pending stats
			if (pendingStats and pendingStats.hits) then
				totalHits = 0
				headshotHits = 0
				for hitgroupID, hitgroupName in pairs(self.hitgroupNames) do
					local columnName = "hits_" .. string.lower(string.gsub(hitgroupName, " ", ""))
					local hits = tonumber(mergedRow[columnName]) or 0
					totalHits = totalHits + hits
					if (hitgroupID == HITGROUP_HEAD) then
						headshotHits = hits
					end
				end
			end

			local accuracy = totalShots > 0 and (totalHits / totalShots) * 100 or 0
			local headshotRate = totalHits > 0 and (headshotHits / totalHits) * 100 or 0
			local kdRatio = deaths > 0 and (kills / deaths) or kills

			if (totalShots > 0) then -- Only include players with shots`
				table.insert(playersStats, {
					steam_id = steamID,
					steam_name = row.steam_name or "Unknown",
					total_shots = totalShots,
					total_hits = totalHits,
					headshot_hits = headshotHits,
					kills = kills,
					deaths = deaths,
					headshot_kills = headshotKills,
					accuracy = accuracy,
					headshot_rate = headshotRate,
					kd_ratio = kdRatio
				})
			end
		end

		-- Also include players who only have pending stats (no database records yet)
		for characterID, pendingStats in pairs(self.pendingStats) do
			local character = ix.char.loaded[characterID]
			if (character) then
				local client = character:GetPlayer()
				local steamID = client:SteamID64()

				-- Skip if this player was already processed from database
				local foundInDb = false
				for _, playerStat in ipairs(playersStats) do
					if (playerStat.steam_id == steamID) then
						foundInDb = true
						break
					end
				end

				if (not foundInDb) then
					local totalShots = pendingStats.shots_fired or 0
					local totalHits = 0
					local headshotHits = 0
					local kills = pendingStats.kills or 0
					local deaths = pendingStats.deaths or 0
					local headshotKills = pendingStats.headshot_kills or 0

					if (pendingStats.hits) then
						for hitgroupID, hits in pairs(pendingStats.hits) do
							totalHits = totalHits + hits
							if (hitgroupID == HITGROUP_HEAD) then
								headshotHits = hits
							end
						end
					end

					local accuracy = totalShots > 0 and (totalHits / totalShots) * 100 or 0
					local headshotRate = totalHits > 0 and (headshotHits / totalHits) * 100 or 0
					local kdRatio = deaths > 0 and (kills / deaths) or kills

					if (totalShots > 0) then -- Only include players with shots
						table.insert(playersStats, {
							steam_id = steamID,
							steam_name = client:Name() or "Unknown",
							total_shots = totalShots,
							total_hits = totalHits,
							headshot_hits = headshotHits,
							kills = kills,
							deaths = deaths,
							headshot_kills = headshotKills,
							accuracy = accuracy,
							headshot_rate = headshotRate,
							kd_ratio = kdRatio
						})
					end
				end
			end
		end

		-- Sort by total shots descending
		table.sort(playersStats, function(a, b)
			return a.total_shots > b.total_shots
		end)

		callback(playersStats)
	end)

	return true
end

Schema.chunkedNetwork.HandleRequest("PlayerHitStats", function(client, respond, requestData)
	if (not client:IsAdmin()) then
		return
	end

	local steamID = requestData.steamID

	if (not steamID) then
		return
	end

	PLUGIN:GetPlayerStats(steamID, function(stats)
		local statsArray = PLUGIN:ConvertStatsToArray(stats)

		respond(statsArray, {
			steamID = steamID
		})
	end)
end)

-- Handle suspicious players requests
Schema.chunkedNetwork.HandleRequest("SuspiciousPlayers", function(client, respond, requestData)
	if (not client:IsAdmin()) then
		return
	end

	local thresholds = requestData.thresholds or {}

	PLUGIN:GetSuspiciousPlayers(function(suspiciousPlayers)
		respond(suspiciousPlayers, {
			steamID = steamID
		})
	end, thresholds)
end)

-- Handle players overview requests
Schema.chunkedNetwork.HandleRequest("PlayersOverview", function(client, respond, requestData)
	if (not client:IsAdmin()) then
		return
	end

	PLUGIN:GetPlayersOverview(function(playersStats)
		respond(playersStats, {})
	end)
end)
