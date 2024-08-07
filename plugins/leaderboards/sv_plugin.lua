local PLUGIN = PLUGIN

local API_KEY, APP_URL
local MYSQL_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"
local LAST_SUBMITTED_DATE_FILE = "leaderboards_last_submitted_day.txt"

PLUGIN.metrics = PLUGIN.metrics or {}
PLUGIN.metricsLookup = PLUGIN.metricsLookup or {}
PLUGIN.dependantTables = {
	"ix_characters",
	"ix_players",

	"exp_alliances",
	"exp_character_metrics",
	"exp_metrics",
}

-- On loading the plugin we will get the API_KEY that we can use to authenticate with the Leaderboards API.
function PLUGIN:OnLoaded()
    local envFile = file.Read(PLUGIN.folder .. "/web/.env", "LUA")

    if (not envFile) then
        ix.util.SchemaErrorNoHalt("The .env file is missing from the web folder for Leaderboards.")
        self.disabled = true
        return
    end

    local variables = Schema.util.EnvToTable(envFile)

    API_KEY = variables.API_SECRET
    APP_URL = Schema.util.ForceEndPath(variables.APP_URL)
end

function PLUGIN:RegisterMetrics()
	self:RegisterOrGetMetric(
		"Bolts Generated",
		"The number of bolts generated by a player."
	)
	self:RegisterOrGetMetric(
		"Successfully Defended",
		"The number of times a player has successfully defended themselves."
	)
	self:RegisterOrGetMetric(
		"Healing Done",
		"The amount of healing a player has done."
	)
	self:RegisterOrGetMetric(
		"Healing Received",
		"The amount of healing a player has received."
	)
	self:RegisterOrGetMetric(
		"Bolts Spent",
		"The number of bolts spent by a player."
	)
	self:RegisterOrGetMetric(
		"Locker Rot Kills",
		"The number of players killed that were infected by Locker Rot."
	)
	self:RegisterOrGetMetric(
		"Monster Damage",
		"The number of damage dealt to monsters."
	)
end

function PLUGIN:IncrementMetric(client, name, value)
	local metric = self.metrics[name]

    if (not metric) then
        ix.util.SchemaError("Attempted to increment a metric that does not exist: " .. name)
    end

	metric:Log(client, value)
end

function PLUGIN:DatabaseConnected()
    local query

    query = mysql:Create("exp_metrics")
    query:Create("metric_id", "INT(11) UNSIGNED NOT NULL AUTO_INCREMENT")
    query:Create("name", "VARCHAR(32) NOT NULL")
    query:Create("description", "TEXT NOT NULL")
    query:Create("created_at", "INT(11) UNSIGNED NOT NULL")
	query:PrimaryKey("metric_id")
    query:Execute()

    query = mysql:Create("exp_character_metrics")
    query:Create("character_metric_id", "INT(11) UNSIGNED NOT NULL AUTO_INCREMENT")
    query:Create("character_id", "INT(11) UNSIGNED NOT NULL")
    query:Create("alliance_id", "INT(11) UNSIGNED")
    query:Create("metric_id", "INT(11) UNSIGNED NOT NULL")
    query:Create("value", "INT(11) UNSIGNED NOT NULL")
    query:Create("created_at", "INT(11) UNSIGNED NOT NULL")
    query:PrimaryKey("character_metric_id")
	query:Execute()
end

function PLUGIN:OnWipeTables()
	local query

	query = mysql:Drop("exp_metrics")
	query:Execute()

	query = mysql:Drop("exp_character_metrics")
	query:Execute()
end

function PLUGIN:RegisterOrGetMetric(name, description)
    local query

    local function createMetricHandler(id, name, description)
        return {
			id = id,
			name = name,
            description = description,

            Log = function(self, client, value)
                local alliance = client:GetAlliance()
                local character = client:GetCharacter()

				if (not character) then
					return
				end

				local query = mysql:Insert("exp_character_metrics")
                query:Insert("character_id", character:GetID())

                if (alliance) then
                    query:Insert("alliance_id", alliance.id)
                end

				query:Insert("metric_id", self.id)
				query:Insert("value", value)
				query:Insert("created_at", os.time())
				query:Execute()
			end,
		}
	end

    query = mysql:Select("exp_metrics")
    query:Select("metric_id")
    query:Select("name")
    query:Select("description")
    query:Where("name", name)
	query:Callback(function(result)
        if (#result > 0) then
			local metric = result[1]
            self.metrics[name] = createMetricHandler(metric.metric_id, metric.name, metric.description)
			self.metricsLookup[metric.metric_id] = self.metrics[name]
		else
			query = mysql:Insert("exp_metrics")
			query:Insert("name", name)
            query:Insert("description", description)
			query:Insert("created_at", os.time())
            query:Callback(function(data, status, lastID)
                self.metrics[name] = createMetricHandler(lastID, name, description)
				self.metricsLookup[lastID] = self.metrics[name]
            end)
			query:Execute()
		end
    end)
	query:Execute()
end

-- lua_run ix.plugin.Get("leaderboards"):SubmitMetrics(true) -- To print it instead of submitting it
function PLUGIN:SubmitMetrics(isDryRun)
    self.isSubmittingMetrics = true

    local dataToQuery = {
        {
            name = "epoch",
            value = self.currentEpoch,
        },
        {
            name = "players",
            table = "ix_players",
            values = {
                opt_out_leaderboard_at = function(rowData)
                    -- local optedOutAt = rowData.data and rowData.data.optedOutOfLeaderboardsAt or nil
                    -- test unix
                    local optedOutAt = 1640000000

                    -- Don't send all data to the API
                    rowData.data = nil

                    return optedOutAt and os.date(MYSQL_DATE_FORMAT, optedOutAt) or nil
                end,
            },
            columns = {
                "steam_name",
                steamid = "steam_id",
                "data", -- Only for getting opt out
            },
        },
        {
            name = "characters",
            table = "ix_characters",
            columns = {
                "id",
                "name",
                steamid = "steam_id",
            },
        },
        {
            name = "character_metrics",
            table = "exp_character_metrics",
            columns = {
                character_metric_id = "id",
                "character_id",
                "alliance_id",
                "metric_id",
                "value",
            },
        },
        {
            name = "alliances",
            table = "exp_alliances",
            columns = {
                alliance_id = "id",
                "name",
            },
        },
    }
    local queriedData = {}

    self.isQueryingData = {
        dataToQuery = dataToQuery,
        queriedData = queriedData,
        timeoutAt = CurTime() + 10,
		forDay = os.date("*t").day,
		isDryRun = isDryRun,
    }

    for _, data in ipairs(dataToQuery) do
        if (data.value) then
            queriedData[#queriedData + 1] = data.value
        end

        if (not data.table) then
            continue
        end

        local query = mysql:Select(data.table)

        for column, key in pairs(data.columns) do
            if (type(column) == "number") then
                column = key
            end

            query:Select(column)
        end

        query:Callback(function(result)
            queriedData[#queriedData + 1] = result
        end)

        query:Execute()
    end
end

function PLUGIN:ShouldSubmitMetrics()
	if (self.isSubmittingMetrics) then
		return false
	end

    if (self.hasSubmittedFinalMetrics) then
        return false
    end

    local currentDate = os.date("*t")
	local epochEndDateAndTime = string.Explode(" ", self.currentEpoch.ends_at)
    local epochEndDateString = epochEndDateAndTime[1]
    local currentDateStr = currentDate.year .. "-" .. currentDate.month .. "-" .. currentDate.day

    if (currentDateStr == epochEndDateString) then
        local epochEndTime = string.Explode(":", epochEndDateAndTime[2])
        local epochEndHour = tonumber(epochEndTime[1])
        local epochEndMinute = tonumber(epochEndTime[2])

        -- If the current time is past the epoch end time, submit the metrics if they haven't been submitted yet
        if (currentDate.hour > epochEndHour or (currentDate.hour == epochEndHour and currentDate.min >= epochEndMinute)) then
			if (not self.hasSubmittedFinalMetrics) then
				self.hasSubmittedFinalMetrics = true
				return true
			end
		end
	end

	local lastSubmittedDay = self.lastSubmittedDay

	if (not lastSubmittedDay) then
		lastSubmittedDay = file.Read(LAST_SUBMITTED_DATE_FILE, "DATA") or -1
		lastSubmittedDay = tonumber(lastSubmittedDay) or -1
	end

	if (currentDate.day == lastSubmittedDay) then
		self.lastSubmittedDay = lastSubmittedDay
		return false
	end

	print("Should submit metrics for day " ..
	currentDate.day .. " because last submitted day was " .. tostring(lastSubmittedDay))
	return true
end

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

		self.hasDependantTables = count == #dependantTables
	end)
end

function PLUGIN:Think()
    if (self.disabled) then
        return
    end

    if (not self.hasDependantTables) then
        self:CheckHasDependantTables()
        return
    end

    if (not self.hasRegisteredMetrics) then
        self.hasRegisteredMetrics = true

        self:RegisterMetrics()
    end

    if (self:ShouldSubmitMetrics()) then
        self:SubmitMetrics()
    end

    if (not self.isQueryingData) then
        return
    end

    if (CurTime() > self.isQueryingData.timeoutAt) then
        ix.util.SchemaErrorNoHaltWithStack("Failed to query data for metrics. Timeout reached.")
        self.isQueryingData = nil
        self.isSubmittingMetrics = nil -- TODO: Do not endlessly retry
        return
    end

    local dataToQuery = self.isQueryingData.dataToQuery
    local currentQueriedData = self.isQueryingData.queriedData

    if (#dataToQuery ~= #currentQueriedData) then
        return
    end

    local data = {}

    for i = 1, #dataToQuery do
        local queryData = dataToQuery[i]
        local queriedData = currentQueriedData[i]

        if (queryData.value) then
            data[queryData.name] = queryData.value
        end

        if (not queryData.table) then
            continue
        end

        data[queryData.name] = {}

        for _, row in ipairs(queriedData) do
            local rowData = {}

            for column, key in pairs(queryData.columns) do
                if (type(column) == "number") then
                    column = key
                end

                rowData[key] = row[column]
            end

            for key, valueGetter in pairs(queryData.values or {}) do
                rowData[key] = valueGetter(rowData)
            end

            data[queryData.name][#data[queryData.name] + 1] = rowData
        end
    end

    -- Append all metrics to the data, clearing the keys and Log function
    data.metrics = {}

    for name, metric in pairs(self.metrics) do
        data.metrics[#data.metrics + 1] = {
            id = metric.id,
            name = metric.name,
            description = metric.description,
        }
    end

    local forDay = self.isQueryingData.forDay
    local isDryRun = self.isQueryingData.isDryRun
    self.isQueryingData = nil

    if (isDryRun) then
        ix.util.SchemaPrint("(Dry Run) Metrics for day " .. tostring(forDay) .. ":")
        PrintTable(data)
        return
    end

    self:PostJson("api/submit-metrics", data, function(response)
        ix.util.SchemaPrint("Metrics submitted successfully for day " .. tostring(forDay))
        file.Write(LAST_SUBMITTED_DATE_FILE, tostring(forDay))
        self.lastSubmittedDay = forDay
        self.isSubmittingMetrics = nil
    end, function(message, body)
        ix.util.SchemaErrorNoHalt("Failed to submit metrics. " .. tostring(message) .. "\n" .. tostring(body) .. "\n")
        self.lastSubmittedDay = forDay -- So it doesnt keep retrying
        self.isSubmittingMetrics = nil
    end)
end

-- Query the metrics so it can be used to figure out who's leading in what.
-- Can fail if the server hasn't loaded fully yet.
function PLUGIN:GetTopCharacters(callback)
	if (self.disabled or not self.hasDependantTables) then
        return
    end

	local query = [[
		SELECT character_id, metric_id, SUM(value) AS total_value
		FROM exp_character_metrics
		GROUP BY character_id, metric_id
		ORDER BY metric_id, total_value DESC
		LIMIT 10;
	]]

	mysql:RawQuery(query, function(result)
		if (not result) then
			ix.util.SchemaErrorNoHaltWithStack("Failed to get top characters.")
			return
		end

		local metricInfo = {}

		-- Sum up the metrics for each character, keeping track of the top 10 for each metric.
		for _, row in ipairs(result) do
			local characterID = row.character_id
			local metricID = row.metric_id
			local totalValue = row.total_value

			if (not metricInfo[metricID]) then
                metricInfo[metricID] = {
                    name = self.metricsLookup[metricID].name,
					topCharacters = {},
				}
			end

			table.insert(metricInfo[metricID].topCharacters, { character_id = characterID, value = totalValue })
		end

		callback(metricInfo)
	end)
end

function PLUGIN:PostJson(endpoint, data, onSuccess, onFailure)
    endpoint = APP_URL .. endpoint

    http.Post(endpoint, {
		json = util.TableToJSON(data),
    }, function(body, length, headers, code)
		if (code ~= 200) then
			if (onFailure) then
				onFailure("HTTP code " .. code, body)
			end

			return
		end

		if (onSuccess) then
			onSuccess({
				body = body,
				length = length,
				headers = headers,
				status = code,
			})
		end
	end, function(message)
		if (onFailure) then
			onFailure(message)
		end
    end, {
		-- ! Do not uncomment this, with it, sometimes GMod will doubly set the Content-Type header (e.g: `application/x-www-form-urlencoded, application/x-www-form-urlencoded`) Bug?!
		-- ["Content-Type"] = "application/x-www-form-urlencoded",
        ["X-Api-Secret"] = API_KEY,
		["Accept"] = "application/json",
	})
end

do
	local COMMAND = {}

	COMMAND.description = "Wipe all character data, temporarily keeping a backup by renaming the tables."
	COMMAND.superAdminOnly = true

    function COMMAND:OnRun(client, pattern)
        local timestamp = os.time()
		local tablesToBackup = {
			"ix_characters",
            "ix_inventories",
			"ix_items",
            "ix_players",

			"exp_alliances",
			"exp_character_metrics",
			"exp_metrics",
        }
        local tablesWiped = 0

        -- Ensure all players are disconnected before wiping the tables.
        for _, otherClient in ipairs(player.GetAll()) do
            otherClient:Kick("Resetting data.")
        end

		RunConsoleCommand("sv_password", math.random(0, math.huge))

        -- Copy the tables to {timestamp}_backup_{table_name} and then truncate the original table.
        for _, tableName in ipairs(tablesToBackup) do
            local backupTableName = timestamp .. "_backup_" .. tableName

            mysql:RawQuery(
				"CREATE TABLE " .. backupTableName .. " AS SELECT * FROM " .. tableName .. ";",
                function(data)
                    client:Notify("Backed up table " .. tableName .. " to " .. backupTableName)

                    local query = mysql:Truncate(tableName)
					query:Callback(function(data)
						tablesWiped = tablesWiped + 1

						if (tablesWiped == #tablesToBackup) then
                            client:Notify("Wiped all tables.")

                            -- Wipe the cache and loaded characters
                            ix.char.cache = {}
                            ix.char.loaded = {}

							Schema.util.ReloadMap()
						end
                    end)
					query:Execute()
				end
			)
		end
	end

	ix.command.Add("LeaderboardWipeData", COMMAND)
end

do
    local COMMAND = {}

    COMMAND.description = "Remove all backup tables."
    COMMAND.superAdminOnly = true

    function COMMAND:OnRun(client)
        local query

		if (mysql.module == "mysqloo") then
			query = [[
				SELECT table_name AS name
				FROM information_schema.tables
				WHERE table_name LIKE '%_backup_%'
				AND table_schema = ']] .. ix.db.config.database .. [[';
			]]
		elseif (mysql.module == "sqlite") then
			query = [[
				SELECT name
				FROM sqlite_master
				WHERE type='table' AND name LIKE '%_backup_%';
			]]
		else
			ix.util.SchemaError("Unsupported module \"%s\"!\n", mysql.module)
		end

        mysql:RawQuery(
            query,
            function(data)
                if (not data) then
                    client:Notify("No backup tables found.")
                    return
                end

                for _, row in ipairs(data) do
                    local tableName = row.name

                    mysql:RawQuery("DROP TABLE " .. tableName .. ";", function(_)
                        client:Notify("Dropped table " .. tableName)
                    end)
                end
            end
        )
    end

	ix.command.Add("LeaderboardRemoveBackups", COMMAND)
end

do
	local COMMAND = {}

	COMMAND.description = "Force the submission of metrics."
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client)
		if (PLUGIN.disabled) then
			client:Notify("Leaderboards are disabled.")
			return
		end

		if (not PLUGIN.hasDependantTables) then
			client:Notify("Dependant tables are not created.")
			return
		end

		if (self.isSubmittingMetrics) then
			client:Notify("Already submitting metrics.")
			return
		end

		PLUGIN:SubmitMetrics()
	end

	ix.command.Add("LeaderboardSubmitMetrics", COMMAND)
end
