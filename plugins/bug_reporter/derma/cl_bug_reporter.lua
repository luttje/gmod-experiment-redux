local PLUGIN = PLUGIN
local PANEL = {}

local STEPS_TEXT = "1. \n2. \n3. "

function PANEL:Init()
	self:SetWide(500)
	self:SetTitle("Report a Bug")
	self:SetDraggable(true)

	local infoLabel = self:Add("DLabel")
	infoLabel:Dock(TOP)
	infoLabel:DockMargin(5, 5, 5, 5)
	infoLabel:SetText(
		"Through this form you can submit a bug report which will be sent to our GitHub repository. "
		.. "Please provide as much detail as possible to help us resolve the issue quickly."
		.. "\nNote that the bug reporter will include your SteamID, player name and other information in the report."
		.. "\nIf you wish to decide for yourself what information to include, you can report directly on GitHub:"
	)
	infoLabel:SetWrap(true)
	infoLabel:SetAutoStretchVertical(true)
	infoLabel:SetTextColor(Color(150, 150, 150))
	infoLabel:SizeToContents()
	infoLabel:InvalidateLayout(true)

	local githubButton = self:Add("DButton")
	githubButton:Dock(TOP)
	githubButton:DockMargin(5, 5, 5, 5)
	githubButton:SetTall(25)
	githubButton:SetText("Open GitHub Issues Page")
	githubButton:SetTextColor(Color(255, 255, 255))
	githubButton.Paint = function(self, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(33, 136, 33))

		if (self:IsHovered()) then
			draw.RoundedBox(4, 0, 0, w, h, Color(28, 115, 28))
		end
	end
	githubButton.DoClick = function()
		gui.OpenURL("https://github.com/experiment-games/gmod-experiment-redux/issues")
	end

	local headingLabel = self:Add("DLabel")
	headingLabel:Dock(TOP)
	headingLabel:DockMargin(5, 5, 5, 5)
	headingLabel:SetText("Your Report")
	headingLabel:SetFont("ixBigFont")
	headingLabel:SizeToContents()

	local titleLabel = self:Add("DLabel")
	titleLabel:Dock(TOP)
	titleLabel:DockMargin(5, 5, 5, 0)
	titleLabel:SetText("Bug Title:")
	titleLabel:SizeToContents()

	self.TitleEntry = self:Add("DTextEntry")
	self.TitleEntry:Dock(TOP)
	self.TitleEntry:DockMargin(5, 10, 5, 0)
	self.TitleEntry:SetTall(30)
	self.TitleEntry:SetAllowNonAsciiCharacters(true)
	self.TitleEntry:SetText("")
	self.TitleEntry:SetPlaceholderText("Brief description of the bug")

	local descLabel = self:Add("DLabel")
	descLabel:Dock(TOP)
	descLabel:DockMargin(5, 10, 5, 0)
	descLabel:SetText("Description:")
	descLabel:SizeToContents()

	self.DescEntry = self:Add("DTextEntry")
	self.DescEntry:Dock(TOP)
	self.DescEntry:DockMargin(5, 10, 5, 0)
	self.DescEntry:SetTall(150)
	self.DescEntry:SetMultiline(true)
	self.DescEntry:SetPlaceholderText(
		"Detailed description of the bug, expected vs actual behavior..."
	)

	local stepsLabel = self:Add("DLabel")
	stepsLabel:Dock(TOP)
	stepsLabel:DockMargin(5, 10, 5, 0)
	stepsLabel:SetText("Steps to Reproduce:")
	stepsLabel:SizeToContents()

	self.StepsEntry = self:Add("DTextEntry")
	self.StepsEntry:Dock(TOP)
	self.StepsEntry:DockMargin(5, 10, 5, 0)
	self.StepsEntry:SetTall(60)
	self.StepsEntry:SetMultiline(true)
	self.StepsEntry:SetText(STEPS_TEXT)

	self.IncludeSysInfo = self:Add("DCheckBoxLabel")
	self.IncludeSysInfo:Dock(TOP)
	self.IncludeSysInfo:DockMargin(5, 10, 5, 0)
	self.IncludeSysInfo:SetText("Include Basic System Info (OS, Resulution, FPS, Ping, etc.)")
	self.IncludeSysInfo:SetValue(true)
	self.IncludeSysInfo:SizeToContents()

	self.SubmitBtn = self:Add("expButton")
	self.SubmitBtn:Dock(TOP)
	self.SubmitBtn:DockMargin(5, 10, 5, 0)
	self.SubmitBtn:SetText("Submit Bug")
	self.SubmitBtn.DoClick = function()
		self:SubmitBug()
	end

	self.StatusLabel = self:Add("DLabel")
	self.StatusLabel:Dock(TOP)
	self.StatusLabel:DockMargin(5, 10, 5, 0)
	self.StatusLabel:SetText("")
	self.StatusLabel:SetTextColor(Color(100, 100, 100))
	self.StatusLabel:SizeToContents()

	self:InvalidateLayout(true)

	-- We need this delay or SetAutoStretchVertical/SetWrap for the first label messes up the height
	timer.Simple(0.1, function()
		if not IsValid(self) then return end
		self:SizeToChildren(false, true)
		self:Center()
	end)
end

function PANEL:SubmitBug()
	local title = self.TitleEntry:GetValue()
	local description = self.DescEntry:GetValue()
	local steps = self.StepsEntry:GetValue()
	local includeSysInfo = self.IncludeSysInfo:GetChecked()

	-- Basic validation
	if (title == "" or description == "") then
		self.StatusLabel:SetText("Please fill in title and description")
		self.StatusLabel:SetTextColor(Color(255, 100, 100))
		return
	end

	-- Gather system information if requested
	local sysInfo = ""

	if (includeSysInfo) then
		sysInfo = self:GatherSystemInfo()
	end

	-- Prepare bug report data
	local bugData = {
		title = title,
		description = description,
		steps = steps,
		systemInfo = sysInfo,
		luaErrors = PLUGIN:GetLuaErrors(),
	}

	-- Send to server
	self.StatusLabel:SetText("Submitting...")
	self.StatusLabel:SetTextColor(Color(255, 255, 100))
	self.SubmitBtn:SetEnabled(false)

	net.Start("expBugReporterSubmit")
	net.WriteTable(bugData)
	net.SendToServer()
end

function PANEL:GatherSystemInfo()
	local info = {}
	info.os = system.IsWindows() and "Windows" or system.IsLinux() and "Linux" or system.IsOSX() and "macOS" or "Unknown"
	info.gamemode = engine.ActiveGamemode()
	info.map = game.GetMap()
	info.fps = math.Round(1 / FrameTime())
	info.ping = LocalPlayer():Ping()
	info.screenWidth, info.screenHeight = ScrW(), ScrH()

	-- Format system info
	local formatted = string.format([[
## System Information
- **OS:** %s
- **Gamemode:** %s
- **Map:** %s
- **FPS:** %d
- **Ping:** %dms
- **Client Version:** %s
- **Screen Resolution:** %dx%d]],
		info.os,
		info.gamemode,
		info.map,
		info.fps,
		info.ping,
		VERSIONSTR or "Unknown",
		info.screenWidth,
		info.screenHeight
	)

	return formatted
end

function PANEL:ResetForm()
	self.TitleEntry:SetValue("")
	self.DescEntry:SetValue("")
	self.StepsEntry:SetValue(STEPS_TEXT)
	self.IncludeSysInfo:SetValue(true)
	self.SubmitBtn:SetEnabled(true)
	self.StatusLabel:SetText("")
	self.StatusLabel:SetTextColor(Color(100, 100, 100))
end

vgui.Register("expBugReporter", PANEL, "expFrame")

net.Receive("expBugReporterResponse", function()
	local success = net.ReadBool()
	local message = net.ReadString()

	if not IsValid(Schema.bugReporter) then
		return
	end

	if (success) then
		Schema.bugReporter.StatusLabel:SetText("Bug submitted successfully!")
		Schema.bugReporter.StatusLabel:SetTextColor(Color(100, 255, 100))
		ix.util.Notify("Bug report submitted successfully.")

		Schema.bugReporter:ResetForm()
	else
		Schema.bugReporter.StatusLabel:SetText("Failed to submit: " .. message)
		Schema.bugReporter.StatusLabel:SetTextColor(Color(255, 100, 100))
		ix.util.Notify("Failed to submit bug report: " .. message .. "!")
		Schema.bugReporter.SubmitBtn:SetEnabled(true)
	end
end)
