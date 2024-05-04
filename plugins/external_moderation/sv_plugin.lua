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

    if (eightbit) then
		return
	end

	local success, errorMessage = pcall(function()
		require("eightbit")

		if (not eightbit) then
			-- https://github.com/Meachamp/gm_8bit
			ix.util.SchemaErrorNoHalt("The eightbit library is missing. Please ensure it is installed.")
		end

		eightbit.SetBroadcastIP("127.0.0.1")
		eightbit.SetBroadcastPort(4000)
		eightbit.EnableBroadcast(true)
    end)

	if (not success) then
		ix.util.SchemaErrorNoHaltWithStack("Failed to load eightbit: " .. errorMessage)
	end
end

-- When the player uses normal chat, we send the chat log to the moderation API.
function PLUGIN:PostPlayerSay(client, chatType, message, anonymous)
    local character = client:GetCharacter()
    local ipAddress = Schema.util.GetPlayerAddress(client).ip

    local data = {
		chat_type = chatType,
        steam_id = client:SteamID64(),
        steam_name = client:Name(),
		character_name = character and character:GetName() or nil,
        character_id = character and client:GetCharacter():GetID() or nil,
        ip_address = ipAddress,
        message = message,
    }

    self:PostJson("api/submit-chat-log", data, function(response)
        ix.util.SchemaPrint("Chatlog submitted successfully.")
    end, function(message)
        ix.util.SchemaErrorNoHaltWithStack("Failed to submit chatlog: " .. message)
    end)
end

-- When the player changes character, we inform the moderation API so it knows which character the player is currently using.
-- This is especially needed for Voice Chat moderation, since that only receives the SteamID64 of the player.
function PLUGIN:PlayerLoadedCharacter(client, character)
    local ipAddress = Schema.util.GetPlayerAddress(client).ip

    local data = {
        steam_id = client:SteamID64(),
        steam_name = client:Name(),
		character_name = character:GetName(),
        character_id = character:GetID(),
        ip_address = ipAddress,
    }

    self:PostJson("api/submit-player-info", data, function(response)
        ix.util.SchemaPrint("Character info submitted successfully.")
    end, function(message)
        ix.util.SchemaErrorNoHaltWithStack("Failed to submit character info: " .. message)
    end)
end

-- Same as with PlayerLoadedCharacter, but when we know the player IP, name and SteamID64, we can already inform the moderation API.
gameevent.Listen("player_connect")
function PLUGIN:player_connect(data)
    if (data.bot == 1) then
        return
    end

	local ipAddress = Schema.util.GetPlayerAddress(data.address).ip

	local data = {
		steam_id = util.SteamIDTo64(data.networkid),
		steam_name = data.name,
		ip_address = ipAddress,
	}

	self:PostJson("api/submit-player-info", data, function(response)
		ix.util.SchemaPrint("Player info submitted successfully.")
	end, function(message)
		ix.util.SchemaErrorNoHaltWithStack("Failed to submit player info: " .. message)
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
