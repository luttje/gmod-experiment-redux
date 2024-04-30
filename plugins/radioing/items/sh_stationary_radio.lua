local ITEM = ITEM

ITEM.name = "Stationary Radio"
ITEM.price = 200
ITEM.model = "models/props_lab/citizenradio.mdl"
ITEM.width = 2
ITEM.height = 3
ITEM.category = "Perpetuities"
ITEM.description = "An antique radio for putting on a table, do you think this'll still work?"
ITEM.maximum = 5
ITEM.data = {
	frequency = "101.1"
}

if (CLIENT) then
    function ITEM:PopulateTooltip(tooltip)
        local after = "name"

		if (self.maximum) then
			local panel = tooltip:AddRowAfter(after, "maximum")
			panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
			panel:SetText("You can only have " .. self.maximum .. " of this item in the world at a time!")
            panel:SizeToContents()

			after = "maximum"
		end

		local panel = tooltip:AddRowAfter(after, "frequency")
		panel:SetBackgroundColor(derma.GetColor("Info", tooltip))
		panel:SetText(L("frequency", self:GetData("frequency", "101.1")))
		panel:SizeToContents()
	end
end

ITEM.functions.Place = {
	OnRun = function(item)
		local client = item.player

        if (client:IsObjectLimited("stationaryRadios", item.maximum)) then
            client:Notify("You can not place this as you have reached the maximum amount of this item!")
            return false
        end

		local success, message, trace = client:TryTraceInteractAtDistance()

		if (not success) then
			client:Notify(message)

			return false
		end

		local entity = ents.Create("exp_stationary_radio")
		entity:SetupRadio(client, item)
		entity:SetPos(trace.HitPos)
		entity:Spawn()
		client:AddLimitedObject("stationaryRadios", entity)
		client:RegisterEntityToRemoveOnLeave(entity)
		Schema.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)

        item:Transfer(0, nil, nil, nil, false, true)

        -- We don't want the instance to dissappear, because we want to attach it to the entity so the same item can later be picked up
		-- For this reason we manually transfer the item to the world(0)
		return false
	end,

	OnCanRun = function(item)
        local client = item.player

        -- Ensure it's in the player's inventory
		return client and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}
