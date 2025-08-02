local PLUGIN = PLUGIN

local API_KEY, APP_URL
local SYNC_INTERVAL_IN_SECONDS = 15

local activeSanctions = {}
local lastSanctionSync = 0

local function getClientRank(client)
	local rank = "player"

	if (client:IsSuperAdmin()) then
		rank = "superadmin"
	elseif (client:IsAdmin()) then
		rank = "admin"
	end

	return rank
end

-- Helper function to find active sanctions for a player
local function getPlayerSanctions(steamID64)
	local playerSanctions = {}

	for _, sanction in pairs(activeSanctions) do
		if (sanction.steam_id == steamID64) then
			table.insert(playerSanctions, sanction)
		end
	end

	return playerSanctions
end

-- Helper function to check if player has active ban
local function isPlayerBanned(steamID64)
	for _, sanction in pairs(activeSanctions) do
		if (sanction.steam_id == steamID64 and sanction.type == "ban") then
			return true, sanction
		end
	end
	return false
end

-- Helper function to check if player has active mute
local function isPlayerMuted(steamID64)
	for _, sanction in pairs(activeSanctions) do
		if (sanction.steam_id == steamID64 and sanction.type == "mute") then
			return true, sanction
		end
	end
	return false
end

-- Sync sanctions from the API
local function syncSanctions()
	if (PLUGIN.disabled) then
		return
	end

	PLUGIN:GetJson("api/sanctions", function(response)
		if (response.body) then
			local success, data = pcall(util.JSONToTable, response.body)

			if (success and data and data.success and data.data) then
				activeSanctions = {}

				-- Store sanctions by ID for easy lookup
				for _, sanction in pairs(data.data) do
					activeSanctions[sanction.id] = sanction
				end

				lastSanctionSync = CurTime()

				if (DEBUG_MODERATION) then
					ix.util.SchemaPrint("Synced " .. table.Count(activeSanctions) .. " active sanctions.")
				end

				-- Immediately check if any players are banned that need to be kicked
				for _, player in ipairs(player.GetAll()) do
					local steamID64 = player:SteamID64()
					local isBanned, banSanction = isPlayerBanned(steamID64)

					if (isBanned) then
						player:Kick("You are banned from this server. Reason: "
							.. (banSanction.reason or "No reason provided"))
					end
				end
			else
				ix.util.SchemaErrorNoHalt("Failed to parse sanctions response: Invalid JSON")
			end
		end
	end, function(message)
		ix.util.SchemaErrorNoHalt("Failed to sync sanctions: " .. message)
	end)
end

-- On loading the plugin we will get the API_KEY that we can use to authenticate with the moderation API.
function PLUGIN:OnLoaded()
	local envFile = file.Read(PLUGIN.folder .. "/web/.env", "LUA")

	if (not envFile) then
		ix.util.SchemaErrorNoHalt("The .env file is missing from the web folder for External Moderation.")
		self.disabled = true
		return
	end

	local variables = Schema.util.EnvToTable(envFile)

	API_KEY = variables.API_SECRET
	APP_URL = Schema.util.ForceEndPath(variables.APP_URL)

	-- Initial sanctions sync
	timer.Simple(2, function()
		syncSanctions()
	end)

	-- Set up periodic syncing
	timer.Create("SanctionSync", SYNC_INTERVAL_IN_SECONDS, 0, function()
		syncSanctions()
	end)

	-- gmsv_eightbit doesn't work in singleplayer or on listen servers, so we only load it on dedicated servers.
	if (eightbit or not game.IsDedicated()) then
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

-- Clean up timer when plugin is unloaded
function PLUGIN:OnUnloaded()
	if (timer.Exists("SanctionSync")) then
		timer.Remove("SanctionSync")
	end
end

-- Block banned players from connecting
function PLUGIN:CheckPassword(steamID64, ipAddress, svPassword, clPassword, name)
	local isBanned, banSanction = isPlayerBanned(steamID64)

	if (isBanned) then
		local reason = banSanction.reason or "No reason provided"
		local banMessage = "You are banned from this server. Reason: " .. reason

		if (banSanction.expires_in and not banSanction.is_permanent) then
			banMessage = banMessage .. "\nBan expires " .. banSanction.expires_in
		else
			banMessage = banMessage .. "\nThis is a permanent ban."
		end

		return false, banMessage
	end
end

-- Block muted players from using chat
function PLUGIN:PlayerSay(client, text)
	local steamID64 = client:SteamID64()
	local isMuted, muteSanction = isPlayerMuted(steamID64)

	if (isMuted) then
		local reason = muteSanction.reason or "No reason provided"
		local muteMessage = "You are muted. Reason: " .. reason

		if (muteSanction.expires_in and not muteSanction.is_permanent) then
			muteMessage = muteMessage .. " (Expires " .. muteSanction.expires_in .. ")"
		end

		ix.chat.Send(nil, "sanction", muteMessage, nil, { client })
		return ""
	end
end

-- Also block muted players from using voice chat (if eightbit is available)
function PLUGIN:PlayerCanHearPlayersVoice(listener, talker)
	local talkerSteamID64 = talker:SteamID64()
	local isMuted = isPlayerMuted(talkerSteamID64)

	if (isMuted) then
		return false
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
		rank = getClientRank(client),
		character_name = character and character:GetName() or nil,
		character_id = character and client:GetCharacter():GetID() or nil,
		ip_address = ipAddress,
		message = message,
	}

	self:PostJson("api/submit-chat-log", data, function(response)
		if (not DEBUG_MODERATION) then
			return
		end

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
		rank = getClientRank(client),
		character_name = character:GetName(),
		character_id = character:GetID(),
		ip_address = ipAddress,
	}

	self:PostJson("api/submit-player-info", data, function(response)
		if (not DEBUG_MODERATION) then
			return
		end

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
		rank = "player", -- Default to player for now, will be updated later when client fully connects.
		steam_name = data.name,
		ip_address = ipAddress,
	}

	self:PostJson("api/submit-player-info", data, function(response)
		if (not DEBUG_MODERATION) then
			return
		end

		ix.util.SchemaPrint("Player info submitted successfully.")
	end, function(message)
		ix.util.SchemaErrorNoHalt("Failed to submit player info: " .. message)
	end)
end

-- Console command to manually sync sanctions (for testing/debugging)
concommand.Add("exp_sanctions_sync", function(client, cmd, args)
	if (IsValid(client) and not client:IsSuperAdmin()) then
		return
	end

	syncSanctions()

	local message = "Sanctions sync initiated."
	if (IsValid(client)) then
		ix.chat.Send(nil, "sanction", message, nil, { client })
	else
		print(message)
	end
end)

-- Console command to check a player's sanctions
concommand.Add("exp_sanctions_check", function(client, cmd, args)
	if (IsValid(client) and not client:IsSuperAdmin()) then
		return
	end

	if (not args[1]) then
		local message = "Usage: sanctions_check <steamid64>"
		if (IsValid(client)) then
			ix.chat.Send(nil, "sanction", message, nil, { client })
		else
			print(message)
		end
		return
	end

	local steamID64 = args[1]
	local playerSanctions = getPlayerSanctions(steamID64)

	local message = "Player " .. steamID64 .. " has " .. #playerSanctions .. " active sanctions:"

	for _, sanction in pairs(playerSanctions) do
		message = message .. "\n- " .. sanction.type .. ": " .. (sanction.reason or "No reason")
		if (sanction.expires_in and not sanction.is_permanent) then
			message = message .. " (expires " .. sanction.expires_in .. ")"
		end
	end

	if (IsValid(client)) then
		ix.chat.Send(nil, "sanction", message, nil, { client })
	else
		print(message)
	end
end)

function PLUGIN:PostJson(endpoint, data, onSuccess, onFailure)
	if (self.disabled) then
		return
	end

	endpoint = APP_URL .. endpoint

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

function PLUGIN:GetJson(endpoint, onSuccess, onFailure)
	if (self.disabled) then
		return
	end

	endpoint = APP_URL .. endpoint

	http.Fetch(endpoint, function(body, length, headers, code)
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
		["X-Api-Secret"] = API_KEY,
		["Accept"] = "application/json",
	})
end
