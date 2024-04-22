local ITEM = ITEM

ITEM.name = "Bolt Generator Informer"
ITEM.price = 200
ITEM.model = "models/props_combine/breenlight.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.noDrop = true
ITEM.category = "Protection"
ITEM.description = "Place it near your bold creators, and be informed when they take damage."
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

ITEM.functions.Place = {
	OnRun = function(item)
		local client = item.player

        if (client:IsObjectLimited("boltInformers", item.maximum)) then
            client:Notify("You can not place this as you have reached the maximum amount of this item!")
            return false
        end

		local success, message, trace = client:TryTraceInteractAtDistance()

		if (not success) then
			client:Notify(message)

			return false
		end

		local entity = ents.Create("exp_bolt_informer")
		entity:SetupBoltInformer(client)
		entity:SetPos(trace.HitPos)
        entity:Spawn()
		client:AddLimitedObject("boltInformers", entity)
		client:RegisterEntityToRemoveOnLeave(entity)
		Schema.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
	end,

	OnCanRun = function(item)
		local client = item.player
		local success, message, trace = client:TryTraceInteractAtDistance()

		if (not success) then
			return false
		end

		local character = client:GetCharacter()
		local protectors = character:GetVar("boltInformers") or {}

		if (#protectors >= 1) then
			client:Notify("You have reached the maximum amount of this item!")

			return false
		end

		return true
	end
}
