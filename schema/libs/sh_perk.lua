if (Schema.perk == nil) then
	Schema.perk = {}
	Schema.perk.stored = {}
	Schema.perk.buffer = {}
end

function Schema.perk.GetBuffer()
	return Schema.perk.buffer
end

function Schema.perk.GetAll()
	return Schema.perk.stored
end

function Schema.perk.LoadFromDir(directory)
    local oldGlobal = PERK

    for _, fileName in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local uniqueID = string.lower(fileName:sub(4, -5))

        PERK = Schema.perk.stored[uniqueID] or {}
        PERK.uniqueID = uniqueID
		PERK.index = table.Count(Schema.perk.buffer) + 1

        ix.util.Include(directory .. "/" .. fileName, "shared")

		if (SERVER) then
			if (PERK.backgroundImage) then
				resource.AddFile("materials/" .. PERK.backgroundImage .. ".vtf")
				resource.AddFile("materials/" .. PERK.backgroundImage .. ".vmt")
			end

			if (PERK.foregroundImage) then
				resource.AddFile("materials/" .. PERK.foregroundImage .. ".vtf")
				resource.AddFile("materials/" .. PERK.foregroundImage .. ".vmt")
			end
		end

        Schema.perk.stored[PERK.uniqueID] = PERK
        Schema.perk.buffer[PERK.index] = PERK
    end

	PERK = oldGlobal
end

function Schema.perk.Get(name)
	if (Schema.perk.buffer[name]) then
		return Schema.perk.buffer[name]
	elseif (Schema.perk.stored[name]) then
		return Schema.perk.stored[name]
	else
		local perk = nil

		for _, perk in pairs(Schema.perk.stored) do
			if (string.find(string.lower(perk.name), string.lower(name))) then
				if (perk) then
					if (string.len(perk.name) < string.len(perk.name)) then
						perk = perk
					end
				else
					perk = perk
				end
			end
		end

		return perk
	end
end

function Schema.perk.GetProperty(name, key)
	local perk = Schema.perk.Get(name)

	if (not perk or not perk[key]) then
		error("Perk '" .. name .. "' does not have property '" .. key .. "'.")
	end

	return perk[key]
end

local function checkHasPerk(perks, perkTable, client)
	local hasPerk = perks[perkTable.uniqueID]

	if (not hasPerk) then
		return false
	end

	if (perkTable.GetIsActive) then
		hasPerk = perkTable:GetIsActive(client or nil)

		if (hasPerk == nil) then
			hasPerk = true
		end
	end

	return hasPerk
end

if (SERVER) then
	util.AddNetworkString("PerkGive")
	util.AddNetworkString("PerkLoadOwned")
	util.AddNetworkString("PerkRequestBuy")

	function Schema.perk.Give(client, perk)
		local perkTable = Schema.perk.Get(perk)
		local perks = client:GetCharacter():GetData("perks", {})

		if (not perkTable) then
			return false, "That is not a valid perk!"
		end

		perks[perkTable.uniqueID] = true
		client:GetCharacter():SetData("perks", perks)

		net.Start("PerkGive")
		net.WriteUInt(perkTable.index, 32)
		net.Send(client)

		if (perkTable.OnGiven) then
			perkTable:OnGiven(client)
		end

		ix.log.Add(client, "perkBought", perkTable.name)
	end

	function Schema.perk.LoadOwned(client)
		local perks = client:GetCharacter():GetData("perks", {})

		net.Start("PerkLoadOwned")
		net.WriteTable(perks)
		net.Send(client)
	end

	function Schema.perk.GetOwned(perk, client)
		local perkTable = Schema.perk.Get(perk)

        if (not perkTable) then
            ix.log.Add(client, "schemaDebug", "Schema.perk.Give", "Attempt to check for invalid perk: " ..
                tostring(perk))
            return false
        end

		if (client:IsBot())then
			return false
		end

		local perks = client:GetCharacter():GetData("perks", {})

		return checkHasPerk(perks, perkTable, client)
	end

	net.Receive("PerkRequestBuy", function(len, client)
		local perkUniqueID = net.ReadString()
		local character = client:GetCharacter()

		if (client.NextBuyPerk and client.NextBuyPerk > CurTime()) then
			ix.util.Notify(
				"Please wait another " ..
				math.ceil(client.NextBuyPerk - CurTime()) .. " seconds before buying a perk again.",
				client)
			return
		end

		client.NextBuyPerk = CurTime() + 5
		local perkTable = Schema.perk.Get(perkUniqueID)

		if (not perkTable) then
			ix.log.Add(client, "schemaDebug", "PerkRequestBuy", "Attempt to check for invalid perk: " ..
				tostring(perkUniqueID))
		end

		if (not character:HasMoney(perkTable.price)) then
			ix.util.Notify("You need another " ..
				ix.currency.Get(perkTable.price - character:GetMoney(), nil, true) .. "!")
			return
		end

		if (Schema.perk.GetOwned(perkTable.uniqueID, client)) then
			ix.util.Notify("You already have the '" .. perkTable.name .. "' perk.", client)
			return
		end

		Schema.perk.Give(client, perkTable.uniqueID)

		character:TakeMoney(perkTable.price, perkTable.name)
		ix.util.Notify("You have gotten the '" .. perkTable.name .. "' perk.", client)

		hook.Run("PlayerPerkBought", client, perkTable)
	end)
else
	Schema.perk.localOwned = Schema.perk.localOwned or {}

	function Schema.perk.GetPanel()
		return ix.gui.perksPanel
	end

    function Schema.perk.UpdatePanel()
        local panel = Schema.perk.GetPanel()

		if (IsValid(panel)) then
			panel:Update()
		end
	end

	function Schema.perk.GetOwned(perk)
		local perkTable = Schema.perk.Get(perk)

		if (not perkTable) then
			return false
		end

		return checkHasPerk(Schema.perk.localOwned, perkTable)
	end

	net.Receive("PerkGive", function()
		local perk = net.ReadUInt(32)
        local perkTable = Schema.perk.Get(perk)

        if (not perkTable) then
			error("Perk with index " .. perk .. " does not exist.")
			return
		end

		Schema.perk.localOwned[perkTable.uniqueID] = true

		Schema.perk.UpdatePanel()
	end)

	net.Receive("PerkLoadOwned", function()
		local perks = net.ReadTable()
		Schema.perk.localOwned = {}

		for uniqueID, _ in pairs(perks) do
			Schema.perk.localOwned[uniqueID] = true
		end

		Schema.perk.UpdatePanel()
	end)
end
