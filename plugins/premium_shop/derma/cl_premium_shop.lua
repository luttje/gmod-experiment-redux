local PLUGIN = PLUGIN
local PANEL = {}

function PANEL:Init()
	ix.gui.premiumShop = self
	Schema.premiumShopPanel = self

	self:Dock(FILL)

	local buttons = self:Add("EditablePanel")
	buttons:SetTall(40)
	buttons:Dock(TOP)

	if (LocalPlayer():IsSuperAdmin()) then
		local adminButton = buttons:Add("expButton")
		adminButton:SetText("Admin Payment Info")
		adminButton:SizeToContents()
		adminButton:Dock(LEFT)
		adminButton:DockMargin(0, 0, 10, 0)
		adminButton.DoClick = function()
			PLUGIN:ShowAdminPaymentsPanel()
		end
	end

	local historyButton = buttons:Add("expButton")
	historyButton:SetText("Payment History")
	historyButton:SizeToContents()
	historyButton:Dock(LEFT)
	historyButton.DoClick = function()
		PLUGIN:ShowPaymentHistory()
	end

	local steamButton = buttons:Add("expButton")
	steamButton:SetText("Open Shop in Steam Browser")
	steamButton:SizeToContents()
	steamButton:Dock(RIGHT)
	steamButton.DoClick = function()
		gui.OpenURL(GetNetVar("premium_shop.url"))
	end

	self.shopHTML = self:Add("HTML")
	self.shopHTML:Dock(FILL)
	self.shopHTML:OpenURL(GetNetVar("premium_shop.url") .. "#in-game")
end

vgui.Register("expPremiumShop", PANEL, "EditablePanel")

-- Add premium shop button to main menu
hook.Add("CreateMenuButtons", "expPremiumShop", function(tabs)
	if (not GetNetVar("premium_shop.url")) then
		return
	end

	tabs["premiumShop"] = function(container)
		container:Add("expPremiumShop")
	end
end)
