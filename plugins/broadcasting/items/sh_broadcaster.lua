local ITEM = ITEM

ITEM.name = "Broadcaster"
ITEM.price = 10000
ITEM.model = "models/props_lab/citizenradio.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Perpetuities"
ITEM.description = "An antique broadcaster, do you think this'll still work?"
ITEM.maximum = 5

ITEM.functions.Deploy = {
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local trace = client:GetEyeTraceNoCursor()

		if (trace.HitPos:Distance(client:GetShootPos()) > 192) then
			client:Notify("You cannot drop a broadcaster that far away!")

			return false
		end

		local entity = ents.Create("exp_broadcaster")
		entity:SetupBroadcaster(client, item)
		entity:SetModel(item.model)
		entity:SetPos(trace.HitPos)
		entity:Spawn()
		Schema.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)

		if (not client:TryAddLimitedObject("broadcasters", entity, item.maximum)) then
            entity:Remove()
			client:Notify("You can not place this as you have reached the maximum amount of this item!")
			return false
		end

		-- We don't want the instance to dissappear, because we want to attach it to the entity so the same item can later be picked up
		local inventory = ix.item.inventories[item.invID]
		inventory:Remove(item.id, false, true)
		return false
	end
}

ITEM.functions.Toggle = {
	OnRun = function(item)
		local client = item.player
		local trace = client:GetEyeTraceNoCursor()
		local entity = trace.Entity

		if (not IsValid(entity) or entity:GetClass() ~= "exp_broadcaster") then
			client:Notify("You must be looking at a broadcaster to toggle it!")

			return false
		end

		entity:Toggle()
	end,

	OnCanRun = function(item)
		local client = item.player
		local trace = client:GetEyeTraceNoCursor()
		local entity = trace.Entity

		return IsValid(entity) and entity:GetClass() == "exp_broadcaster"
	end
}
