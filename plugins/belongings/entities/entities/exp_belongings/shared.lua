ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Experiment Redux"
ENT.PrintName = "Belongings"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.UsableInVehicle = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", "ID")
	self:NetworkVar("Int", "OwnerID")
end

function ENT:GetInventory()
	return ix.item.inventories[self:GetID()]
end

function ENT:GetOwnerName(client)
    local ownerName = CLIENT and L "someone" or L("someone", client)
    local ownerID = self:GetOwnerID()

	if (ownerID == 0) then
		return ownerName, false
	end

    local character = ix.char.loaded[ownerID]
	local isOwner = false

	if (not client and CLIENT) then
		client = LocalPlayer()
	end

	if (character) then
        local ourCharacter = client:GetCharacter()

        if (ourCharacter and character and ourCharacter:DoesRecognize(character)) then
            ownerName = character:GetName()

			isOwner = ourCharacter:GetID() == character:GetID()
        end
	end

	return ownerName, isOwner
end
