local ITEM = ITEM

ITEM.name = "Breach"
ITEM.price = 295
ITEM.model = "models/props_wasteland/prison_padlock001a.mdl"
ITEM.width = 1
ITEM.height = 2
ITEM.description = "A device that will breach a door protected by a door protector. Place on the door and shoot it to breach."

ITEM.functions.Place = {
	OnRun = function(item)
		local client = item.player
		local success, message, trace = client:TryTraceInteractAtDistance(true)

        if (not success) then
			client:Notify(message)

			return false
		end

		local entity = trace.Entity
		local canBreach = hook.Run("PlayerCanBreachEntity", client, entity)

		if (not canBreach and (not IsValid(entity) or not entity:IsDoor())) then
			client:Notify("You are not looking at an entity that can be breached!")

			return false
		end

		local breach = ents.Create("exp_breach")
		breach:Spawn()

		if (IsValid(entity.breach)) then
			entity.breach:RemoveWithEffect()
		end

		breach:SetBreachEntity(entity, trace)
	end,

	OnCanRun = function(item)
        local client = item.player

        -- Ensure it's in the player's inventory
        if (not client or item.invID ~= client:GetCharacter():GetInventory():GetID()) then
            return false
        end

		local success, message, trace = client:TryTraceInteractAtDistance(true)

		if (not success) then
			return false
		end

		return true
	end
}
