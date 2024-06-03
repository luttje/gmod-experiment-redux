local PLUGIN = PLUGIN

function PLUGIN:SaveData()
	self:SaveBelongings()
end

function PLUGIN:LoadData()
	self:LoadBelongings()
end

function PLUGIN:CanTransferItem(item, sourceInventory, targetInventory)
	if (targetInventory.vars and targetInventory.vars.belongingsEntity) then
		return false
	end
end

function PLUGIN:OnItemTransferred(item, sourceInventory, targetInventory)
	self:RemoveIfEmpty(sourceInventory)
end

function PLUGIN:OnPlayerCorpseNotCreated(client)
	self:CreateBelongings(client)
end

function PLUGIN:OnPlayerCorpseRemoved(client, corpse)
    if (not corpse.ixInventory) then
        return
    end

    Schema.CloseInventory(corpse.ixInventory)

    if (self:HandleCorpseEmpty(corpse)) then
		return
	end

    self:CreateBelongings(client, corpse)
end

function PLUGIN:OnMonsterCorpseRemoved(corpse)
	if (not corpse.ixInventory) then
		return
	end

    Schema.CloseInventory(corpse.ixInventory)

    if (self:HandleCorpseEmpty(corpse)) then
		return
	end

	self:CreateBelongingsForMonster(corpse)
end

function PLUGIN:OnPlayerCorpseCreated(client, corpse)
	corpse.expIsBelongings = true
end

function PLUGIN:EntityTakeDamage(entity, damageInfo)
	local inflictor = damageInfo:GetInflictor()

	if (inflictor) then
		local inflictorClass = inflictor:GetClass()

		if (inflictorClass == "exp_belongings") then
			damageInfo:SetDamage(0)
			return
		end
	end
end

function PLUGIN:CanPlayerHoldObject(client, entity)
	if (entity:GetClass() == "exp_belongings") then
		return true
	end
end
