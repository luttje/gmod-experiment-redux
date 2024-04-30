ENT.Type = "anim"
ENT.Model = "models/props_combine/combine_mine01.mdl"
ENT.PrintName = "Bolt Generator"
ENT.IsBoltGenerator = true

function ENT:SetupDataTables()
    self:NetworkVar("String", "ItemID")

    self:NetworkVar("Int", "Power")
    self:NetworkVar("Int", "Upgrades")
    self:NetworkVar("Int", "HeldBolts")

    self:NetworkVar("Int", "OwnerID")
end

function ENT:GetItemTable()
	return ix.item.list[self:GetItemID()]
end

function ENT:GetNextUpgrade(client)
	local itemTable = self:GetItemTable()

	if (not itemTable) then
		return false
	end

    local nextUpgrade = itemTable:GetNextUpgrade(self)

    if (not nextUpgrade) then
        return false
    end

    local label

	if (SERVER) then
		label = L("upgrade", client, nextUpgrade.name, ix.currency.Get(nextUpgrade.price))
	else
		label = L("upgrade", nextUpgrade.name, ix.currency.Get(nextUpgrade.price))
	end

	return nextUpgrade, label
end

function ENT:GetOwnerName(client)
	local ownerName = CLIENT and L"someone" or L("someone", client)
    local character = ix.char.loaded[self:GetOwnerID()]
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
