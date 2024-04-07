local PLUGIN = PLUGIN

-- Only after all plugins are loaded (with their entities and weapons) will we be able to setup attachment menu's
function PLUGIN:InitializedPlugins()
	for uniqueID, item in pairs(ix.item.list) do
        if (not item.class) then
            continue
        end

		PLUGIN:SetupCustomizableWeaponItem(item)
	end
end
