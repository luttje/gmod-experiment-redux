local PLUGIN = PLUGIN

PLUGIN.name = "Debug Tools"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds various tools for debugging."

if (SERVER) then
	function PLUGIN:PlayerSpawn(client)
		_G["PT"] = PrintTable

		for k, otherClient in ipairs(player.GetAll()) do
			-- P1, P2, etc... to get a player by index
			_G["P" .. k] = otherClient

			-- P1C(), P2C(), etc... to get a player's character by index
			_G["P" .. k .. "C"] = function()
				return otherClient:GetCharacter()
			end

			-- P1CI(), P2CI(), etc... to get a player's character's inventory by index
			_G["P" .. k .. "CI"] = function()
				return otherClient:GetCharacter():GetInventory()
			end

			-- P1K() to kill a player by index
			_G["P" .. k .. "K"] = function()
				otherClient:Kill()
			end
		end
	end
end

do
	local COMMAND = {}

	COMMAND.description = "Give yourself every item which has an uniqueID that matches the provided pattern."
	COMMAND.arguments = {
		ix.type.string,
	}

	COMMAND.superAdminOnly = true

    function COMMAND:OnRun(client, pattern)
        local items = ix.item.list
		local count = 0

        for _, item in pairs(items) do
            if (item.uniqueID:match(pattern)) then
                client:GetCharacter():GetInventory():Add(item.uniqueID)
				count = count + 1
            end
        end

		client:Notify("You have been given " .. count .. " items that match the pattern '" .. pattern .. "'.")
	end

	ix.command.Add("CharGiveAllItems", COMMAND)
end
