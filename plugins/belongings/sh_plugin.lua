local PLUGIN = PLUGIN

PLUGIN.name = "Belongings"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Fallen players drop their belongings in suitcases."

ix.util.Include("sv_plugin.lua")
ix.util.Include("sv_hooks.lua")

PLUGIN.inventoryTypePrefix = "belongings:"
PLUGIN.inventoryMinWidth = 4
PLUGIN.inventoryMinHeight = 4
PLUGIN.inventoryMaxWidth = 20
PLUGIN.inventoryMaxHeight = 20

function PLUGIN:InitializedPlugins()
	-- Register all possible belongings inventory types
	for width = self.inventoryMinWidth, self.inventoryMaxWidth do
		for height = self.inventoryMinHeight, self.inventoryMaxHeight do
			ix.inventory.Register(self.inventoryTypePrefix .. width .. "x" .. height, width, height)
		end
	end
end

function PLUGIN:GetPerfectFitInventoryType(items)
	local totalArea = 0
    for _, item in ipairs(items) do
        if item.width < 1 or item.height < 1 then
            error("Invalid item dimensions")
        end
        totalArea = totalArea + (item.width * item.height)
    end

    for width = self.inventoryMinWidth, self.inventoryMaxWidth do
        for height = self.inventoryMinHeight, self.inventoryMaxHeight do
            if width * height >= totalArea then
                -- Simplified check: just ensures total area fits, doesn't guarantee actual fitting
                -- You should replace this with a more sophisticated fitting algorithm
                return self.inventoryTypePrefix .. width .. "x" .. height
            end
        end
    end

    error("No suitable inventory size found")
end
