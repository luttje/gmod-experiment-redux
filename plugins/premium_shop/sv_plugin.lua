local PLUGIN = PLUGIN

local STATUS_MAP = {
	purchased = "purchased",
	expired = "expired",
	renewed = "renewed",
	refunded = "refunded",
	canceled = "canceled"
}

function PLUGIN:OnLoaded()
	local envFile = file.Read(PLUGIN.folder .. "/web/.env", "LUA")

	if (not envFile) then
		ix.util.SchemaErrorNoHalt("The .env file is missing from the web folder for Leaderboards.")
		self.disabled = true
		return
	end

	local variables = Schema.util.EnvToTable(envFile)

	local url = Schema.util.ForceEndPath(variables.PAYNOW_STORE)

	SetNetVar("premium_shop.url", url)
end

function PLUGIN:DatabaseConnected()
	local statusses = table.concat(table.GetKeys(STATUS_MAP), ", ")
	local query
	query = mysql:Create("exp_premium")
	query:Create("order_id", "VARCHAR(255) NOT NULL")
	query:Create("steamid64", "VARCHAR(32) NOT NULL")
	query:Create("player_name", "VARCHAR(64) NOT NULL")
	query:Create("item_slug", "VARCHAR(255) NOT NULL") -- The item as registered with RegisterPremiumPackage
	query:Create("status", "ENUM(" .. statusses .. ") NOT NULL")
	query:Create("created_at", "INT(11) UNSIGNED NOT NULL")
	query:Create("updated_at", "INT(11) UNSIGNED NOT NULL")
	query:PrimaryKey("order_id")
	query:Execute()

	-- Add indexes for faster lookups
	mysql:CreateIndexIfNotExists("exp_premium", "idx_order_id", "order_id")
	mysql:CreateIndexIfNotExists("exp_premium", "idx_steamid64", "steamid64")
end

function PLUGIN:OnWipeTables()
	local query
	query = mysql:Drop("exp_premium")
	query:Execute()
end

function PLUGIN:PrePlayerMessageSend(speaker, chatType, text, bAnonymous)
	if (speaker:HasPremiumKey("supporter_role")) then
		speaker.ixLastOOC = nil -- No OOC delay for supporters
	end
end

-- Network data about premium packages
function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
	local premiumPackages = character:GetData("premiumPackages", {})

	client:SetCharacterNetVar("premiumPackages", premiumPackages)
end

-- Save premium packages when they change
function PLUGIN:OnPlayerGainPremiumKey(client, key)
	local character = client:GetCharacter()

	if (character) then
		local premiumPackages = client:GetPremiumPackages()
		character:SetData("premiumPackages", premiumPackages)
	end
end

function PLUGIN:OnPlayerLosePremiumKey(client, key)
	local character = client:GetCharacter()

	if (character) then
		local premiumPackages = client:GetPremiumPackages()
		character:SetData("premiumPackages", premiumPackages)
	end
end

--[[
	Player Meta functions
--]]

local playerMeta = FindMetaTable("Player")

function playerMeta:GivePremiumKey(key)
	if (not self:GetCharacter()) then
		return false
	end

	local premiumPackages = self:GetPremiumPackages()
	premiumPackages[key] = true
	self:SetCharacterNetVar("premiumPackages", premiumPackages)

	hook.Run("OnPlayerGainPremiumKey", self, key)
	return true
end

function playerMeta:RemovePremiumKey(key)
	if (not self:GetCharacter()) then
		return false
	end

	local premiumPackages = self:GetPremiumPackages()
	premiumPackages[key] = nil
	self:SetCharacterNetVar("premiumPackages", premiumPackages)

	hook.Run("OnPlayerLosePremiumKey", self, key)
	return true
end

--[[
	Database functions for payments
--]]

function PLUGIN:CreatePaymentRecord(orderId, steamId64, playerName, itemSlug, status, callback)
	local query = mysql:Insert("exp_premium")
	query:Insert("order_id", orderId)
	query:Insert("steamid64", steamId64)
	query:Insert("player_name", playerName)
	query:Insert("item_slug", itemSlug)
	query:Insert("status", status)
	query:Insert("created_at", os.time())
	query:Insert("updated_at", os.time())
	query:Callback(function(result, status, lastID)
		if (status == false) then
			ix.log.Add(nil, "schemaDebug", "CreateAlliance",
				"Failed to create alliance with result " .. tostring(result) .. " and lastID " .. tostring(lastID) .. ".")
			return
		end

		character:SetData("rank", rank)
		callback(lastID, members)
	end)
	query:Execute()
end

function PLUGIN:UpdatePaymentRecord(orderId, status, callback)
	local query = mysql:Update("exp_premium")
	query:Update("status", status)
	query:Update("updated_at", os.time())
	query:Where("order_id", orderId)
	query:Callback(function(result, status, lastID)
		if (status == false) then
			ix.log.Add(nil, "schemaDebug", "UpdatePaymentRecord",
				"Failed to update payment record with result " ..
				tostring(result) .. " and lastID " .. tostring(lastID) .. ".")
			return
		end

		callback(true)
	end)
	query:Execute()
end

concommand.Add("exp_premium_order", function(client, command, arguments)
	if (IsValid(client) and not client:IsSuperAdmin()) then
		return
	end

	local status = arguments[1]
	local itemSlug = arguments[2]
	local orderId = arguments[3]
	local steamId64 = arguments[4]

	if (not status or not itemSlug or not orderId or not steamId64) then
		ix.log.Add(client, "schemaDebug", "exp_premium_order",
			"Invalid command usage: " .. command .. " " .. table.concat(arguments, " "))
		return
	end

	if (not STATUS_MAP[status]) then
		ix.log.Add(client, "schemaDebug", "exp_premium_order",
			"Invalid status: " .. status .. " for command: " .. command)
		return
	end

	local player = player.GetBySteamID64(steamId64)

	if (player) then
		player:GivePremiumKey(itemSlug)
	end

	PLUGIN:UpdatePaymentRecord(orderId, status, function(success)
		if (success) then
			client:Notify("Payment record updated successfully for order ID: " .. orderId)
		else
			client:Notify("Failed to update payment record for order ID: " .. orderId)
		end
	end)
end)
