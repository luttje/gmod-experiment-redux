local ITEM = ITEM

ITEM.name = "Door Protector"
ITEM.price = 50
ITEM.model = "models/props_combine/breenlight.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Protection"
ITEM.description = "Using this you can take ownership of powered doors (they have a key symbol on them)."

ITEM.functions.Place = {
	OnRun = function(item)
		local client = item.player
		local success, message, trace = client:TryTraceInteractAtDistance(true)

        if (not success) then
			client:Notify(message)

			return false
		end

		local entity = trace.Entity

		if (not IsValid(entity) or not entity:IsDoor() or entity:GetNetVar("disabled")) then
			client:NotifyLocalized("dNotValid")

			return false
		end

		if (not entity:GetNetVar("ownable") or entity:GetNetVar("faction") or entity:GetNetVar("class")) then
			client:NotifyLocalized("dNotAllowedToOwn")
			return false
		end

		if (IsValid(entity:GetDTEntity(0)) or IsValid(entity.expProtector)) then
			-- return "@dOwnedBy", entity:GetDTEntity(0):Name()
			client:Notify("This door is already owned by someone else.")
			return false
		end

		local protector = ents.Create("exp_door_protector")
		protector:SetupDoorProtector(client, entity)
		protector:Spawn()
		client:RegisterEntityToRemoveOnLeave(protector)
	end,

	OnCanRun = function(item)
		local client = item.player
		local success, message, trace = client:TryTraceInteractAtDistance(true)

		if (not success) then
			return false
		end

		return true
	end
}
