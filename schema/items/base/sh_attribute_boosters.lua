local ITEM = ITEM

ITEM.name = "Stimpack"
ITEM.model = "models/props_c17/trappropeller_lever.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Stimpacks"
ITEM.description = "A Stimpack branded stimulator promising to enhance the body."
ITEM.boostSound = "items/medshot4.wav"
ITEM.boostAttribs = {
	-- Example:
	-- ["agl"] = {
	-- 	amount = 25,
	-- 	duration = 3600
	-- },
	-- ["acr"] = {
	-- 	amount = 25,
	-- 	duration = 3600
	-- }
}

ITEM.functions.Consume = {
    OnRun = function(item)
        local client = item.player
		local character = client:GetCharacter()

        for attrib, data in pairs(item.boostAttribs) do
            character:AddBoost(item.uniqueID, attrib, data.amount)
            client:QueueBoostRemove(item.uniqueID, attrib, data.duration)
        end

		if (item.GetEmitBoostSound) then
            client:EmitSound(item:GetEmitBoostSound())
		elseif (item.boostSound) then
			client:EmitSound(item.boostSound)
		end

		if (item.OnBoosted) then
			item:OnBoosted()
		end
	end
}
