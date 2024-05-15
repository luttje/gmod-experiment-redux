local PLUGIN = PLUGIN

PLUGIN.name = "Customizable Weaponry"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds the Customizable Weaponry to the schema."

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")

local conVarsToSet = {
	["tacrp_funny_loudnoises"] = { isServer = true, value = false },
	["tacrp_checknews"] = { isServer = true, value = false },
	["tacrp_hud"] = { isServer = true, value = false },
	["tacrp_drawhud"] = { isServer = false, value = false },
	["tacrp_shutup"] = { isServer = false, value = true },
	["tacrp_hints"] = { isServer = false, value = false },

	-- Note that without setting this to false the server errors in TacRP.LoadAtt.
	-- This is because Material("*.png") fails to load on the server
	-- See https://wiki.facepunch.com/gmod/Global.Material#description
	["tacrp_generateattentities"] = { isServer = true, value = false },

	-- Balance recoil, damage and other features
	["tacrp_mult_recoil_kick"] = { isServer = true, value = 0.75 },
	["tacrp_mult_recoil_vis"] = { isServer = true, value = 0.85 },
	["tacrp_sway"] = { isServer = true, value = false }, -- false disables: Weapon point of aim will move around gently. While aiming, hold sprint key to hold breath and steady aim
	["tacrp_freeaim"] = { isServer = true, value = false }, -- false disables: While not aiming, moving around will cause the crosshair to move off center
	["tacrp_autoreload"] = { isServer = false, value = false }
	-- ["tacrp_physbullet"] = false, -- false disables: Bullets will be hitscan up to a certain range depending on muzzle velocity
	-- ["tacrp_recoilpattern"] = false,
	-- ["tacrp_altrecoil"] = false, -- false disables: If enabled, gaining bloom intensifies recoil but does not modify spread.\nIf disabled, gaining bloom increases spread but does not modify recoil kick (old behavior).\nBloom is gained when firing consecutive shots.
	-- ["tacrp_mult_damage"] = 0.5,
	-- ["tacrp_mult_damage_magnum"] = 0.8,
	-- ["tacrp_mult_damage_sniper"] = 0.8,
	-- ["tacrp_mult_damage_shotgun"] = 0.8,
	-- ["tacrp_mult_damage_explosive"] = 0.5,
	-- ["tacrp_penalty_reload"] = false,
	-- ["tacrp_penalty_melee"] = false,
}

Schema.util.ForceConVars(conVarsToSet)

PLUGIN.compatibleItemsLookup = PLUGIN.compatibleItemsLookup or {}

function PLUGIN:GetCompatibleItems(attachmentId)
	local attachment = TacRP.GetAttTable(attachmentId)
	local categories = istable(attachment.Category) and attachment.Category or { attachment.Category }
	local compatibleItems = {}

	for _, category in ipairs(categories) do
		local items = self.compatibleItemsLookup[category]

		if (items) then
			for _, item in ipairs(items) do
				compatibleItems[item.uniqueID] = item
			end
		end
	end

	return compatibleItems
end

function PLUGIN:InitializedPlugins()
	local items = ix.item.list

	for _, item in pairs(items) do
		if (item.base ~= "base_customizable_weaponry") then
			continue
		end

		local swep = weapons.Get(item.class)

		if (not swep or not swep.Attachments) then
			continue
		end

		for attachmentSlotId, attachmentSlot in pairs(swep.Attachments) do
			local categories = istable(attachmentSlot.Category) and attachmentSlot.Category or { attachmentSlot.Category }

			for _, category in ipairs(categories) do
				if (not self.compatibleItemsLookup[category]) then
					self.compatibleItemsLookup[category] = {}
				end

				local newIndex = #self.compatibleItemsLookup[category] + 1
				self.compatibleItemsLookup[category][newIndex] = item
			end
		end
	end
end
