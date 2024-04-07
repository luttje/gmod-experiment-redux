local ITEM = ITEM

ITEM.name = "Breach"
ITEM.price = 150
ITEM.model = "models/props_wasteland/prison_padlock001a.mdl"
ITEM.plural = "Breaches"
ITEM.width = 1
ITEM.height = 1.5
ITEM.description = "A small device which looks similiar to a padlock."

ITEM.functions.Place = {
	OnRun = function(item)
		local client = item.player
		local trace = client:GetEyeTraceNoCursor()

		if (trace.HitPos:Distance(client:GetShootPos()) > 192) then
			client:Notify("You are not close enough to the entity!")

			return false
		end

		local entity = trace.Entity

		if (not IsValid(entity)) then
			client:Notify("You are not looking at a valid entity!")

			return false
		end

		if (not hook.Run("PlayerCanBreachEntity", client, entity)) then
			client:Notify("This entity cannot be breached!")

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
		local trace = client:GetEyeTraceNoCursor()

		if (trace.HitPos:Distance(client:GetShootPos()) > 192) then
			return false
		end

		return true
	end
}
