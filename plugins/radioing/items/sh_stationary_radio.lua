local ITEM = ITEM

ITEM.name = "Stationary Radio"
ITEM.price = 200
ITEM.model = "models/props_lab/citizenradio.mdl"
ITEM.width = 2
ITEM.height = 3
ITEM.category = "Perpetuities"
ITEM.description = "An antique radio for putting on a table, do you think this'll still work?"
ITEM.data = {
	frequency = 101.1
}

if (CLIENT) then
	function ITEM:PopulateTooltip(tooltip)
		local panel = tooltip:AddRowAfter("name", "frequency")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText(L("frequency", self:GetData("frequency", ITEM.data.frequency or 101.1)))
		panel:SizeToContents()
	end
end

ITEM.functions.Place = {
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local trace = client:GetEyeTraceNoCursor()

		if (trace.HitPos:Distance(client:GetShootPos()) > 192) then
			client:Notify("You cannot drop a radio that far away!")

			return false
		end

		local entity = ents.Create("exp_stationary_radio")
		entity:SetupRadio(client, item)
		entity:SetPos(trace.HitPos)
		entity:Spawn()
		Schema.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)

		-- TODO: Limit the amount that can be spawned (TODO: This logic is repetitive, move it somewhere common)
		local radios = character:GetVar("stationaryRadios") or {}
		radios[#radios + 1] = entity
		character:SetVar("stationaryRadios", radios, true)

		-- We don't want the instance to dissappear, because we want to attach it to the entity so the same item can later be picked up
		local inventory = ix.item.inventories[item.invID]
		inventory:Remove(item.id, false, true)
		return false
	end
}
