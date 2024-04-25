ATTRIBUTE.name = "Stamina"
ATTRIBUTE.description = "Affects your overall stamina, e.g: how fast you can run."

function ATTRIBUTE:OnSetup(client, value)
	local runSpeed = ix.config.Get("runSpeed") + value
	local hasGodspeed, godspeedPerkTable = Schema.perk.GetOwned("godspeed", client)

    if (hasGodspeed) then
        runSpeed = runSpeed * godspeedPerkTable.modifyRunSpeed
    end

	client:SetRunSpeed(runSpeed)
end
