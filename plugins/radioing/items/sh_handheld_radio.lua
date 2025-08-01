local PLUGIN = PLUGIN
local ITEM = ITEM

ITEM.name = "Handheld Radio"
ITEM.price = 75
ITEM.shipmentSize = 5
ITEM.model = "models/deadbodies/dead_male_civilian_radio.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Reusables"
ITEM.description = "A shiny handheld radio with a frequency tuner."

if (SERVER) then
	util.AddNetworkString("RadioSetFrequency")

	resource.AddFile("models/deadbodies/dead_male_civilian_radio.mdl")
	resource.AddFile("materials/models/deadbodies/corpse_01_radio.vmt")
elseif (CLIENT) then
	function ITEM:PopulateTooltip(tooltip)
		local panel = tooltip:AddRowAfter("name", "frequency")
		panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		panel:SetText(L("frequency", self:GetData("frequency", "101.1")))
		panel:SizeToContents()
	end

	net.Receive("RadioSetFrequency", function()
		local itemID = net.ReadUInt(32)
		local item = ix.item.instances[itemID]
		local currentFrequency = item and item:GetData("frequency", "101.1") or "101.1"

		Derma_StringRequest("Frequency", "What would you like to set the frequency to?", currentFrequency,
			function(frequency)
				local frequency = tonumber(frequency)
				local success, fault = PLUGIN:ValidateFrequency(frequency)

				if (not success) then
					LocalPlayer():Notify(fault)
					return
				end

				ix.command.Send("SetFrequency", frequency, itemID)
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
			net.WriteUInt(item:GetID(), 32)
			net.Send(item.player)
		end

		return false
	end
}
