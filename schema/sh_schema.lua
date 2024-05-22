Schema.registeredWeaponAttachments = Schema.registeredWeaponAttachments or {}
Schema.meta = Schema.meta or {}

Schema.name = "Experiment Redux"
Schema.author = "Experiment Redux"
Schema.description = "It's a dog-eat-dog world out there, and these dogs have guns."
Schema.version = {
	major = 6,
	minor = 0,
	revision = 1,
	suffix = "alpha"
}

Schema.disabledPlugins = {
	-- We use our own stamina system, that doesn't train by running
	"stamina",

	-- We use our own strength system, that doesn't train by throwing punches
	"strength",

	-- We don't want player positions to be saved, they can only spawn at the spawn points
    "spawnsaver",

    -- We disable the default spawn point system, because we want players to select one from a list
	"spawns",
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

RANKS = {
	[RANK_RCT] = "Recruit",
	[RANK_PVT] = "Private",
	[RANK_SGT] = "Sergeant",
	[RANK_LT] = "Lieutenant",
	[RANK_CPT] = "Captain",
	[RANK_MAJ] = "Major",
	[RANK_COL] = "Colonel",
	[RANK_GEN] = "General",
}

ix.util.IncludeDir("meta")

Schema.achievement.LoadFromDir(Schema.folder .. "/schema/achievements")
Schema.buff.LoadFromDir(Schema.folder .. "/schema/buffs")
Schema.perk.LoadFromDir(Schema.folder .. "/schema/perks")
Schema.npc.LoadFromDir(Schema.folder .. "/schema/npcs")
Schema.map.LoadFromDir(Schema.folder .. "/schema/maps")

ix.chat.Register("achievement", {
	OnChatAdd = function(self, speaker, text)
		local icon = ix.util.GetMaterial("icon16/star.png")

		chat.AddText(icon, Color(139, 174, 179, 255), speaker, " has achieved the ", Color(139, 174, 179, 255), text, " achievement!")
	end,
	deadCanChat = true,
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

--- Returns the players attribute as a fraction of the maximum value.
--- @param character Player
--- @param attributeKey string
--- @return number
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

function Schema.RegisterMaterialSources()
    local helperMetaTable = {}
    helperMetaTable.__index = helperMetaTable
    local toBeRemoved = {}

    function helperMetaTable:Add(data)
        table.insert(self, data)
    end

    function helperMetaTable:Remove(uniqueID)
        table.insert(toBeRemoved, uniqueID)
    end

    function helperMetaTable:RemoveQueued()
        for _, uniqueID in ipairs(toBeRemoved) do
            for i, data in ipairs(self) do
                if (data.uniqueID == uniqueID) then
                    table.remove(self, i)
                end
            end
        end

        toBeRemoved = {}
    end

    local materialSources = setmetatable({}, helperMetaTable)

    hook.Run("AdjustMaterialSources", materialSources)

    materialSources:RemoveQueued()

    -- Register the allowed props as blueprint items
    for _, data in ipairs(materialSources) do
        local uniqueID = string.lower(data.uniqueID)
        local ITEM = ix.item.Register(
            uniqueID,
            "base_material_sources",
            false,
            nil,
            true
        )

        table.Merge(ITEM, data, true)
        ITEM.uniqueID = uniqueID
    end
end

local function randomElement(table)
	return table[math.random(1, #table)]
end

function Schema.GetRandomName()
    local NAMES_FIRST,
		NAMES_LAST = include(Schema.folder .. "/schema/content/sh_names.lua")

	return randomElement(NAMES_FIRST) .. " " .. randomElement(NAMES_LAST)
end

function Schema.GetRandomDescription()
	local DESCRIPTION_AGE_INDICATOR,
		DESCRIPTION_BODY_TYPE_HEIGHT,
		DESCRIPTION_BODY_TYPE_FRAME,
		DESCRIPTION_FACIAL_FEATURES,
		DESCRIPTION_TRAITS,
		DESCRIPTION_BEHAVIOR = include(Schema.folder .. "/schema/content/sh_descriptions.lua")

    return randomElement(DESCRIPTION_AGE_INDICATOR)
        .. " "
        .. randomElement(DESCRIPTION_BODY_TYPE_HEIGHT):format("person")
        .. " "
        .. randomElement(DESCRIPTION_BODY_TYPE_FRAME)
        .. ". They've got "
        .. randomElement(DESCRIPTION_FACIAL_FEATURES)
        .. ". " .. randomElement(DESCRIPTION_TRAITS)
    	.. "."
end
