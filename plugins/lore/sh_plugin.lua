local PLUGIN = PLUGIN

PLUGIN.name = "Lore"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds lore items to the game to tell the story of the world."

function PLUGIN:InitializedPlugins()
    local items = ix.item.list
    local loreItemCount = 0

    for _, item in pairs(items) do
        if (not item.isLoreItem or item.isBase) then
            continue
        end

        loreItemCount = loreItemCount + 1
    end

	Schema.achievement.Get("archivist").maximum = loreItemCount
end
