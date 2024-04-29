local PLUGIN = PLUGIN

PLUGIN.name = "Attribute Training"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Implements several new ways to train attributes."

if (CLIENT) then
	function PLUGIN:HUDPaint()
		local client = LocalPlayer()

		if (not IsValid(client)) then
			return
		end

		local raceStartEntity = client:GetCharacterNetVar("expRaceJoined")

        if (IsValid(raceStartEntity)) then
            local npc = Schema.npc.Get(raceStartEntity:GetNpcId())
            npc:HUDPaintBeforeStart(raceStartEntity)
        end

        local raceStartedAt = client:GetCharacterNetVar("expRaceStartedAt")

		if (raceStartedAt) then
            local npc = Schema.npc.Get("race_start")
			npc:HUDPaintStarted()
		end

		local targetPracticeChallenger = client:GetCharacterNetVar("targetPracticeChallenger")

		if (IsValid(targetPracticeChallenger)) then
			local npc = Schema.npc.Get(targetPracticeChallenger:GetNpcId())
			npc:HUDPaint(targetPracticeChallenger)
		end
	end
end

if (SERVER)then
	function PLUGIN:SaveData()
		local targetPracticeSpawners = {}

		for _, targetPracticeSpawner in pairs(ents.FindByClass("exp_target_practice_spawn")) do
			targetPracticeSpawners[#targetPracticeSpawners + 1] = {
				position = targetPracticeSpawner:GetPos(),
				angles = targetPracticeSpawner:GetAngles(),
			}
		end

		self:SetData({
			targetPracticeSpawners = targetPracticeSpawners,
		})
	end

	function PLUGIN:LoadData()
		local data = self:GetData()

		if (not data) then
			return
		end

		local targetPracticeSpawners = data.targetPracticeSpawners or {}

		for _, targetPracticeSpawner in ipairs(targetPracticeSpawners) do
			local entity = ents.Create("exp_target_practice_spawn")
			entity:SetPos(targetPracticeSpawner.position)
			entity:SetAngles(targetPracticeSpawner.angles)
			entity:Spawn()
		end
	end
end
