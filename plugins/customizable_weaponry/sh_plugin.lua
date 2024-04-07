local PLUGIN = PLUGIN

PLUGIN.name = "Customizable Weaponry"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds the Customizable Weaponry to the schema."

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sh_hooks.lua")

local conVarsToSet = {
	["tacrp_funny_loudnoises"] = { isServer = true, value = 0 },
	["tacrp_checknews"] = { isServer = true, value = 0 },
	["tacrp_hud"] = { isServer = true, value = 0 },
	["tacrp_drawhud"] = { isServer = false, value = 0 },
	["tacrp_shutup"] = { isServer = false, value = 1 },
	["tacrp_hints"] = { isServer = false, value = 0 },

	-- Note that without setting this to false the server errors in TacRP.LoadAtt.
	-- This is because Material("*.png") fails to load on the server
	-- See https://wiki.facepunch.com/gmod/Global.Material#description
	["tacrp_generateattentities"] = { isServer = true, value = false },
}

for conVarName, value in pairs(conVarsToSet) do
	if (value.isServer and not SERVER) then
		continue
	elseif (!value.isServer and not CLIENT) then
		continue
	end

    local conVar = GetConVar(conVarName)
	value = value.value

	if (!conVar) then
		ErrorNoHalt("ConVar " .. conVarName .. " does not exist in conVarsToSet.")
		continue
	end

	if (isbool(value)) then
		conVar:SetBool(value)
	elseif (isnumber(value)) then
        conVar:SetInt(value)
	elseif (isstring(value)) then
        conVar:SetString(value)
    else
		ErrorNoHalt("Invalid value type for conVar " .. conVarName .. " in conVarsToSet.")
	end
end

function PLUGIN:SetupCustomizableWeaponItem(item)
    local swep = weapons.Get(item.class)

	if (not swep) then
		-- Error commented because half life weapons cannot be fetched with weapons.Get
		-- error("Attempt to register item for invalid weapon '" .. item.class .. "'.")
		return
	end

	if (not weapons.IsBasedOn(item.class, "tacrp_base")) then
		return
	end

    local attachmentSlots = swep.Attachments

    for attachmentSlotId, attachmentSlot in ipairs(attachmentSlots) do
        local name = attachmentSlot.PrintName
        local attachmentCategories = attachmentSlot.Category

        if (isstring(attachmentCategories)) then
            attachmentCategories = { attachmentCategories }
        end

		item.functions["toggle" .. name] = {
			name = "(Admin) Toggle Attachments " .. name,
			icon = "icon16/wrench.png",
			isMulti = true,
			multiOptions = function(item, client)
				local attachedAttachments = item:GetData("attachments", {})
				local options = {}

				for _, attachmentCategory in ipairs(attachmentCategories) do
					local attachments = TacRP.GetAttsForCats(attachmentCategory)

					for __, attachmentName in ipairs(attachments) do
						local attachment = TacRP.GetAttTable(attachmentName)
                        local hasAttachment = false

						for _, attachedAttachmentName in pairs(attachedAttachments) do
							if (attachedAttachmentName == attachmentName) then
								hasAttachment = true
								break
							end
						end

						options[attachmentName] = {
							name = (hasAttachment and "Remove" or "Add") .. " " .. attachment.PrintName,
							icon = hasAttachment and "icon16/delete.png" or "icon16/add.png",
							data = {
								category = attachmentSlotId,
								name = attachmentName,
								remove = hasAttachment
							},
						}
					end
				end

				return options
			end,

			OnRun = function(item, data)
                local attachments = item:GetData("attachments", {})

				if (not data.category or not data.name) then
					-- happens when the category, not an attachment, is selected
					return false
				end

				-- TODO: Unattach existing attachments of the same type into inventory item
				if (data.remove) then
					item.player:Notify("You have removed the attachment.")
					attachments[data.category] = nil
				else
					item.player:Notify("You have added the attachment.")
					attachments[data.category] = data.name
				end

                item:SetData("attachments", attachments)

				if (item:GetData("equip")) then
					local weapon = item.player:GetWeapon(item.class)

                    if (IsValid(weapon) and weapon.ixItem == item) then
						if (data.remove) then
							weapon:Detach(data.category, true, true)
						else
							weapon:Detach(data.category, true, true)
							weapon:Attach(data.category, data.name, true, true)
						end

						weapon:NetworkWeapon()
						TacRP:PlayerSendAttInv(client)
					end
				end

				return false
			end,

			OnCanRun = function(item)
				return item.player:IsAdmin()
			end
		}
	end
end
