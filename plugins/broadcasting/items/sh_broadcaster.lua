local ITEM = ITEM

ITEM.name = "Broadcaster"
ITEM.price = 2500
ITEM.model = "models/props_lab/citizenradio.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Perpetuities"
ITEM.description = "An antique broadcaster, do you think this'll still work?"
ITEM.maximum = 5

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

ITEM.functions.Deploy = {
	OnRun = function(item)
		local client = item.player

		if (client:IsObjectLimited("broadcasters", item.maximum)) then
			client:Notify("You can not place this as you have reached the maximum amount of this item!")
			return false
		end

		local success, message, trace = client:TryTraceInteractAtDistance()

		if (not success) then
			client:Notify(message)

			return false
		end

		local entity = ents.Create("exp_broadcaster")
		entity:SetupBroadcaster(client, item)
		entity:SetModel(item.model)
		entity:SetPos(trace.HitPos)
		entity:Spawn()
		client:AddLimitedObject("broadcasters", entity)
		client:RegisterEntityToRemoveOnLeave(entity)
		Schema.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)

		-- We don't want the instance to dissappear, because we want to attach it to the entity so the same item can later be picked up
		-- For this reason we manually transfer the item to the world(0)
		item:Transfer(0, nil, nil, nil, false, true)
		return false
	end,

	OnCanRun = function(item)
		local client = item.player

		-- Ensure it's in the player's inventory
		return client and item.invID == client:GetCharacter():GetInventory():GetID()
	end
}

ITEM.functions.Toggle = {
	OnRun = function(item)
		local client = item.player
		local success, message, trace = client:TryTraceInteractAtDistance()

		if (not success) then
			client:Notify(message)

			return false
		end

		local entity = trace.Entity

		if (not IsValid(entity) or entity:GetClass() ~= "exp_broadcaster") then
			client:Notify("You must be looking at a broadcaster to toggle it!")

			return false
		end

		entity:Toggle()
	end,

	OnCanRun = function(item)
		local client = item.player
		local success, message, trace = client:TryTraceInteractAtDistance()

		if (not success) then
			return false
		end

		local entity = trace.Entity

		return IsValid(entity) and entity:GetClass() == "exp_broadcaster"
	end
}
