local PLUGIN = PLUGIN

net.Receive("expPremiumShopFinishPayment", function()
	LocalPlayer():Notify("Purchase completed and claimed!")

	-- Close any open premium shop panels to force refresh
	if (IsValid(ix.gui.premiumShop)) then
		ix.gui.premiumShop:Refresh()
	end

	-- Close payment history if open to show updated status
	if (IsValid(PLUGIN.paymentHistoryPanel)) then
		PLUGIN.paymentHistoryPanel:Close()
	end

	surface.PlaySound("buttons/button15.wav")
end)

net.Receive("expPremiumShopLemonSqueezyURL", function()
	local checkoutURL = net.ReadString()
	local checkoutId = net.ReadString()

	print("Opening LemonSqueezy checkout URL:", checkoutURL, "Checkout ID:", checkoutId)

	gui.OpenURL(checkoutURL)
end)
