local PLUGIN = PLUGIN
local PANEL = {}

function PANEL:Init()
	ix.gui.premiumShop = self
	Schema.premiumShopPanel = self

	self:Dock(FILL)

	self.shopHTML = self:Add("HTML")
	self.shopHTML:Dock(FILL)
	self.shopHTML:OpenUrl(GetNetVar("premium_shop.url"))
end

vgui.Register("expPremiumShop", PANEL, "EditablePanel")

-- Add premium shop button to main menu
hook.Add("CreateMenuButtons", "expPremiumShop", function(tabs)
	tabs["premiumShop"] = function(container)
		container:Add("expPremiumShop")
	end
end)
