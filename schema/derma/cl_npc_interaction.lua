local PANEL = {}

function PANEL:Init()
end

function PANEL:SetInteraction(interaction)
	self.interaction = interaction
	self:Clear()

	if (interaction.responses == nil) then
		self:ShowChosenAnswer("Goodbye...")
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
	self:ShowChosenAnswer(answer.text)

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

function PANEL:ShowChosenAnswer(text)
	self:Clear()

	self:GetParent():ShowChosenAnswer(text)

	self:SetTall(64)
end

vgui.Register("expNpcAnswers", PANEL, "EditablePanel")

PANEL = {}

function PANEL:Init()
	if (IsValid(Schema.npc.panel)) then
		Schema.npc.panel:Remove()
	end

	self.html = self:Add("DHTML")
	self.html:Dock(FILL)

	self.answers = self:Add("expNpcAnswers")
	self.answers:Dock(BOTTOM)
	self.answers:DockMargin(8, 8, 8, 8)

	Schema.npc.panel = self
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
					@font-face {
						font-family: "LightsOut";
						src: url(http://fastdl.experiment.games/resource/fonts/lightout.woff)
					}

					@font-face {
						font-family: "RomanAntique";
						src: url(http://fastdl.experiment.games/resource/fonts/RomanAntique.woff);
					}

					body {
						color: white;
						padding: 1em;
						font-size: 24px;
						font-family: "RomanAntique";
						margin: 0;
					}

					h1,
					h2,
					h3,
					h4,
					h5,
					h6 {
						color: #A33426;
						font-family: "LightsOut";
						margin: 0;
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
				<h1>]] .. (self.npc.name or "???") .. [[</h1>
				<div id="text">]] .. text .. [[</div>
			</body>
		</html>
	]])
end

function PANEL:SetInteraction(interaction, npc, npcEntity)
	local text = interaction.text

	self.npcEntity = npcEntity
	self.npc = npc

	if (istable(text)) then
		text = text[math.random(#text)]
	end

	if (isfunction(text)) then
		text = text(LocalPlayer(), self.npcEntity, self)
	end

	self:SetText(text)
	self.answers:SetInteraction(interaction)
end

function PANEL:ShowChosenAnswer(text)
	local gracePeriod = ix.config.Get("npcAnswerGracePeriod")
	self.chosenAnswer = text
	self.chosenAnswerTime = CurTime() + gracePeriod
end

function PANEL:PaintOver(width, height)
	if (not self.chosenAnswerTime or CurTime() > self.chosenAnswerTime) then
		return
	end

	local gracePeriod = ix.config.Get("npcAnswerGracePeriod")
	local fraction = 1 - ((self.chosenAnswerTime - CurTime()) / gracePeriod)
	local maxAlpha = 150

	surface.SetDrawColor(0, 0, 0, maxAlpha * fraction)
	surface.DrawRect(0, 0, width, height)

	local text = self.chosenAnswer
	local font = "ixMenuButtonFont"

	surface.SetFont(font)
	local textWidth, textHeight = surface.GetTextSize(text)

	local x = width * 0.5
	local targetY = height * 0.5 - textHeight * 0.5
	local y = Lerp(fraction, self.answers.y, targetY)

	draw.SimpleText(text, font, x, y, Color(255, 255, 255, 255 - (255 * fraction)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function PANEL:OnRemove()
	Schema.npc.panel = nil

	if (IsValid(ix.menu.panel)) then
		ix.menu.panel:Remove()
	end
end

vgui.Register("expNpcInteraction", PANEL, "EditablePanel")
