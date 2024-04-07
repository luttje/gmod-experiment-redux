local PLUGIN = PLUGIN

do
	local COMMAND = {}

	COMMAND.description = "Set the frequency of your radio."
	COMMAND.arguments = {
		ix.type.string,
	}

    function COMMAND:OnRun(client, frequency)
        local success, fault = PLUGIN:ValidateFrequency(frequency)

		if (not success) then
			return client:Notify(fault)
		end

		local radio = hook.Run("GetRadioEntityToSetFrequency", client, frequency)

		if (radio) then
			radio:SetFrequency(frequency)

			ix.util.Notify("You have set this stationary radio's frequency to " .. frequency .. ".", client)
		else
			client:GetCharacter():SetData("frequency", frequency)

			ix.util.Notify("You have set your radio frequency to " .. frequency .. ".", client)

			hook.Run("PlayerSetFrequency", client, frequency)
		end
	end

	ix.command.Add("SetFreq", COMMAND)
end
