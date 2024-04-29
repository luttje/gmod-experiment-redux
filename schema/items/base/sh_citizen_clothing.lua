local ITEM = ITEM

--[[
	This base changes how bodygroups are applied to the player model.
	instead of removing the body groups from the character (like helix does), we just overlay the
	item bodygroups. When the item is removed, the character's original bodygroups are restored.

	This will only work for items that match the citizen model's bodygroups.

	! WARNING: Currently this doesn't conflict with any models, like the exo skeleton, because it
	! has no bodygroups. In the future, if we have items with the same body group names as the
	! citizens, we'll have to either save the original bodygroups or unequip the clothing.
--]]

ITEM.base = "base_armor"
ITEM.name = "Clothing"
ITEM.description = "A suitcase full of clothes."
ITEM.model = Model("models/props_c17/suitcase_passenger_physics.mdl")
ITEM.category = "Clothing"
ITEM.width = 1
ITEM.height = 1
ITEM.iconCam = {
	pos = Vector(0, -2, 200),
	ang = Angle(90, 0, 90),
	fov = 7.65
}
-- ITEM.bodyGroups = {
-- 	["legs"] = 0,
-- }

function ITEM:CanEquipOutfit()
	local client = self.player

	return IsValid(client) and client:GetModel():lower():StartsWith("models/hl2rp/citizens/")
end

function ITEM:AddOutfit(client)
	local character = client:GetCharacter()

	self:SetData("equip", true)

	if (self.newSkin) then
		-- TODO: Rethink this
		-- character:SetData("oldSkin" .. self.outfitCategory, self.player:GetSkin())
		-- self.player:SetSkin(self.newSkin)
		error("ITEM.newSkin is not implemented yet.")
	end

	if (istable(self.bodyGroups)) then
		for bodyGroupName, value in pairs(self.bodyGroups) do
			local index = client:FindBodygroupByName(bodyGroupName)

			if (index > -1) then
				client:SetBodygroup(index, value)
			end
		end
	end

	local materials  = self:GetData("submaterial", {})

	if (!table.IsEmpty(materials) and self:ShouldRestoreSubMaterials()) then
		for k, v in pairs(materials) do
			if (!isnumber(k) or !isstring(v)) then
				continue
			end

			client:SetSubMaterial(k - 1, v)
		end
	end

	if (istable(self.attribBoosts)) then
		for k, v in pairs(self.attribBoosts) do
			character:AddBoost(self.uniqueID, k, v)
		end
	end

	self:OnEquipped()
end

local function ForEachSubMaterial(client, callback)
	for materialIndex, defaultValue in ipairs(client:GetMaterials()) do
		callback(materialIndex, defaultValue)
	end
end

function ITEM:RemoveOutfit(client)
	local client = self.player -- client was nil somehow?
	local character = client:GetCharacter()

	self:SetData("equip", false)

	local materials = {}

	ForEachSubMaterial(client, function(materialIndex)
		materials[materialIndex] = client:GetSubMaterial(materialIndex - 1)
	end)

	-- Save outfit submaterials
	if (!table.IsEmpty(materials)) then
		self:SetData("submaterial", materials)
	end

	-- Remove outfit submaterials
	ForEachSubMaterial(client, function(materialIndex)
		client:SetSubMaterial(materialIndex - 1)
	end)

	-- Restore the original player model skin
	if (self.newSkin) then
		-- TODO: Rethink this
		-- if (character:GetData("oldSkin" .. self.outfitCategory)) then
		-- 	client:SetSkin(character:GetData("oldSkin" .. self.outfitCategory))
		-- 	character:SetData("oldSkin" .. self.outfitCategory, nil)
		-- else
		-- 	client:SetSkin(0)
		-- end
		error("ITEM.newSkin is not implemented yet.")
	end

	if (istable(self.bodyGroups)) then
		local characterBodyGroups = character:GetData("groups", {})

		for bodyGroupName, _ in pairs(self.bodyGroups) do
			local index = client:FindBodygroupByName(bodyGroupName)

			if (index > -1) then
				client:SetBodygroup(index, characterBodyGroups[index] or 0)
			end
		end
	end

	if (istable(self.attribBoosts)) then
		for k, _ in pairs(self.attribBoosts) do
			character:RemoveBoost(self.uniqueID, k)
		end
	end

	for k, _ in pairs(self:GetData("outfitAttachments", {})) do
		self:RemoveAttachment(k, client)
	end

	self:OnUnequipped()
end
