local PLUGIN = PLUGIN

local API_KEY, APP_URL

-- On loading the plugin we will get the API_KEY that we can use to authenticate with the moderation API.
function PLUGIN:OnLoaded()
    local envFile = file.Read(PLUGIN.folder .. "/web/.env", "LUA")

    if (not envFile) then
        error("The .env file is missing from the web folder.")
    end

    local variables = Schema.util.EnvToTable(envFile)

    API_KEY = variables.API_SECRET
    APP_URL = variables.APP_URL
end

function PLUGIN:PostPlayerSay(client, chatType, message, anonymous)
    local character = client:GetCharacter()
    local ipAddress = client:IPAddress()

    -- Remove the port from the IP address
	ipAddress = ipAddress:match("([^:]+)")

	local data = {
		steam_id = client:SteamID64(),
        name = client:Name(),
        character_id = character and client:GetCharacter():GetID() or nil,
		ip_address = ipAddress,
		message = message,
		anonymous = anonymous,
	}

    self:PostJson("api/submit-chat-log", data, function(response)
        ix.util.SchemaPrint("Chatlog submitted successfully.")
	end, function(message)
		ix.util.SchemaErrorNoHaltWithStack("Failed to submit chatlog: " .. message)
	end)
end

function PLUGIN:PostJson(endpoint, data, onSuccess, onFailure)
    endpoint = APP_URL .. "/" .. endpoint

    print("Posting JSON to " .. endpoint)
	PrintTable(data)

    http.Post(endpoint, {
		json = util.TableToJSON(data),
	}, function(body, length, headers, code)
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
