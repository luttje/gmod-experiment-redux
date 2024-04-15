Schema.npc = ix.util.GetOrCreateCommonLibrary("NPC", function() return setmetatable({}, Schema.meta.npc) end)

util.AddNetworkString("expNpcInteractShow")
util.AddNetworkString("expNpcInteractResponse")
util.AddNetworkString("expNpcInteractEnd")

function Schema.npc.SpawnEntity(npc, position, angles)
    npc = isstring(npc) and Schema.npc.Get(npc) or npc

	local npcEntity = ents.Create("exp_npc")
	npcEntity:SetupNPC(npc)
	npcEntity:SetPos(position)
	npcEntity:SetAngles(angles)
	npcEntity:Spawn()

	return npcEntity
end

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

	if (not interaction) then
		return
	end

    client.expCurrentInteraction = {
		npcEntity = npcEntity,
		npc = npc,
		interaction = interaction,
	}

	net.Start("expNpcInteractShow")
	net.WriteEntity(npcEntity)
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

    local interactionData = npc:GetInteraction(interaction)

	if (interactionData.registersCompletion) then
		Schema.npc.CompleteInteraction(client, interaction, npcID)
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

hook.Add("SaveData", "expSaveNpcData", function()
	local npcData = {}

	for _, npc in pairs(ents.FindByClass("exp_npc")) do
		npcData[#npcData + 1] = {
            id = npc:GetNpcId(),
            position = npc:GetPos(),
            angles = npc:GetAngles(),
		}
	end

    Schema:SetData({
		npcData = npcData,
	})
end)

hook.Add("LoadData", "expLoadNpcData", function()
	local data = Schema:GetData()

    if (not data) then
        return
    end

	local npcData = data.npcData or {}

	for _, npc in ipairs(npcData) do
		Schema.npc.SpawnEntity(npc.id, npc.position, npc.angles)
	end
end)
