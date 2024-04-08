local ITEM = ITEM

ITEM.name = "Door Protector"
ITEM.price = 300
ITEM.model = "models/props_combine/breenlight.mdl"
ITEM.width = 2
ITEM.height = 1
ITEM.noDrop = true
ITEM.category = "Wealth Generation & Protection"
ITEM.description = "When placed near doors it will prevent them from being shot open. This does not protect from breaches. The protector is not permanent and can be destroyed by others."
ITEM.maximum = 5

ITEM.functions.Place = {
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local trace = client:GetEyeTraceNoCursor()

        if (trace.HitPos:Distance(client:GetShootPos()) > 192) then
            client:Notify("You cannot place a bolt protector that far away!")

            return false
        end

		if (not client:TryAddLimitedObject("doorProtectors", entity, item.maximum)) then
            entity:Remove()
			client:Notify("You can not place this as you have reached the maximum amount of this item!")
			return false
		end

		local entity = ents.Create("exp_door_protector")
		entity:SetupDoorProtector(client)
		entity:SetPos(trace.HitPos)
		entity:Spawn()
		Schema.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
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

function ITEM:OnCanOrder(client)
	if (SERVER and client:IsObjectLimited("doorProtectors", self.maximum)) then
		client:Notify("You have reached the maximum amount of this item!")

		return false
	end
end
