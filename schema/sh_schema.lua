Schema.registeredWeaponAttachments = Schema.registeredWeaponAttachments or {}

Schema.name = "Experiment Redux"
Schema.Author = "Experiment Redux"
Schema.description = "It's a dog-eat-dog world out there, and these dogs have guns."
Schema.version = {
	major = 6,
	minor = 0,
	revision = 1,
	suffix = "alpha"
}

ix.util.Include("libs/thirdparty/sh_netstream2.lua")

ix.util.Include("sh_commands.lua")

ix.util.Include("cl_schema.lua")
ix.util.Include("cl_hooks.lua")

ix.util.Include("sh_configs.lua")
ix.util.Include("sh_hooks.lua")

ix.util.Include("sv_schema.lua")
ix.util.Include("sv_hooks.lua")

RANK_RCT = 0
RANK_PVT = 1
RANK_SGT = 2
RANK_LT = 3
RANK_CPT = 4
RANK_MAJ = 5
RANK_COL = 6
RANK_GEN = 7

ix.util.IncludeDir("meta")
ix.util.IncludeDir("achievements")
ix.util.IncludeDir("perks")

ix.chat.Register("achievement", {
	OnChatAdd = function(self, speaker, text)
		local icon = ix.util.GetMaterial("icon16/star.png")

		chat.AddText(icon, Color(139, 174, 179, 255), speaker, " has achieved the ", Color(139, 174, 179, 255), text, " achievement!")
	end,
})

ix.chat.Register("broadcast", {
	OnChatAdd = function(self, speaker, text)
		chat.AddText("(Broadcast) ", Color(150, 125, 175, 255), speaker..": "..text)
	end,
})

ix.chat.Register("shipment", {
	OnChatAdd = function(self, speaker, text)
		local icon = ix.util.GetMaterial("icon16/box.png")

		chat.AddText(icon, "You've ordered ", Color(139, 174, 179, 255), text, "!")
		ix.util.Notify("You've ordered " .. text .. "!")
	end,
})

function Schema.GetAttributeFraction(character, attributeKey)
	local attributeTable = ix.attributes.list[attributeKey]
	local maximum = attributeTable.maxValue or ix.config.Get("maxAttributes", 100)
	local amount = character:GetAttribute(attributeKey, 0)

	return amount / maximum
end

function Schema.GetPlayer(entity)
	if (IsValid(entity) and entity:IsPlayer()) then
		return entity
	end
end

function Schema.RegisterWeaponAttachment(itemTable)
	if (not itemTable.class) then
		error("Weapon item must have a class property!")
	end

	if (not itemTable.isAttachment) then
		error("Weapon item must be attachment!")
	end

	Schema.registeredWeaponAttachments[itemTable.class] = itemTable
end

function Schema.GetWeaponAttachment(class)
    return Schema.registeredWeaponAttachments[class]
end
