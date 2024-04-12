local PLUGIN = PLUGIN

local PANEL = {}

local widthClasses = ""

for i = 1, 96 do
	widthClasses = widthClasses .. ".w-" .. i .. " { width: " .. (i * 8) .. "px; }\n"
end

function PANEL:Init()
    if (IsValid(PLUGIN.panel)) then
        PLUGIN.panel:Remove()
    end

    self:SetSize(350, 400)
    self:Center()
    self:SetBackgroundBlur(true)
    self:SetDeleteOnClose(true)
    self:SetTitle(L("paper"))

    self.close = self:Add("DButton")
    self.close:Dock(BOTTOM)
    self.close:DockMargin(0, 4, 0, 0)
    self.close:SetText(L("close"))
    self.close.DoClick = function()
        self:Close()
    end

    self.html = self:Add("HTML")
    self.html:Dock(FILL)

    self:MakePopup()

    PLUGIN.panel = self
end

function PANEL:ReplaceNewLines(text)
	return text:gsub("\n", "<br>")
end

function PANEL:SetText(text)
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
end

function PANEL:OnRemove()
	PLUGIN.panel = nil
end

vgui.Register("expLoreFrame", PANEL, "DFrame")
