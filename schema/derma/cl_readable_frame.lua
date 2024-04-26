local PANEL = {}

local widthClasses = ""

for i = 1, 96 do
	widthClasses = widthClasses .. ".w-" .. i .. " { width: " .. (i * 8) .. "px; }\n"
end

function PANEL:Init()
    if (IsValid(ix.gui.expReadableFrame)) then
        ix.gui.expReadableFrame:Remove()
    end

    self:SetSize(350, 400)
    self:Center()
    self:SetSizable(false)
    self:ShowCloseButton(false)
    self:SetBackgroundBlur(true)
    self:SetDeleteOnClose(true)
    self:SetTitle(L("paper"))

    self.close = self:Add("DButton")
    self.close:Dock(BOTTOM)
    self.close:DockMargin(0, 4, 0, 0)
    self.close:SetTall(32)
    self.close:SetFont("ixSmallFont")
    self.close:SetText(L("close"))
    self.close.DoClick = function()
        self:Close()
    end

    self.html = self:Add("HTML")
    self.html:Dock(FILL)

    self.html.ConsoleMessage = function(html, message, file, line)
        if (not isstring(message)) then
            message = "*js variable*"
        end
		print(message)

        if (message == "CLOSE_READABLE") then
            self:Close()
        end
    end

    self:ParentToHUD()
    self:MakePopup()
    self:SetZPos(32767)

    ix.gui.expReadableFrame = self
end

function PANEL:ReplaceNewLines(text)
    return text:gsub("\n", "<br>")
end

function PANEL:SetText(text, isFullHtml)
    if (isFullHtml) then
        self.html:SetHTML(text)
		self.html:RequestFocus()
        return
    end

    text = self:ReplaceNewLines(text)

    self.html:SetHTML([[
		<html>
			<head>
				<style>
					body {
						font-family: Arial, sans-serif;
						font-size: 14px;
						color: #FFF;
						background-color: #303030;
						margin: 0;
						padding: 16px;
					}

					.censored {
						display: inline-block;
						background-color: #000;
						color: #000;
						height: 14px;
						border-radius: 8px;
						margin-right: 4px;
					}

					]] .. widthClasses .. [[
				</style>
			</head>
			<body>
				<p>]] .. text .. [[</p>
			</body>
		</html>
	]])
	self.html:RequestFocus()
end

function PANEL:HideTitleBar()
    self:SetDraggable(false)
    self.lblTitle:SetVisible(false)
    self.btnClose:SetVisible(false)
    self.close:DockMargin(0, 0, 0, 0)
    self:DockPadding(0, 0, 0, 0)
end

function PANEL:HideCloseButton()
	self.close:SetVisible(false)
end

function PANEL:OnRemove()
    ix.gui.expReadableFrame = nil
end

vgui.Register("expReadableFrame", PANEL, "DFrame")
