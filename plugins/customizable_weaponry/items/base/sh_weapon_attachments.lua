local PLUGIN = PLUGIN
local ITEM = ITEM

ITEM.name = "TacRP Weapon Attachment"
ITEM.description = "An attachment for a weapon."
ITEM.model = "models/weapons/tacint/addons/optic_rmr_hq.mdl"
ITEM.attachmentId = "optic_rmr"
ITEM.category = "Weapon Attachments"
ITEM.requiresGunsmith = true

function ITEM:GetModel()
	if (SERVER) then
		-- Attachments are really small, so to prevent them glitching, show a bigger model when spawning the item on the server
		return "models/tacint/props_containers/supply_case-2.mdl"
	end

	return self.model
end

function ITEM:GetAttachment()
	local attachment = TacRP.GetAttTable(self.attachmentId)

	return attachment
end

-- Hack a context menu into the business panel for attachments to list compatible weapons before the player buys them
function ITEM.PaintOver(icon, itemTable, w, h)
	local parent = icon:GetParent()

	if (not parent) then
		return
	end

	if (parent:GetName() ~= "ixBusinessItem") then
		return
	end

	if (icon.expHasInjectedContextMenu) then
		return
	end

	icon.expHasInjectedContextMenu = true

	icon.DoRightClick = function(icon)
		local menu = DermaMenu()

		menu:AddOption("List Compatible Items", function()
			PLUGIN:ShowCompatibleItems(itemTable.attachmentId)
		end):SetImage("icon16/text_list_bullets.png")

		menu:Open()
	end
end

function ITEM:GetSearchMatches(search)
	local compatibleItems = PLUGIN:GetCompatibleItems(self.attachmentId)

	for _, item in pairs(compatibleItems) do
		if (item.name:lower():find(search, 1, true)) then
			return true
		end
	end

	return false
end

function ITEM:GetFilters()
	local compatibleWeapons = PLUGIN:GetCompatibleItems(self.attachmentId)
	local filters = {}

	for _, itemTable in pairs(compatibleWeapons) do
		filters["Compatible with " .. itemTable.name] = "checkbox"
	end

	return filters
end

ITEM.functions.ListCompatibleItems = {
	name = "List Compatible Items",
	icon = "icon16/text_list_bullets.png",
	OnClick = function(item)
		PLUGIN:ShowCompatibleItems(item.attachmentId)
		return false
	end,
}

ITEM.functions.Attach = {
	name = "Attach to...",
	icon = "icon16/add.png",
	isMulti = true,
	multiOptions = function(item, client)
		local character = client:GetCharacter()
		local inventory = character:GetInventory()
		local options = {}

		for _, item in ipairs(inventory:GetItemsByNestedBase("base_customizable_weaponry")) do
			options[item.id] = {
				name = item.name,
				data = {
					itemID = item.id,
				},
			}
		end

		return options
    end,

	OnRun = function(attachmentItem, data)
		local client = attachmentItem.player
		local character = client:GetCharacter()

        if (not data.itemID) then
            local inventory = character:GetInventory()
            local matchedWeapons = #inventory:GetItemsByNestedBase("base_customizable_weaponry")

			if (matchedWeapons == 0) then
				client:Notify("You do not have any weapons to attach this to.")
			else
				client:Notify("Select one of the listed weapons to attach this to.")
			end

			return false
		end

		local weaponItem = character:GetInventory():GetItemByID(data.itemID)

		if (not weaponItem) then
			client:Notify("You must select a valid weapon to attach this to.")

			return false
		end

		local attachment = attachmentItem:GetAttachment()

		if (not attachment) then
			ix.util.SchemaErrorNoHalt("Attachment not found for item " .. attachmentItem.uniqueID .. ".\n")
			client:Notify("This attachment is not valid")

			return false
		end

		-- Check if the weapon can have this attachment
		local swep = weapons.Get(weaponItem.class)

		if (not swep) then
			ix.util.SchemaErrorNoHalt("Weapon not found for item "
				.. weaponItem.uniqueID
				.. " when attaching "
				.. attachmentItem.uniqueID .. ".\n")
			client:Notify("This weapon is not valid.")

			return false
		end

        -- Find the attachment slot on the SWEP that goes with the attachment category
        local attachmentCategories = istable(attachment.Category)
			and attachment.Category
			or { attachment.Category }
        local foundAttachmentSlot

		for attachmentSlotId, attachmentSlot in ipairs(swep.Attachments) do
			local slotCategories = istable(attachmentSlot.Category)
				and attachmentSlot.Category
                or { attachmentSlot.Category }

            for _, slotCategory in ipairs(slotCategories) do
				for _, attachmentCategory in ipairs(attachmentCategories) do
					if (slotCategory == attachmentCategory) then
						foundAttachmentSlot = attachmentSlotId
						break
					end
				end
			end
		end

		if (not foundAttachmentSlot) then
			client:Notify("This weapon cannot have this attachment.")

			return false
		end

		-- Check if the weapon item's slot is already taken
		local attachments = weaponItem:GetData("attachments", {})

		if (attachments[foundAttachmentSlot]) then
			client:Notify("This weapon already has an attachment occupying this slot.")

			return false
		end

		-- Keep track of the attachment id so we can later restore the true instance
		-- This can be useful in the future, when we set item data on attachments (e.g: zeroing on scopes)
		attachments[foundAttachmentSlot] = {
			id = attachmentItem.attachmentId,
			itemID = attachmentItem.id,
		}
		weaponItem:SetData("attachments", attachments)

		attachmentItem:Transfer(0, nil, nil, nil, false, true)

		if (swep.Attachments[foundAttachmentSlot] and swep.Attachments[foundAttachmentSlot].DetachSound) then
			client:EmitSound(swep.Attachments[foundAttachmentSlot].AttachSound)
		end

		if (not weaponItem:GetData("equip")) then
			-- We have manually removed the item from the inventory (so the instance isn't destroyed)
			return false
		end

		-- If we have the weapon equipped, immediately attach the attachment to it
		local weapon = client:GetWeapon(weaponItem.class)

		if (IsValid(weapon) and weapon.ixItem == weaponItem) then
			weapon:Attach(foundAttachmentSlot, attachmentItem.attachmentId, true, true)
			weapon:NetworkWeapon()
            TacRP:PlayerSendAttInv(client)
		end

		-- We have manually removed the item from the inventory (so the instance isn't destroyed)
		return false
    end,

    OnCanRun = function(item)
        local client = item.player

        -- Ensure it's in the player's inventory
        if (not client or item.invID ~= client:GetCharacter():GetInventory():GetID()) then
            return false
        end

		return true
	end,
}
