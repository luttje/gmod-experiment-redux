local PLUGIN = PLUGIN

util.AddNetworkString("expSetMonitorTarget")
util.AddNetworkString("expMonitorsPrintPresets")

-- ix.plugin.list["monitors"]:SetTarget(player.GetByID(1))
function PLUGIN:SetTarget(entity)
	net.Start("expSetMonitorTarget")
	net.WriteEntity(entity)
	net.Broadcast()

	-- Dramatically turn on all monitors with delay
	local monitorEntities = ents.FindByClass("exp_monitor")

	for i = 1, #monitorEntities do
		local monitor = monitorEntities[i]

		timer.Simple(math.Rand(0, 1) * i, function()
			if (IsValid(monitor)) then
				monitor:SetPoweredOn(true)
			end
		end)
	end
end

function PLUGIN:RelateMonitorToParent(monitor, parent)
	parent._relatedMonitors = parent._relatedMonitors or {}
	parent._relatedMonitors[#parent._relatedMonitors + 1] = monitor

	if (not parent._uniqueNameForSaving) then
		PLUGIN.lastUniqueName = (PLUGIN.lastUniqueName or 0) + 1
		parent._uniqueNameForSaving = util.Base64Encode(os.time() .. "#" .. PLUGIN.lastUniqueName)
	end

	monitor._parentUniqueName = parent._uniqueNameForSaving
end

function PLUGIN:SaveData()
	local entities = {}

	local parentEntities = {}

	for _, monitor in ipairs(ents.FindByClass("exp_monitor")) do
		if (not IsValid(monitor)) then
			continue
		end

		local data = {
			width = monitor:GetMonitorWidth(),
			height = monitor:GetMonitorHeight(),
			scale = monitor:GetMonitorScale(),
			parentName = monitor._parentUniqueName,
			angles = monitor:GetLocalAngles(),
			pos = monitor:GetLocalPos(),
			on = monitor:GetPoweredOn()
		}

		parentEntities[monitor._parentUniqueName] = parentEntities[monitor._parentUniqueName] or monitor:GetParent()

		entities[#entities + 1] = data
	end

	local parentEntitiesData = {}

	for uniqueName, parentEntity in pairs(parentEntities) do
		if (not IsValid(parentEntity)) then
			continue
		end

		local data = {
			name = parentEntity._uniqueNameForSaving,
			model = parentEntity:GetModel(),
			scale = parentEntity:GetModelScale(),
			pos = parentEntity:GetPos(),
			angles = parentEntity:GetAngles()
		}

		local physicsObject = parentEntity:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			data.movable = physicsObject:IsMoveable()
		end

		parentEntitiesData[uniqueName] = data
	end

	self:SetData({
		entities = entities,
		parentEntities = parentEntitiesData
	})
end

function PLUGIN:LoadData()
	local data = self:GetData()

	-- Place the parent entities
	local parentEntities = {}

	for uniqueName, parentData in pairs(data.parentEntities) do
		local parent = ents.Create("prop_physics")
		parent:SetModel(parentData.model)
		parent:SetModelScale(parentData.scale)
		parent:SetPos(parentData.pos)
		parent:SetAngles(parentData.angles)
		parent:Spawn()

		local physicsObject = parent:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:EnableMotion(parentData.movable)
		else
			parent:SetMoveType(MOVETYPE_NONE)
		end

		parent._uniqueNameForSaving = uniqueName
		parent._relatedMonitors = {}

		parentEntities[uniqueName] = parent
	end

	-- Place the monitors
	for _, monitorData in ipairs(data.entities) do
		local parent = parentEntities[monitorData.parentName]

		if (not IsValid(parent)) then
			continue
		end

		local monitor = ents.Create("exp_monitor")
		monitor:SetMonitorWidth(monitorData.width)
		monitor:SetMonitorHeight(monitorData.height)
		monitor:SetMonitorScale(monitorData.scale)
		monitor:ConfigureParent(parent, monitorData.pos, monitorData.angles)
		monitor:Spawn()
		monitor:SetPoweredOn(monitorData.on)
	end
end
