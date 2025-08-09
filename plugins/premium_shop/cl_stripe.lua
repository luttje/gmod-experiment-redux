local PLUGIN = PLUGIN

PLUGIN.localSessions = PLUGIN.localSessions or {}

net.Receive("expPremiumShopFinishPayment", function()
	PLUGIN:ClearCart()
end)

net.Receive("expPremiumShopStripeURL", function()
	local checkoutURL = net.ReadString()
	local sessionId = net.ReadString()

	PLUGIN.localSessions[sessionId] = checkoutURL

	gui.OpenURL(checkoutURL)

	PLUGIN:ShowPaymentStatusWindow(sessionId, checkoutURL)
end)

function PLUGIN:ShowPaymentStatusWindow(sessionId, checkoutURL)
	local statusFrame = vgui.Create("expFrame")
	statusFrame:SetTitle("Payment Status")
	statusFrame:SetWide(400)
	statusFrame:Center()
	statusFrame:MakePopup()
	statusFrame:SetDeleteOnClose(true)

	local instructionLabel = vgui.Create("DLabel", statusFrame)
	instructionLabel:SetText("Complete your payment in the Steam browser that just opened.")
	instructionLabel:SetFont("ixMediumFont")
	instructionLabel:SetTextColor(Color(255, 255, 255))
	instructionLabel:Dock(TOP)
	instructionLabel:DockMargin(8, 8, 8, 8)
	instructionLabel:SetWrap(true)
	instructionLabel:SetAutoStretchVertical(true)

	local statusLabel = vgui.Create("DLabel", statusFrame)
	statusLabel:SetText("Click the button below after completing your payment.")
	statusLabel:SetFont("ixSmallFont")
	statusLabel:SetTextColor(PLUGIN.THEME.textSecondary)
	statusLabel:Dock(TOP)
	statusLabel:DockMargin(8, 8, 8, 8)
	statusLabel:SetWrap(true)
	statusLabel:SetAutoStretchVertical(true)

	-- Commented because this button is confusing. Just let them attempt a new purchase flow.
	-- local openUrlAgain = vgui.Create("expButton", statusFrame)
	-- openUrlAgain:SetText("Open Payment URL Again")
	-- openUrlAgain:Dock(TOP)
	-- openUrlAgain:SizeToContents()
	-- openUrlAgain:DockMargin(0, 0, 0, 8)
	-- openUrlAgain.DoClick = function()
	-- 	gui.OpenURL(checkoutURL)
	-- end

	local completedButton = vgui.Create("expButton", statusFrame)
	completedButton:SetText("I have completed the purchase")
	completedButton:Dock(TOP)
	completedButton:SizeToContents()
	completedButton:DockMargin(0, 0, 0, 8)
	completedButton:SetEnabled(false)
	completedButton.DoClick = function()
		if (IsValid(statusFrame)) then
			statusFrame:Close()
		end
	end

	statusFrame.OnClose = function()
		completedButton:SetEnabled(false)
		completedButton:SetText("Checking payment...")

		net.Start("expPremiumShopCheckPayment")
		net.WriteString(sessionId)
		net.SendToServer()
	end

	statusFrame:InvalidateChildren(true)

	timer.Simple(5, function()
		if (IsValid(completedButton)) then
			completedButton:SetEnabled(true)
		end
	end)

	timer.Simple(0.1, function()
		if (IsValid(statusFrame)) then
			statusFrame:SizeToChildren(false, true)
		end
	end)
end
