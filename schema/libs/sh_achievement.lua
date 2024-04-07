if(Schema.achievement == nil)then
	Schema.achievement = {}
	Schema.achievement.stored = {}
	Schema.achievement.buffer = {}
end

function Schema.achievement.GetBuffer()
	return Schema.achievement.buffer
end

function Schema.achievement.GetAll()
	return Schema.achievement.stored
end

function Schema.achievement.Register(achievement)
	achievement.uniqueID = achievement.uniqueID or string.lower(string.gsub(achievement.name, "%s", "_"))
	achievement.index = tonumber(util.CRC(achievement.name))

	Schema.achievement.stored[achievement.uniqueID] = achievement
	Schema.achievement.buffer[achievement.index] = achievement

	resource.AddFile("materials/"..achievement.backgroundImage..".vtf")
	resource.AddFile("materials/"..achievement.backgroundImage..".vmt")

	resource.AddFile("materials/"..achievement.foregroundImage..".vtf")
	resource.AddFile("materials/"..achievement.foregroundImage..".vmt")

	return achievement.uniqueID
end

function Schema.achievement.Get(name)
	if (Schema.achievement.buffer[name]) then
		return Schema.achievement.buffer[name]
	elseif (Schema.achievement.stored[name]) then
		return Schema.achievement.stored[name]
	else
		local achievement

		for k, v in pairs(Schema.achievement.stored) do
			if (string.find(string.lower(v.name), string.lower(name))) then
				if (achievement) then
					if (string.len(v.name) < string.len(achievement.name)) then
						achievement = v
					end
				else
					achievement = v
				end
			end
		end

		return achievement
	end
end

function Schema.achievement.GetProperty(name, key)
	local achievement = Schema.achievement.Get(name)

	if (not achievement or not achievement[key]) then
		error("Achievement '" .. name .. "' does not have property '" .. key .. "'.")
	end

	return achievement[key]
end

if (SERVER) then
	util.AddNetworkString("exp_AchievementProgress")
	util.AddNetworkString("exp_AchievementsLoad")

	function Schema.achievement.Progress(client, achievement, progress)
		local achievementTable = Schema.achievement.Get(achievement)
		local achievements = client:GetCharacter():GetData("achievements", {})

		if (not progress) then
			progress = 1
		end

		if (not achievementTable) then
			ix.log.Add(client, "schemaDebug", "Schema.achievement.Progress", "Attempted to progress an achievement that does not exist.")
			return false
		end

		local currentAchievement = achievements[achievementTable.uniqueID] or 0

		if (currentAchievement == achievementTable.maximum) then
			return false
		end

		achievements[achievementTable.uniqueID] = math.Clamp(currentAchievement + progress, 0,
			achievementTable.maximum)
		client:GetCharacter():SetData("achievements", achievements)

		if (achievements[achievementTable.uniqueID] < achievementTable.maximum) then
			if (achievementTable.OnProgress) then
				achievementTable:OnProgress(client, achievements[achievementTable.uniqueID])
			end
		else
			ix.chat.Send(client, "achievement", achievementTable.name)

			if (achievementTable.reward) then
				client:GetCharacter():GiveMoney(achievementTable.reward)
			end

			if (achievementTable.OnAchieved) then
				achievementTable:OnAchieved(client)
			end

			ix.log.Add(client, "achievementAchieved", achievementTable.name, achievementTable.reward)
		end

		net.Start("exp_AchievementProgress")
		net.WriteUInt(achievementTable.index, 32)
		net.WriteUInt(achievements[achievementTable.uniqueID], 16)
		net.Send(client)
	end

	function Schema.achievement.LoadProgress(client)
		local achievements = client:GetCharacter():GetData("achievements", {})

		net.Start("exp_AchievementsLoad")
		net.WriteTable(achievements)
		net.Send(client)
	end

	function Schema.achievement.HasAchieved(achievement, client)
		local achievementTable = Schema.achievement.Get(achievement)

		if (achievementTable) then
			if (Schema.achievement.GetProgress(achievement, client) == achievementTable.maximum) then
				return true
			end
		end

		return false
	end

	function Schema.achievement.GetProgress(achievement, client)
		local achievementTable = Schema.achievement.Get(achievement)
		local achievements = client:GetCharacter():GetData("achievements", {})

		if (achievementTable) then
			return achievements[achievementTable.uniqueID] or 0
		else
			return 0
		end
	end
else
	Schema.achievement.localAchieved = Schema.achievement.localAchieved or {}

	function Schema.achievement.GetPanel()
		return ix.gui.achievementsPanel
	end

    function Schema.achievement.UpdatePanel()
        local panel = Schema.achievement.GetPanel()

		if (IsValid(panel)) then
			panel:Update()
		end
	end

	function Schema.achievement.GetProgress(achievement)
		local achievementTable = Schema.achievement.Get(achievement)

		if (achievementTable) then
			return Schema.achievement.localAchieved[achievementTable.uniqueID] or 0
		else
			return 0
		end
	end

	function Schema.achievement.HasAchieved(achievement)
		local achievementTable = Schema.achievement.Get(achievement)

		if (achievementTable) then
			if (Schema.achievement.GetProgress(achievement) == achievementTable.maximum) then
				return true
			end
		end

		return false
	end

	net.Receive("exp_AchievementProgress", function(msg)
		local achievement = net.ReadUInt(32)
		local progress = net.ReadUInt(16)
		local achievementTable = Schema.achievement.Get(achievement)

        if (not achievementTable) then
            error("Achievement with index " .. achievement .. " does not exist.")
            return
        end

		Schema.achievement.localAchieved[achievementTable.uniqueID] = progress

		Schema.achievement.UpdatePanel()
	end)


	net.Receive("exp_AchievementsLoad", function()
		local achievements = net.ReadTable()
		Schema.achievement.localAchieved = {}

		for uniqueID, progress in pairs(achievements) do
			local achievement = Schema.achievement.Get(uniqueID)

			if (not achievement) then
				continue
			end

			Schema.achievement.localAchieved[uniqueID] = progress
		end

		Schema.achievement.UpdatePanel()
	end)
end
