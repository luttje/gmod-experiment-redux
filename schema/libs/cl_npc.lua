--- Client library that exposes functions to interact with NPCs.
--- It also has all functions a `CommonLibrary` has.
--- @class Schema.npc : CommonLibrary
Schema.npc = ix.util.GetOrCreateCommonLibrary("NPC", function() return ix.util.NewMetaObject(Schema.meta.npc) end)
Schema.npc.isInlineEditing = Schema.npc.isInlineEditing or false

ix.chat.Register("npc_me", {
	CanSay = function(self, speaker, text)
		-- Only NPCs can use this chat, they are provided through data.npcSpeakerEntity
		return not IsValid(speaker)
	end,
	OnChatAdd = function(self, speaker, text, anonymous, data)
		local format = "** %s %s"

		if (string.sub(text, 1, 1) == "'") then
			format = "** %s%s"
		end

		chat.AddText(Color(102, 205, 170), format:format(data.name, text))
	end,
	CanHear = function(self, speaker, listener, data)
		if (not IsValid(data.npcSpeakerEntity) or not IsValid(listener)) then
			return false
		end

		local range = ix.config.Get("chatRange") * 2
		return data.npcSpeakerEntity:GetPos():DistToSqr(listener:GetPos()) <= range * range
	end,
})

ix.chat.Register("npc", {
	CanSay = function(self, speaker, text)
		-- Only NPCs can use this chat, they are provided through data.npcSpeakerEntity
		return not IsValid(speaker)
	end,
	OnChatAdd = function(self, speaker, text, anonymous, data)
		local format = "%s says \"%s\""

		if (data.yelling) then
			format = "%s yells \"%s\""
		elseif (data.whispering) then
			format = "%s whispers \"%s\""
		end

		chat.AddText(Color(255, 255, 255), format:format(data.name, text))
	end,
})

--- Makes it so that when talking to NPC's, operators/admins can modify the NPC's interactions.
function Schema.npc.ToggleInlineEditor()
	if (not Schema.npc.HasManagePermission(LocalPlayer())) then
		return
	end

	Schema.npc.isInlineEditing = not Schema.npc.isInlineEditing
end

net.Receive("expNpcInteractShow", function(length)
	local npcEntity = net.ReadEntity()
	local interactionSet = net.ReadString()
	local interaction = net.ReadString()

	local npc = Schema.npc.Get(npcEntity:GetNpcId())

	if (not npc) then
		ix.util.SchemaErrorNoHaltFormatted("Attempted to interact with an invalid NPC.")
		return
	end

	interactionSet = npc:GetInteractionSet(interactionSet)

	if (not interactionSet) then
		ix.util.SchemaErrorNoHaltFormatted("Attempted to interact with an invalid NPC interaction set.\n")
		return
	end

	interaction = interactionSet:GetInteraction(interaction)

	if (not interaction) then
		ix.util.SchemaErrorNoHaltFormatted("Attempted to interact with an invalid NPC interaction.\n")
		return
	end

	if (IsValid(Schema.npc.panel)) then
		Schema.npc.panel:SetInteraction(interaction, npc, npcEntity)
		return
	end

	local panel = vgui.Create("expEntityMenu")
	panel:InitDoubleList()
	panel:SetEntity(npcEntity)

	panel:SetCallOnRemove(function()
		if (IsValid(Schema.npc.panel)) then
			Schema.npc.panel:Remove()
		end
	end)

	local interactionPanel = vgui.Create("expNpcInteraction")
	interactionPanel:SetInteraction(interaction, npc, npcEntity)

	panel:SetMainPanel(interactionPanel)
	panel:SetToRemoveOnceInvalid(interactionPanel)
end)
