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

	local responses = interaction.responses
    local height = 0

	if (isfunction(responses)) then
		responses = responses(LocalPlayer(), self.npcEntity, self)
	end

    for _, answer in ipairs(responses) do
		local button = self:Add("expButton")
		button:Dock(TOP)
		button:SetScale(BUTTON_SCALE_SMALL)
		button:DockMargin(0, 0, 0, 8)
		button:SetText(answer.text)
        button.DoClick = function()
            self:OnAnswer(answer)
        end

		if (answer.color) then
			function button:Paint(width, height)
				surface.SetDrawColor(Color(answer.color.r, answer.color.g, answer.color.b, 100))
				surface.DrawRect(0, 0, width, height)
			end
		end

		height = height + button:GetTall() + 8
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

	self:SetTall(64)
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

    self.html = self:Add("DHTML")
    self.html:Dock(FILL)
    self.html:AddFunction("interop", "onKnownTextHeight", function(height)
		self:RecalculateDimensions(height + 16) -- Add some padding to prevent sudden scrollbars
	end)

    self.answers = self:Add("expNpcAnswers")
    self.answers:Dock(BOTTOM)
    self.answers:DockMargin(8, 8, 8, 8)

    self:RecalculateDimensions()
    self:MakePopup()

    Schema.npc.panel = self
end

function PANEL:RecalculateDimensions(htmlHeight)
	local titleBarHeight = 24
    htmlHeight = htmlHeight or 200

	local height = htmlHeight + titleBarHeight + self.answers:GetTall() + 32

    self:SetSize(math.min(ScrW(), 512), math.min(height, ScrH()))
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
				<div id="text">]] .. text .. [[</div>

				<script>
					var text = document.getElementById("text");
					var height = text.clientHeight + 16; // Add the body padding

					document.addEventListener("DOMContentLoaded", function() {
						window.interop.onKnownTextHeight(height);
					});
				</script>
			</body>
		</html>
	]])
end

function PANEL:SetInteraction(interaction, npc, npcEntity)
    local text = interaction.text

	self.npcEntity = npcEntity

    self:SetTitle(npc.name or L("conversation"))

    if (istable(text)) then
        text = text[math.random(#text)]
    end

	if (isfunction(text)) then
		text = text(LocalPlayer(), self.npcEntity, self)
	end

	self:SetText(text)
    self.answers:SetInteraction(interaction)

	self.html:RunJavascript("window.interop.onKnownTextHeight(height);")
end

function PANEL:OnRemove()
	Schema.npc.panel = nil
end

vgui.Register("expNpcInteraction", PANEL, "expFrame")
