Schema.npc = Schema.npc or {}

util.AddNetworkString("expNpcInteractShow")
util.AddNetworkString("expNpcInteractResponse")
util.AddNetworkString("expNpcInteractEnd")

function Schema.npc.StartInteraction(client, npcEntity, desiredInteraction)
	local distance = client:GetPos():Distance(npcEntity:GetPos())

	if (distance > ix.config.Get("maxInteractionDistance")) then
		client:Notify("You are too far away from this NPC to interact with them.")
		return
	end

	local npcID = npcEntity:GetNpcId()
	local npc = Schema.npc.Get(npcID)

	if (not npc) then
		ErrorNoHalt("Attempted to interact with an invalid NPC interaction.\n")
		return
	end

	local interaction = npc:OnInteract(client, npcEntity, desiredInteraction)

    client.expCurrentInteraction = {
		npcEntity = npcEntity,
		npc = npc,
		interaction = interaction,
	}

	net.Start("expNpcInteractShow")
	net.WriteString(npcID)
	net.WriteString(interaction)
	net.Send(client)
end

--- Marks an interaction as completed for a player, optionally within a scope (e.g: belonging to a quest/npc)
---@param client any
---@param interaction any
---@param scope? any
function Schema.npc.CompleteInteraction(client, interaction, scope)
	local character = client:GetCharacter()

	if (character) then
		local completed = character:GetData("npcInteractions", {})
		completed[interaction] = completed[interaction] or {}

		if (scope) then
			completed[interaction][scope] = os.time()
		else
			completed[interaction] = os.time()
		end

		character:SetData("npcInteractions", completed)
	end
end

net.Receive("expNpcInteractResponse", function(length, client)
	local response = net.ReadString()

	if (not client.expCurrentInteraction) then
		client:Notify("You are not currently interacting with an NPC!")
		return
	end

	local npcEntity = client.expCurrentInteraction.npcEntity

	local npcID = npcEntity:GetNpcId()
	local npc = Schema.npc.Get(npcID)

	if (not npc) then
		ErrorNoHalt("Attempted to interact with an invalid NPC interaction.\n")
		return
	end

	local interaction = client.expCurrentInteraction.interaction

	if (not interaction) then
		ErrorNoHalt("Attempted to interact with an invalid NPC interaction.\n")
		return
	end

	Schema.npc.StartInteraction(client, npcEntity, response)
end)

net.Receive("expNpcInteractEnd", function(length, client)
	if (not client.expCurrentInteraction) then
		client:Notify("You are not currently interacting with an NPC!")
		return
	end

	local npcEntity = client.expCurrentInteraction.npcEntity

	local npcID = npcEntity:GetNpcId()
	local npc = Schema.npc.Get(npcID)

	if (not npc) then
		ErrorNoHalt("Attempted to interact with an invalid NPC interaction.\n")
		return
	end

	if (npc.OnEnd) then
		npc:OnEnd(client, npcEntity)
	end
end)
