local PLUGIN = PLUGIN
local PANEL = {}

function PANEL:Init()
    self.messages = {}
    self.nextMessageToShow = 1

    -- Panel to show the current message
    self.messageContainer = self:Add("EditablePanel")
    self.messageContainer:Dock(FILL)

    -- Buttons to manually switch between messages
    self.buttonContainer = self:Add("EditablePanel")
    self.buttonContainer:Dock(BOTTOM)
    self.buttonContainer:DockMargin(0, 0, 0, 10)
    self.buttonContainer:DockPadding(0, 0, 0, 0)

    self.nextButton = self.buttonContainer:Add("expButton")
    self.nextButton:Dock(FILL)
    self.nextButton:SetText("Next")
    self.nextButton.DoClick = function()
        self:ShowMessage()
    end

    self.closeButton = self.buttonContainer:Add("expButton")
    self.closeButton:Dock(RIGHT)
    self.closeButton:SetText("Close")
    self.closeButton.DoClick = function()
        self:Remove()
    end

    self:Dock(FILL)
    self:ParentToHUD()
    self:MakePopup()
    self:SetZPos(32767)
end

function PANEL:PerformLayout(width, height)
    self.buttonContainer:SetTall(64)

    self.nextButton:SetTall(64)
	self.nextButton:SetWide(width * .3)

	self.closeButton:SetTall(64)
	self.closeButton:SetWide(width * .3)
end

function PANEL:SetMessages(messages)
    self.messages = messages

    self:ShowMessage()
end

function PANEL:ShowMessage()
    if (not self.messages[self.nextMessageToShow]) then
		self:Remove()
        return
    end

	local message = self.messages[self.nextMessageToShow]

    if (not message.vgui) then
        error("Message of the day does not have a VGUI panel!")
    end

	self.messageContainer:Clear()

	local messagePanel = self.messageContainer:Add(message.vgui)
    messagePanel:Dock(FILL)
	messagePanel.Close = function()
		self:ShowMessage()
	end

	if (message.noButtons) then
		self.buttonContainer:SetVisible(false)
	else
		self.buttonContainer:SetVisible(true)
	end

	self.nextMessageToShow = self.nextMessageToShow + 1
end

vgui.Register("expMessageOfTheDay", PANEL, "EditablePanel")

if (IsValid(Schema.messageOfTheDayPanel)) then
	local messages = Schema.messageOfTheDayPanel.messages
    Schema.messageOfTheDayPanel:Remove()

    Schema.messageOfTheDayPanel = ix.gui.characterMenu:Add("expMessageOfTheDay")
	Schema.messageOfTheDayPanel:SetMessages(messages)
end
