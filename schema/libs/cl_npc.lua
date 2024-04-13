Schema.npc = Schema.npc or {}

net.Receive("expNpcInteractShow", function(length)
	local interaction = net.ReadTable()

	if (IsValid(Schema.npc.panel)) then
		Schema.npc.panel:SetInteraction(interaction)
		return
	end

	local frame = vgui.Create("expNpcInteraction")
	frame:SetInteraction(interaction)
end)
