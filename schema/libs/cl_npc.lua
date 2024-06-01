Schema.npc = ix.util.GetOrCreateCommonLibrary("NPC", function() return setmetatable({}, Schema.meta.npc) end)

net.Receive("expNpcInteractShow", function(length)
	local npcEntity = net.ReadEntity()
    local interaction = net.ReadString()

    local npc = Schema.npc.Get(npcEntity:GetNpcId())

    if (not npc) then
        ix.util.SchemaErrorNoHalt("Attempted to interact with an invalid NPC.")
        return
    end

    interaction = npc:GetInteraction(interaction)

	if (not interaction) then
		ix.util.SchemaErrorNoHalt("Attempted to interact with an invalid NPC interaction.\n")
		return
	end

	if (IsValid(Schema.npc.panel)) then
		Schema.npc.panel:SetInteraction(interaction, npc, npcEntity)
		return
	end

    local panel = vgui.Create("expEntityMenu")
    panel:InitDoubleList()
	panel:SetShowCloseButton(true)
    panel:SetEntity(npcEntity)

	local interactionPanel = vgui.Create("expNpcInteraction")
	interactionPanel:SetInteraction(interaction, npc, npcEntity)

    panel:SetMainPanel(interactionPanel)
end)
