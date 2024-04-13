Schema.npc = Schema.npc or {}

net.Receive("expNpcInteractShow", function(length)
	local npcID = net.ReadString()
    local interaction = net.ReadString()

    local npc = Schema.npc.Get(npcID)

    if (not npc) then
        ErrorNoHalt("Attempted to interact with an invalid NPC.")
        return
    end

    interaction = npc:GetInteraction(interaction)

	if (not interaction) then
		ErrorNoHalt("Attempted to interact with an invalid NPC interaction.\n")
		return
	end

	if (IsValid(Schema.npc.panel)) then
		Schema.npc.panel:SetInteraction(interaction, npc)
		return
	end

	local frame = vgui.Create("expNpcInteraction")
	frame:SetInteraction(interaction, npc)
end)
