local PLUGIN = PLUGIN
local ITEM = ITEM

ITEM.name = "Handheld Radio"
ITEM.price = 100
ITEM.model = "models/props/cs_office/phone_p2.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Reusables"
ITEM.description = "A shiny handheld radio with a frequency tuner."
ITEM.data = {
	frequency = 101.1
}

if (SERVER) then
    util.AddNetworkString("RadioSetFrequency")
elseif (CLIENT) then
	function ITEM:PopulateTooltip(tooltip)
		local panel = tooltip:AddRowAfter("name", "frequency")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText(L("frequency", self:GetData("frequency", ITEM.data.frequency)))
		panel:SizeToContents()
	end

	net.Receive("RadioSetFrequency", function()
		Derma_StringRequest("Frequency", "What would you like to set the frequency to?", net.ReadString(), function(text)
			local frequency = tonumber(text)
			local success, fault = PLUGIN:ValidateFrequency(frequency)

			if (not success) then
				LocalPlayer():Notify(fault)
				return
			end

			ix.command.Send("SetFreq", text)
		end)
	end)
end

ITEM.functions.SetFrequency = {
	name = "Set Frequency",
	tip = "Set the frequency of the radio.",
	icon = "icon16/transmit_add.png",
	OnRun = function(item)
		if (SERVER) then
			net.Start("RadioSetFrequency")
			net.Send(item.player)
		end

		return false
	end
}
