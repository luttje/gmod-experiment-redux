local PLUGIN = PLUGIN

PLUGIN.name = "Lore"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds lore items to the game to tell the story of the world."

if (SERVER) then
    util.AddNetworkString("expReadLore")
end

function PLUGIN:InitializedPlugins()
    local items = ix.item.list
    local loreItemCount = 0

    for _, item in pairs(items) do
        if (item.base ~= "base_readable_lore") then
            continue
        end

        loreItemCount = loreItemCount + 1
    end

	Schema.achievement.Get("archivist").maximum = loreItemCount
end

if (not CLIENT) then
    return
end

net.Receive("expReadLore", function()
	local itemID = net.ReadUInt(32)
	local item = ix.item.instances[itemID]

    if (not item) then
        ErrorNoHalt("Attempted to read a lore item that doesn't exist!\n")
        return
    end

	local frame = vgui.Create("expLoreFrame")
	frame:SetTitle(item:GetName())
	frame:SetText(item:GetText())
end)