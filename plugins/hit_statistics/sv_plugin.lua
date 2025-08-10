local PLUGIN = PLUGIN

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

	-- Add weapon data
	for weapon, data in pairs(stats.weapons or {}) do
		table.insert(statsArray, {
			type = "weapon",
			weapon = weapon,
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

-- Record a hit with detailed information
function PLUGIN:RecordHit(attacker, hitData)
	local character = attacker:GetCharacter()
	if (not character) then
		return
	end

	local victimCharacter = hitData.victim:GetCharacter()
	local victimCharacterID = victimCharacter and victimCharacter:GetID() or nil

	local query = mysql:Insert("exp_player_hit_stats")
	query:Insert("character_id", character:GetID())
	query:Insert("steam_id", attacker:SteamID())
	query:Insert("victim_character_id", victimCharacterID)
	query:Insert("hitgroup", hitData.hitgroup)
	query:Insert("weapon_class", hitData.weapon)
	query:Insert("damage", hitData.damage)
	query:Insert("distance", hitData.distance)
	query:Insert("stat_type", "hit")
	query:Insert("value", 1)
	query:Insert("created_at", hitData.timestamp)
	query:Execute()

	-- Also increment total hits counter
	self:IncrementStat(attacker, "total_hits", 1)

	-- Track headshot hits specifically
	if (hitData.hitgroup == HITGROUP_HEAD) then
		self:IncrementStat(attacker, "headshot_hits", 1)
	end
end

-- Increment a simple stat counter
function PLUGIN:IncrementStat(client, statType, value)
	local character = client:GetCharacter()
	if (not character) then
		return
	end

	local query = mysql:Insert("exp_player_hit_stats")
	query:Insert("character_id", character:GetID())
	query:Insert("steam_id", client:SteamID())
	query:Insert("stat_type", statType)
	query:Insert("value", value)
	query:Insert("created_at", os.time())
	query:Execute()
end

-- Get player statistics for admin review
function PLUGIN:GetPlayerStats(steamID, callback)
	if (not self.hasDependantTables) then
		return false
	end

	local query = [[
		SELECT
			ps.stat_type,
			ps.hitgroup,
			ps.weapon_class,
			SUM(ps.value) as total_value,
			AVG(ps.damage) as avg_damage,
			AVG(ps.distance) as avg_distance,
			COUNT(*) as count
		FROM exp_player_hit_stats ps
		WHERE ps.steam_id = ']] .. steamID .. [['
		GROUP BY ps.stat_type, ps.hitgroup, ps.weapon_class
		ORDER BY ps.stat_type, total_value DESC;
	]]

	mysql:RawQuery(query, function(result)
		if (not result) then
			ix.util.SchemaErrorNoHaltWithStack("Failed to get player stats.")
			return
		end

		-- Process the raw data into a more useful format
		local stats = {
			accuracy = {},
			hitgroups = {},
			weapons = {},
			totals = {}
		}

		local totalShots = 0
		local totalHits = 0
		local headshotHits = 0

		for _, row in ipairs(result) do
			local statType = row.stat_type
			local value = tonumber(row.total_value) or 0

			if (statType == "shots_fired") then
				totalShots = totalShots + value
				stats.totals.shots_fired = totalShots
			elseif (statType == "total_hits") then
				totalHits = totalHits + value
				stats.totals.total_hits = totalHits
			elseif (statType == "headshot_hits") then
				headshotHits = headshotHits + value
				stats.totals.headshot_hits = headshotHits
			elseif (statType == "kills") then
				stats.totals.kills = value
			elseif (statType == "deaths") then
				stats.totals.deaths = value
			elseif (statType == "headshot_kills") then
				stats.totals.headshot_kills = value
			elseif (statType == "hit") then
				-- Detailed hit information
				local hitgroupName = self.hitgroupNames[row.hitgroup] or "Unknown"
				if (not stats.hitgroups[hitgroupName]) then
					stats.hitgroups[hitgroupName] = {
						hits = 0,
						avg_damage = 0,
						avg_distance = 0
					}
				end

				stats.hitgroups[hitgroupName].hits = stats.hitgroups[hitgroupName].hits + value
				stats.hitgroups[hitgroupName].avg_damage = tonumber(row.avg_damage) or 0
				stats.hitgroups[hitgroupName].avg_distance = tonumber(row.avg_distance) or 0

				-- Track weapon-specific stats
				local weaponClass = row.weapon_class or "unknown"
				if (not stats.weapons[weaponClass]) then
					stats.weapons[weaponClass] = {
						hits = 0,
						avg_damage = 0
					}
				end
				stats.weapons[weaponClass].hits = stats.weapons[weaponClass].hits + value
				stats.weapons[weaponClass].avg_damage = tonumber(row.avg_damage) or 0
			end
		end

		-- Calculate accuracy percentages
		if (totalShots > 0) then
			stats.accuracy.hit_rate = (totalHits / totalShots) * 100
		else
			stats.accuracy.hit_rate = 0
		end

		if (totalHits > 0) then
			stats.accuracy.headshot_rate = (headshotHits / totalHits) * 100
		else
			stats.accuracy.headshot_rate = 0
		end

		-- Calculate K/D ratio
		if (stats.totals.deaths and stats.totals.deaths > 0) then
			stats.totals.kd_ratio = (stats.totals.kills or 0) / stats.totals.deaths
		else
			stats.totals.kd_ratio = stats.totals.kills or 0
		end

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
	thresholds.min_shots = thresholds.min_shots or 100             -- Minimum shots to be considered
	thresholds.max_accuracy = thresholds.max_accuracy or 85        -- Accuracy above this is suspicious
	thresholds.max_headshot_rate = thresholds.max_headshot_rate or 60 -- Headshot rate above this is suspicious

	local query = [[
		SELECT
			ps.steam_id,
			p.steam_name,
			SUM(CASE WHEN ps.stat_type = 'shots_fired' THEN ps.value ELSE 0 END) as total_shots,
			SUM(CASE WHEN ps.stat_type = 'total_hits' THEN ps.value ELSE 0 END) as total_hits,
			SUM(CASE WHEN ps.stat_type = 'headshot_hits' THEN ps.value ELSE 0 END) as headshot_hits
		FROM exp_player_hit_stats ps
		LEFT JOIN ix_players p ON ps.steam_id = p.steamid
		GROUP BY ps.steam_id, p.steam_name
		HAVING total_shots >= ]] .. thresholds.min_shots .. [[
		ORDER BY (total_hits * 100.0 / total_shots) DESC;
	]]

	mysql:RawQuery(query, function(result)
		if (not result) then
			ix.util.SchemaErrorNoHaltWithStack("Failed to get suspicious players.")
			return
		end

		local suspiciousPlayers = {}

		for _, row in ipairs(result) do
			local totalShots = tonumber(row.total_shots) or 0
			local totalHits = tonumber(row.total_hits) or 0
			local headshotHits = tonumber(row.headshot_hits) or 0

			if (totalShots > 0) then
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
						steam_id = row.steam_id,
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

		callback(suspiciousPlayers)
	end)

	return true
end

Schema.chunkedNetwork.HandleRequest("PlayerHitStats", function(client, requestData)
	if (not client:IsAdmin()) then
		return
	end

	local steamID = requestData.steamID

	if (not steamID) then
		return
	end

	PLUGIN:GetPlayerStats(steamID, function(stats)
		local statsArray = PLUGIN:ConvertStatsToArray(stats)

		Schema.chunkedNetwork.Send("PlayerHitStats", client, statsArray, {
			steamID = steamID
		})
	end)
end)

-- Handle suspicious players requests
Schema.chunkedNetwork.HandleRequest("SuspiciousPlayers", function(client, requestData)
	if (not client:IsAdmin()) then
		return
	end

	local thresholds = requestData.thresholds or {}

	PLUGIN:GetSuspiciousPlayers(function(suspiciousPlayers)
		Schema.chunkedNetwork.Send("SuspiciousPlayers", client, suspiciousPlayers)
	end, thresholds)
end)

-- Handle players overview requests
Schema.chunkedNetwork.HandleRequest("PlayersOverview", function(client, requestData)
	if (not client:IsAdmin()) then
		return
	end

	PLUGIN:GetPlayersOverview(function(playersStats)
		Schema.chunkedNetwork.Send("PlayersOverview", client, playersStats)
	end)
end)

-- Get basic overview stats for all players
function PLUGIN:GetPlayersOverview(callback)
	if (not self.hasDependantTables) then
		return false
	end

	local query = [[
	SELECT
		ps.steam_id,
		p.steam_name,
		SUM(CASE WHEN ps.stat_type = 'shots_fired' THEN ps.value ELSE 0 END) as total_shots,
		SUM(CASE WHEN ps.stat_type = 'total_hits' THEN ps.value ELSE 0 END) as total_hits,
		SUM(CASE WHEN ps.stat_type = 'headshot_hits' THEN ps.value ELSE 0 END) as headshot_hits,
		SUM(CASE WHEN ps.stat_type = 'kills' THEN ps.value ELSE 0 END) as kills,
		SUM(CASE WHEN ps.stat_type = 'deaths' THEN ps.value ELSE 0 END) as deaths,
		SUM(CASE WHEN ps.stat_type = 'headshot_kills' THEN ps.value ELSE 0 END) as headshot_kills
	FROM exp_player_hit_stats ps
	LEFT JOIN ix_players p ON ps.steam_id = p.steamid
	GROUP BY ps.steam_id, p.steam_name
	HAVING total_shots > 0
	ORDER BY total_shots DESC;
]]

	mysql:RawQuery(query, function(result)
		if (not result) then
			ix.util.SchemaErrorNoHaltWithStack("Failed to get players overview.")
			callback({})
			return
		end

		local playersStats = {}

		for _, row in ipairs(result) do
			local totalShots = tonumber(row.total_shots) or 0
			local totalHits = tonumber(row.total_hits) or 0
			local headshotHits = tonumber(row.headshot_hits) or 0
			local kills = tonumber(row.kills) or 0
			local deaths = tonumber(row.deaths) or 0

			local accuracy = totalShots > 0 and (totalHits / totalShots) * 100 or 0
			local headshotRate = totalHits > 0 and (headshotHits / totalHits) * 100 or 0
			local kdRatio = deaths > 0 and (kills / deaths) or kills

			table.insert(playersStats, {
				steam_id = row.steam_id,
				steam_name = row.steam_name or "Unknown",
				total_shots = totalShots,
				total_hits = totalHits,
				headshot_hits = headshotHits,
				kills = kills,
				deaths = deaths,
				headshot_kills = tonumber(row.headshot_kills) or 0,
				accuracy = accuracy,
				headshot_rate = headshotRate,
				kd_ratio = kdRatio
			})
		end

		callback(playersStats)
	end)

	return true
end
