local PLUGIN = PLUGIN
local PANEL = {}

function PANEL:Init()
	ix.gui.premiumShop = self
	Schema.premiumShopPanel = self

	self:Dock(FILL)

	local buttons = self:Add("EditablePanel")
	buttons:SetTall(40)
	buttons:DockMargin(0, 0, 0, 10)
	buttons:Dock(TOP)

	self.shopHTML = self:Add("HTML")
	self.shopHTML:Dock(FILL)
	self.shopHTML:OpenURL(GetNetVar("premium_shop.url") .. "#in-game")
	self.shopHTML.OnFinishLoadingDocument = function(pnl, url)
		if (url:find("about:blank", 1, true)) then
			self.shopHTML:OpenURL(GetNetVar("premium_shop.url") .. "#in-game")
		end
	end

	local homeButton = buttons:Add("expButton")
	homeButton:SetText("Shop Home")
	homeButton:SizeToContents()
	homeButton:Dock(LEFT)
	homeButton:DockMargin(0, 0, 10, 0)
	homeButton.DoClick = function()
		-- For some reason without going to blank first, we're stuck with a background if we go to the PayNow.gg TOS
		self.shopHTML:OpenURL("about:blank")
	end

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
