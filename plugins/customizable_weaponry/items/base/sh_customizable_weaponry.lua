local ITEM = ITEM

ITEM.base = "base_weapons"
ITEM.name = "TacRP Weapon"
ITEM.description = "A weapon that can be enhanced with attachments."

function ITEM:OnEquipWeapon(client, weapon)
	local attachments = self:GetData("attachments", {})

	if (not IsValid(weapon)) then
		return
	end

	for attachmentSlotId, attachmentData in pairs(attachments) do
		weapon:Attach(attachmentSlotId, attachmentData.id, true, true)
	end

	weapon:NetworkWeapon()
	TacRP:PlayerSendAttInv(client)
end

ITEM.functions.DetachAttachment = {
	name = "Detach Attachment",
	icon = "icon16/circlecross.png",
	isMulti = true,
	multiOptions = function(item, client)
		local attachments = item:GetData("attachments", {})
		local options = {}

		for attachmentSlotId, attachmentData in pairs(attachments) do
			local attachment = TacRP.GetAttTable(attachmentData.id)

			options[attachmentSlotId] = {
				name = "Remove " .. attachment.PrintName,
				data = {
					attachmentSlotId = attachmentSlotId,
				},
			}
		end

		return options
	end,

	OnRun = function(weaponItem, data)
		local client = weaponItem.player
		local attachments = weaponItem:GetData("attachments", {})
		local attachmentSlotId = data.attachmentSlotId
		local attachmentData = attachments[attachmentSlotId]

		if (not attachmentData) then
			client:Notify("This attachment is not attached to the weapon.")

			return false
		end

		local attachmentItem = ix.item.instances[attachmentData.itemID]

		if (not attachmentItem) then
			ErrorNoHalt("Attachment item not found for item " .. weaponItem.uniqueID .. " when attempting to detach from weapon.\n")
			client:Notify("This attachment no longer belongs to a valid item.")

			return false
		end

		-- Return the item to the player's inventory if there's space
		local targetInventory = client:GetCharacter():GetInventory()
		local x, y, bagInv = targetInventory:FindEmptySlot(attachmentItem.width, attachmentItem.height)

		if (not (x and y)) then
			client:Notify("You do not have enough space in your inventory to detach this attachment.")

			return false
		end

		if (bagInv) then
			targetInventory = bagInv
		end

		attachments[attachmentSlotId] = nil
		weaponItem:SetData("attachments", attachments)

		local attachmentItemData = nil -- TODO: Should we store the data of the attachment item? E.g. durability? Does Helix not do this for us?
		targetInventory:Add(attachmentItem.id, 1, attachmentItemData, x, y)

		local swep = weapons.Get(weaponItem.class)

		if (swep and swep.Attachments and swep.Attachments[attachmentSlotId]) then
			if (swep.Attachments[attachmentSlotId].DetachSound) then
				client:EmitSound(swep.Attachments[attachmentSlotId].DetachSound)
			end
		end

		if (not weaponItem:GetData("equip")) then
			return false
		end

		-- If we have the weapon equipped, immediately detach the attachment from it
		local weapon = client:GetWeapon(weaponItem.class)

		if (IsValid(weapon) and weapon.ixItem == weaponItem) then
			weapon:Detach(attachmentSlotId, true, true)
			weapon:NetworkWeapon()
			TacRP:PlayerSendAttInv(client)
		end

		return false
	end,

	OnCanRun = function(item)
		local attachments = item:GetData("attachments", {})

		return table.Count(attachments) > 0
	end,
}

if (CLIENT) then
    function ITEM:PopulateTooltip(tooltip)
        local attachments = self:GetData("attachments", {})
        local swep = weapons.Get(self.class)
        local ammo = swep.Primary.Ammo

		if (weapons.IsBasedOn(self.class, "tacrp_base")) then
			ammo = swep.Ammo -- For TacRP
		end

		ammo = Schema.ammo.ConvertToCalibreName(ammo)

        local panel = tooltip:AddRowAfter("name", "ammo")
        panel:SetBackgroundColor(derma.GetColor("Info", tooltip))
        panel:SetText("Ammo: " .. ammo)
		panel:SizeToContents()

        for attachmentSlotId, attachmentData in pairs(attachments) do
            local attachment = TacRP.GetAttTable(attachmentData.id)

            local panel = tooltip:AddRowAfter("ammo", "attachments" .. attachmentSlotId)
            panel:SetBackgroundColor(derma.GetColor("Warning", tooltip))
            panel:SetText(attachment.PrintName)
            panel:SizeToContents()
        end

		return tooltip
	end
end
