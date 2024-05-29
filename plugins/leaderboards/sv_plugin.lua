local PLUGIN = PLUGIN

local API_KEY, APP_URL
local MYSQL_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"
local LAST_SUBMITTED_DATE_FILE = "leaderboards_last_submitted_day.txt"

PLUGIN.metrics = PLUGIN.metrics or {}
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
            self.metrics[name] = createMetricHandler(result[1].metric_id, result[1].name, result[1].description)
		else
			query = mysql:Insert("exp_metrics")
			query:Insert("name", name)
            query:Insert("description", description)
			query:Insert("created_at", os.time())
            query:Callback(function(data, status, lastID)
				self.metrics[name] = createMetricHandler(lastID, name, description)
            end)
			query:Execute()
		end
    end)
	query:Execute()
end

-- lua_run ix.plugin.Get("leaderboards"):SubmitMetrics()
function PLUGIN:SubmitMetrics()
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
        {
            name = "metrics",
            table = "exp_metrics",
            columns = {
                metric_id = "id",
                "name",
                "description",
            },
        }
    }
    local queriedData = {}

    self.isQueryingData = {
        dataToQuery = dataToQuery,
        queriedData = queriedData,
        timeoutAt = CurTime() + 10,
		forDay = os.date("*t").day,
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

	local lastSubmittedDay = self.lastSubmittedDay
	local currentDate = os.date("*t")

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

		-- Register the metrics so that we can log them, e.g: PLUGIN.metrics["Kills"]:Log(character, 5)
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
			"Kills",
			"The number of other players killed by a player."
		)
		self:RegisterOrGetMetric(
			"Bolts Stolen",
			"The number of bolts stolen by a player."
		)
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

    if (#dataToQuery ~= #self.isQueryingData.queriedData) then
		return
	end

	local data = {}

	for i = 1, #dataToQuery do
		local queryData = dataToQuery[i]
		local queriedData = queriedData[i]

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

    self.isQueryingData = nil

    local forDay = self.isQueryingData.forDay

    self:PostJson("api/submit-metrics", data, function(response)
        ix.util.SchemaPrint("Metrics submitted successfully for day " .. tostring(forDay))
        file.Write(LAST_SUBMITTED_DATE_FILE, tostring(forDay))
		self.lastSubmittedDay = forDay
		self.isSubmittingMetrics = nil
	end, function(message)
		ix.util.SchemaErrorNoHalt("Failed to submit metrics." .. tostring(message))
		self.lastSubmittedDay = forDay -- So it doesnt keep retrying
		self.isSubmittingMetrics = nil
	end)
end

function PLUGIN:PostJson(endpoint, data, onSuccess, onFailure)
    endpoint = APP_URL .. endpoint

    http.Post(endpoint, {
		json = util.TableToJSON(data),
    }, function(body, length, headers, code)
		if (code ~= 200) then
			if (onFailure) then
				onFailure("HTTP code " .. code)
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
