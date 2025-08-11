local PLUGIN = PLUGIN

local PERSONAL_ACCESS_TOKEN, GITHUB_OWNER_NAME, GITHUB_REPO_NAME, ISSUE_PREFIX

local REPORT_INTERVAL_MINUTES = 1

util.AddNetworkString("expBugReporterSubmit")
util.AddNetworkString("expBugReporterResponse")
util.AddNetworkString("expBugReporterOpen")

function PLUGIN:OnLoaded()
	local envFile = file.Read(PLUGIN.folder .. "/.env", "LUA")

	if (not envFile) then
		ix.util.SchemaErrorNoHalt("The .env file is missing from the bug reporter plugin folder.")
		self.disabled = true
		return
	end

	local variables = Schema.util.EnvToTable(envFile)

	PERSONAL_ACCESS_TOKEN = variables.PERSONAL_ACCESS_TOKEN
	GITHUB_OWNER_NAME = variables.GITHUB_OWNER_NAME
	GITHUB_REPO_NAME = variables.GITHUB_REPO_NAME
	ISSUE_PREFIX = variables.ISSUE_PREFIX or ""

	if (not PERSONAL_ACCESS_TOKEN or not GITHUB_OWNER_NAME or not GITHUB_REPO_NAME or not ISSUE_PREFIX) then
		ix.util.SchemaErrorNoHalt("Missing required environment variables in the bug reporter .env file.")
		self.disabled = true
		return
	end
end

function PLUGIN:MakeGitHubRequest(endpoint, data, callback)
	local url = "https://api.github.com" .. endpoint
	local headers = {
		["Authorization"] = "Bearer " .. PERSONAL_ACCESS_TOKEN,
		["Accept"] = "application/vnd.github+json",
		["X-GitHub-Api-Version"] = "2022-11-28"
	}

	HTTP({
		method = "POST",
		url = url,
		headers = headers,
		body = util.TableToJSON(data),
		type = "application/json",
		timeout = 60,
		success = function(code, body, responseHeaders)
			if (body and body ~= "") then
				local jsonResponse = util.JSONToTable(body)

				if (jsonResponse) then
					if (code == 201) then
						callback(true, jsonResponse)
					else
						callback(false, { error = "GitHub API returned status code " .. code, body = jsonResponse })
					end
				else
					callback(false, { error = "Invalid JSON response" })
				end
			else
				callback(false, { error = "No response from GitHub API" })
			end
		end,
		failed = function(reason)
			callback(false, { error = reason })
		end
	})
end

function PLUGIN:CreateGitHubIssue(bugData, callback)
	local luaErrors = bugData.luaErrors or {}
	local systemInfo = bugData.systemInfo or {}

	local luaErrorsFormatted = ""

	if (#luaErrors > 0) then
		luaErrorsFormatted = "### Lua Errors\n\n"
		for _, error in ipairs(luaErrors) do
			local stackFormatted = ""

			if (error.stack and #error.stack > 0) then
				for _, frame in ipairs(error.stack) do
					stackFormatted = stackFormatted ..
						string.format("- **%s**: %s (Line %d)\n", frame.File or "Unknown", frame.Function or "Unknown",
							frame.Line or -1)
				end
			else
				stackFormatted = "No stack trace available.\n"
			end

			luaErrorsFormatted = luaErrorsFormatted .. string.format("- **%s**: %s\n", error.name, error.error)
			luaErrorsFormatted = luaErrorsFormatted .. "  - **Realm**: " .. error.realm .. "\n"
			luaErrorsFormatted = luaErrorsFormatted .. "  - **Stack**: " .. stackFormatted .. "\n"
			luaErrorsFormatted = luaErrorsFormatted .. "  - **Timestamp**: " .. error.timestamp .. "\n\n"
		end
	else
		luaErrorsFormatted = "No Lua errors reported.\n\n"
	end

	local systemInfoFormatted = ""

	if (systemInfo and systemInfo ~= "") then
		systemInfoFormatted = "### System Information\n\n" .. systemInfo .. "\n\n"
	else
		systemInfoFormatted = "No system information provided.\n\n"
	end


	local body = string.format([[%s

## Steps to Reproduce
%s

## Additional Information
- **Reporter:** %s (%s)
- **Submitted:** %s
%s]],
		bugData.description,
		bugData.steps or "Not provided",
		bugData.playerName,
		bugData.steamID,
		bugData.timestamp,
		luaErrorsFormatted,
		systemInfoFormatted
	)

	local issueData = {
		title = (ISSUE_PREFIX or "") .. bugData.title,
		body = body,
		labels = {
			"bug",
			"from in-game",
		}
	}

	local endpoint = string.format("/repos/%s/%s/issues", GITHUB_OWNER_NAME, GITHUB_REPO_NAME)
	self:MakeGitHubRequest(endpoint, issueData, callback)
end

net.Receive("expBugReporterSubmit", function(len, client)
	local bugData = net.ReadTable()

	if (not bugData.title or not bugData.description) then
		net.Start("expBugReporterResponse")
		net.WriteBool(false)
		net.WriteString("Missing required fields")
		net.Send(client)
		return
	end

	-- Rate limiting (prevent spam)
	client.expLastBugReport = client.expLastBugReport or -REPORT_INTERVAL_MINUTES

	if (CurTime() - client.expLastBugReport < REPORT_INTERVAL_MINUTES) then
		net.Start("expBugReporterResponse")
		net.WriteBool(false)
		net.WriteString("Please wait before submitting another report")
		net.Send(client)
		return
	end

	client.expLastBugReport = CurTime()

	bugData.playerName = client:Nick()
	bugData.steamID = client:SteamID()
	bugData.timestamp = os.date("%Y-%m-%d %H:%M:%S")

	PLUGIN:CreateGitHubIssue(bugData, function(success, response)
		if (success) then
			net.Start("expBugReporterResponse")
			net.WriteBool(true)
			net.WriteString("Bug report submitted successfully!")
			net.Send(client)
		else
			PrintTable(response)
			ix.util.SchemaErrorNoHalt(string.format("[Bug Reporter] Failed to create GitHub issue: %s",
				response and util.TableToJSON(response, true) or "Unknown error"))

			net.Start("expBugReporterResponse")
			net.WriteBool(false)
			net.WriteString("Failed to submit to GitHub. Please try again later.")
			net.Send(client)
		end
	end)
end)
