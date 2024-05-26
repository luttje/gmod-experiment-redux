
function Derma_Message(strText, strTitle, strButtonText)
	local window = vgui.Create("expFrame")
	window:SetTitle(strTitle or "Message")
	window:SetDraggable(false)
	window:ShowCloseButton(false)
	window:SetBackgroundBlur(true)
	window:SetDrawOnTop(true)

	local innerPanel = vgui.Create("Panel", window)

	local text = vgui.Create("DLabel", innerPanel)
    text:SetText(strText or "Message text")
	text:SetFont("ixMediumFont")
	text:SizeToContents()
	text:SetContentAlignment(5)
	text:SetTextColor(color_white)

	local buttonPanel = vgui.Create("DPanel", window)
	buttonPanel:SetTall(30)
	buttonPanel:SetPaintBackground(false)

	local button = vgui.Create("expButton", buttonPanel)
	button:SetText(strButtonText or "OK")
	button:SetPos(5, 5)
	button.DoClick = function() window:Close() end

	buttonPanel:SetWide(button:GetWide() + 10)

	local w, h = text:GetSize()

	window:SetSize(w + 50, h + 25 + 45 + 10)
	window:Center()

	innerPanel:StretchToParent(5, 25, 5, 45)

	text:StretchToParent(5, 5, 5, 5)

	buttonPanel:CenterHorizontal()
	buttonPanel:AlignBottom(8)

	window:MakePopup()
	window:DoModal()

	return window
end


function Derma_Query(strText, strTitle, ...)
	local window = vgui.Create("expFrame")
	window:SetTitle(strTitle or "Message Title (First Parameter)")
	window:SetDraggable(false)
	window:ShowCloseButton(false)
	window:SetBackgroundBlur(true)
	window:SetDrawOnTop(true)

	local innerPanel = vgui.Create("DPanel", window)
	innerPanel:SetPaintBackground(false)

	local text = vgui.Create("DLabel", innerPanel)
    text:SetText(strText or "Message text (Second Parameter)")
	text:SetFont("ixMediumFont")
	text:SizeToContents()
	text:SetContentAlignment(5)
	text:SetTextColor(color_white)

	local buttonPanel = vgui.Create("DPanel", window)
	buttonPanel:SetPaintBackground(false)

	-- Loop through all the options and create buttons for them.
	local numOptions = 0
	local x = 5

	for k = 1, 8, 2 do

		local txt = select(k, ...)
		if (txt == nil) then break end

		local Func = select(k + 1, ...) or function() end

		local button = vgui.Create("expButton", buttonPanel)
		button:SetText(txt)
		button.DoClick = function() window:Close() Func() end
		button:SetPos(x, 5)

		x = x + button:GetWide() + 5

        buttonPanel:SetWide(x)
		buttonPanel:SetTall(button:GetTall())
		numOptions = numOptions + 1

	end

	local w, h = text:GetSize()

	w = math.max(w, buttonPanel:GetWide())

	window:SetSize(w + 50, h + 25 + 45 + 10)
	window:Center()

	innerPanel:StretchToParent(5, 25, 5, 45)

	text:StretchToParent(5, 5, 5, 5)

	buttonPanel:CenterHorizontal()
	buttonPanel:AlignBottom(8)

	window:MakePopup()
	window:DoModal()

	if (numOptions == 0) then

		window:Close()
		Error("Derma_Query: Created Query with no Options!?")
		return nil

	end

	return window
end

function Derma_StringRequest(strTitle, strText, strDefaultText, fnEnter, fnCancel, strButtonText, strButtonCancelText)
	local window = vgui.Create("expFrame")
	window:SetTitle(strTitle or "Message Title (First Parameter)")
	window:SetDraggable(false)
	window:ShowCloseButton(false)
	window:SetBackgroundBlur(true)
	window:SetDrawOnTop(true)

	local innerPanel = vgui.Create("DPanel", window)
	innerPanel:SetPaintBackground(false)

	local text = vgui.Create("DLabel", innerPanel)
	text:SetText(strText or "Message text (Second Parameter)")
	text:SetFont("ixMediumFont")
	text:SizeToContents()
	text:SetContentAlignment(5)
	text:SetTextColor(color_white)

	local textEntry = vgui.Create("DTextEntry", innerPanel)
	textEntry:SetText(strDefaultText or "")
	textEntry.OnEnter = function() window:Close() fnEnter(textEntry:GetValue()) end

	local buttonPanel = vgui.Create("DPanel", window)
	buttonPanel:SetTall(30)
	buttonPanel:SetPaintBackground(false)

	local button = vgui.Create("expButton", buttonPanel)
	button:SetText(strButtonText or "OK")
	button:SetPos(5, 5)
	button.DoClick = function() window:Close() fnEnter(textEntry:GetValue()) end

	local buttonCancel = vgui.Create("expButton", buttonPanel)
	buttonCancel:SetText(strButtonCancelText or "Cancel")
	buttonCancel:SetPos(5, 5)
	buttonCancel.DoClick = function() window:Close() if (fnCancel) then fnCancel(textEntry:GetValue()) end end
	buttonCancel:MoveRightOf(button, 5)

	buttonPanel:SetWide(button:GetWide() + 5 + buttonCancel:GetWide() + 10)

	local w, h = text:GetSize()
	w = math.max(w, 400)

	window:SetSize(w + 50, h + 25 + 75 + 10)
	window:Center()

	innerPanel:StretchToParent(5, 25, 5, 45)

	text:StretchToParent(5, 5, 5, 35)

	textEntry:StretchToParent(5, nil, 5, nil)
	textEntry:AlignBottom(5)

	textEntry:RequestFocus()
	textEntry:SelectAllText(true)

	buttonPanel:CenterHorizontal()
	buttonPanel:AlignBottom(8)

	window:MakePopup()
	window:DoModal()

	return window
end
