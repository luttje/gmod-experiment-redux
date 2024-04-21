local PLUGIN = PLUGIN

function PLUGIN:LoadData()
	local lockers = self:GetData()

	for _, lockerData in pairs(lockers) do
		local entity = ents.Create("exp_lockers")
		entity:SetPos(lockerData.pos)
		entity:SetAngles(lockerData.ang)
		entity:Spawn()
	end
end

function PLUGIN:SaveData()
	local lockers = {}

	for _, entity in ipairs(ents.FindByClass("exp_lockers")) do
		table.insert(lockers, {
			pos = entity:GetPos(),
			ang = entity:GetAngles()
		})
	end
end
