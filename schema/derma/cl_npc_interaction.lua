local PANEL = {}

function PANEL:Init()
end

function PANEL:SetInteraction(interaction)
	self.interaction = interaction
	self:Clear()

	if (interaction.responses == nil) then
		self:ShowLoading("Goodbye...")
		self:Close()

		return
	end

	local height = 0

	for _, answer in ipairs(interaction.responses) do
		local button = self:Add("DButton")
		button:SetTall(32)
		button:Dock(TOP)
		button:SetFont("ixSmallFont")
		button:DockMargin(0, 0, 0, 8)
		button:SetText(answer.text)
		button.DoClick = function()
			self:OnAnswer(answer)
		end

		height = height + button:GetTall()
	end

	self:SetTall(height)
end

function PANEL:Close()
	local gracePeriod = ix.config.Get("npcAnswerGracePeriod")

	timer.Simple(gracePeriod, function()
		net.Start("expNpcInteractEnd")
		net.SendToServer()

		if (not IsValid(self) or not IsValid(self:GetParent())) then
			return
		end

		self:GetParent():Remove()
	end)
end

function PANEL:OnAnswer(answer)
	self:ShowLoading(answer.text)

	if (answer.next == nil) then
		self:Close()

		return
	end

	local gracePeriod = ix.config.Get("npcAnswerGracePeriod")

	timer.Simple(gracePeriod, function()
		net.Start("expNpcInteractResponse")
		net.WriteString(answer.next)
		net.SendToServer()
	end)
end

function PANEL:ShowLoading(text)
	self:Clear()

	local panel = self:Add("EditablePanel")
	panel:SetContentAlignment(5)
	panel:Dock(FILL)

	local label = panel:Add("DLabel")
	label:SetText("Answering:")
	label:SetFont("expSmallerFont")
	label:SetTextColor(Color(255, 255, 255, 40))
	label:SetContentAlignment(5)
	label:Dock(TOP)

	local textLabel = panel:Add("DLabel")
	textLabel:SetText(text)
	textLabel:SetFont("expSmallItalicFont")
	textLabel:SetTextColor(Color(255, 255, 255, 40))
	textLabel:SetContentAlignment(5)
	textLabel:Dock(TOP)
end

vgui.Register("expNpcAnswers", PANEL, "EditablePanel")

PANEL = {}

function PANEL:Init()
    if (IsValid(Schema.npc.panel)) then
        Schema.npc.panel:Remove()
    end

    self:SetBackgroundBlur(false)
    self:SetDeleteOnClose(true)
    self:SetTitle(L("interaction"))

    self.html = self:Add("HTML")
    self.html:Dock(FILL)

    self.answers = self:Add("expNpcAnswers")
    self.answers:Dock(BOTTOM)
    self.answers:DockMargin(8, 8, 8, 8)

    self:RecalculateDimensions()
    self:MakePopup()

    Schema.npc.panel = self
end

function PANEL:RecalculateDimensions()
    self:SetSize(math.min(ScrW(), 512), 200)
    self:SetPos(ScrW() * 0.5 - self:GetWide() * 0.5, ScrH() - self:GetTall() - 32)
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
						margin: 0;
						padding: 8px;
					}

					.censored {
						display: inline-block;
						background-color: #000;
						color: #000;
						height: 14px;
						border-radius: 8px;
						margin-right: 4px;
					}
				</style>
			</head>
			<body>
				<p>]] .. text .. [[</p>
			</body>
		</html>
	]])
end

function PANEL:SetInteraction(interaction, npc)
	local text = istable(interaction.text) and interaction.text[math.random(#interaction.text)] or interaction.text

	self:SetTitle(npc.name or L("conversation"))
	self:SetText(text)
	self.answers:SetInteraction(interaction)
end

function PANEL:OnRemove()
	Schema.npc.panel = nil
end

vgui.Register("expNpcInteraction", PANEL, "DFrame")
