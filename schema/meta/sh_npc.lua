local META = Schema.meta.npc or {}
Schema.meta.npc = META

META.__index = META

function META:__tostring()
    return "npc[" .. self.uniqueID .. "]"
end

function META:GetUniqueID()
    return self.uniqueID
end

function META:GetName()
    return self.name
end

function META:GetDescription()
    return self.description
end

function META:GetModel()
    return self.model
end

function META:GetInteractions()
    return self.interactions
end

function META:RegisterInteraction(uniqueID, data, registersCompletion)
    self.interactions = self.interactions or {}
	data.registersCompletion = registersCompletion
    self.interactions[uniqueID] = data

	return uniqueID
end

function META:GetInteraction(uniqueID)
    return self.interactions[uniqueID]
end

function META:OnInteract(client, npcEntity, desiredInteraction)
    if (desiredInteraction) then
        return desiredInteraction
    end

	return self.defaultInteraction
end
