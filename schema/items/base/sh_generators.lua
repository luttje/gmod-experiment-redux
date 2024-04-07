local ITEM = ITEM

ITEM.name = "Generator Base"
ITEM.color = Color(0, 255, 255, 255)
ITEM.model = "models/props_combine/combine_mine01.mdl"
ITEM.width = 2
ITEM.height = 1
ITEM.noDrop = true
ITEM.category = "Generators"
ITEM.payTime = 600

function ITEM:OnRegistered()
	if (self.isBase) then
		return
	end

    if (not self.generator) then
        error("Generator table not found for item " .. self.uniqueID)
    end

	Schema.generator.Register(
		self.generator.name,
		self.generator.power,
		self.generator.health,
		self.generator.maximum,
		self.generator.money,
		self.generator.uniqueID,
		self.generator.powerName,
		self.generator.powerPlural,
		self.generator.upgrades
	)
end

local function tryOrShowError(client, uniqueID, silent)
	local character = client:GetCharacter()
	local generators = character:GetVar("generators") or {}
    local generator = Schema.generator.Get(uniqueID)
	local maximum = generator.maximum

	if (#generators >= maximum) then
		if (not silent) then
			client:Notify("You can not order this as you have reached the maximum amount of this item!")
		end

        return false
    end

	local trace = client:GetEyeTraceNoCursor()

	if (trace.HitPos:Distance(trace.StartPos) > 256) then
		if (not silent) then
			client:Notify("You can not place this that far away!")
		end

		return false
	end

	if (trace.HitNonWorld) then
		if (not silent) then
        	client:Notify("You can not place this here!")
		end

        return false
    end

    return true
end

function ITEM:OnCanOrder(client)
	if (not tryOrShowError(client, self.generator.uniqueID, true)) then
        return false
    end
end

ITEM.functions.Place = {
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local trace = client:GetEyeTraceNoCursor()

		if (not tryOrShowError(client, item.generator.uniqueID)) then
			return false
		end

		local generator = Schema.generator.Get(item.uniqueID)

		local entity = Schema.generator.Spawn(generator, trace.HitPos, trace.HitNormal:Angle())
		entity:SetupGenerator(client, item)
		local physicsObject = entity:GetPhysicsObject()

		if physicsObject and physicsObject:IsValid() then
			physicsObject:EnableMotion(false)
		end

		-- TODO: Limit the amount that can be spawned (TODO: This logic is repetitive, move it somewhere common)
		local generators = character:GetVar("generators") or {}
		generators[#generators + 1] = entity
		character:SetVar("generators", generators, true)

		-- We don't want the instance to dissappear, because we want to attach it to the entity so the same item can later be picked up
		local inventory = ix.item.inventories[item.invID]
		inventory:Remove(item.id, false, true)

		return false
	end,

	OnCanRun = function(item)
		local client = item.player

		return tryOrShowError(client, item.generator.uniqueID, true)
	end
}
