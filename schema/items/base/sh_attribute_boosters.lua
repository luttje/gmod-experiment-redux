local ITEM = ITEM

ITEM.name = "Stimpack"
ITEM.model = "models/props_c17/trappropeller_lever.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Stimpacks"
ITEM.description = "A Stimpack branded stimulator promising to enhance the body."
-- ITEM.boostSound = "items/medshot4.wav"
-- ITEM.attributeBoosts = {
	-- Example:
	-- ["agility"] = {
	-- 	amount = 25,
	-- 	duration = 3600
	-- },
	-- ["acrobatics"] = {
	-- 	amount = 25,
	-- 	duration = 3600
	-- }
-- }

ITEM.functions.Consume = {
    OnRun = function(item)
        local client = item.player
		local character = client:GetCharacter()

        for attributeKey, data in pairs(item.attributeBoosts) do
            local attribute = ix.attributes.list[attributeKey]

			if (not attribute) then
				-- In case the attribute plugin is disabled, we skip this attribute.
				continue
			end

			local boostID = "item#"..item.uniqueID
            character:AddBoost(boostID, attributeKey, data.amount)
            client:QueueBoostRemove(boostID, attributeKey, data.duration)
        end

		if (item.GetEmitBoostSound) then
            client:EmitSound(item:GetEmitBoostSound())
		else
			client:EmitSound(item.boostSound or "items/medshot4.wav")
		end

		if (item.OnBoosted) then
			item:OnBoosted()
		end
	end
}
