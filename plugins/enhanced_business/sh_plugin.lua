local PLUGIN = PLUGIN

PLUGIN.name = "Enhanced Business"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Enhances the business tab with more features like better search and filtering."

if (not CLIENT) then
	return
end

function PLUGIN:BuildBusinessMenu()
	return false
end

function PLUGIN:CreateMenuButtons(tabs)
	tabs["business"] = function(container)
		container:Add("expEnhancedBusiness")
	end
end
