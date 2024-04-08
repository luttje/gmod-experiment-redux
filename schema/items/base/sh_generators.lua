local ITEM = ITEM

ITEM.name = "Generator Base"
ITEM.color = Color(0, 255, 255, 255)
ITEM.model = "models/props_combine/combine_mine01.mdl"
ITEM.width = 2
ITEM.height = 1
ITEM.noDrop = true
ITEM.category = "Generators"
ITEM.payTime = 600
ITEM.maximum = 1

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
        self.generator.price,
        self.generator.uniqueID,
        self.generator.powerName,
        self.generator.powerPlural,
        self.generator.upgrades
    )
end

if (CLIENT) then
	function ITEM:PopulateTooltip(tooltip)
		if (not self.maximum) then
			return
		end

		local panel = tooltip:AddRowAfter("name", "maximum")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText("You can only have " .. self.maximum .. " of this item in the world at a time!")
		panel:SizeToContents()
	end
end

function ITEM:CanTransfer(oldInventory, newInventory)
	return false
end

function ITEM:OnCanOrder(client)
    if (CLIENT) then
        -- OnCanOnder will also be called clientside to see if it should display at all, we will display it, so
		-- users aren't confused why tne item isn't showing up in the business
        return
    end

    local character = client:GetCharacter()

    if (character and character:GetInventory():HasItem(self.uniqueID)) then
		client:Notify("You can not order this as you have reached the maximum amount of this item!")

        return false
    end

    -- TODO: Check existing shipments in the world, belonging to the player for the same item
    -- TODO: That would be friendly, but we can also consider it the players' own mistake since they were warned.
	-- TODO: We'll just let them destroy existing generators if they mistakenly order multiple.

    local generator = Schema.generator.Get(self.uniqueID)

	if (client:IsObjectLimited(generator.uniqueID, self.maximum)) then
		client:Notify("You can not order this as you have reached the maximum amount of this item!")

        return false
    end
end

ITEM.functions.Place = {
	OnRun = function(item)
        local client = item.player
		local generator = Schema.generator.Get(item.uniqueID)

        if (client:IsObjectLimited(generator.uniqueID, item.maximum)) then
            client:Notify("You can not place this as you have reached the maximum amount of this item!")
            return false
        end

		local success, message, trace = client:TryTraceInteractAtDistance()

		if (not success) then
			client:Notify(message)

			return false
		end

		local entity = Schema.generator.Spawn(generator, trace.HitPos, trace.HitNormal:Angle())
        entity:SetupGenerator(client, item)
		client:AddLimitedObject(generator.uniqueID, entity)
		client:RegisterEntityToRemoveOnLeave(entity)

		local physicsObject = entity:GetPhysicsObject()

		if physicsObject and physicsObject:IsValid() then
			physicsObject:EnableMotion(false)
		end

		-- We don't want the instance to dissappear, because we want to attach it to the entity so the same item can later be picked up
		local inventory = ix.item.inventories[item.invID]
		inventory:Remove(item.id, false, true)

		return false
	end,
}

ITEM.functions.zDestroy = {
    name = "Destroy",
	icon = "icon16/cross.png",

    OnClick = function(item)
		Derma_Query("Are you sure you want to destroy this generator?", "Destroy Generator", "Yes", function()
			Schema.util.RunInventoryAction(item:GetID(), item.invID, "zDestroy")
		end, "No", function() end)

		-- We will manually send the inventory action
		return false
	end,

	OnRun = function(item)
        local client = item.player

        client:EmitSound("ambient/materials/dinnerplates1.wav", 75, 200)

        ix.log.Add(client, "itemDestroy", item:GetName(), item:GetID())

		return true
	end,
}
