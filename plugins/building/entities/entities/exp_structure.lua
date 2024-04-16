local PLUGIN = PLUGIN

if (SERVER) then
    AddCSLuaFile()
end

ENT.Type = "anim"
ENT.PrintName = "Structure Base"
ENT.IsStructure = true
ENT.PopulateEntityInfo = true

function ENT:SetupDataTables()
	self:NetworkVar("String", "ItemID")
	self:NetworkVar("Bool", "UnderConstruction")
end

function ENT:GetItemTable()
	return ix.item.list[self:GetItemID()]
end

function ENT:Draw()
    -- Don't draw the entity
	-- self:DrawModel()
end

function ENT:OnPopulateEntityInfo(tooltip)
    if (not self:GetUnderConstruction()) then
        return
    end

    local itemTable = self:GetItemTable()

	if (not itemTable) then
		return
	end

    local name = tooltip:AddRow("name")
    name:SetImportant()
    -- name:SetText(L("propHealth", self:Health(), self:GetMaxHealth()))
	name:SetText(L("propMaterialsRequired"))
    name:SizeToContents()

    local structureMaterials = self:GetNetVar("structureMaterials", {})
	local anyMaterialsRemaining = false

    for materialItem, amount in pairs(itemTable:GetConstructionMaterials()) do
        local amountRemaining = amount - (structureMaterials[materialItem] or 0)

        if (amountRemaining <= 0) then
            continue
        end

        anyMaterialsRemaining = true

        local item = ix.item.list[materialItem]
        local row = tooltip:AddRowAfter("name", "material_" .. materialItem)
        row:SetText(L("propMaterial", item.name, amountRemaining))
        row:SizeToContents()
    end

	if (not anyMaterialsRemaining) then
		local row = tooltip:AddRowAfter("name", "readyToFinishConstruction")
		row:SetText(L("readyToFinishConstruction"))
		row:SizeToContents()
	end
end

function ENT:GetEntityMenu(client)
    if (not self:GetUnderConstruction()) then
        return
    end

    local itemTable = self:GetItemTable()

    if (not itemTable) then
        return false
    end

    local options = {}

    options[L("abortConstruction")] = function() end

	local structureMaterials = self:GetNetVar("structureMaterials", {})
	local anyMaterialsRemaining = false

	for materialItem, amount in pairs(itemTable:GetConstructionMaterials()) do
        local item = ix.item.list[materialItem]
        local itemCount = client:GetCharacter():GetInventory():GetItemCount(materialItem)
		local amountRemaining = amount - (structureMaterials[materialItem] or 0)
        local fillCount = math.min(itemCount, amountRemaining)

		if (amountRemaining <= 0) then
			continue
		end

        anyMaterialsRemaining = true

        if (fillCount <= 0) then
            continue
		end

		options[L("fillMaterials", item.name, fillCount)] = function()
			ix.menu.NetworkChoice(self, "fillMaterials", {
				amount = fillCount,
				item = materialItem
			})

			-- We manually send the amount of materials to fill
			return false
		end
	end

    if (not anyMaterialsRemaining) then
		options[L("finishConstruction")] = function() end
    end

    return options
end

if (not SERVER) then
	return
end

AccessorFunc(ENT, "expClient", "Client")

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetModel("models/props_lab/huladoll.mdl")
end

function ENT:SetStructure(client, item, position, angles)
	self.expItem = item
    self:SetClient(client)

	client:RegisterEntityToRemoveOnLeave(self)

	self:SetPos(position)
	self:SetAngles(angles)

	self:SetItemID(item.uniqueID)
	self:SetHealth(item.health)

	self:SetUnderConstruction(true)
	self:BuildStructure(client, item)
end

function ENT:BuildStructure(client, item)
    local structure = item:GetStructure(client)

	for _, structurePart in ipairs(structure) do
        local structureEntity = ents.Create("exp_structure_part")
		structureEntity:SetModel(structurePart.model)
		structureEntity:SetPos(self:LocalToWorld(structurePart.position))
		structureEntity:SetAngles(self:LocalToWorldAngles(structurePart.angles))
		structureEntity:SetParent(self)
		structureEntity:Spawn()
		structureEntity:Activate()
	end
end

function ENT:OnOptionSelected(client, option, data)
    if (option == L("abortConstruction", client)) then
        local structureMaterials = self:GetNetVar("structureMaterials", {})
        -- Refund materials and return the blueprint (if they have space)
        local inventory = client:GetCharacter():GetInventory()

        for materialItem, amount in pairs(structureMaterials) do
            local success, error = inventory:Add(materialItem, amount)

            if (not success) then
                client:Notify(error)
                return
            end
        end

        local success, error = inventory:Add(self:GetItemID())

		if (not success) then
			client:Notify(error)
			return
		end

		self:RemoveWithEffect()
    elseif (option == "fillMaterials") then
        local character = client:GetCharacter()
        local inventory = character:GetInventory()

        local structureMaterials = self:GetNetVar("structureMaterials", {})
        local itemTable = self:GetItemTable()

        local amount = math.min(data.amount,
            itemTable:GetConstructionMaterials()[data.item] - (structureMaterials[data.item] or 0))

        if (amount <= 0) then
            client:Notify("You have already filled the required materials.")
            return
        end

        local items = inventory:GetItemsByUniqueID(data.item)

        if (#items < amount) then
            client:Notify("You do not have enough materials.")
            return
        end

        for i = 1, amount do
            items[i]:Remove()
        end

        structureMaterials[data.item] = (structureMaterials[data.item] or 0) + amount

        self:SetNetVar("structureMaterials", structureMaterials)

        self:CheckConstruction(client)
    elseif (option == L("finishConstruction", client)) then
		self:CheckConstruction(client)
    end
end

function ENT:CheckConstruction(client)
    local itemTable = self:GetItemTable()
    local structureMaterials = self:GetNetVar("structureMaterials", {})

    for materialItem, amount in pairs(itemTable:GetConstructionMaterials()) do
        if (amount > (structureMaterials[materialItem] or 0)) then
            return
        end
    end

    self:FinishConstruction(client)
end

function ENT:FinishConstruction(client)
    local children = self:GetChildren()

	for _, child in ipairs(children) do
        if (child.IsStructurePart) then
			child.expIsTouched = false
			child:SetTrigger(true)
		end
	end

	timer.Simple(0.1, function()
		if (not IsValid(self)) then
			return
		end

		local children = self:GetChildren()

		for _, child in ipairs(children) do
            if (not child.IsStructurePart) then
                continue
            end

			child:SetTrigger(false)

			if (child.expIsTouched) then
				if (IsValid(client)) then
					client:Notify("You cannot finish the construction while it's intersecting with another object.")
				end

				return
			end
		end

		self:SetUnderConstruction(false)

		local children = self:GetChildren()

		for _, child in ipairs(children) do
			if (child.IsStructurePart) then
				child:SetCollisionGroup(COLLISION_GROUP_NONE)
			end
		end
	end)
end

function ENT:Think()
    local client = self:GetClient()

	if (not IsValid(client) or not client:Alive()) then
		self:Remove()
		return
	end
end

function ENT:OnTakeDamage(damageInfo)
	if (self:GetUnderConstruction()) then
		return
	end

	local damage = damageInfo:GetDamage()
	local attacker = damageInfo:GetAttacker()

	if (IsValid(attacker) and attacker:IsPlayer()) then
		local structureBuilder = self:GetClient()

		if (IsValid(structureBuilder)) then
			local victimData = {
				victim = structureBuilder
			}
			local buff, buffTable = Schema.buff.GetActive(attacker, "siege_surge", victimData)

			if (buff) then
				local stacks = buffTable:GetStacks(attacker, buff)

				damage = damage * stacks
				print("Damage increased by " .. stacks .. "x (was: " .. damageInfo:GetDamage() .. ", now: " .. damage .. ")")
			end
		end
	end

	self:SetHealth(self:Health() - damage)

	-- TODO: Change color of the structure parts to indicate damage

	if (self:Health() <= 0) then
		hook.Run("StructureDestroyed", damageInfo:GetAttacker(), self)
		self:RemoveWithEffect()
	end
end
