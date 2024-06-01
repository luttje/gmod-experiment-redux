local PLUGIN = PLUGIN

PLUGIN.name = "Message of the Day"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Show rules, terms of service, or other information to players when they join the server."

PLUGIN.termsOfServiceVersion = "2024-05-04"

ix.config.Add("privacyEmail", "privacy@experiment.games", "The email address for privacy concerns.", nil, {
	category = "Message of the Day"
})
ix.config.Add("githubUrl", "https://experiment.games/issues", "The URL to the GitHub issues page.", nil, {
	category = "Message of the Day"
})

do
	local COMMAND = {}

	COMMAND.description =
		"Open the terms of service panel, where you can request to have your data removed."

    function COMMAND:OnRun(client)
        net.Start("expTermsOfService")
		net.Send(client)
	end

	ix.command.Add("TermsOfService", COMMAND)
end

if (SERVER) then
    util.AddNetworkString("expTermsOfService")
    util.AddNetworkString("expAcceptTermsOfService")
    util.AddNetworkString("expDisagreeTermsOfService")

    net.Receive("expAcceptTermsOfService", function(_, client)
        local acceptedTerms = client:GetData("acceptedTerms")

		if (acceptedTerms and acceptedTerms.version == PLUGIN.termsOfServiceVersion) then
			return
		end

        client:SetData("acceptedTerms", {
			at = os.time(),
			version = PLUGIN.termsOfServiceVersion,
        })

		client:SaveData()
    end)

	-- Kick the player, remove all their data
    net.Receive("expDisagreeTermsOfService", function(_, client)
        PLUGIN:RemovePlayerData(client)
    end)

    function PLUGIN:RemovePlayerData(client, noKick)
        local characterIds = client.ixCharList
        local steamID = client:SteamID64()

		ix.char.cache[steamID] = nil

		if (#characterIds > 0) then
            for _, id in ipairs(characterIds) do
                local character = ix.char.loaded[id]

				if (character) then
					hook.Run("PreCharacterDeleted", client, character)
					ix.char.loaded[id] = nil
				end
			end

			-- Remove items belonging to the characters
			query = mysql:Select("ix_inventories")
			query:Select("inventory_id")
			query:WhereIn("character_id", characterIds)
			query:Callback(function(result)
				if (istable(result)) then
					-- remove associated items from database
					for _, v in ipairs(result) do
						local itemQuery = mysql:Delete("ix_items")
						itemQuery:Where("inventory_id", v.inventory_id)
						itemQuery:Execute()

						ix.item.inventories[tonumber(v.inventory_id)] = nil
					end
				end
			end)
			query:Execute()

			-- Remove the inventories belonging to the characters
			query = mysql:Delete("ix_inventories")
			query:WhereIn("character_id", characterIds)
			query:Execute()

			-- Remove the characters
			local query = mysql:Delete("ix_characters")
			query:Where("steamid", steamID)
			query:Execute()
		end

        -- Other plugins might need to deal with deleted characters.
        for _, id in ipairs(characterIds) do
            local isCurrentChar = client:GetCharacter() and client:GetCharacter():GetID() == id

            hook.Run("CharacterDeleted", client, id, isCurrentChar)

            if (isCurrentChar) then
                client:SetNetVar("char", nil)
                client:KillSilent()
                client:RemoveAllAmmo()
            end
        end

        -- Remove the player data
        query = mysql:Delete("ix_players")
        query:Where("steamid", steamID)
		query:Callback(function(result)
            if (not IsValid(client)) then
                return
            end

			hook.Run("PlayerDataRemoved", client, steamID)

            if (not noKick) then
                client:Kick("Data removal requested.")
            end
		end)
        query:Execute()
    end
end

if (not CLIENT) then
    return
end

PLUGIN.messagesOfTheDay = PLUGIN.messagesOfTheDay or {}

function PLUGIN:AddMessage(order, data)
    self.messagesOfTheDay[order] = data

    return order
end

local lastOrder = PLUGIN:AddMessage(1, {
    vgui = "expTermsOfService", -- Includes rules

	noButtons = true,

    ShouldShow = function()
        local client = LocalPlayer()

        local acceptedTerms = client:GetData("acceptedTerms")

		return not acceptedTerms or acceptedTerms.version ~= PLUGIN.termsOfServiceVersion
	end
})

-- lastOrder = PLUGIN:AddMessage(lastOrder + 1, {
-- 	vgui = "expRules",

-- 	ShouldShow = function()
-- 		return true
-- 	end
-- })

function PLUGIN:ShowMessageOfTheDay()
    local parent = ix.gui.characterMenu

    if (not IsValid(parent) or not IsValid(LocalPlayer())) then
        return
    end

	if (IsValid(Schema.messageOfTheDayPanel)) then
		return
	end

    local messageStack = {}

	for _, message in ipairs(self.messagesOfTheDay) do
		if (not message.ShouldShow or message:ShouldShow()) then
			table.insert(messageStack, message)
		end
	end

    Schema.messageOfTheDayPanel = parent:Add("expMessageOfTheDay")
	Schema.messageOfTheDayPanel:SetMessages(messageStack)
end

-- Show the message when the character menu is created AND LocalPlayer() is valid
function PLUGIN:OnCharacterMenuCreated(panel)
	self:ShowMessageOfTheDay()
end

function PLUGIN:InitPostEntity()
	self:ShowMessageOfTheDay()
end

net.Receive("expTermsOfService", function()
    local window = vgui.Create("expFrame")
    window:SetSize(ScrW() * 0.75, ScrH() * 0.8)
    window:Center()
    window:SetTitle("Terms of Service")
    window:MakePopup()

    local terms = window:Add("expTermsOfService")
	terms:Dock(FILL)
	terms.Close = function()
		window:Close()
	end
end)
